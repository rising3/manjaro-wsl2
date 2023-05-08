FROM manjarolinux/base:latest

RUN pacman-mirrors --fasttrack 5; pacman-key --init; pacman-key --populate \
  && sed -ibak -e 's/#Color/Color/g' -e 's/CheckSpace/#CheckSpace/g' /etc/pacman.conf; sed -ibak -e 's/IgnorePkg/#IgnorePkg/g' /etc/pacman.conf \
  && sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf; sed -i '/\[multilib\]/ { n; s/#Include/Include/; }' /etc/pacman.conf \
  && grep -q builder /etc/passwd && userdel -r builder \
  && pacman --noconfirm -Syyu \
  && pacman -Sy --noconfirm --needed aria2 aspell base base-devel bc ccache curl dos2unix figlet git grep hspell hunspell hwdata inetutils iputils iproute2 keychain libxcrypt-compat libvoikko linux-tools lolcat nano ntp nuspell procps socat sudo usbutils vi vim wget xdg-utils xmlto yay yelp-tools \
  && mkdir -p /etc/pacman.d/hooks; echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
  && sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
  && locale-gen; systemd-machine-id-setup; rm /var/lib/dbus/machine-id; dbus-uuidgen --ensure=/etc/machine-id; dbus-uuidgen --ensure \
  && LC_ALL=en_US.UTF-8 pacman -Scc \
  # install wslutilities
  && wget https://pkg.wslutiliti.es/public.key > /dev/null 2>&1 && pacman-key --add public.key && pacman-key --lsign-key 2D4C887EB08424F157151C493DD50AA7E055D853 && rm public.key \
  && echo '[wslutilities]' | sudo tee -a /etc/pacman.conf > /dev/null 2>&1; echo 'Server = https://pkg.wslutiliti.es/arch/' | sudo tee -a /etc/pacman.conf > /dev/null 2>&1 \
  && pacman -Sy --noconfirm wslu \
  && echo 'export BROWSER="wslview"' | sudo tee -a /etc/skel/.bashrc > /dev/null 2>&1
