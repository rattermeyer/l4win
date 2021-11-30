#!/bin/bash
# scripts used here must be idempotent

echo "Install some additional packages..."
apt-get update
apt-get install -y zsh jq shellcheck fzf silversearcher-ag htop \
  bat tldr zip unzip ca-certificates httpie tig curl gnupg lsb-release \
  firefox python3 python3-pip pylint rustc golang postgresql-client \
  cmake mc unattended-upgrades
apt-get install -y --no-install-recommends meld
 
# install homebrew
echo "Install homebrew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sudo -u vagrant bash -s CI=1
# TODO this is not idempotent. better do it in ansible instead of bash?
# TODO or would need to check for presence of line in file before making modifications
# TODO move to ansible
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' | sudo -u vagrant tee -a /home/vagrant/.zprofile

# allow setting of DISPLAY variable for Windows XServer
# TODO this should be moved to ANSIBLE to make it idempotent
echo export DISPLAY='$(/sbin/ip route | awk '"'"'/default/ { print $3 }'"'"'):0' | sudo -u vagrant tee -a /home/vagrant/.zprofile 

# McFly (advanced shell history)
echo "Install mcfly..."
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
sudo -u vagrant zsh -c eval "$(mcfly init zsh)"

# install ansible and some other packages
echo "Install ansible and other python packages..."
pip3 install ansible ansible-lint yq tmuxp tig pre-commit

# install docker
# see https://docs.docker.com/engine/install/ubuntu/
echo "Install Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
groupadd docker
usermod -aG docker vagrant

# Hashicorp Tools
echo "Install Hashicorp Tools..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && sudo apt-get install -y consul nomad vault terraform consul-template boundary
sudo -H -u vagrant zsh -c 'cd /home/vagrant ; boundary config autocomplete install'
sudo -H -u vagrant zsh -c 'cd /home/vagrant ; consul -autocomplete-install'
sudo -H -u vagrant zsh -c 'cd /home/vagrant ; nomad -autocomplete-install'
sudo -H -u vagrant zsh -c 'cd /home/vagrant ; terraform -install-autocomplete'

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# install podman
# TODO move to ansible
. /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install podman

# Install k3s kubernetes distribution
# see https://k3s.io
# TODO move to ansible
echo "Install k3s..."
curl -sfL https://get.k3s.io | sh - 
## enable vagrant to read kubeconfig for k3s
echo "K3S_KUBECONFIG_MODE=0644"| sudo tee /etc/systemd/system/k3s.service.env
systemctl restart k3s

# install k3d
# see: https://k3d.io/v5.1.0/#installation
# curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Install IntelliJ
# TODO Probably also in Ansible?
echo "Install intellij..."
if [ ! -d /opt/intellij ] ; then
  curl -sL "https://download.jetbrains.com/product?code=IU&latest&distribution=linux" > /tmp/intellij.tar.gz
  mkdir -p /opt/intellij
  tar xvz -C /opt/intellij -f /tmp/intellij.tar.gz
fi

# VS Code
sudo snap install --classic code
CODE_EXTENSIONS=(
"amazonwebservices.aws-toolkit-vscode" 
"asciidoctor.asciidoctor-vscode"
"DavidAnson.vscode-markdownlint"
"dbaeumer.vscode-eslint"
"dracula-theme.theme-dracula"
"eamodio.gitlens"
"EditorConfig.EditorConfig"
"esbenp.prettier-vscode"
"golang.go"
"hashicorp.terraform"
"hediet.vscode-drawio"
"jebbs.plantuml"
"joaompinto.asciidoctor-vscode"
"marcostazi.VS-code-vagrantfile"
"mimarec.swagger-doc-viewer"
"ms-kubernetes-tools.vscode-kubernetes-tools"
"ms-python.python"
"redhat.vscode-yaml"
)
for i in "${CODE_EXTENSIONS[@]}"; do 
  sudo -u vagrant code --install-extension "$i"
done     

# following is customizing the user experience
# therefore, most things are done using as the actual user

# install oh-my-zsh
# see https://ohmyz.sh/#install
echo "Install oh-my-zsh..."
sudo -u vagrant sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install sdkman (managing jdks)
echo "Install sdkman..."
sudo -u vagrant sh -c "curl -s https://get.sdkman.io | bash"

## change shell to zsh
echo "change vagrant shell to zsh..."
chsh --shell /usr/bin/zsh vagrant

# clone powerlevel10k
echo "installing oh-my-zsh theme p10k..."
if [ ! -d /home/vagrant/.oh-my-zsh/custom/themes/powerlevel10k ]; then
  sudo -u vagrant sh -c "git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git /home/vagrant/.oh-my-zsh/custom/themes/powerlevel10k"
  sudo -u vagrant sh -c "sed -i 's,ZSH_THEME=.*,ZSH_THEME=\"powerlevel10k/powerlevel10k\",g' .zshrc"
else
  echo "powerlevel10k alread installed"
fi

## brew installs
echo "installing multiple brews..."
sudo -H -i -u vagrant zsh -c "brew install lsd gitui lazygit git-delta procs broot rs/tap/curlie derailed/k9s/k9s dive helm terragrunt cdktf"

# set alias
# TODO this should be moved to ansible to make it idempotent
echo "alias ls='lsd'" >> .oh-my-zsh/custom/alias.zsh
echo "alias bat='batcat'" >> .oh-my-zsh/custom/alias.zsh
# kubeconfig for k3s
sudo -u vagrant mkdir /home/vagrant/.kube
sudo -u vagrant ln -s /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config

echo "install nerd font..."
bash -s nerd-font.sh

# Samba
# exporting vagrant home and /etc/rancher as shares.
# the latter can be used to add config to lens as a kube config
# need to mount shares and assign a device letter.
# TODO move to Ansible
echo "install and configure samba"
apt-get install -y samba
cp /vagrant/files/smb.conf /etc/samba/smb.conf
systemctl restart smbd
# create smb user vagrant/vagrant
(echo vagrant; echo vagrant) | sudo smbpasswd -a -s vagrant

# Lens
echo "install lens"
if [ ! -f /usr/bin/lens ] ; then
  LENS_FILE=Lens-5.3.0-latest.20211125.2.amd64.deb
  wget -q "https://api.k8slens.dev/binaries/${LENS_FILE}"
  apt install -y libnotify4 libnss3 libxss1 xdg-utils libsecret-1-0 libnspr4 libsecret-common libxshmfence1 libgbm1  
  dpkg -i "${LENS_FILE}"
fi

# trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
apt-add-repository "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main"
apt-get update
apt-get install trivy

# clone
echo "cloning repo..."
if [ ! -d /home/vagrant/git ] ; then
  sudo -u vagrant sh -c mkdir -p /home/vagrant/git
fi

if [ ! -d /home/vagrant/git/l4win ]; then
  sudo -H -u vagrant git clone https://github.com/rattermeyer/l4win.git /home/vagrant/git/l4win
fi

# Run Ansible
# Workaround youcomplete me
echo "running ansible"
sudo -H -u vagrant sh -c 'unset SUDO_USER; unset SUDO_COMMAND; env ; cd /home/vagrant/.vim/bundle/YouCompleteMe ; ./install.py'