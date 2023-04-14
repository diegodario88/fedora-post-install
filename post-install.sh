#! /bin/bash

# This script is meant to be run after the installation of the Fedora Workstation
# It will install some packages and configure some settings

echo "Starting post-installation script..."
# First, optimize the dnf package manager
echo "Optimizing the package manager..."
sudo cp dnf.conf /etc/dnf/dnf.conf

# Ensure the system is up to date
echo "Updating the system..."
sudo dnf upgrade -y --refresh

# Install RPM Fusion (free & non-free) repositories
echo "Installing RPM Fusion repositories..."
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# Enable Flathub repository and install some softwares
echo "Installing flatpak softwares..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub -y  com.getpostman.Postman com.github.huluti.Curtail com.github.micahflee.torbrowser-launcher \
com.github.tchx84.Flatseal com.stremio.Stremio com.usebottles.bottles de.haeckerfelix.Shortwave \
io.bassi.Amberol io.dbeaver.DBeaverCommunity  org.gnome.World.PikaBackup org.gnome.gitlab.somas.Apostrophe org.videolan.VLC

# Install multimedia codecs
echo "Installing multimedia codecs..."
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia

# Change host name
echo "Changing hostname..."
sudo hostnamectl set-hostname "Suindara"

# Install Brave Browser
echo "Installing Brave Browser..."
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ 
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

# cht
echo "Installing cht..."
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh
cp -r .zsh.d ~/

#Install Docker
echo "Installing Docker..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo systemctl start docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

#Install some packages
echo "Installing some packages..."
sudo dnf copr enable atim/lazygit -y && sudo dnf install lazygit -y
sudo dnf copr enable atim/gping -y && sudo dnf install gping -y
sudo dnf install -y python3-pip tmux neofetch zsh libgtop2-devel lm_sensors grc solaar lsd fd-find procs drawing gnome-tweaks gnome-extensions-app gnome-password-generator expect editorconfig wl-clipboard @virtualization btop ffmpeg youtube-dl libpam.so.0 git-delta autojump-zsh bat fzf micro cmatrix

# Tmux plugins
echo "Installing tmux plugins."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# ZSH plugins
echo "Installing ZSH plugins..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search

# Fonts
echo "Installing fonts..."
mkdir jetbrains
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip
unzip JetBrainsMono.zip -d jetbrains 
sudo mv jetbrains /usr/share/fonts/
rm -rf JetBrainsMono.zip
# Local fonts for vscode integrated terminal
sudo cp fonts/* /usr/share/fonts/
sudo fc-cache -f

# SNX VPN
echo "Installing SNX VPN..."
sudo dnf install -y libstdc++.i686 libX11.i686 libpamtest.i686 libnsl.i686
sudo dnf install -y snx/compat-libstdc++-33-3.2.3-72.el7.i686.rpm
sudo sh -c snx/snx_install_linux30.sh

# VSCODE
echo "Installing VSCODE..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install code -y

# GPT
echo "Installing GPT..."
pip install shell-gpt --upgrade --no-cache

# Dynamic wallpapers
echo "Installing Dynamic wallpapers..."
curl -s "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/main/Easy_Install.sh" | sudo bash

# Gnome extensions
echo "Installing Gnome extensions..."
gnome-extensions install weatheroclock@CleoMenezesJr.github.io Vitals@CoreCoding.com snx-vpn-indicator@diegodario88.github.io gestureImprovements@gestures ddterm@amezin.github.com

# Keyd
echo "Installing Keyd..."
folder_path="~/repos/keyd"
mkdir -p "$folder_path"
git clone https://github.com/rvaiya/keyd "$folder_path"
cd "$folder_path"
echo "$PWD"
make && sudo make install
sudo systemctl enable keyd
cd ..
echo "$PWD"

# Dotfiles
echo "Managing Dotfiles..."
git clone https://github.com/diegodario88/dotfiles
cd dotfiles
echo "$PWD"
cp -r micro ~/.config/
sudo cp -r /etc/ keyd
cp -r .snxrc .zshrc .zsh_history .tmux.conf .gitconfig .git-credentials .ssh .gnupg ~/
cp -r DBeaverData ~/.local/share/
cp  monitors.xml ~/.config/monitors.xml
sudo monitors.xml /var/lib/gdm/.config/
dconf load / < dconf-backup.ini

# Linking
echo "Linking..."
ln -nfs .gitconfig ~/.gitconfig
ln -nfs .zshrc ~/.zshrc
ln -nfs .tmux.conf ~/.tmux.conf
ln -nfs micro/bindings.json ~/.config/micro/bindings.json
sudo ln -nfs keyd/default.conf /etc/keyd/default.conf

# Node NVM
echo "Installing Node NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
source ~/.zshrc
nvm install --lts
nvm use --lts

echo "Done! reboot your system"