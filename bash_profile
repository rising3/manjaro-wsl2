grn=$(tput setaf 2)
red=$(tput setaf 1)
ylw=$(tput setaf 3)
rst=$(tput sgr0)

echo -e ${grn}"Initializing and populating keyring..."${rst}
pacman-mirrors --fasttrack > /dev/null 2>&1
pacman-key --init > /dev/null 2>&1
pacman-key --populate > /dev/null 2>&1
pacman --noconfirm -Syyu > /dev/null 2>&1

echo -e ${grn}"Creating default user..."${rst}
while read -p "Plase enter the username : " username; do
    if [ -z "${username}" ]; then
        echo -e ${red}"Blank username entered. Try again!!"${rst}
        username=""
    elif grep -q "${username}" /etc/passwd; then
        echo -e ${red}"Username already exists. Try again!!"${rst}
        username=""
    else
        useradd -m -u 1000 -U -G users,wheel -s /bin/bash "${username}"
        echo "%wheel ALL=(ALL) ALL" >/etc/sudoers.d/wheel
        passwd ${username}
        sed -i "/\[user\]/a default = ${username}" /etc/wsl.conf >/dev/null
        break;
    fi
done

echo "@echo off" | sudo tee -a ~/shutdown.cmd >/dev/null 2>&1
echo "wsl.exe --terminate $WSL_DISTRO_NAME" | sudo tee -a ~/shutdown.cmd >/dev/null 2>&1
if env | grep "WT_SESSION" >/dev/null 2>&1; then
    echo "wt.exe -w 0 nt wsl.exe -d $WSL_DISTRO_NAME" | sudo tee -a ~/shutdown.cmd >/dev/null 2>&1
else
    echo "cmd /c start \"$WSL_DISTRO_NAME\" wsl.exe --cd ~ -d $WSL_DISTRO_NAME" | sudo tee -a ~/shutdown.cmd >/dev/null 2>&1
fi
echo "del C:\Users\Public\shutdown.cmd" | sudo tee -a ~/shutdown.cmd >/dev/null 2>&1
cp ~/shutdown.cmd /mnt/c/Users/Public && rm ~/shutdown.cmd

secs=3
printf ${ylw}"\nManjaroWSL2 will shutdown and restart to setup systemd!!!\n\n"${rst}
while [ $secs -gt 0 ]; do
    printf "\r\033[KShutting down in %.d seconds. " $((secs--))
    sleep 1
done

rm ~/.bash_profile
powershell.exe -command "Start-Process -Verb Open -FilePath 'shutdown.cmd' -WorkingDirectory 'C:\Users\Public' -WindowStyle Hidden"
exec sleep 0
