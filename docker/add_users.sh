#!/bin/bash

for USER in "$@"
do
    useradd -m -s /bin/bash -g rstudio -G sudo ${USER}
    echo ${USER}:${USER} | chpasswd
    ln -s /home/rstudio/srv /home/${USER}/srv
    echo "umask 000" >> /home/${USER}/.bashrc
    mkdir -p /home/${USER}/.config/rstudio
    cp /home/rstudio/.config/rstudio/rstudio-prefs.json /home/${USER}/.config/rstudio/rstudio-prefs.json
    chown ${USER}:rstudio /home/${USER}/.config/rstudio/rstudio-prefs.json
    cp /home/rstudio/.Rprofile /home/${USER}/.Rprofile
    chown ${USER}:rstudio /home/${USER}/.Rprofile
done