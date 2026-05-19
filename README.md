# nujabec/myrocker

## 概要

- R 4.5.3（rocker/geospatial:4.5.3 ベース、Ubuntu 24.04 noble）
- RStudio Server（GitHub Copilot 有効、ポート 50003）
- **Shiny Server 同梱（ポート 81）**
- オフライン環境で使うケースも想定し大量のパッケージを install 済み
- CRAN リポジトリは Posit Package Manager (PPM) を 2026-05-18 で日付ピン
- 同梱 CLI: Claude Code、Gemini CLI、GitHub CLI、DuckDB、LibreOffice、Microsoft ODBC 17
- ユーザー: user00〜user20（パスワード=ユーザー名）


## 使い方

```bash
# renvのcache用にvolume作成(初回のみ)
docker volume create renv

# pgnetworkの作成(初回のみ)
docker network create pgnetwork

# イメージのpull
docker pull nujabec/myrocker:20260519

# (イメージの作成)
# docker-compose build

# コンテナの起動
docker-compose up -d
```
## push方法

```bash
docker login
docker push nujabec/myrocker:20260519
```

## オフライン環境にdocker imageを持っていく方法

```bash
# オンライン端末でイメージを作成
# docker imageをtarファイルに変換
docker save nujabec/myrocker:20260519 > myrocker_20260519.tar
# オフライン端末で、tarファイルからdocker imageを読む
docker load < myrocker_20260519.tar
```

## sqlserverのODBCdriverを追加

参考1

https://qiita.com/miraijin/items/0c7bfbd70234967e87bd

参考2

https://learn.microsoft.com/ja-jp/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15&tabs=alpine18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline#microsoft-odbc-17

## gemini cliのapi key 設定方法

### Google AI StudioでAPI keyを取得

https://j-aic.com/techblog/google-ai-studio-api-free

## API KEYの環境変数設定

docker/.env

GEMINI_API_KEY=Your API KEY

## History

### 2026/05/19

- R を 4.5.3 にアップデート（rocker/geospatial:4.5.3、Ubuntu 24.04 noble ベース）
- **Shiny Server を同梱**（旧 myrocker-shiny を統合、ポート 81）
- 不足パッケージ追加: arrow, Polychrome, future, openxlsx2, reactable,
  shinyWidgets, shinybusy, shinycssloaders, shinymanager, shinytest2,
  sortable, stringdist, tidyxl, waiter, writexl
- samba (CIFS マウント) を廃止
- PPM 日付ピン（2026-05-18）で再現性を担保
- Microsoft ODBC リポジトリを signed-by 方式に修正（Ubuntu 24.04 対応）
- Claude Code / Gemini CLI を最終レイヤーに分離（オンラインの差分ビルド高速化）
- HEALTHCHECK 追加
- イメージタグ: 20260519

### 2024/04/12

- userを追加
- pgnetworkを追加

### 2024/05/03

- 私たちのR用にpackageを追加
- Tokyo.R2024/4/20で紹介されていたpackageを追加
- rstudio-prefs_mysettingsを更新
  - Consoleパネルを右に変更
  - CRANをTokyoに変更
  - QuartoのPreviewをViewerパネルに変更

### 2024/09/03

- cronをinstall
- user00を追加

### 2024/09/07

- DuckDBをinstall
- 過去のパッケージは特に変更しなかった

### 2024/10/18

- patchwork1.1.3だとエラーが出たので、Rのパッケージをすべて最新のものにアップデートした。

### 2025/10/19

- claude codeを追加
- gemini cliを追加
- イメージタグを20260519に更新

