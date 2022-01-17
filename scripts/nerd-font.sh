#!/bin/bash
# install DroidSansMono Nerd Font --> u can choose another at: https://www.nerdfonts.com/font-downloads
echo "[-] Download fonts [-]"
echo "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip"
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip"
mkdir -p .local/share/fonts
sudo -u vagrant unzip FiraCode.zip -d /home/vagrant/.local/share/fonts
fc-cache -fv
rm FiraCode.zip
echo "done!"