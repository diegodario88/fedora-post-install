#! /bin/bash

# This script is meant to be run after the installation of the Fedora Workstation
# It will install some packages and configure some settings

# First, optimize the dnf package manager
sudo cp dnf.conf /etc/dnf/dnf.conf

# Ensure the system is up to date
sudo dnf upgrade --refresh
sudo dnf autoremove -y

# Install RPM Fusion (free & non-free) repositories
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# Enable Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install multimedia codecs
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel -y
sudo dnf install lame\* --exclude=lame-devel -y
sudo dnf group upgrade --with-optional Multimedia

# Change host name
sudo hostnamectl set-hostname "Suindara"

# Install Brave Browser
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ -y
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc -y
sudo dnf install brave-browser -y

# cht
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh
cp -r .zsh.d ~/

#Install Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo -y
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose -y
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

#Install some packages
sudo dnf copr enable atim/gping -y && sudo dnf install gping -y
sudo dnf install -y tmux zsh libgtop2-devel lm_sensors grc solaar lsd fd-find procs gnome-tweaks gnome-extensions-app expect editorconfig wl-clipboard @virtualization btop lazygit ffmpeg youtube-dl libstdc++-12.2.1-2.fc37.i686 compat-libstdc libpam.so.0 git-delta autojump-zsh bat fzf micro rust cargo cmatrix

# ZSH plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

# Fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
unzip JetBrainsMono.zip
sudo cp -r JetBrainsMono-*/*.ttf /usr/share/fonts/jetbrains
rm -rf JetBrainsMono.zip JetBrainsMono-*/

sudo cp fonts/* ~/.local/share/fonts/


# SNX VPN
sudo dnf install -y libstdc++.i686 libX11.i686 libpamtest.i686 libnsl.i686
sudo dnf install -y snx/compat-libstdc++-33-3.2.3-72.el7.i686.rpm
./snx/snx_install_linux30.sh

# VSCODE
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install code -y

# GPT
pip install shell-gpt --upgrade --no-cache

# Gnome extensions
gnome-extensions install weatheroclock@CleoMenezesJr.github.io Vitals@CoreCoding.com snx-vpn-indicator@diegodario88.github.io gestureImprovements@gestures ddterm@amezin.github.com

# Keyd
folder_path="~/repos/keyd"
mkdir -p "$folder_path"
git clone https://github.com/rvaiya/keyd "$folder_path"
cd "$folder_path"
echo "$PWD"
make && sudo make install -y
sudo systemctl enable keyd
cd ..
echo "$PWD"

# Dotfiles
git clone https://github.com/diegodario88/dotfiles
cd dotfiles
echo "$PWD"
cp -r micro ~/.config/
sudo cp -r /etc/ keyd
cp -r .zshrc .zsh_history .tmux.conf .gitconfig .git-credentials .ssh .gnupg ~/
cp -r DBeaverData ~/.local/share/

# Linking
ln -nfs .gitconfig ~/.gitconfig
ln -nfs .zshrc ~/.zshrc
ln -nfs .tmux.conf ~/.tmux.conf
ln -nfs micro/bindings.json ~/.config/micro/bindings.json
sudo ln -nfs keyd/default.conf /etc/keyd/default.conf

# Node NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
source ~/.zshrc
nvm install --lts
nvm use --lts

echo "Done! reboot your system"