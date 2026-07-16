{% docs dim_customer_dedupe_logic %}

## Customer Deduplication Strategy

Customers are deduplicated using the following hierarchy:

1. Email address (if present)
2. Customer ID (fallback)

The most recent record is selected using:
- created_at_ts (primary ordering)
- ingested_at (secondary ordering)

This approach simulates a lightweight golden record strategy.

{% enddocs %}