#!/bin/bash

# Colors
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Ask about SWAP and set it up
echo "Do you wish to setup a SWAP file?"
echo -n "y/N: "
read -r _SWAP
if [[ $_SWAP == y* ]]
then
    sudo fallocate -l 2048M /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
else
    :
fi

# Install some packages
sudo pacman -S boinc-nox zsh make gcc gc automake autoconf pkgconf fakeroot binutils netdata lm_sensors neofetch rng-tools fake-hwclock opensc nano-syntax-highlighting

echo "Your new SSH private and public key will be generated now..."
ssh-keygen

# Add you to these groups
sudo gpasswd -a $USER dbus
sudo gpasswd -a $USER audio
sudo gpasswd -a $USER video
sudo gpasswd -a $USER wheel
sudo gpasswd -a $USER boinc
sudo gpasswd -a $USER optical
sudo gpasswd -a $USER lp

sudo systemctl enable netdata rngd fake-hwclock fake-hwclock-save.timer
sudo systemctl start fake-hwclock

# Additional netdata charts
sudo gpasswd -a netdata boinc
# TODO: get BOINC's gui-rpc value and write it to netdata config

echo "Do you wish to run sensors-detect?"
read -r _SENSORS_TRUE
if [[ $_SENSORS_TRUE == y* ]]
then
    sudo sensors-detect
else
    :
fi

# ZSH stuff
echo
echo "${red}WARNING!${reset} An external script will now be run! Is this OK?"
echo -n "y/N: "
read -r _OK
if [[ $_OK == y* ]]
then
    echo "${red}WARNING!${reset}"
    echo "The following script will drop you to ZSH, be sure to type \"exit\" to continue the script."
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    echo "export ZSH=\"/home/$USER/.oh-my-zsh\"" > ~/.zshrc
    echo "include \"/usr/share/nano/*.nanorc\"" | sudo tee -a /etc/nanorc
    echo "include \"/usr/share/nano-syntax-highlighting/*.nanorc\"" | sudo tee -a /etc/nanorc
    cat ~/rugl/bash/arch-setuptools/configs/user/zshrc | tee -a ~/.zshrc
else
    echo "ZSH setup will be skipped!"
fi

# Install yay and powerpill
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~
sudo rm -r yay
yay -S powerpill toilet

echo
echo "${green}Done!${reset}"
echo "My customisations are done!"
echo
