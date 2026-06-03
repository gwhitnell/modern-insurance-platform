import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session


DEFAULT_DATABASE = "PRD_MODERN_INSURANCE_PLATFORM"
DEFAULT_SCHEMA = "ANALYTICS"


st.set_page_config(
    page_title="Customer Search",
    layout="wide",
    initial_sidebar_state="collapsed",
)


@st.cache_resource(show_spinner=False)
def snowflake_session():
    return get_active_session()


def build_search_sql(filters: dict[str, object]):
    conditions = []
    params: list[object] = []
    limit = int(filters["limit"])
    condition_joiner = " or " if filters["match_mode"] == "Any populated field" else " and "

    if filters["first_name"]:
        if filters["exact_name"]:
            conditions.append("upper(c.first_name) = upper(?)")
            params.append(filters["first_name"])
        else:
            conditions.append("upper(c.first_name) like upper(?)")
            params.append(f"%{filters['first_name']}%")

    if filters["last_name"]:
        if filters["exact_name"]:
            conditions.append("upper(c.last_name) = upper(?)")
            params.append(filters["last_name"])
        else:
            conditions.append("upper(c.last_name) like upper(?)")
            params.append(f"%{filters['last_name']}%")

    if filters["date_of_birth"]:
        conditions.append("c.date_of_birth = try_to_date(?)")
        params.append(filters["date_of_birth"])

    if filters["email"]:
        conditions.append("upper(c.email) like upper(?)")
        params.append(f"%{filters['email']}%")

    if filters["customer_id"]:
        conditions.append("upper(c.customer_id) like upper(?)")
        params.append(f"%{filters['customer_id']}%")

    if filters["policy_id"]:
        conditions.append("upper(p.policy_id) like upper(?)")
        params.append(f"%{filters['policy_id']}%")

    if filters["claim_id"]:
        conditions.append("upper(cl.claim_id) like upper(?)")
        params.append(f"%{filters['claim_id']}%")

    where_clause = condition_joiner.join(conditions)

    sql = f"""
        select
            c.customer_nk,
            c.customer_id,
            c.first_name,
            c.last_name,
            c.date_of_birth,
            c.email,
            p.policy_id,
            p.product_code,
            p.policy_status,
            p.inception_date,
            p.expiry_date,
            p.annual_premium,
            cl.claim_id,
            cl.loss_date,
            cl.reported_date,
            cl.claim_status,
            cl.paid_amount
        from {DEFAULT_DATABASE}.{DEFAULT_SCHEMA}.dim_customer c
        left join {DEFAULT_DATABASE}.{DEFAULT_SCHEMA}.dim_policy p
          on c.customer_nk = p.customer_nk
        left join {DEFAULT_DATABASE}.{DEFAULT_SCHEMA}.fct_claims cl
          on p.policy_id = cl.policy_id
        where {where_clause}
        order by
            c.last_name,
            c.first_name,
            p.inception_date desc nulls last,
            cl.reported_date desc nulls last
        limit {limit}
    """

    return sql, params


def run_search(filters: dict[str, object]) -> pd.DataFrame:
    session = snowflake_session()
    sql, params = build_search_sql(filters)
    return session.sql(sql, params=params).to_pandas()


def empty_filter_state(filters: dict[str, object]) -> bool:
    fields = [
        "first_name",
        "last_name",
        "date_of_birth",
        "email",
        "customer_id",
        "policy_id",
        "claim_id",
    ]
    return not any(filters[field] for field in fields)


def show_metric_row(results: pd.DataFrame):
    customer_count = results["CUSTOMER_NK"].nunique()
    policy_count = results["POLICY_ID"].dropna().nunique()
    claim_count = results["CLAIM_ID"].dropna().nunique()

    left, middle, right = st.columns(3)
    left.metric("Customers", customer_count)
    middle.metric("Policies", policy_count)
    right.metric("Claims", claim_count)


def clean_frame(frame: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    existing = [column for column in columns if column in frame.columns]
    return frame[existing].drop_duplicates().reset_index(drop=True)


st.title("Customer Service Search")
st.caption("Find customers, policies, and claims from verified customer details.")

with st.form("customer_search"):
    st.subheader("Search Criteria")

    row_one = st.columns(4)
    first_name = row_one[0].text_input("First name")
    last_name = row_one[1].text_input("Last name")
    date_of_birth = row_one[2].text_input("Date of birth", placeholder="YYYY-MM-DD")
    email = row_one[3].text_input("Email")

    row_two = st.columns([1, 1, 1, 1])
    customer_id = row_two[0].text_input("Customer ID")
    policy_id = row_two[1].text_input("Policy ID")
    claim_id = row_two[2].text_input("Claim ID")
    exact_name = row_two[3].checkbox("Exact name match", value=False)

    row_three = st.columns([2, 1, 3])
    match_mode = row_three[0].selectbox(
        "Match mode",
        ["Any populated field", "All populated fields"],
    )
    limit = row_three[1].number_input("Result limit", min_value=10, max_value=500, value=100, step=10)
    submitted = row_three[2].form_submit_button("Search", use_container_width=True)

filters = {
    "first_name": first_name.strip(),
    "last_name": last_name.strip(),
    "date_of_birth": date_of_birth.strip(),
    "email": email.strip(),
    "customer_id": customer_id.strip(),
    "policy_id": policy_id.strip(),
    "claim_id": claim_id.strip(),
    "exact_name": exact_name,
    "match_mode": match_mode,
    "limit": int(limit),
}

if submitted:
    if empty_filter_state(filters):
        st.warning("Enter at least one search value before searching.")
        st.stop()

    with st.spinner("Searching Snowflake..."):
        results = run_search(filters)

    if results.empty:
        st.warning("No matching customers, policies, or claims found.")
        st.stop()

    show_metric_row(results)

    customers = clean_frame(
        results,
        [
            "CUSTOMER_ID",
            "FIRST_NAME",
            "LAST_NAME",
            "DATE_OF_BIRTH",
            "EMAIL",
        ],
    )
    policies = clean_frame(
        results,
        [
            "POLICY_ID",
            "CUSTOMER_ID",
            "PRODUCT_CODE",
            "POLICY_STATUS",
            "INCEPTION_DATE",
            "EXPIRY_DATE",
            "ANNUAL_PREMIUM",
        ],
    ).dropna(subset=["POLICY_ID"])
    claims = clean_frame(
        results,
        [
            "CLAIM_ID",
            "POLICY_ID",
            "CUSTOMER_ID",
            "LOSS_DATE",
            "REPORTED_DATE",
            "CLAIM_STATUS",
            "PAID_AMOUNT",
        ],
    ).dropna(subset=["CLAIM_ID"])

    customer_tab, policy_tab, claim_tab, raw_tab = st.tabs(
        ["Customers", "Policies", "Claims", "Joined Results"]
    )

    with customer_tab:
        st.dataframe(customers, use_container_width=True)

    with policy_tab:
        st.dataframe(policies, use_container_width=True)

    with claim_tab:
        st.dataframe(claims, use_container_width=True)

    with raw_tab:
        st.dataframe(results.reset_index(drop=True), use_container_width=True)
