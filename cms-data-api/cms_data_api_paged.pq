// Pulls every row of a data.cms.gov data-api v1 dataset, one page at a time.
// Paste into a blank query (Advanced Editor), set DatasetId, then add your own type step at the end.

let
    DatasetId = "44060663-47d8-4ced-a115-b53b4c270acb",  // type ID = latest release; a version ID pins one year
    PageSize = 1000,

    // The host stays fixed and the dataset path goes in RelativePath, so the
    // Power BI Service sees one static data source and scheduled refresh works.
    GetPage = (offset as number) as list =>
        Json.Document(
            Web.Contents(
                "https://data.cms.gov",
                [
                    RelativePath = "data-api/v1/dataset/" & DatasetId & "/data",
                    Query = [size = Text.From(PageSize), offset = Text.From(offset)]
                ]
            )
        ),

    // Keep requesting the next page until one comes back empty.
    Pages = List.Generate(
        () => [Offset = 0, Page = GetPage(0)],
        each List.Count([Page]) > 0,
        each [Offset = [Offset] + PageSize, Page = GetPage([Offset] + PageSize)],
        each [Page]
    ),

    Source = List.Combine(Pages),
    Result = Table.FromRecords(Source, null, MissingField.UseNull)
in
    Result
