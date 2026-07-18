# Report Spec

## Report identity
- Report name: Claims Leadership Scorecard
- Semantic model: New local `Claims Leadership` semantic model over `PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS`
- Audience: Claims leadership
- Primary purpose: Support a recurring claims review
- Delivery target: Local PBIP project only

## User decisions and constraints
- Scope: Single-page leadership scorecard
- Page count: 1
- Interactivity: One Year dropdown slicer; predictable cross-filtering across all charts; no drill-through in the first build
- Design direction: Corporate Cool
- Publishing: Not approved; local files only
- Tooling: Use the local skills-for-fabric Power BI planning, design, semantic-model, and authoring workflows
- Model edit permissions: Create a new local Import-mode semantic model; do not change Snowflake objects
- Accessibility: WCAG AA contrast, insight-driven alt text, logical tab order, labels in addition to semantic color
- Data caveats: Current production mart contains 162 claims from 2023-04-02 through 2025-08-09 and GBP 255,050 paid. `paid_amount` is paid-to-date, not incurred loss or outstanding reserve. Open-claim paid amount is therefore not an exposure or reserve measure.

## Narrative
- Core story: Give leadership a fast, repeatable view of claim volume, payments, open workload, closure performance, reporting timeliness, and the product/status drivers behind results.
- Audience promise: The page can be scanned in under ten seconds and still supports a structured monthly review.
- Key questions answered:
  - How many claims and how much paid value are in scope?
  - How many claims remain open, and what is the closure rate?
  - How quickly are losses reported?
  - How are paid amounts and claim volumes trending?
  - Which products and claim statuses drive the results?

## Dependency status
- Snowflake source: Available and read-only connectivity verified through the configured dbt profile
- Source objects: `ANALYTICS.FCT_CLAIMS` and `ANALYTICS.DIM_POLICY`
- Existing semantic model: None found
- Existing PBIP/PBIR: None found; scaffold during implementation
- TMDL persistence: Required for the new local semantic model
- Modeling MCP: Not available in the current tool session
- Power BI report-authoring skill: Available
- Power BI authoring CLI: Not currently on PATH
- Node generator: Node.js not currently on PATH
- Desktop preview: Power BI Desktop is not available in this Linux environment; rendered screenshot validation is a manual Windows handoff unless a Desktop bridge becomes available
- Fabric publishing: Out of scope

## Design identity
- Tone: Corporate Cool — cool-grey surface, slate typography, white containers, restrained cyan accent, and compact executive density
- Signature: Single-accent discipline — cyan highlights the primary claims measures while supporting context remains slate/grey
- Brownfield delta: Not applicable; this is a greenfield report

## Page plan
1. Motor currently drives 76% of paid claims
   - Archetype: Executive Summary
   - Layout variant: B — KPI-Strip; six comparable leadership measures have similar importance and no single KPI warrants a dominant hero
   - Purpose: Run the recurring claims review from one scan-first page
   - Visuals: Dynamic insight title, Year dropdown, six-value KPI strip, paid trend, claim-volume trend, paid amount by product, claims by status, source/freshness footer
   - Fields/measures: Date, product, claim status, total claims, total paid, average paid, open claims, closure rate, average reporting lag, prior-year deltas
   - Slicers/interactions: Year dropdown in the top-right filter band; all data visuals filter together; selecting product or status cross-filters the other charts

## Design system summary
- Theme: Claims Corporate Cool, adapted from `assets/base.json`; page `#F1F5F9`, containers `#FFFFFF`, slate text `#0F172A`, cyan accent `#0891B2`, muted slate `#64748B`
- Color semantics: Paid amount uses cyan; claim count uses slate blue; open workload uses amber; closure/positive direction uses teal; adverse movement uses red plus a text/direction cue
- Typography: Segoe UI Semibold headings and Segoe UI body; consistent tabular-looking numeric formatting on KPI values
- Layout: FHD 1920x1080, 12-column/12-row grid, 32px margins, 24px gutters, all placements snapped to 8px
- Accessibility commitments: Body-text contrast at least 4.5:1, non-text contrast at least 3:1, alt text on every data visual, visible slicer state, no red/green-only encoding, reading-order tab sequence

## Model requirements
- Storage mode: Import (Snowflake is not OneLake and DirectQuery was not requested)
- Source parameters: Snowflake account/server, warehouse, database, and schema as Power Query parameters; credentials remain in Power BI Desktop, never in PBIP/TMDL files
- Tables:
  - `Claims`: one row per `claim_id` from `FCT_CLAIMS`
  - `Policy`: one row per `policy_id` from `DIM_POLICY`, limited to reporting attributes
  - `Date`: Power Query-generated calendar spanning the claims loss-date range, with Date, Year, Month, Month Number, and Year Month
- Relationships:
  - `Policy[Policy ID]` 1:* `Claims[Policy ID]`
  - `Date[Date]` 1:* `Claims[Loss Date]` active
  - `Date[Date]` 1:* `Claims[Reported Date]` inactive, retained for future reported-date analysis
  - Single-direction dimension-to-fact filtering
- Hidden technical fields: Customer natural key, source-system keys, ingestion timestamps, and relationship foreign keys where not needed by report users
- Existing measures: None
- New measures:
  - Total Claims
  - Total Paid
  - Average Paid per Claim
  - Open Claims
  - Closed Claims
  - Closure Rate
  - Average Reporting Lag Days
  - Claims Prior Year
  - Claims YoY Change
  - Paid Prior Year
  - Paid YoY Change
  - Claims Review Headline
  - Claims Alt Text
  - Paid Alt Text
- Calculated columns: Avoid model calculated columns; create reporting lag and date attributes in Power Query
- Formats: GBP currency for paid measures, whole numbers for counts/days, `0.0%` for rates and changes

## Canonical design contract

```yaml
Design Brief:
  generated_by: powerbi-report-design
  contract_version: 1
  mode: greenfield
  design_identity:
    tone: "Corporate Cool — cool-grey surface, slate typography, white containers, restrained cyan accent, and compact executive density"
    signature: "Single-accent discipline — cyan carries the primary claims story while supporting context remains slate and grey"
  archetype: Executive
  color_map:
    - measure: Claims[Total Paid]
      color: "#0891B2"
      tint: "#CFFAFE"
    - measure: Claims[Total Claims]
      color: "#334155"
      tint: "#E2E8F0"
    - measure: Claims[Average Paid per Claim]
      color: "#0E7490"
      tint: "#CFFAFE"
    - measure: Claims[Open Claims]
      color: "#B45309"
      tint: "#FEF3C7"
    - measure: Claims[Closure Rate]
      color: "#0F766E"
      tint: "#CCFBF1"
    - measure: Claims[Average Reporting Lag Days]
      color: "#475569"
      tint: "#E2E8F0"
  pages:
    - name: "Motor currently drives 76% of paid claims"
      role: landing
      archetype: Executive
      layout_variant: B
      variant_rationale: "Six comparable review measures have similar leadership importance, so a full-width KPI strip and balanced evidence charts are more appropriate than a single hero KPI."
      page_background: "#F1F5F9"
      page_background_transparency: 0
      layout_summary: "A reserved title/filter band leads into a six-value KPI strip, followed by two balanced trend panels, two balanced driver panels, and a real source/freshness footer."
      layout_contract:
        canvas:
          width: 1920
          height: 1080
          margin: 32
          gutter: 24
          snap: 8
        grid:
          columns: 12
          rows: 12
          regions:
            header: [1, 1, 10, 2]
            filters: [10, 1, 13, 2]
            kpis: [1, 2, 13, 4]
            paid_trend: [1, 4, 7, 8]
            claims_trend: [7, 4, 13, 8]
            product_driver: [1, 8, 7, 12]
            status_driver: [7, 8, 13, 12]
            footer: [1, 12, 13, 13]
        placements:
          - id: page_title
            region: header
            kind: textbox
            text: "Motor currently drives 76% of paid claims"
            purpose: "State the leading current claims insight; bind to Claims[Claims Review Headline] when dynamic textbox binding is supported."
            field_bindings: Claims[Claims Review Headline]
          - id: year_slicer
            region: filters
            kind: slicer
            field_bindings: Date[Year]
            slicer_type: dropdown
            purpose: "Select the review year while keeping filter state visible."
          - id: leadership_kpis
            region: kpis
            kind: cardVisual
            purpose: "What are the core volume, payment, workload, closure, and timeliness measures for the review?"
            field_bindings:
              Data:
                - Claims[Total Claims]
                - Claims[Total Paid]
                - Claims[Average Paid per Claim]
                - Claims[Open Claims]
                - Claims[Closure Rate]
                - Claims[Average Reporting Lag Days]
            color_strategy: measure_match
            composite_kpi_treatment: true
            context: "Use a single multi-value cardVisual with compact reference labels for prior-year change where available; do not create six oversized standalone cards."
          - id: paid_monthly_trend
            region: paid_trend
            kind: lineChart
            purpose: "How is paid claim value changing month by month?"
            field_bindings:
              Category: Date[Date]
              Y: Claims[Total Paid]
            color_strategy: measure_match
            title: "Paid claim value by loss month"
            subtitle: "GBP paid-to-date; loss-date basis"
          - id: claims_monthly_trend
            region: claims_trend
            kind: lineChart
            purpose: "How is claim volume changing month by month?"
            field_bindings:
              Category: Date[Date]
              Y: Claims[Total Claims]
            color_strategy: measure_match
            title: "Claims by loss month"
            subtitle: "Distinct claims; loss-date basis"
          - id: paid_by_product
            region: product_driver
            kind: barChart
            purpose: "Which insurance products drive paid claim value?"
            field_bindings:
              Category: Policy[Product]
              Y: Claims[Total Paid]
            sort_policy: value_desc
            color_strategy: gradient
            title: "Paid claim value by product"
            subtitle: "Sorted highest to lowest"
          - id: claims_by_status
            region: status_driver
            kind: barChart
            purpose: "How is the current claim workload distributed by status?"
            field_bindings:
              Category: Claims[Claim Status]
              Y: Claims[Total Claims]
            sort_policy: value_desc
            color_strategy: semantic
            title: "Claims by current status"
            subtitle: "Labels accompany status colors"
          - id: source_freshness
            region: footer
            kind: textbox
            text: "Source: Snowflake PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS | Refresh date shown by the semantic model"
            purpose: "Make source and data freshness explicit for the recurring review."
        space_audit:
          content_cell_count: 132
          placed_cell_count: 132
          empty_cell_pct: 0
          unplaced_regions: []
          largest_region:
            name: paid_trend
            pct_of_content: 18.2
          balance_rationale: "The six-value KPI strip is compact and contextual; four equally sized evidence panels explain trend and drivers, while a populated footer removes dead space. No bare KPI occupies a hero region."
  interaction_pattern:
    drill_targets: []
    cross_filter_rules: "Year filters every visual; product and status selections filter the remaining data visuals; title and footer do not participate."
  accessibility:
    alt_text_strategy: "Use dynamic headline-and-trend measures for the two line charts and comparison framing for product/status bars; keep card alt text under 150 characters."
    contrast_notes: "Use #0F172A text on #FFFFFF containers and #F1F5F9 page surface; cyan is not used for body text. Status colors always include labels, and adverse/positive change includes direction text or icons."
    tab_order: "Page title, Year slicer, KPI strip, paid trend, claims trend, product driver, status driver, footer."
  theme:
    name: Claims Corporate Cool
    base: "assets/base.json adapted"
    palette:
      page: "#F1F5F9"
      container: "#FFFFFF"
      foreground: "#0F172A"
      secondary_foreground: "#475569"
      accent: "#0891B2"
      positive: "#0F766E"
      warning: "#B45309"
      negative: "#B91C1C"
    typography: "Segoe UI Semibold for titles; Segoe UI for labels/body; consistent numeric formats."
    implementation_notes: "Preserve base.json textbox zero-padding/background/border safeguards, cardVisual zero-padding and spacing, table grow-to-fit defaults, hidden visual headers, and chart defaults. Use 8px container radius, no shadows, explicit chart titles, compact card reference labels, and per-visual accent/gradient settings."
    user_overrides: "None"
```

## Implementation notes
- Model changes: Build a new local Import semantic model with parameterized Snowflake Power Query partitions, star-schema relationships, hidden technical fields, DAX measures, and formats listed above.
- PBIR/report authoring: Scaffold `powerbi/ClaimsLeadershipScorecard/ClaimsLeadershipScorecard.pbip`, its `.SemanticModel` folder, and its `.Report` folder; adapt the approved design contract into deterministic PBIR files.
- Validation: Validate JSON and PBIP references locally. Install/use the official authoring CLI if approved and available; fix all errors and review warnings.
- Desktop screenshot verification: Blocked in the current Linux environment. Open the PBIP in Power BI Desktop on Windows, enter Snowflake credentials, refresh, and perform the reload/screenshot accessibility review before production use.
- Publishing boundary: Do not publish or create Fabric items.
- Risks:
  - No incurred amount, outstanding reserve, claim cause, handler, severity, or SLA target exists in the current mart; the scorecard must not imply these measures.
  - Current production data is small and ends in August 2025; trend interpretation should show the selected period and refresh date.
  - Static title fallback reflects the current data snapshot; prefer the dynamic `Claims Review Headline` measure during authoring.

