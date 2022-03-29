# Quickinstall

Basically, we need the following software installed on Windows

- [Chocolatey](https://chocolatey.org)

This guide assumes, that you have installed these two already.

## Windows Preparation

Now you need to install several things using Chocolatey

```bash
choco install virtualbox
choco install vagrant
choco install openssh
choco install microsoft-windows-terminal
choco install firacodenf
choco install vscode
choco install intellijidea-ultimate
choco install kube
choco install kubernetes-cli

```

You can use the `choco-install.bat` file in this directory.

## Linux VM setup

In this project directory, start provisioning the VM using:

```bash
    vagrant up
```

This will power up the Linux VM and configure it.

## Test it

You should be able to log in using

```bash
vagrant ssh
```

Please cancel your login attempt, because until windows terminal is not configured correctly, you will have problems with the config questions you are being asked.

Show your ssh-config using

```bash
vagrant ssh-config
```

This command prints out where your ssh private key file is located:

```bash
IdentityFile D:/noscan/git/l4win-dev/.vagrant/machines/default/virtualbox/private_key
```

We need to set some permissions, so the private key file can be used for login (without password).
See this superuser [arcticle](https://superuser.com/a/1296046) for the right settings.

You should be able to login with your private key file as well:

```bash
ssh -i D:/noscan/git/l4win-dev/.vagrant/machines/default/virtualbox/private_key vagrant@192.168.110.2
```

Replacing the path with the path of your `IdentityFile`. The IP address must be the same as specified in the vagrant file under `config.vm.network`. 

## Configure Windows Terminal

Open the "Windows Terminal" and settings and create a new profile ("Neues Profil hinzufügen")
![Profile](/doc/images/terminal01.png "adding new profile")

And enter the ssh command you tested above:

![Profile](/doc/images/terminal02.png "configuring new profile")

And change the font and choose the "FiraCode NF" font.

![Profile](/doc/images/terminal03.png "configuring font")

And save your changes.

To support default key bindings of `broot`, you have to remove the key binding `Alt+Enter` for toggling full screen mode in Windows Terminal.

## Configure Linux VM

Open a new tab with the l4win profile.

You should be asked several questions. Configure it to your liking

### Personalize Git Config

You must set your name and email, so git can record this in the commits.

```bash
git config --global user.name "Max Mustermann"
git config --global user.email max.mustermann@mycompany.com
```

Replace name and email with your real ones, of course.

### Install Java and build tools

```bash
sdk install java
sdk install gradle
sdk install maven
```

### Install latest node lts version

```bash
nvm install --lts
```

### Enable Broot

Simply run `broot` once. Then source your init files `. ~/.zshrc`.
And now entering `br` allows you to search and navigate to any subdirectory.

### Enable McFly

Run `eval "$(mcfly init zsh)"` and when you now hit `Ctrl-R` you can easily surf your history.

## What is in the Box?

### Command Line

The shell of the vagrant user is configured to zsh.
The configurations are managed using [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).
The theme is using [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
You can reconfigure p10k using `p10k configure`.

A lot of modern Linux command line tools are installed.

- [jq](https://stedolan.github.io/jq/): for handling json files
- [yq](https://github.com/mikefarah/yq): for handling yaml files
- [fzf](https://github.com/junegunn/fzf)
- [silversearcher-ag](https://github.com/ggreer/the_silver_searcher) (`ag` on the command line)
- htop: a modern top
- [bat](https://github.com/sharkdp/bat): an advanced cat
- [tldr](https://tldr.sh): an easy to consume man page alternative
- [httpie](https://httpie.io): curl for the modern json API age.
- [curlie](https://github.com/rs/curlie): similar to httpie
- [lsd](https://github.com/Peltoche/lsd): modern `ls` replacement. An alias has been set from `ls` to `lsd`. It is CLI compatible with `ls`
- [broot](https://github.com/Canop/broot): easily navigate to all subdirs using `br`
- [procs](https://github.com/dalance/procs): a modern ps
- [mcfly](https://github.com/cantino/mcfly): navigation of your shell history
- [tmuxp](https://github.com/tmux-python/tmuxp): store tmux session manager

### Linux GUI apps

A `DISPLAY` variable is exported, that will support an X Server running on Windows, so you can easily start GUI apps, like IntelliJ from the command line.

### Programming Languages and Development Environment

The box is prepared for different languages / frameworks

- Java (using sdkman)
- node (using nvm)
- Python3 (including pylint)
- golang

#### Java IDE

##### From within VM
If you need an IDE for development, you can use Intellij.
This requires an X Server on Windows.
Intellij Ultimate is installed at /opt/intellij.
At the time of writing, you could start it with `/opt/intellij/idea-IU-212.5457.46/bin/idea.sh`.
You could of course also use `nohup /opt/intellij/idea-IU-212.5457.46/bin/idea.sh &`

##### From Windows

JetBrains is diving into the remote development area, feeling the pressure from VS Code.
One Option currently is J[etBrains Gateway](https://www.jetbrains.com/remote-development/gateway/) which is in Beta, but seems quite usable.
The next option is already on the horizon: [JetBrains Fleet](https://www.jetbrains.com/fleet/).
Unfortunately, I have not been able to test this one yet.

#### Visual Studio Code

Visual Studio Code is also installed in Linux and you can simply start it up using `code` or `nohup code &`.
But Visual Studio is quite good also in remote development. You can start VS Code in Windows and then connect to the VM remotely.
You best configure your SSH key as described in the Windows Terminal customization section.

#### Vim

As a more CLI focused VM setup, a decent configured Vim is a requirements.
We install Vim and Vundle and configure some very interesting plugins.
Have a look at `~/.vimrc`.

Most notable are:

- [ctrlp](https://ctrlpvim.github.io/ctrlp.vim/)
- [nerdtree](https://github.com/preservim/nerdtree)
- [vim-airline](https://github.com/vim-airline/vim-airline)
- [vim-fugitive](https://github.com/tpope/vim-fugitive) and [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
- [vim-visual-multi](https://github.com/mg979/vim-visual-multi)
- [vim-surround](https://github.com/tpope/vim-surround)
- [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim)

### Git support

#### Git commit message template

Git is installed and an opinionated configuration has been provided.
This includes the use of a `gitmessage` template to push better commit messages.
It configures [Vim](https://www.vim.org) as the editor.
If you use git from the command line or tig, this git commit template will be displayed.

#### Credential Store

It configures a credential store.
You should therefore not use your general password, but only personal access tokens for authentication against a git server (github, GitLab or Bitbucket).

#### Diff and Merge

The configuration defines [delta](https://github.com/dandavison/delta) as the diff filter.

And uses [meld](https://meldmerge.org) as the mergetool.
This requires a running X Server on Windows.

#### Git Guis

Different CLI GUIs are installed

- [tig](https://github.com/jonas/tig)
- [gitui](https://github.com/extrawurst/gitui)
- [lazygit](https://github.com/jesseduffield/lazygit)

### Docker and Kubernetes

The VM contains [k3d](https://k3d.io) for starting docker based [k3s](https://k3s.io) clusters.
We think, this a good starting point for developer machines.
However also available is [k3sup](https://github.com/alexellis/k3sup) to easily setup a local k3s cluster.
If you want a k3s local cluster just run:

```bash
k3sup install --local
```

The VM contains the [k3s](https://k3s.io) Kubernetes distribution as well as the k3d distribution.
K3s is disabled by default, so you can easily use k3d which might be more suited for a development machine to test multiple different setups.

The kubeconfig for this cluster is linked from `.kube/config`.
If you want to use k3s execute the following commands:

You can use the cli tool [`k9s`](https://github.com/derailed/k9s) to get an overview of the cluster.

With a running X Server on Windows you can also use the  [`lens`](https://k8slens.dev) kubernetes IDE to explore your cluster(s).

Lens could also be used on Windows, if you mount the k3s samba and map it to a drive letter.

We have also `docker` and `podman` available on the VM.

You can scan images using `trivy`(https://github.com/aquasecurity/trivy) and explore images using [`dive`](https://github.com/wagoodman/dive).

To deploy for example a Kubernetes cluster, simply follow the strimzi instructions and run:

```bash
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml -n kafka 
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka 
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.26.0-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic my-topic
```

... here you can write message, e.g. hello, world! that can be received by the consumer

```bash
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.26.0-kafka-3.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning
```

### Infrastructure as Code

Different tools are available on the VM:

- Ansible
- Ansible-lint
- shellcheck
- terraform
- terragrunt
- aws cli (aws)
- azure cli (az)

## File exchange

The Linux box provides two shares

- vagrant (home)
- k3s

We assume, that the IP of your VM (see Vagrantfile) is 192.168.110.3, then you can mount it in Windows as:

TODO:

- wsdd script: wget https://raw.githubusercontent.com/christgau/wsdd/master/src/wsdd.py
- Mounting on Windows Explorer

```cmd
net use z: \\192.168.110.3\k3s /User:vagrant
net use x: \\192.168.110.3\vagrant /User:vagrant
```

## Customize VM Settings

Currently, you can easly change settings in the Vagrantfile.
E.g. if you want to assign more memory or CPU to your machine.

```ruby
config.vm.provider "virtualbox" do |vb|
     # Display the VirtualBox GUI when booting the machine
     vb.gui = false
     # Customize the amount of memory on the VM:
     vb.memory = "16384"
     # Customize the amount of CPUs assigned
     vb.cpus = 12
  end
```

And then enter `vagrant reload` to restart your VM.

### Increasing the disk size

TBD

### Updating to a new l4w version

Currently, you should run `vagrant up --provision` or `vagrant provision`.

## Backing up

Although not a direct backup, but you can use `vagrant snapshot` command to create snapshots and revert back to this version, if you encounter problems.
For a real backup the recipe is (will detail later):

- Creat a Windows shared foldger
- Mount the folder `mount.cifs` on the VM
- run borgbackup (restic had permission problems) with a suitable config.
