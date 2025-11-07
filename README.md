# 臨流ネット OMOP CDM 構築プロジェクト

## 概要
本リポジトリは、臨中ネットにおける標準データテーブルを、国際標準である OMOP CDM（Common Data Model）形式へ変換・構築するための設計、ETL（Extract, Transform, Load）プロセス、マッピング仕様を公開します。
国際的な医療データ利活用基盤との互換性確保と、リアルワールドデータの研究活用を目的としています。

## プロジェクトの目的
- 臨中ネット標準データベースに蓄積された医療データを OMOP CDM 5.4 へ変換
- 国際共同研究や多施設研究でのデータ利活用を推進

## 作業範囲
- 臨中ネット標準データテーブルの解析
- OMOP CDM への変換要件整理
- システム・インフラ要件の整理
- ETL プロセス設計
- データ品質要件・評価手法の検討

## データ変換対象の例
| 臨中ネット DB テーブル | OMOP CDM テーブル | 備考 |
|----------------------|------------------|------|
| PatientIdentification  PatientAddress | person | 個人情報の秘匿化方針に基づき変換 |
| PatientVisit | visit_occurrence, observation_period, death | イベント種別ごとに変換先を分岐 |
| PatientDisease | condition_occurrence, procedure_occurrence, observation, measurement | ICD10コードからマッピングされるドメインに基づき、各テーブルへ振り分け |
| ObservationResult | measurement, observation, specimen | 検査項目・単位の標準化 |
| PrescriptionData  InjectionData | drug_exposure, drug_era, dose_era | 薬剤コード・単位・投与経路の標準化 |
| 標準診療科コード | provider | 通常は医療従事者のデータが入るが、標準診療科コードを格納 |
| 参加施設情報 | care_site | 医療機関番号を登録 |
| 郵便番号 | location | 検討中 |

## 採用 CDM バージョン
- OMOP CDM 5.4（OHDSI ツールとの互換性・拡張性を考慮）

## ETL プロセス概要（マッピングテーブル・変換ロジックは本リポジトリで公開）
1. 臨中ネット標準 DB から抽出（CSV 等）
2. 中間テーブル・ビューを介して OMOP 形式へ変換
3. OMOP CDM テーブルへロード

## セキュリティ・プライバシー
- 個人情報の秘匿化（ID 変換、郵便番号→別のコードに変更）
- OMOP DB は個人情報を含む前提で運用
- データ提供時に個人情報・施設固有情報は含めない

## システム・インフラ要件
- PostgreSQL 16.x
- R 4.4.x, RStudio Server
- Java（OpenJDK 8）、Apache Tomcat 8.5
- Node.js v20.x
- OHDSI ツール（ATLAS, WebAPI, DQD, HADES, Usagi, WhiteRabbit 等）

## データ品質・評価
- 検討中
- 
## 参考資料
- [OMOP CDM 公式ドキュメント](https://ohdsi.github.io/CommonDataModel/)
- [OHDSI Athena](https://athena.ohdsi.org/)
- [臨中ネット公式サイト](https://www.nu-mitc.org/rinchu-net/)

## 注意事項
- 本リポジトリは公開可能な情報のみを掲載しています
- 個人情報・施設固有情報は含みません
- 詳細なマッピング仕様・ETL サンプルは順次追加予定
