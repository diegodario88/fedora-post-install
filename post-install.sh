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
com.github.tchx84.Flatseal com.usebottles.bottles de.haeckerfelix.Shortwave io.bassi.Amberol io.dbeaver.DBeaverCommunity \
org.gnome.World.PikaBackup org.gnome.gitlab.somas.Apostrophe org.videolan.VLC

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

# Install Rust without user input
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

# Gnome extensions and Gnome Settings
echo "Installing Gnome extensions..."
pip3 install --user gnome-extensions-cli
gnome-extensions-cli install weatheroclock@CleoMenezesJr.github.io
gnome-extensions-cli install Vitals@CoreCoding.com
gnome-extensions-cli install snx-vpn-indicator@diegodario88.github.io
gnome-extensions-cli install gestureImprovements@gestures
gnome-extensions-cli install ddterm@amezin.github.com

gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm background-color 'rgb(23,20,33)'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm audible-bell false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm background-opacity 1.0
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm command 'custom-command'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm cursor-shape 'block'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm custom-command 'tmux'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm custom-font 'JetBrainsMono Nerd Font 11'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm ddterm-toggle-hotkey "['<Super>Return']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm delete-binding 'auto'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm foreground-color 'rgb(208,207,204)'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm hide-animation 'linear'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm hide-when-focus-lost true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm override-window-animation true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm palette "['rgb(23,20,33)', 'rgb(192,28,40)', 'rgb(38,162,105)', 'rgb(162,115,76)', 'rgb(18,72,139)', 'rgb(163,71,186)', 'rgb(42,161,179)', 'rgb(208,207,204)', 'rgb(94,92,100)', 'rgb(246,97,81)', 'rgb(51,209,122)', 'rgb(233,173,12)', 'rgb(42,123,222)', 'rgb(192,97,203)', 'rgb(51,199,222)', 'rgb(255,255,255)']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm panel-icon-type 'none'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm pointer-autohide true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm preserve-working-directory true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm scroll-on-output true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm scrollback-unlimited true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm shortcuts-enabled false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm show-scrollbar false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm tab-policy 'never'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm theme-variant 'dark'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm transparent-background false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm use-system-font false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm use-theme-colors false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm window-maximize true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm window-resizable false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/schemas/ set com.github.amezin.ddterm window-size 1.0


gsettings --schemadir ~/.local/share/gnome-shell/extensions/gestureImprovements@gestures/schemas/ set org.gnome.shell.extensions.gestureImprovements default-overview-gesture-direction false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gestureImprovements@gestures/schemas/ set org.gnome.shell.extensions.gestureImprovements enable-alttab-gesture false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gestureImprovements@gestures/schemas/ set org.gnome.shell.extensions.gestureImprovements enable-forward-back-gesture true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gestureImprovements@gestures/schemas/ set org.gnome.shell.extensions.gestureImprovements forward-back-application-keyboard-shortcuts "{'firefox.desktop': (1, false), 'org.chromium.Chromium.desktop': (1, false), 'org.gnome.gThumb.desktop': (2, false), 'org.gnome.eog.desktop': (3, false), 'org.gnome.Photos.desktop': (3, false), 'shotwell.desktop': (3, false), 'com.spotify.Client.desktop': (4, false), 'code.desktop': (5, false), 'code-insiders.desktop': (5, false), 'org.gnome.Terminal.desktop': (5, false), 'com.gexperts.Tilix.desktop': (5, false), 'org.gnome.TextEditor.desktop': (5, false)}"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gestureImprovements@gestures/schemas/ set org.gnome.shell.extensions.gestureImprovements overview-navifation-states 'GNOME'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gestureImprovements@gestures/schemas/ set org.gnome.shell.extensions.gestureImprovements pinch-4-finger-gesture 'NONE'

gsettings --schemadir ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com/schemas/ set org.gnome.shell.extensions.vitals hide-icons false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com/schemas/ set org.gnome.shell.extensions.vitals hot-sensors "['_processor_usage_', '_memory_usage_', '_network-rx_enp11s0_rx_', '_network-tx_enp11s0_tx_', '__temperature_avg__']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/Vitals@CoreCoding.com/schemas/ set org.gnome.shell.extensions.vitals update-time 3

gsettings set org.gnome.TextEditor auto-indent true
gsettings set org.gnome.TextEditor custom-font 'Noto Sans Hebrew 12'
gsettings set org.gnome.TextEditor discover-settings true
gsettings set org.gnome.TextEditor highlight-current-line false
gsettings set org.gnome.TextEditor indent-style 'tab'
gsettings set org.gnome.TextEditor last-save-directory 'file:///home/dario/Documents'
gsettings set org.gnome.TextEditor restore-session false
gsettings set org.gnome.TextEditor right-margin-position 100
gsettings set org.gnome.TextEditor show-grid true
gsettings set org.gnome.TextEditor show-map true
gsettings set org.gnome.TextEditor show-right-margin true
gsettings set org.gnome.TextEditor spellcheck true
gsettings set org.gnome.TextEditor style-scheme 'Adwaita'
gsettings set org.gnome.TextEditor style-variant 'follow'
gsettings set org.gnome.TextEditor tab-width 4
gsettings set org.gnome.TextEditor use-system-font false
gsettings set org.gnome.TextEditor wrap-text true
gsettings set org.gnome.desktop.background color-shading-type 'solid'
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Dynamic_Wallpapers/Mojave.xml'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/Dynamic_Wallpapers/Mojave.xml'
gsettings set org.gnome.desktop.background primary-color '#3465a4'
gsettings set org.gnome.desktop.background secondary-color '#000000'
gsettings set org.gnome.desktop.interface clock-show-seconds false
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface cursor-size 32
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
gsettings set org.gnome.desktop.interface font-name 'Cantarell 11'
gsettings set org.gnome.desktop.interface toolkit-accessibility false
gsettings set org.gnome.desktop.screensaver color-shading-type 'solid'
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/Dynamic_Wallpapers/Mojave.xml'
gsettings set org.gnome.desktop.screensaver primary-color '#3465a4'
gsettings set org.gnome.desktop.screensaver secondary-color '#000000'
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left []
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right []
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 []
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-last []
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super>Home']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>End']"
gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super>c']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute "['<Super>m']"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'suspend'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command '/bin/systemctl suspend'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Control><Alt>BackSpace'
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.shell disabled-extensions "['background-logo@fedorahosted.org']"
gsettings set org.gnome.shell enabled-extensions "['ddterm@amezin.github.com', 'snx-vpn-indicator@diegodario88.github.io', 'Vitals@CoreCoding.com', 'gestureImprovements@gestures', 'weatheroclock@CleoMenezesJr.github.io']"
gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop']"
gsettings set org.gnome.shell.app-switcher current-workspace-only true
gsettings set org.gnome.shell.keybindings focus-active-notification []
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>n']"
gsettings set org.gnome.GWeather4 temperature-unit 'centigrade'
gsettings set org.gnome.Weather locations "[<(uint32 2, <('Maringá', 'SBMG', true, [(-0.40869793899310303, -0.9066985464110543)], [(-0.40869793899310303, -0.90611677581148686)])>)>]"
gsettings set org.gnome.calendar active-view 'month'
gsettings set org.gnome.calendar window-maximized false
gsettings set org.gnome.calendar window-size "(1242, 851)"
gsettings set org.gtk.Settings.FileChooser date-format 'regular'
gsettings set org.gtk.Settings.FileChooser location-mode 'path-bar'
gsettings set org.gtk.Settings.FileChooser show-hidden false
gsettings set org.gtk.Settings.FileChooser show-size-column true
gsettings set org.gtk.Settings.FileChooser show-type-column true
gsettings set org.gtk.Settings.FileChooser sidebar-width 286
gsettings set org.gtk.Settings.FileChooser sort-column 'modified'
gsettings set org.gtk.Settings.FileChooser sort-directories-first false
gsettings set org.gtk.Settings.FileChooser sort-order 'descending'
gsettings set org.gtk.Settings.FileChooser type-format 'category'
gsettings set org.gtk.Settings.FileChooser window-position "(26, 23)"
gsettings set org.gtk.Settings.FileChooser window-size "(1231, 902)"
gsettings set org.gnome.software download-updates false
gsettings set org.gnome.software download-updates-notify false
gsettings set org.gnome.software first-run false
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
gsettings set org.gnome.nautilus.preferences migrated-gtk-settings true
gsettings set org.gnome.nautilus.preferences search-filter-time-type 'last_modified'
gsettings set org.gnome.nautilus.preferences search-view 'list-view'



# Disable extensions 
gnome-extensions disable background-logo@fedorahosted.org

# Keyd
echo "Installing Keyd..."
folder_path="$HOME/repos/keyd"
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
ls
cp -r micro ~/.config/
sudo cp -r /etc/ keyd
cp -r .snxrc .zshrc .zsh_history .tmux.conf .gitconfig .git-credentials .ssh .gnupg ~/
cp -r DBeaverData ~/.local/share/
cp  monitors.xml ~/.config/
sudo cp monitors.xml /var/lib/gdm/.config/

# Node NVM
echo "Installing Node NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

echo "Done! reboot your system"