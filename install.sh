#!/bin/bash
############################
# Updated: 18 December 2022
############################

######## Variables and Arrays ######## 

reset="\e[0m"
red_bold="\e[1;31m"
green_bold="\e[1;32m"
yellow_bold="\e[1;33m"
blue_bold="\e[1;34m"
purple_bold="\e[1;35m"
cyan_bold="\e[1;36m"
white_bold="\e[1;37m"
reset_bold="\e[1m"

pacman=()
paru=()

readarray -t pacman < pacman.lst
readarray -t paru < aur.lst

SUCKLESS=(st dwm dmenu slstatus slock)

######## Installation script ######## 

cd $HOME

echo " "
echo -e "${green_bold}===> ${cyan_bold}Installing Lady's Arch Linux build ${green_bold}<=== ${reset}"
echo " "


echo -e "${green_bold}===> ${cyan_bold}Installing Paru...${reset}"
mkdir -p .config
cd $HOME/.config
sudo pacman -S --needed base-devel    
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd $HOME


echo -e "${green_bold}===> ${cyan_bold}Installing packages from core, extra, and community...${reset}" 
sudo pacman -S "${pacman[@]}" 


echo -e "${green_bold}===> ${cyan_bold}Installing packages from AUR...${reset}" 
paru -S "${paru[@]}"


echo -e "${green_bold}===> ${cyan_bold}Pulling dotfiles from Github...${reset}"
git clone https://github.com/ladybouy/.dotfiles.git


echo -e "${green_bold}===> ${cyan_bold}Making symbolic links from dotfiles folder...${reset}"
rm .bashrc .Xresouces .xprofile .xinitrc
cd .dotfiles
stow */

echo -e "${green_bold}==> ${cyan_bold}Installing system scripts ...${reset}"
sudo cp $HOME/.scripts/shell/system/volume.sh                     /usr/bin/
sudo cp $HOME/.scripts/shell/system/audio-setup                   /usr/bin/
sudo cp $HOME/.scripts/shell/system/internet                      /usr/bin/
sudo cp $HOME/.scripts/shell/system/hotplug_monitor.sh            /usr/local/bin/
sudo cp $HOME/.scripts/shell/notes                                /usr/bin/
sudo cp $HOME/.scripts/shell/mpdstatus                            /usr/bin/
sudo cp $HOME/.scripts/shell/system/udev/rules.d/                 /etc/udev/
sudo cp $HOME/.scripts/shell/system/rofi-power-menu/              /usr/bin/
sudo cp $HOME/.scripts/shell/system/lightdm.conf                  /etc/lightdm/ 
sudo cp $HOME/.scripts/shell/system/lightdm-gtk-greeter.conf      /etc/lightdm/ 

# TODO  lightdm settings

echo -e "${green_bold}==> ${cyan_bold}Compiling Suckless software...${reset}"
for FOLDER in ${SUCKLESS[*]}; do
    cd $HOME/.config/suckless/${FOLDER}
    sudo make install
    make clean
done

cd $HOME/.config/sxiv
sudo make install && make clean

cd $HOME/.config/xmenu
sudo make install
sudo mv xmenu /usr/local/bin
sudo mv xmenu.sh /usr/local/bin

cd $HOME

echo -e "${green_bold}==> ${cyan_bold}Changing shell to zsh...${reset}"
sudo chsh -s /usr/bin/zsh

echo -e "${green_bold}==> ${cyan_bold}Enabling systemd services...${reset}"
sudo cp $HOME/.scripts/shell/system/systemd/system/* /etc/systemd/system
sudo systemctl enable plymouth.service && systemctl --user start plymouth.service
sudo systemctl enable NetworkManager && systemctl --user start NetworkManager.service
sudo systemctl enable bluetooth && systemctl --user start bluetooth.service
sudo systemctl enable cups && systemctl --user start cups.service
sudo systemctl enable lightdm && systemctl --user start lightdm.service
sudo systemctl enable audio-setup.service && systemctl --user start audio-setup.service
sudo systemctl enable lock.service && systemctl --user start lock.service
sudo systemctl --user enable mpd.service && systemctl --user start mpd.service
sudo systemctl enable rtirq
mpd
mpc update


echo -e "${green_bold}==> ${cyan_bold}Setting up audio production settings...${reset}"
sudo groups add audio
sudo groups add realtime
sudo usermod -a -G audio $USER
sudo usermod -a -G realtime $USER

sudo echo "@realtime -rtprio 99" >> /etc/security/limits.d/99-realtime-privileges.conf
sudo echo "@realtime - memlock unlimited" >> /etc/security/limits.d/99-realtime-privileges.conf
sudo echo "@realtime - nice -11" >> /etc/security/limits.d/99-realtime-privileges.conf

sudo echo "@audio - rtprio 99" > /etc/security/limits.d/audio.conf
sudo echo "@audio - memlock unlimited" >> /etc/security/limits.d/audio.conf

echo "vm.swappiness = 10" > /etc/sysctl.d/90-swappiness.conf
echo "fs.inotify.max_user_watches = 600000" > /etc/sysctl.d/90-max_user_watches.conf
