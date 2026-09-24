# Docker イメージ修正依頼: CohortExplorer Shiny バグパッチ

## 概要

rinchu/hades:1.0.0 の CohortExplorer パッケージ（v0.1.0）に、R 4.4.x 環境で Shiny アプリが正常動作しないバグがあります。Docker イメージのビルド時にパッチを適用してください。

## 問題

CohortExplorer の `createCohortExplorerApp()` が生成する Shiny アプリで、患者タイムラインが `Error: [object Object]` で表示されない。

### 根本原因

パッケージ内テンプレート `/usr/local/lib/R/site-library/CohortExplorer/shiny/server.R` に2つのバグ：

1. **Date-POSIXt 型不整合**（220行目付近）: `daysToFirst = firstOccurrenceDateValue - startDate` で Date 型と POSIXt 型の減算が発生し、後続の `abs()` が `'abs' not defined for "POSIXt" objects` エラーになる
2. **Shiny 初期化タイミング**: reactive が初期化前に評価され `filter()` が NULL に適用される

### OHDSI Issue

https://github.com/OHDSI/CohortExplorer/issues/38

## Dockerfile への追加内容

CohortExplorer インストール後に以下の3つの `sed` コマンドを追加してください：

```dockerfile
# CohortExplorer v0.1.0 Shiny バグパッチ（R 4.4.x 対応）
# Issue: https://github.com/OHDSI/CohortExplorer/issues/38

# 修正1: Date-POSIXt 型不整合を修正
RUN sed -i 's/daysToFirst = firstOccurrenceDateValue - startDate/daysToFirst = as.integer(as.Date(firstOccurrenceDateValue) - as.Date(startDate))/' \
    /usr/local/lib/R/site-library/CohortExplorer/shiny/server.R

# 修正2: dataFromRds reactive に req() ガード追加
RUN sed -i '/dataFromRds <- shiny::reactive({/a\    shiny::req(input$selectedDatabaseId, input$selectedCohortId)' \
    /usr/local/lib/R/site-library/CohortExplorer/shiny/server.R

# 修正3: queryResult reactive に req() ガード追加
RUN sed -i '/filteredConceptIds <- dataFromRds()\\$conceptId/i\    shiny::req(dataFromRds())' \
    /usr/local/lib/R/site-library/CohortExplorer/shiny/server.R
```

## 検証方法

パッチ適用後、以下の手順で動作確認：

```r
library(CohortExplorer)
source("/home/rstudio/hades_user/hades_tutorial/_common.R")

# Shiny アプリ生成
dir.create("/home/rstudio/test_app", showWarnings = FALSE)
createCohortExplorerApp(
  connectionDetails = get_connection_details(),
  cohortDatabaseSchema = "result",
  cdmDatabaseSchema = "omop",
  cohortTable = "s1_cohort",
  cohortDefinitionId = 1,
  cohortName = "COVID-19",
  sampleSize = 5,
  exportFolder = "/home/rstudio/test_app",
  databaseId = "mydb"
)

# Shiny 起動 → ブラウザでタイムラインが表示されること
shiny::runApp("/home/rstudio/test_app")
```

### 確認ポイント

- タイムラインプロット（plotly）が表示される（`Error: [object Object]` が出ない）
- 患者切替（< > ボタン）が動作する
- ドメインフィルターのチェック/アンチェックが動作する

## docker-compose.yml の変更

Shiny アプリのスクリーンショット取得用にポートを追加済み（不要であれば削除可）：

```yaml
ports:
  - "18787:8787"
  - "14321:4321"   # ← 追加済み（Shiny直接アクセス用）
```

## 補足

- この問題は CohortExplorer v0.1.0 固有で、OHDSI 側で修正されるまでパッチが必要
- R 4.2.x では Date-POSIXt の暗黙変換が動いていたため問題が顕在化しなかった
- パッチ対象ファイル: `/usr/local/lib/R/site-library/CohortExplorer/shiny/server.R`（テンプレート）
