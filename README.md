[README.md](https://github.com/user-attachments/files/33677655/README.md)
# CMS Data API pagination (Power Query)

`cms_data_api_paged.pq` loads a full dataset from the data.cms.gov data-api v1 into Power BI. The API returns at most 1,000 rows per request, so the query requests page after page and combines them.

## Using it

1. Paste the file into a blank query in the Advanced Editor.
2. Set `DatasetId`. The **Dataset Type Identifier** on the dataset's data.cms.gov page always returns the latest release, so a yearly update is picked up at the next refresh. The **Dataset Version Identifier** belongs to one release (for example, 2024) and works in the same place; use it only to pin a year.
3. Add a column type step at the end.
4. Check the row count against the dataset page. If it stops at 1,000, the paging did not run.

`DatasetId` is a step inside the query, not a Power BI parameter, on purpose: the source can only be changed by editing the query, not from the ribbon or the semantic model settings in the Service.

## How it works

1. `GetPage` requests one page: `PageSize` rows starting at `offset`.
2. `List.Generate` starts at offset 0 and moves forward one page at a time, stopping at the first empty page. No hard-coded row count, so it keeps working when CMS adds rows.
3. `List.Combine` stacks the pages, and `Table.FromRecords` turns the records into a table. `MissingField.UseNull` covers any record missing a field.

## Why the URL is split

The host (`https://data.cms.gov`) stays fixed, and the dataset path and paging values go in `RelativePath` and `Query`. If the full URL is built by joining text, the Power BI Service treats it as a dynamic data source and scheduled refresh fails after publishing.

## Before analysis

Check the grain. In the Hospital Provider Cost Report (6,109 rows), `rpt_rec_num` is unique but `Provider CCN` is not (6,026 distinct), so some hospitals have more than one report in a year.

Import mode is the right fit: the API is called at refresh, not each time someone opens the report.
