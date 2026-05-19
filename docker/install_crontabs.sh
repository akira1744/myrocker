#!/usr/bin/with-contenv bash
# /etc/cont-init.d/03_install_crontabs
#
# 起動時に host bind-mount された crontab ファイルを cron spool に展開する。
# パターン: /home/rstudio/srv/crontabs/<user> (file) → /var/spool/cron/crontabs/<user>
# OS user が存在しなければスキップ。perms は cron 要求どおり root:crontab 600。

set -u

SRC_DIR="/home/rstudio/srv/crontabs"
DST_DIR="/var/spool/cron/crontabs"

if [ ! -d "$SRC_DIR" ]; then
    echo "[install_crontabs] $SRC_DIR が存在しないためスキップ"
    exit 0
fi

mkdir -p "$DST_DIR"
chmod 1730 "$DST_DIR"
chown root:crontab "$DST_DIR"

shopt -s nullglob
for src in "$SRC_DIR"/*; do
    [ -f "$src" ] || continue
    user="$(basename "$src")"

    if ! id -u "$user" >/dev/null 2>&1; then
        continue
    fi

    cp "$src" "$DST_DIR/$user"
    chown "root:crontab" "$DST_DIR/$user"
    chmod 600 "$DST_DIR/$user"
    echo "[install_crontabs] installed crontab for $user from $src"
done
