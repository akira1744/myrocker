# nujabec/myrocker

## 概要

- R 4.3.2
- RstudioServer(Enabel GitHub Copilot)
- オフライン環境で使うケースも想定し大量のパッケージをinstall済み


## 使い方

```bash
# renvのcache用にvolume作成(初回のみ)
docker volume create renv

# pgnetworkの作成(初回のみ)
docker network create pgnetwork

# イメージのpull
docker pull nujabec/myrocker:20250917

# (イメージの作成)
# docker-compose build

# コンテナの起動
docker-compose up -d
```
## push方法

```bash
docker login
docker push nujabec/myrocker:20250917
```

## オフライン環境にdocker imageを持っていく方法

```bash
# オンライン端末でイメージを作成
# docker imageをtarファイルに変換
docker save nujabec/myrocker:20250917 > myrocker_20250917.tar
# オフライン端末で、tarファイルからdocker imageを読む
docker load < myrocker_20250917.tar
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
- イメージタグを20250917に更新

