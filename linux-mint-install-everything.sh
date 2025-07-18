#!/bin/bash

# =========== CONFIG =============
# Assuming we'll set the Google Drive folder to ~/GoogleDrive
GOOGLE_DRIVE_FOLDER=$HOME/GoogleDrive
# ================================


# =========== ESSENTIAL ALIASES ==========
INSTALL='sudo apt install --yes'
UNINSTALL='sudo apt remove --yes'
SYNC='rsync -IPavz'
IMPORTABLE_SETTINGS_FOLDER="$GOOGLE_DRIVE_FOLDER/Reference/Importable Software Settings"
CURRENT_DIR=`pwd`

function install_deb_from_url {
    # Parameters: <url>
    local deb_filename=$(mktemp /tmp/XXXXXX.deb)
    wget -O $deb_filename $1
    sudo dpkg -i $deb_filename
    rm $deb_filename
}

function install_tarball_from_url {
    # Parameters: <name> <url>
    local tarball_filename=$(mktemp /tmp/XXXXXX.tar.gz)
    local install_dir=/opt/$1
    wget -O $tarball_filename $2
    sudo mkdir -p $install_dir
    sudo chown -R $(whoami):$(whoami) $install_dir
    tar xzvf $tarball_filename --strip 1 --directory $install_dir
    rm $tarball_filename
}
# ========================================


# ----- Prepare Package Manager -----
$INSTALL apt-transport-https ca-certificates gnupg
sudo mkdir -p /etc/apt/keyrings/

# For latest NVIDIA drivers
sudo add-apt-repository --yes ppa:graphics-drivers/ppa

# For latest Git
sudo add-apt-repository --yes ppa:git-core/ppa

# For Google Chrome
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/google.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-temp.list > /dev/null

# For Docker
wget -qO - https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# For Gradle
sudo add-apt-repository --yes ppa:cwchien/gradle

# For Mono
sudo gpg --homedir /tmp --no-default-keyring --keyring /etc/apt/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

# For Double Commander
wget -qO - https://download.opensuse.org/repositories/home:Alexx2000/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/doublecmd.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/doublecmd.gpg] https://download.opensuse.org/repositories/home:/Alexx2000/xUbuntu_22.04/ /" | sudo tee /etc/apt/sources.list.d/doublecmd.list > /dev/null

# For Spotify
wget -qO - https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/spotify.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null

# For Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/sublimehq-pub.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null

# For Pinta
sudo gpg --homedir /tmp --no-default-keyring --keyring /etc/apt/keyrings/pinta.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 45EAD2AF3C2BB95F11E609A1BC3E0682A5A1D6B2
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/pinta.gpg] http://ppa.launchpad.net/pinta-maintainers/pinta-daily/ubuntu jammy main" | sudo tee /etc/apt/sources.list.d/pinta.list > /dev/null

# For Insync
sudo gpg --homedir /tmp --no-default-keyring --keyring /etc/apt/keyrings/insync.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ACCAF35C
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/insync.gpg] http://apt.insync.io/mint vera non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list > /dev/null

# For qBitTorrent
sudo add-apt-repository --yes ppa:qbittorrent-team/qbittorrent-stable

# For VirtualBox
wget -qO - https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/virtualbox.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian jammy contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list > /dev/null

# For 1Password
wget -qO - https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/1password.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/1password.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list > /dev/null
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
wget -qO - https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
wget -qO - https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor | sudo tee /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg > /dev/null

# For Grub Customizer
sudo add-apt-repository --yes ppa:danielrichter2007/grub-customizer


# Done adding sources at this point.
sudo apt update


# ----- Browsers -----
$INSTALL google-chrome-stable
# When Chrome is installed, a new source is added automatically which causes a duplicate apt entry.
# We'll remove the one we added manually.
sudo rm -rf /etc/apt/sources.list.d/google-temp.list

# ----- Install Insync (Google Drive client) to pull all importable settings -----
$INSTALL insync
echo
echo "----- Now, please launch the Insync app and set it up. -----"
echo "Assuming the Google Drive folder will be set to: $GOOGLE_DRIVE_FOLDER"
echo
read -p "Press [Enter] once Insync has finished syncing your files..."

# ----- Bash profile -----
cp -Rf "$IMPORTABLE_SETTINGS_FOLDER/Linux/Mint/.bashrc" "$HOME"

# ----- Custom fonts -----
USER_FONTS_FOLDER=$HOME/.fonts
$INSTALL fontconfig
$INSTALL fonts-noto

if [ ! -d "$USER_FONTS_FOLDER" ]; then
  mkdir "$USER_FONTS_FOLDER"
fi

$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Fonts/Windows" "$USER_FONTS_FOLDER"
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Fonts/Presentation" "$USER_FONTS_FOLDER"
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Fonts/Developer" "$USER_FONTS_FOLDER"
fc-cache -fv "$USER_FONTS_FOLDER"

# ----- Editors, protocol clients, terminal programs
$INSTALL curl wget axel httpie qbittorrent filezilla w3m mc terminator
$INSTALL vim gedit sublime-text
$INSTALL remmina remmina-plugin-rdp
$INSTALL p7zip-full
$INSTALL tree tldr ack-grep icu-devtools lnav

# ----- System Utils -----
$INSTALL hardinfo htop iftop mtr-tiny glances sysstat dstat ncdu xclip gparted grub-customizer

# ----- Double Commander + Settings -----
$INSTALL doublecmd-gtk
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Linux/Mint/.config/doublecmd/" "$HOME/.config/doublecmd/"

# ----- Gnome configs -----
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Linux/Mint/.config/initial/" "$HOME/.config/initial/"
dconf dump / > ~/.config/initial/root.dconf.bak
dconf load / < ~/.config/initial/root.dconf

# ----- SSH config -----
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/SSH/" "$HOME/.ssh/"

# ----- Development Tools -----
# Python
$INSTALL python3 idle3 pypy python3-pip python3-dev pypy-dev python3-virtualenv python3-virtualenvwrapper python3-venv

# Visual Studio Code
install_deb_from_url https://go.microsoft.com/fwlink/?LinkID=760868

# Beyond Compare
install_deb_from_url https://www.scootersoftware.com/bcompare-4.3.7.25118_amd64.deb

# Mono
$INSTALL mono-devel mono-complete

$INSTALL git subversion gitg meld cloc awscli
$INSTALL g++ clang gfortran cmake
$INSTALL maven
$INSTALL ruby ruby-dev php
$INSTALL apparmor
$INSTALL jq

# Node.js
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

# R
$INSTALL r-base r-base-dev

# RStudio
$INSTALL libjpeg62 libclang-dev libssl-dev libpq5
install_deb_from_url https://download1.rstudio.org/electron/jammy/amd64/rstudio-2023.03.0-386-amd64.deb
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/RStudio/" "$HOME/.rstudio-desktop/"

# Gradle
$INSTALL gradle
echo 'GRADLE_HOME=/usr/lib/gradle/default' | sudo tee -a /etc/environment

# Ansible
$INSTALL ansible

# Docker
$INSTALL docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker `whoami`
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOT
{
  "storage-driver": "overlay2"
}
EOT

# Wireshark
$INSTALL wireshark
sudo groupadd wireshark
sudo usermod -a -G wireshark `whoami`
sudo chgrp wireshark /usr/bin/dumpcap
sudo chmod 750 /usr/bin/dumpcap
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
sudo getcap /usr/bin/dumpcap

# Postman
install_tarball_from_url postman https://dl.pstmn.io/download/latest/linux64
sudo desktop-file-install "$IMPORTABLE_SETTINGS_FOLDER/Linux/Desktop Files/Postman.desktop"

# Studio 3T
wget -O studio-3t.tar.gz https://download.studio3t.com/studio-3t/linux/2023.4.1/studio-3t-linux-x64.tar.gz
tar xzvf studio-3t.tar.gz
bash studio-3t-linux-x64.sh
rm -rf studio-3t.tar.gz

# Other settings
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Linux/Mint/" "$HOME/"
chmod +x ~/.bash-git-prompt/*.sh && cd ~/.bash-git-prompt && git undo . && cd -

# JetBrains Toolbox
install_tarball_from_url jetbrains-toolbox https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.28.1.15219.tar.gz

# ----- Anaconda -----
ANACONDA_PACKAGE=Anaconda3-2023.03-1-Linux-x86_64.sh

cd /tmp
ANACONDA_HOME=$HOME/anaconda3
wget https://repo.anaconda.com/archive/$ANACONDA_PACKAGE
bash $ANACONDA_PACKAGE -b -p $ANACONDA_HOME

cd $CURRENT_DIR
export PATH=$ANACONDA_HOME/bin:$PATH
conda install -y virtualenv joblib numpy nltk scikit-learn jupyter ipykernel matplotlib pyqt libgcc

# IPython and Jupyter
ipython profile create
jupyter notebook --generate-config

$SYNC "$IMPORTABLE_SETTINGS_FOLDER/IPython/profile_default/" ~/.ipython/profile_default/
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/Jupyter/jupyter_notebook_config.py" ~/.jupyter/


# ----- Redshift + Settings -----
$INSTALL redshift redshift-gtk
cp -Rf "$IMPORTABLE_SETTINGS_FOLDER/Linux/Mint/.config/redshift.conf" "$HOME/.config/redshift.conf"


# ----- SSH Server -----
$INSTALL openssh-server
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
sudo chmod a-w /etc/ssh/sshd_config.factory-defaults
# sudo nano /etc/ssh/sshd_config


# ----- VPN -----
$INSTALL network-manager-openvpn network-manager-openvpn-gnome
#$INSTALL l2tp-ipsec-vpn


# ----- Virtualization ------
$INSTALL dosbox
$INSTALL dkms build-essential linux-headers-`uname -r`
$INSTALL virtualbox-7.0
$INSTALL virtualbox-ext-pack


# ----- Multimedia & Misc Utils -----
$INSTALL gthumb
$INSTALL ffmpeg handbrake mkvtoolnix mkvtoolnix-gui
$INSTALL rhythmbox vlc smplayer audacity spotify-client
$INSTALL inkscape pinta
$INSTALL xfburn
$INSTALL 1password
$INSTALL steam

# VeraCrypt
install_deb_from_url https://launchpad.net/veracrypt/trunk/1.25.9/+download/veracrypt-1.25.9-Ubuntu-22.04-amd64.deb

# ----- ZSH -----
$INSTALL zsh

# Prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Prepare Prezto initialization script in an environment variable, then execute it in zsh.
read -r -d '' ZSH_PREZTO_SETUP_COMMAND <<'EOF'
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
EOF
zsh -i -c "$ZSH_PREZTO_SETUP_COMMAND"

# Import configs
$SYNC "$IMPORTABLE_SETTINGS_FOLDER/zsh/.zprezto/runcoms/" "$HOME/.zprezto/runcoms/"


# =========== Finalization ============
# Update DB for 'locate'
sudo updatedb

sudo apt update
cd "$CURRENT_DIR"
# ===================================



# =========== MANUAL STEPS ============
# ----- System Clock -----
# Set RTC to local time (useful for Windows + Linux multiboot systems)
# sudo timedatectl set-local-rtc 1 --adjust-system-clock

# ----- SSD -----
# sudo nano /etc/fstab        # Add ",noatime" option to all non-swap partitions

# ----- Swap usage -----
# A) Disable swap
# sudo swapoff /swapfile
# sudo nano /etc/fstab        # Comment out the line starting with "/swapfile"
# sudo rm -rf /swapfile
# 
# B) OR, decrease it to a more reasonable level
# Add this line to /etc/sysctl.conf
# vm.swappiness=5

# ----- Disable apache2 from autostart -----
# sudo systemctl disable apache2
# sudo service apache2 stop

# ----- Increase file limit -----
# 1. Add this line to /etc/pam.d/common-session:
# session required pam_limits.so
# 2. Add these lines to /etc/security/limits.conf:
# *               soft    nofile          65535
# *               hard    nofile          65535

# ----- Change shell to zsh -----
# chsh -s $(which zsh)

# ----- Bluetooth keyboard/mouse (multiboot) -----
# 1. sudo service bluetooth stop
# 2. Import configs to /var/lib/bluetooth
# 3. sudo service bluetooth start
# 4. If they don't work right away, run:
#    sudo bluetoothctl
#    > power off
#    > power on
#    > devices
#    > connect <DeviceMAC>

# Set account picture
# Set Login window
# Customize fonts in Google Chrome (Monospace -> Consolas)
# Customize panel appearance and applets (Bluetooth, Network, Date/Time, etc.)
# Power settings: hibernation, sleep, screensaver, locking window
# Customize Firefox: search engine, bookmarks 
