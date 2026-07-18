import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve('powerbi/ClaimsLeadershipScorecard');
const model = path.join(root, 'ClaimsLeadershipScorecard.SemanticModel');
const report = path.join(root, 'ClaimsLeadershipScorecard.Report');
const definition = path.join(report, 'definition');
const pageId = 'ReportSection0c1a1d5c0a1e20260001';
const visualsDir = path.join(definition, 'pages', pageId, 'visuals');
const themeName = 'ClaimsCorporateCool-20260718.json';

const write = (file, value) => {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const normalized = typeof value === 'string'
    ? value
        .replaceAll('\n+', '\n')
        .replaceAll("Claims['Claim ID']", "'Claims'[Claim ID]")
        .replaceAll("Claims['Paid Amount']", "'Claims'[Paid Amount]")
        .replaceAll("Claims['Claim Status']", "'Claims'[Claim Status]")
        .replaceAll("Claims['Reporting Lag Days']", "'Claims'[Reporting Lag Days]")
        .replaceAll("Claims['Reported Date']", "'Claims'[Reported Date]")
    : `${JSON.stringify(value, null, 2)}\n`;
  fs.writeFileSync(file, normalized);
};

const schema = {
  visual: 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.9.0/schema.json',
  page: 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json'
};

const literal = value => ({ expr: { Literal: { Value: value } } });
const column = (entity, property) => ({ Column: { Expression: { SourceRef: { Entity: entity } }, Property: property } });
const measure = (entity, property) => ({ Measure: { Expression: { SourceRef: { Entity: entity } }, Property: property } });
const projection = (field, entity, property) => ({ field, queryRef: `${entity}.${property}`, nativeQueryRef: property });
const position = (x, y, width, height, z, tabOrder) => ({ x, y, z, height, width, tabOrder });

const titleVco = (title, subtitle, altText) => ({
  title: [{ properties: { show: literal('true'), text: literal(`'${title}'`), heading: literal("'Heading2'"), fontSize: literal('14D') } }],
  ...(subtitle ? { subTitle: [{ properties: { show: literal('true'), text: literal(`'${subtitle}'`), fontSize: literal('10D') } }] } : {}),
  general: [{ properties: { altText: literal(`'${altText}'`) } }],
  background: [{ properties: { show: literal('true'), color: { solid: { color: literal("'#FFFFFF'") } }, transparency: literal('0D') } }],
  border: [{ properties: { show: literal('true'), color: { solid: { color: literal("'#E2E8F0'") } }, radius: literal('8D') } }],
  padding: [{ properties: { top: literal('8D'), bottom: literal('8D'), left: literal('8D'), right: literal('8D') } }]
});

const textbox = (id, pos, text, fontSize, color, weight = 'normal') => ({
  $schema: schema.visual,
  name: id,
  position: pos,
  visual: {
    visualType: 'textbox',
    objects: { general: [{ properties: { paragraphs: [{ textRuns: [{ value: text, textStyle: { fontFamily: weight === 'bold' ? 'Segoe UI Semibold' : 'Segoe UI', fontSize: `${fontSize}px`, color, ...(weight === 'bold' ? { fontWeight: 'bold' } : {}) } }], horizontalTextAlignment: 'left' }] } }] },
    visualContainerObjects: {
      background: [{ properties: { show: literal('false') } }],
      border: [{ properties: { show: literal('false') } }],
      padding: [{ properties: { top: literal('0D'), bottom: literal('0D'), left: literal('0D'), right: literal('0D') } }]
    }
  }
});

const chart = (id, pos, type, categoryEntity, categoryProperty, measureProperty, title, subtitle, altText, sort = false) => ({
  $schema: schema.visual,
  name: id,
  position: pos,
  visual: {
    visualType: type,
    query: {
      queryState: {
        Category: { projections: [projection(column(categoryEntity, categoryProperty), categoryEntity, categoryProperty)] },
        Y: { projections: [projection(measure('Claims', measureProperty), 'Claims', measureProperty)] }
      },
      ...(sort ? { sortDefinition: { sort: [{ field: measure('Claims', measureProperty), direction: 'Descending' }], isDefaultSort: false } } : {})
    },
    visualContainerObjects: titleVco(title, subtitle, altText)
  }
});

const kpiCard = (id, pos, measureProperty, altText) => ({
  $schema: schema.visual,
  name: id,
  position: pos,
  visual: {
    visualType: 'cardVisual',
    query: { queryState: { Data: { projections: [projection(measure('Claims', measureProperty), 'Claims', measureProperty)] } } },
    objects: {
      outline: [{ properties: { show: literal('false') }, selector: { id: 'default' } }],
      layout: [{ properties: { paddingUniform: literal('0L'), topOuterMargin: literal('0L'), bottomOuterMargin: literal('0L'), leftOuterMargin: literal('0L'), rightOuterMargin: literal('0L') }, selector: { id: 'default' } }]
    },
    visualContainerObjects: {
      ...titleVco('', '', altText),
      title: [{ properties: { show: literal('false') } }],
      padding: [{ properties: { top: literal('0D'), bottom: literal('0D'), left: literal('0D'), right: literal('0D') } }]
    }
  }
});

write(path.join(root, 'ClaimsLeadershipScorecard.pbip'), {
  $schema: 'https://developer.microsoft.com/json-schemas/fabric/pbip/pbipProperties/1.0.0/schema.json',
  version: '1.0',
  artifacts: [{ report: { path: 'ClaimsLeadershipScorecard.Report' } }],
  settings: { enableAutoRecovery: true }
});

write(path.join(model, 'definition.pbism'), {
  $schema: 'https://developer.microsoft.com/json-schemas/fabric/item/semanticModel/definitionProperties/1.0.0/schema.json',
  version: '4.2',
  settings: { qnaEnabled: true }
});
write(path.join(model, '.platform'), {
  $schema: 'https://developer.microsoft.com/json-schemas/fabric/gitIntegration/platformProperties/2.0.0/schema.json',
  metadata: { type: 'SemanticModel', displayName: 'Claims Leadership Scorecard' },
  config: { version: '2.0', logicalId: '4c61696d-734c-6561-6465-727368697001' }
});

write(path.join(model, 'definition', 'database.tmdl'), `database ClaimsLeadershipScorecard\n\tcompatibilityLevel: 1702\n\tcompatibilityMode: powerBI\n\tlanguage: 2057\n`);
write(path.join(model, 'definition', 'model.tmdl'), `model Model\n\tculture: en-GB\n\tdefaultPowerBIDataSourceVersion: powerBI_V3\n\tsourceQueryCulture: en-GB\n\tdiscourageImplicitMeasures\n\nref table Claims\nref table Policy\nref table Date\n\nexpression SnowflakeServer = "DBSKDCV-OV11805.snowflakecomputing.com" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]\n\nexpression SnowflakeWarehouse = "MODERN_INSURANCE_PLATFORM_WH" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]\n\nexpression SnowflakeDatabase = "PRD_MODERN_INSURANCE_PLATFORM" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]\n\nexpression SnowflakeSchema = "ANALYTICS" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]\n`);
write(path.join(model, 'definition', 'relationships.tmdl'), `relationship 'Claims to Policy'\n\tfromColumn: Claims.'Policy ID'\n\ttoColumn: Policy.'Policy ID'\n\nrelationship 'Claims Loss Date to Date'\n\tfromColumn: Claims.'Loss Date'\n\ttoColumn: Date.Date\n\nrelationship 'Claims Reported Date to Date'\n\tisActive: false\n\tfromColumn: Claims.'Reported Date'\n\ttoColumn: Date.Date\n`);

write(path.join(model, 'definition', 'tables', 'Claims.tmdl'), `/// Claim activity at one row per claim identifier.\n+table Claims\n+\n+\t/// Distinct claims in the current filter context.\n+\tmeasure 'Total Claims' = DISTINCTCOUNT(Claims['Claim ID'])\n+\t\tformatString: #,##0\n+\t\tdisplayFolder: Leadership KPIs\n+\n+\t/// Paid-to-date claim value; this is not incurred loss or outstanding reserve.\n+\tmeasure 'Total Paid' = SUM(Claims['Paid Amount'])\n+\t\tformatString: £#,##0\n+\t\tdisplayFolder: Leadership KPIs\n+\n+\t/// Average paid-to-date value for claims in context.\n+\tmeasure 'Average Paid per Claim' = DIVIDE([Total Paid], [Total Claims])\n+\t\tformatString: £#,##0\n+\t\tdisplayFolder: Leadership KPIs\n+\n+\t/// Claims whose current lifecycle status is open.\n+\tmeasure 'Open Claims' = CALCULATE([Total Claims], KEEPFILTERS(Claims['Claim Status'] = "OPEN"))\n+\t\tformatString: #,##0\n+\t\tdisplayFolder: Leadership KPIs\n+\n+\t/// Claims whose current lifecycle status is closed.\n+\tmeasure 'Closed Claims' = CALCULATE([Total Claims], KEEPFILTERS(Claims['Claim Status'] = "CLOSED"))\n+\t\tformatString: #,##0\n+\t\tdisplayFolder: Supporting Measures\n+\n+\t/// Share of claims currently closed.\n+\tmeasure 'Closure Rate' = DIVIDE([Closed Claims], [Total Claims])\n+\t\tformatString: 0.0%\n+\t\tdisplayFolder: Leadership KPIs\n+\n+\t/// Mean whole-day interval between loss and initial report.\n+\tmeasure 'Average Reporting Lag Days' = AVERAGE(Claims['Reporting Lag Days'])\n+\t\tformatString: #,##0.0\n+\t\tdisplayFolder: Leadership KPIs\n+\n+\t/// Distinct claim count for the same date period one year earlier.\n+\tmeasure 'Claims Prior Year' = CALCULATE([Total Claims], SAMEPERIODLASTYEAR('Date'[Date]))\n+\t\tformatString: #,##0\n+\t\tdisplayFolder: Time Intelligence\n+\n+\t/// Percentage change in claim count from the same period one year earlier.\n+\tmeasure 'Claims YoY Change' = DIVIDE([Total Claims] - [Claims Prior Year], [Claims Prior Year])\n+\t\tformatString: +0.0%;-0.0%;0.0%\n+\t\tdisplayFolder: Time Intelligence\n+\n+\t/// Paid-to-date value for the same date period one year earlier.\n+\tmeasure 'Paid Prior Year' = CALCULATE([Total Paid], SAMEPERIODLASTYEAR('Date'[Date]))\n+\t\tformatString: £#,##0\n+\t\tdisplayFolder: Time Intelligence\n+\n+\t/// Percentage change in paid-to-date value from the same period one year earlier.\n+\tmeasure 'Paid YoY Change' = DIVIDE([Total Paid] - [Paid Prior Year], [Paid Prior Year])\n+\t\tformatString: +0.0%;-0.0%;0.0%\n+\t\tdisplayFolder: Time Intelligence\n+\n+\t/// Filter-responsive leadership headline naming the product with the largest paid share.\n+\tmeasure 'Claims Review Headline' = \`\`\`\n+\t\t\tVAR _products =\n+\t\t\t\tTOPN(\n+\t\t\t\t\t1,\n+\t\t\t\t\tADDCOLUMNS(VALUES('Policy'[Product]), "PaidValue", [Total Paid]),\n+\t\t\t\t\t[PaidValue], DESC,\n+\t\t\t\t\t'Policy'[Product], ASC\n+\t\t\t\t)\n+\t\t\tVAR _product = MAXX(_products, 'Policy'[Product])\n+\t\t\tVAR _paid = MAXX(_products, [PaidValue])\n+\t\t\tVAR _share = DIVIDE(_paid, CALCULATE([Total Paid], REMOVEFILTERS('Policy'[Product])))\n+\t\t\tRETURN IF(ISBLANK(_product), "Claims leadership review", _product & " currently drives " & FORMAT(_share, "0%") & " of paid claims")\n+\t\t\t\`\`\`\n+\t\tformatString: General\n+\t\tdisplayFolder: Narrative\n+\n+\t/// Screen-reader summary of claim volume in the selected context.\n+\tmeasure 'Claims Alt Text' = "There are " & FORMAT([Total Claims], "#,##0") & " claims in the selected period, with " & FORMAT([Open Claims], "#,##0") & " currently open."\n+\t\tformatString: General\n+\t\tdisplayFolder: Accessibility\n+\n+\t/// Screen-reader summary of paid-to-date value in the selected context.\n+\tmeasure 'Paid Alt Text' = "Paid-to-date claim value is " & FORMAT([Total Paid], "£#,##0") & ". This is not an incurred or reserve amount."\n+\t\tformatString: General\n+\t\tdisplayFolder: Accessibility\n+\n+\t/// Supporting count evaluated by reported date via the inactive relationship.\n+\tmeasure 'Total Claims by Reported Date' = CALCULATE([Total Claims], USERELATIONSHIP(Claims['Reported Date'], 'Date'[Date]))\n+\t\tformatString: #,##0\n+\t\tdisplayFolder: Supporting Measures\n+\t\tisHidden\n+\n+\t/// Technical claim identifier retained only for distinct-count calculation.\n+\tcolumn 'Claim ID'\n+\t\tdataType: string\n+\t\tisHidden\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Claim ID\n+\n+\t/// Relationship key to the Policy dimension.\n+\tcolumn 'Policy ID'\n+\t\tdataType: string\n+\t\tisHidden\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Policy ID\n+\n+\t/// Date on which the insured loss occurred.\n+\tcolumn 'Loss Date'\n+\t\tdataType: dateTime\n+\t\tformatString: dd MMM yyyy\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Loss Date\n+\n+\t/// Date on which the claim was first reported.\n+\tcolumn 'Reported Date'\n+\t\tdataType: dateTime\n+\t\tformatString: dd MMM yyyy\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Reported Date\n+\n+\t/// Current claim lifecycle status.\n+\tcolumn 'Claim Status'\n+\t\tdataType: string\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Claim Status\n+\n+\t/// Paid-to-date value supplied by the claims mart.\n+\tcolumn 'Paid Amount'\n+\t\tdataType: decimal\n+\t\tisHidden\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Paid Amount\n+\n+\t/// Whole-day interval between loss and first report.\n+\tcolumn 'Reporting Lag Days'\n+\t\tdataType: int64\n+\t\tisHidden\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Reporting Lag Days\n+\n+\tpartition Claims = m\n+\t\tmode: import\n+\t\tsource =\n+\t\t\tlet\n+\t\t\t\tSource = Snowflake.Databases(#"SnowflakeServer", #"SnowflakeWarehouse", [Implementation="2.0"]),\n+\t\t\t\tDatabase = Source{[Name=#"SnowflakeDatabase"]}[Data],\n+\t\t\t\tSchema = Database{[Name=#"SnowflakeSchema", Kind="Schema"]}[Data],\n+\t\t\t\tClaimsSource = Schema{[Name="FCT_CLAIMS", Kind="Table"]}[Data],\n+\t\t\t\t#"Selected Columns" = Table.SelectColumns(ClaimsSource, {"CLAIM_ID", "POLICY_ID", "LOSS_DATE", "REPORTED_DATE", "CLAIM_STATUS", "PAID_AMOUNT"}),\n+\t\t\t\t#"Renamed Columns" = Table.RenameColumns(#"Selected Columns", {{"CLAIM_ID", "Claim ID"}, {"POLICY_ID", "Policy ID"}, {"LOSS_DATE", "Loss Date"}, {"REPORTED_DATE", "Reported Date"}, {"CLAIM_STATUS", "Claim Status"}, {"PAID_AMOUNT", "Paid Amount"}}),\n+\t\t\t\t#"Added Reporting Lag" = Table.AddColumn(#"Renamed Columns", "Reporting Lag Days", each Duration.Days([Reported Date] - [Loss Date]), Int64.Type),\n+\t\t\t\t#"Changed Types" = Table.TransformColumnTypes(#"Added Reporting Lag", {{"Claim ID", type text}, {"Policy ID", type text}, {"Loss Date", type date}, {"Reported Date", type date}, {"Claim Status", type text}, {"Paid Amount", Currency.Type}, {"Reporting Lag Days", Int64.Type}})\n+\t\t\tin\n+\t\t\t\t#"Changed Types"\n+`);

write(path.join(model, 'definition', 'tables', 'Policy.tmdl'), `/// Policy attributes used to segment claim results, at one row per policy identifier.\n+table Policy\n+\n+\t/// Relationship key retained for model joins.\n+\tcolumn 'Policy ID'\n+\t\tdataType: string\n+\t\tisHidden\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Policy ID\n+\n+\t/// Insurance product associated with the policy.\n+\tcolumn Product\n+\t\tdataType: string\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Product\n+\n+\t/// Current policy lifecycle status.\n+\tcolumn 'Policy Status'\n+\t\tdataType: string\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Policy Status\n+\n+\tpartition Policy = m\n+\t\tmode: import\n+\t\tsource =\n+\t\t\tlet\n+\t\t\t\tSource = Snowflake.Databases(#"SnowflakeServer", #"SnowflakeWarehouse", [Implementation="2.0"]),\n+\t\t\t\tDatabase = Source{[Name=#"SnowflakeDatabase"]}[Data],\n+\t\t\t\tSchema = Database{[Name=#"SnowflakeSchema", Kind="Schema"]}[Data],\n+\t\t\t\tPolicySource = Schema{[Name="DIM_POLICY", Kind="Table"]}[Data],\n+\t\t\t\t#"Selected Columns" = Table.SelectColumns(PolicySource, {"POLICY_ID", "PRODUCT_CODE", "POLICY_STATUS"}),\n+\t\t\t\t#"Renamed Columns" = Table.RenameColumns(#"Selected Columns", {{"POLICY_ID", "Policy ID"}, {"PRODUCT_CODE", "Product"}, {"POLICY_STATUS", "Policy Status"}}),\n+\t\t\t\t#"Changed Types" = Table.TransformColumnTypes(#"Renamed Columns", {{"Policy ID", type text}, {"Product", type text}, {"Policy Status", type text}})\n+\t\t\tin\n+\t\t\t\t#"Changed Types"\n+`);

write(path.join(model, 'definition', 'tables', 'Date.tmdl'), `/// Contiguous calendar used for loss-date reporting and time intelligence.\n+table Date\n+\tdataCategory: Time\n+\n+\t/// Calendar date at daily grain.\n+\tcolumn Date\n+\t\tdataType: dateTime\n+\t\tformatString: dd MMM yyyy\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Date\n+\n+\t/// Calendar year used by the leadership slicer.\n+\tcolumn Year\n+\t\tdataType: int64\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Year\n+\n+\t/// Calendar month name.\n+\tcolumn Month\n+\t\tdataType: string\n+\t\tsortByColumn: 'Month Number'\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Month\n+\n+\t/// Calendar month number used to sort month names.\n+\tcolumn 'Month Number'\n+\t\tdataType: int64\n+\t\tisHidden\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Month Number\n+\n+\t/// First day of the month for chronological chart axes.\n+\tcolumn 'Year Month'\n+\t\tdataType: dateTime\n+\t\tformatString: MMM yyyy\n+\t\tsummarizeBy: none\n+\t\tsourceColumn: Year Month\n+\n+\thierarchy 'Calendar Hierarchy'\n+\t\tlevel Year\n+\t\t\tcolumn: Year\n+\t\tlevel Month\n+\t\t\tcolumn: Month\n+\t\tlevel Date\n+\t\t\tcolumn: Date\n+\n+\tpartition Date = m\n+\t\tmode: import\n+\t\tsource =\n+\t\t\tlet\n+\t\t\t\tSource = Snowflake.Databases(#"SnowflakeServer", #"SnowflakeWarehouse", [Implementation="2.0"]),\n+\t\t\t\tDatabase = Source{[Name=#"SnowflakeDatabase"]}[Data],\n+\t\t\t\tSchema = Database{[Name=#"SnowflakeSchema", Kind="Schema"]}[Data],\n+\t\t\t\tClaimsSource = Schema{[Name="FCT_CLAIMS", Kind="Table"]}[Data],\n+\t\t\t\tMinDate = Date.StartOfYear(Date.From(List.Min(ClaimsSource[LOSS_DATE]))),\n+\t\t\t\tMaxDate = Date.EndOfYear(Date.From(List.Max(ClaimsSource[LOSS_DATE]))),\n+\t\t\t\tDates = List.Dates(MinDate, Duration.Days(MaxDate - MinDate) + 1, #duration(1, 0, 0, 0)),\n+\t\t\t\t#"Converted to Table" = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),\n+\t\t\t\t#"Changed Date Type" = Table.TransformColumnTypes(#"Converted to Table", {{"Date", type date}}),\n+\t\t\t\t#"Added Year" = Table.AddColumn(#"Changed Date Type", "Year", each Date.Year([Date]), Int64.Type),\n+\t\t\t\t#"Added Month" = Table.AddColumn(#"Added Year", "Month", each Date.MonthName([Date], "en-GB"), type text),\n+\t\t\t\t#"Added Month Number" = Table.AddColumn(#"Added Month", "Month Number", each Date.Month([Date]), Int64.Type),\n+\t\t\t\t#"Added Year Month" = Table.AddColumn(#"Added Month Number", "Year Month", each Date.StartOfMonth([Date]), type date)\n+\t\t\tin\n+\t\t\t\t#"Added Year Month"\n+`);

write(path.join(report, 'definition.pbir'), {
  $schema: 'https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json',
  version: '4.0',
  datasetReference: { byPath: { path: '../ClaimsLeadershipScorecard.SemanticModel' } }
});
write(path.join(report, '.platform'), {
  $schema: 'https://developer.microsoft.com/json-schemas/fabric/gitIntegration/platformProperties/2.0.0/schema.json',
  metadata: { type: 'Report', displayName: 'Claims Leadership Scorecard' },
  config: { version: '2.0', logicalId: '4c61696d-7352-6570-6f72-740000000001' }
});
write(path.join(definition, 'version.json'), { $schema: 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/versionMetadata/1.0.0/schema.json', version: '2.0.0' });
write(path.join(definition, 'report.json'), {
  $schema: 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/report/3.3.0/schema.json',
  themeCollection: { customTheme: { name: themeName, reportVersionAtImport: { visual: '2.6.0', report: '3.1.0', page: '2.1.0' }, type: 'RegisteredResources' } },
  resourcePackages: [{ name: 'RegisteredResources', type: 'RegisteredResources', items: [{ name: themeName, path: themeName, type: 'CustomTheme' }] }],
  settings: { useStylableVisualContainerHeader: true }
});
write(path.join(definition, 'pages', 'pages.json'), { $schema: 'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.0.0/schema.json', pageOrder: [pageId], activePageName: pageId });
write(path.join(definition, 'pages', pageId, 'page.json'), {
  $schema: schema.page, name: pageId, displayName: 'Claims Leadership Scorecard', displayOption: 'FitToPage', height: 1080, width: 1920,
  objects: { background: [{ properties: { color: { solid: { color: literal("'#F1F5F9'") } }, transparency: literal('0D') } }] }
});

const visualFiles = [
  ['0a0a0a0a0a0a0a0a0a01', textbox('0a0a0a0a0a0a0a0a0a01', position(32, 32, 1392, 64, 1000, 0), 'Motor currently drives 76% of paid claims', 30, '#0F172A', 'bold')],
  ['0b0b0b0b0b0b0b0b0b02', {
    $schema: schema.visual, name: '0b0b0b0b0b0b0b0b0b02', position: position(1448, 24, 440, 80, 2000, 1000),
    visual: { visualType: 'slicer', query: { queryState: { Values: { projections: [projection(column('Date', 'Year'), 'Date', 'Year')] } } }, objects: { data: [{ properties: { mode: literal("'Dropdown'") } }], header: [{ properties: { show: literal('true'), text: literal("'Review Year'") } }] }, visualContainerObjects: { ...titleVco('', '', 'Select the calendar year for the claims review.'), title: [{ properties: { show: literal('false') } }], padding: [{ properties: { top: literal('8D'), bottom: literal('8D'), left: literal('8D'), right: literal('8D') } }] } }
  }],
  ['0c0c0c0c0c0c0c0c0c03', kpiCard('0c0c0c0c0c0c0c0c0c03', position(32, 120, 296, 160, 3000, 2000), 'Total Claims', 'Total distinct claims in the selected review period.')],
  ['12121212121212121212', kpiCard('12121212121212121212', position(344, 120, 296, 160, 3100, 2100), 'Total Paid', 'Paid-to-date claim value in the selected review period.')],
  ['13131313131313131313', kpiCard('13131313131313131313', position(656, 120, 296, 160, 3200, 2200), 'Average Paid per Claim', 'Average paid-to-date value per claim in the selected review period.')],
  ['14141414141414141414', kpiCard('14141414141414141414', position(968, 120, 296, 160, 3300, 2300), 'Open Claims', 'Claims currently carrying an open lifecycle status.')],
  ['15151515151515151515', kpiCard('15151515151515151515', position(1280, 120, 296, 160, 3400, 2400), 'Closure Rate', 'Share of claims currently carrying a closed lifecycle status.')],
  ['16161616161616161616', kpiCard('16161616161616161616', position(1592, 120, 296, 160, 3500, 2500), 'Average Reporting Lag Days', 'Average whole-day interval between loss and first report.')],
  ['0d0d0d0d0d0d0d0d0d04', chart('0d0d0d0d0d0d0d0d0d04', position(32, 304, 904, 328, 4000, 3000), 'lineChart', 'Date', 'Year Month', 'Total Paid', 'Paid claim value by loss month', 'GBP paid-to-date; loss-date basis', 'Monthly paid-to-date claim value by loss month.')],
  ['0e0e0e0e0e0e0e0e0e05', chart('0e0e0e0e0e0e0e0e0e05', position(960, 304, 928, 328, 5000, 4000), 'lineChart', 'Date', 'Year Month', 'Total Claims', 'Claims by loss month', 'Distinct claims; loss-date basis', 'Monthly distinct claim count by loss month.')],
  ['0f0f0f0f0f0f0f0f0f06', chart('0f0f0f0f0f0f0f0f0f06', position(32, 656, 904, 328, 6000, 5000), 'barChart', 'Policy', 'Product', 'Total Paid', 'Paid claim value by product', 'Sorted highest to lowest', 'Ranked paid-to-date claim value by insurance product.', true)],
  ['10101010101010101010', chart('10101010101010101010', position(960, 656, 928, 328, 7000, 6000), 'barChart', 'Claims', 'Claim Status', 'Total Claims', 'Claims by current status', 'Labels accompany status colors', 'Distinct claims ranked by current lifecycle status.', true)],
  ['11111111111111111111', textbox('11111111111111111111', position(32, 1008, 1856, 40, 8000, 7000), 'Source: Snowflake PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS  •  Paid amounts are paid-to-date, not incurred or reserve values', 12, '#475569')]
];
for (const [id, visual] of visualFiles) write(path.join(visualsDir, id, 'visual.json'), visual);

const baseTheme = JSON.parse(fs.readFileSync(path.resolve('../skills-for-fabric/skills/powerbi-report-design/assets/base.json'), 'utf8'));
baseTheme.name = themeName;
baseTheme.dataColors = ['#0891B2', '#334155', '#0F766E', '#B45309', '#64748B', '#B91C1C', '#0E7490', '#94A3B8'];
baseTheme.good = '#0F766E';
baseTheme.neutral = '#B45309';
baseTheme.bad = '#B91C1C';
baseTheme.maximum = '#0891B2';
baseTheme.center = '#64748B';
baseTheme.minimum = '#CFFAFE';
baseTheme.null = '#CBD5E1';
baseTheme.foreground = '#0F172A';
baseTheme.background = '#FFFFFF';
baseTheme.tableAccent = '#0891B2';
baseTheme.textClasses.callout = { fontSize: 28, fontFace: 'Segoe UI Semibold', color: '#0F172A' };
baseTheme.textClasses.title = { fontSize: 14, fontFace: 'Segoe UI Semibold', color: '#0F172A' };
baseTheme.textClasses.header = { fontSize: 12, fontFace: 'Segoe UI Semibold', color: '#0F172A' };
baseTheme.textClasses.label = { fontSize: 10, fontFace: 'Segoe UI', color: '#0F172A' };
delete baseTheme.visualStyles.cardVisual['*'].border[0].radius;
delete baseTheme.visualStyles.cardVisual['*'].spacing[0].customizeSpacing;
delete baseTheme.visualStyles.cardVisual['*'].padding;
write(path.join(report, 'StaticResources', 'RegisteredResources', themeName), baseTheme);

write(path.join(root, 'README.md'), `# Claims Leadership Scorecard\n\nOpen \`ClaimsLeadershipScorecard.pbip\` in Power BI Desktop. On first refresh, authenticate to Snowflake and confirm the parameter values in the semantic model. Credentials are intentionally not stored in this project.\n\nThe report uses Import mode against \`PRD_MODERN_INSURANCE_PLATFORM.ANALYTICS.FCT_CLAIMS\` and \`DIM_POLICY\`. Paid values are paid-to-date and must not be interpreted as incurred loss or outstanding reserve.\n`);

console.log(root);
