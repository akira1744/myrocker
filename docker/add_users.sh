#!/bin/bash

# for USER in "$@" で引数として与えられたユーザー名のリストをループします。"$@" はシェルスクリプトの引数全体を表します
for USER in "$@"
do
    # useradd -m -s /bin/bash -g rstudio -G sudo ${USER} で新しいユーザーを作成します。オプションは以下の通りです：
    # -m : ユーザーのホームディレクトリを作成します。
    # -s /bin/bash : ユーザーのログインシェルを /bin/bash に設定します。
    # -g rstudio : ユーザーの初期グループを rstudio に設定します。
    # -G sudo : ユーザーを sudo グループに追加します。
    useradd -m -s /bin/bash -g rstudio -G sudo ${USER}

    # echo ${USER}:${USER} | chpasswd でユーザーのパスワードを設定します。ここではユーザー名と同じものをパスワードとしています。
    echo ${USER}:${USER} | chpasswd
    
    # ln -s /home/rstudio/srv /home/${USER}/srv で /home/rstudio/srv を /home/${USER}/srv へシンボリックリンクします。
    ln -s /home/rstudio/srv /home/${USER}/srv
    
    # echo "umask 000" >> /home/${USER}/.bashrc でユーザーの .bashrc ファイルに umask 000 を追加します。
    # これにより、新しく作成されるファイルのパーミッションが全ユーザーに対して読み書き可能になります。
    echo "umask 000" >> /home/${USER}/.bashrc
    
    # mkdir -p /home/${USER}/.config/rstudio でユーザーの .config/rstudio ディレクトリを作成します。
    mkdir -p /home/${USER}/.config/rstudio
    
    cp /home/rstudio/.config/rstudio/rstudio-prefs.json /home/${USER}/.config/rstudio/rstudio-prefs.json
    
    # chown ${USER}:rstudio /home/${USER}/.config/rstudio/rstudio-prefs.json で rstudio-prefs.json ファイルの所有者を新しく作成したユーザーに変更します
    chown ${USER}:rstudio /home/${USER}/.config/rstudio/rstudio-prefs.json
    
    cp /home/rstudio/.Rprofile /home/${USER}/.Rprofile
    
    # chown ${USER}:rstudio /home/${USER}/.Rprofile で .Rprofile ファイルの所有者を新しく作成したユーザーに変更します。
    chown ${USER}:rstudio /home/${USER}/.Rprofile
done