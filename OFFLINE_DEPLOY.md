# 電子カルテ端末（オフライン環境）導入・運用手順

このドキュメントは、電子カルテネットワークに接続された **Windows PC** に
本 myrocker 環境を導入し、日常運用するための手順書です。

---

## 0. 必要なもの

### 持ち込むファイル（USB 等で運搬）

オンライン PC で作成したものを、まるごとフォルダコピーで運搬してください。

```
myrocker_20260519/                ← このフォルダごと持ち込む
├── docker-compose.yml
├── docker/
│   ├── Dockerfile               (オフラインでは使わないがあってよい)
│   ├── add_users.sh
│   ├── dotRprofile
│   ├── rstudio-prefs_mysettings.json
│   └── .env                     ← 必須（中身は空でも可）
├── myrocker_20260519.tar        ★ Docker イメージ本体 約 8GB
├── README.md
├── CLAUDE.md
└── OFFLINE_DEPLOY.md            ← 本書
```

### 電子カルテ端末側の前提

| 項目 | 要件 |
|---|---|
| OS | Windows 10/11 |
| Docker Desktop | インストール済みで起動できる状態 |
| 空きディスク | 30 GB 以上推奨（イメージ + ボリューム） |
| ポート | 50003 / 81 が他で使われていないこと |

> ⚠️ Docker Desktop が起動していないと一切動きません。タスクトレイの
> クジラアイコンが緑（Running）になっているか確認してください。

---

## 1. 初回セットアップ（最初の 1 回だけ）

### Step 1. フォルダ配置

`C:\dockerenv\` 配下に次のように配置します（場所は変えても構いませんが、
**`myrocker_20260519` と同じ階層に `srv` フォルダがある**ことが必要です）。

```
C:\dockerenv\
├── myrocker_20260519\        ← 持ち込んだフォルダ
└── srv\                       ← 自分で作成（中は空でも OK）
    ├── shinyapps\
    └── shinylog\
```

PowerShell で作成する場合：

```powershell
cd C:\dockerenv
mkdir srv\shinyapps -Force
mkdir srv\shinylog -Force
```

### Step 2. Docker イメージの読み込み

PowerShell（または Git Bash）を **管理者として開いて**、tar ファイルを
Docker に読み込ませます。

```powershell
cd C:\dockerenv\myrocker_20260519
docker load -i myrocker_20260519.tar
```

8 GB ほどあるので数分かかります。完了すると以下のように表示されます。

```
Loaded image: nujabec/myrocker:20260519
```

確認：

```powershell
docker images | findstr myrocker
```

`nujabec/myrocker  20260519` の行が表示されれば OK。

### Step 3. コンテナ起動

```powershell
cd C:\dockerenv\myrocker_20260519
docker compose up -d
```

初回はネットワークとボリュームが自動作成されます。
30 秒〜1 分待つと、コンテナの状態が `(healthy)` になります。

確認：

```powershell
docker ps
```

`STATUS` 列が `Up 〜 (healthy)` になっていれば成功です。

---

## 2. アクセス方法

### RStudio Server

ブラウザで以下にアクセス：

```
http://localhost:50003
```

ログイン情報：

| Username | Password |
|---|---|
| `rstudio` | `rs` |
| `user00` | `user00` |
| `user01` | `user01` |
| … | … |
| `user20` | `user20` |

### Shiny Server

ブラウザで以下にアクセス：

```
http://localhost:81
```

アプリは `C:\dockerenv\srv\shinyapps\` 直下のフォルダごとに配置されます。
例: `C:\dockerenv\srv\shinyapps\myapp\app.R` を置くと
`http://localhost:81/myapp/` で見られます。

### コンテナ内シェル

```powershell
docker exec -it myrocker_20260519-rstudio-1 bash
```

---

## 3. 日常運用

### 停止

```powershell
cd C:\dockerenv\myrocker_20260519
docker compose down
```

### 再起動（PC を再起動した後など）

```powershell
cd C:\dockerenv\myrocker_20260519
docker compose up -d
```

> `restart: always` 設定なので、Docker Desktop が起動すれば
> コンテナも自動で立ち上がります。手動で `up -d` する必要は通常ありません。

### ログ確認

```powershell
# 直近のログを表示
docker compose logs --tail 100

# ストリーミング表示（Ctrl+C で抜ける）
docker compose logs -f
```

### コンテナ状態確認

```powershell
docker ps
```

### Shiny アプリのログ

```
C:\dockerenv\srv\shinylog\
```

の中にアプリごとのログが出ます。

---

## 4. ファイルの受け渡し

コンテナの中の `/home/rstudio/srv/` は、Windows の
`C:\dockerenv\srv\` と同じ場所を見ています。

| Windows 側 | コンテナ側 |
|---|---|
| `C:\dockerenv\srv\` | `/home/rstudio/srv/` |
| `C:\dockerenv\srv\shinyapps\` | `/srv/shiny-server/` |
| `C:\dockerenv\srv\shinylog\` | `/var/log/shiny-server/` |

→ Windows のエクスプローラーでファイルを置けば、そのまま RStudio や
Shiny からアクセスできます。

---

## 5. トラブルシューティング

### ❌ `docker: command not found` / `docker compose` が動かない

→ Docker Desktop が起動していません。タスクトレイで起動を確認。

### ❌ `port is already allocated` のエラー

ポート 50003 または 81 が他のプロセスで使われています。

```powershell
# 使用中プロセス確認
netstat -ano | findstr ":50003"
netstat -ano | findstr ":81"
```

他で使えないポートに変更する場合は、`docker-compose.yml` の `ports:` を編集：

```yaml
ports:
  - "50004:8787"   # ← 50003 から変更例
  - "82:3838"      # ← 81 から変更例
```

変更後に `docker compose up -d` で再起動。

### ❌ ブラウザで開けない

```powershell
# コンテナの状態
docker ps

# healthy になっているか
docker inspect --format='{{.State.Health.Status}}' myrocker_20260519-rstudio-1
```

`starting` のままなら起動中。1〜2 分待ってもうダメなら：

```powershell
docker compose logs --tail 200
```

でエラー内容を確認。

### ❌ Shiny アプリが 500 / 404 になる

`C:\dockerenv\srv\shinylog\` の中に当該アプリのログがあります。
エラー内容を確認してください。

### ❌ 環境を一旦リセットしたい（データは残す）

```powershell
docker compose down
docker compose up -d
```

### ❌ 完全リセット（ボリュームも消す）

```powershell
docker compose down -v
```

> ⚠️ `-v` を付けると `duckdb-data` ボリュームの中身が消えます。

---

## 6. イメージの更新

オンライン PC で新しい tar ができたら：

### Step 1. 旧コンテナを停止

```powershell
cd C:\dockerenv\myrocker_20260519
docker compose down
```

### Step 2. 新しい tar を読み込み

```powershell
docker load -i myrocker_20260519_new.tar
```

### Step 3. （タグが新しくなった場合）docker-compose.yml の image タグを更新

```yaml
image: nujabec/myrocker:20260601   # 新しいタグに変更
```

### Step 4. 起動

```powershell
docker compose up -d
```

### Step 5. 古いイメージを削除（ディスク節約）

```powershell
docker images | findstr myrocker
docker rmi nujabec/myrocker:20260519   # 古いタグを指定
```

---

## 7. オフライン環境での制限事項

以下は **インターネット接続が必要なため、オフラインでは動作しません**。
存在しても害はありませんが、機能としては使えないと考えてください。

- Claude Code CLI（Anthropic API への接続必要）
- Gemini CLI（Google API への接続必要）
- GitHub CLI（GitHub への接続必要）
- `install.packages()` での新規 R パッケージ追加（CRAN/PPM への接続必要）

→ 新しい R パッケージが必要になったら、**オンライン PC でビルドし直して
tar を作り直す**運用になります。

---

## 8. 困ったときの連絡先

メンテナンス担当：（運用に合わせて記載）
