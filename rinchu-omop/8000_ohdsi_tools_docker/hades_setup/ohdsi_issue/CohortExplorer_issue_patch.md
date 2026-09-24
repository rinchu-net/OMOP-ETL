# CohortExplorer server.R パッチ

## 問題

CohortExplorer v0.1.0 の `createCohortExplorerApp()` が生成する `server.R` に2つのバグがある:

1. **初期化タイミング**: `dataFromRds()` が NULL の場合に `filter()` が呼ばれてエラー
2. **Date-POSIXt 型不整合**: `daysToFirst = firstOccurrenceDateValue - startDate` で Date と POSIXt が混在し、`abs()` が適用できない

## 修正方法

`createCohortExplorerApp()` 実行後、生成された `server.R` に以下の修正を適用する:

### 修正1: req() ガード追加

```r
# 修正前（4行目付近）
dataFromRds <- shiny::reactive({
    readData(

# 修正後
dataFromRds <- shiny::reactive({
    shiny::req(input$selectedDatabaseId, input$selectedCohortId)
    readData(
```

### 修正2: queryResult にも req() 追加

```r
# 修正前（queryResult reactive 内）
filteredConceptIds <- dataFromRds()$conceptId

# 修正後
shiny::req(dataFromRds())
filteredConceptIds <- dataFromRds()$conceptId
```

### 修正3: daysToFirst の型統一

```r
# 修正前
dplyr::mutate(daysToFirst = firstOccurrenceDateValue - startDate)

# 修正後
dplyr::mutate(daysToFirst = as.integer(as.Date(firstOccurrenceDateValue) - as.Date(startDate)))
```

## 自動パッチスクリプト

```r
# createCohortExplorerApp() 実行後に実行
patch_cohort_explorer <- function(appDir) {
  server_file <- file.path(appDir, "server.R")
  content <- readLines(server_file)
  
  # 修正1: req() ガード
  idx <- grep("dataFromRds <- shiny::reactive", content)
  if (length(idx) > 0) {
    content <- append(content, '    shiny::req(input$selectedDatabaseId, input$selectedCohortId)', after = idx)
  }
  
  # 修正2: queryResult req()
  idx <- grep("filteredConceptIds <- dataFromRds", content)
  if (length(idx) > 0) {
    content <- append(content, '    shiny::req(dataFromRds())', after = idx - 1)
  }
  
  # 修正3: daysToFirst
  content <- gsub(
    "dplyr::mutate(daysToFirst = firstOccurrenceDateValue - startDate)",
    "dplyr::mutate(daysToFirst = as.integer(as.Date(firstOccurrenceDateValue) - as.Date(startDate)))",
    content, fixed = TRUE
  )
  
  writeLines(content, server_file)
  cat("Patched:", server_file, "\n")
}
```
