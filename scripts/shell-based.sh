#!/bin/bash
# scripts used here must be idempotent

echo "Install some additional packages..."
apt-get update
apt-get install -y zsh jq shellcheck fzf silversearcher-ag htop \
  bat tldr zip unzip ca-certificates httpie tig curl gnupg lsb-release \
  firefox python3 python3-pip rustc golang postgresql-client \
  unattended-upgrades
apt-get install -y --no-install-recommends meld
 
# install homebrew
echo "Install homebrew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sudo -u vagrant bash -s CI=1
# TODO this is not idempotent. better do it in ansible instead of bash?
# TODO or would need to check for presence of line in file before making modifications
# TODO move to ansible
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' | sudo -u vagrant tee /home/vagrant/.zprofile
echo 'export DISPLAY=$(/sbin/ip route | awk '/default/ { print $3 }'):0'| sudo -u vagrant tee /home/vagrant/.zprofile 

# install mcfly (advanced shell history)
echo "Install mcfly..."
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly

# install ansible and some other packages
echo "Install ansible and other python packages..."
pip3 install ansible ansible-lint yq tmuxp tig pre-commit

# install docker
# see https://docs.docker.com/engine/install/ubuntu/
# TODO move to ansible
echo "Install Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
groupadd docker
usermod -aG docker vagrant

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

# Install VS Code
sudo snap install --classic code

# following is customizing the user experience
# therefore, most things are done using as the actual user

# install oh-my-zsh
# see https://ohmyz.sh/#install
echo "Install oh-my-zsh..."
sudo -u vagrant sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install sdkman (managing jdks)
echo "Install sdkman..."
sudo -u vagrant sh -c "curl -s https://get.sdkman.io | bash"

# install nvm (managing node versions)
echo "Install nvm..."
sudo -u vagrant sh -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash"

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
sudo -H -i -u vagrant zsh -c "brew install gitui lazygit git-delta procs broot rs/tap/curlie derailed/k9s/k9s"

# config git
# TODO move to Ansible
echo "configure git"
sudo -u vagrant git config --global core.pager delta
sudo -u vagrant git config --global interactive.diffFilter "delta --color-only"
sudo -u vagrant git config --global credential.helper store
sudo -u vagrant git config --global core.editor vim
sudo -u vagrant git config --global commit.template ~/.gitmessage
sudo -u vagrant cp ansible/playbooks/files/git-commit-template.txt /home/vagrant/.gitmessage

# clone
echo "cloning repo..."
if [ ! -d /home/vagrant/git ] ; then
  sudo -u vagrant sh -c mkdir -p /home/vagrant/git
fi

if [ ! -d /home/vagrant/git/l4win ]; then
  sudo -H -u vagrant git clone https://github.com/rattermeyer/l4win.git /home/vagrant/git/l4win
fi
