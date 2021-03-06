#/bin/bash

# Get sudo permissions for script run
sudo -v

# Update system
sudo apt-get update
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get autoclean

# Install i3 and other packages
sudo apt-get -y install curl compton dunst feh i3 i3lock libjsoncpp1 libmpdclient2 lxappearance rofi git wget unzip xautolock

# Install numix icons
sudo apt-add-repository ppa:numix/ppa -y
sudo apt-get update
sudo apt-get -y install numix-folders numix-icon-theme numix-icon-theme-circle numix-icon-theme-square

# Backup .Xresources
sudo cp ~/.Xresources ~/.Xresources.bak

# Install polybar
sudo apt-get -y install build-essential cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev clang
cd /tmp
git clone --recursive https://github.com/jaagr/polybar
mkdir polybar/build
cd polybar/build
cmake ..
sudo make install
cd ~

# Istall fonts for system
mkdir ~/.fonts
cd /tmp/
wget https://github.com/chrissimpkins/Hack/releases/download/v2.020/Hack-v2_020-ttf.zip
mkdir HackFont
unzip Hack-v2_020-ttf.zip -d HackFont
cd HackFont
cp Hack-Regular.ttf ~/.fonts

cd /tmp/
wget https://github.com/FortAwesome/Font-Awesome/archive/v4.7.0.tar.gz
tar -xzf v4.7.0.tar.gz
cd 'Font-Awesome-4.7.0/fonts'
cp fontawesome-webfont.ttf ~/.fonts

# Reload font cache
fc-cache -f -v

# Download config files from GitHub
cd ~
git clone https://github.com/BurningSmile/dotfiles.git

# Install configs
cd ~/dotfiles/
mkdir ~/.config/polybar/
mv ./polybar/* ~/.config/polybar/
mkdir ~/.config/i3
mv ./i3/config ~/.config/i3/
mv ./i3/scripts ~/.config/i3
mv .Xresources ~
mkdir ~/.config/dunst
mv ./dunst/dunstrc ~/.config/dunst/dunstrc
mkdir ~/.config/rofi
mv ./rofi/* ~/.config/rofi/

# Copy background image
mkdir ~/Pictures/backgrounds
mv ~/dotfiles/i3/Background/firewatch_ARC.jpg ~/Pictures/backgrounds

# Install Vim
sudo apt-get -y install vim-gnome
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cd ~/dotfiles/vim
mkdir ~/.vim/
mv ~/vimrc ~/vimrc.bak # Backup vimrc if present
mv .vimrc ~
cp -r ./.vim/ultisnips ~/.vim/
cd ~

# Install Vim plugins
vim +PlugClean +PlugInstall +PlugUpdate +q! +q!

# Install you-complete-me for vim auto completion.
sudo apt-get -y install cmake clang python python3
mkdir /tmp/ycm_build
cd /tmp/ycm_build
cmake -G "Unix Makefiles" . ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp
cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp
cmake --build . --target ycm_core --config Release
cd ~

# Install powerline
sudo apt-get -y install python-pip powerline fonts-powerline

# Install tmux
sudo apt-get -y install tmux xsel # xsel is for x copy support
cd ~/dotfiles/tmux
mv ~/.tmux.conf ~/.tmux.conf.bak # Backup Tmux.conf if present.
mv .tmux.conf ~
mv ~/dotfiles/tmux/.tmux-ssh.conf ~
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~

# Install Arc theme [This works for 16.10 and debian 9 and newer. For older versions refer to the arc theme documentation.]
sudo apt-get -y install arc-theme

# Install htop
sudo apt-get -y install htop
mv ~/.config/htop/htoprc ~/.config/htop/htoprc.bak # Backup htoprc if present
cd ~/dotfiles/htop
mkdir ~/.config/htop
mv htoprc ~/.config/htop/
cd ~

# Setup Mpd and Mpc
sudo apt-get -y install mpd mpc
mkdir -p ~/.config/mpd/
mkdir -p ~/.mpd/playlists
cd ~/.mpd/
touch database log pid state sticker.sql
mv ~/.config/mpd/mpd.conf ~/.config/mpd/mpd.conf.bak #Backup config if present
mv ~/dotfiles/mpd/mpd.conf ~/.config/mpd/
sudo systemctl disable mpd.service

# Setup ncmpcpp
sudo apt-get -y install ncmpcpp
mkdir ~/.ncmpcpp/
mv ~/.ncmpcpp/config ~/.ncmpcpp/config.bak #Backup config if present
mv ~/dotfiles/ncmpcpp/config ~/.ncmpcpp/
cd ~

# Setup Cava
sudo apt-get -y install libfftw3-dev libasound2-dev libncursesw5-dev libpulse-dev libtool automake autoconf autogen m4
cd /tmp
git clone https://github.com/karlstav/cava.git
cd cava
./autogen.sh
./configure
sudo make install
mkdir ~/.config/cava
mv ~/.config/cava/config ~/.config/cava/config.bak #Backup config if present
mv ~/dotfiles/cava/config ~/.config/cava

# Setup Urxvt
sudo apt-get -y install rxvt-unicode-256color

# Install prezto
sudo apt-get -y install zsh
cat << 'EOF' >> /tmp/prezto-install.sh
#!/usr/bin/zsh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
EOF

chmod +x /tmp/przto-install.sh
/tmp/przto-install.sh
mv ~/dotfiles/zsh/.zshrc ~/.zshrc
mv ~/dotfiles/zsh/zpreztorc ~/.zprezto/runcoms/zpreztorc
chsh -s /bin/zsh

# Cleanup
cd ~
rm -rf dotfiles/
sudo apt-get -y autoremove
