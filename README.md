# Quickinstall

Basically, we need the following software installed on Windows

- [VirtualBox](https://www.virtualbox.org)
- [Chocolatey](https://chocolatey.org)

This guide assumes, that you have installed these two already.

## Windows Preparation

Now you need to install several things using Chocolatey

```bash
choco install vagrant
choco install openssh
choco install microsoft-windows-terminal
choco install firacodenf
choco install vscode
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
ssh -i D:/noscan/git/l4win-dev/.vagrant/machines/default/virtualbox/private_key vagrant@192.168.2.2
```

Replacing the path with the path of your `IdentityFile`.

## Configure Windows Terminal

Open the "Windows Terminal" and settings and create a new profile ("Neues Profil hinzufügen")
![Profile](/doc/images/terminal01.png "adding new profile")

And enter the ssh command you tested above:

![Profile](/doc/images/terminal02.png "configuring new profile")

And change the font and choose the "FiraCode NF" font.

![Profile](/doc/images/terminal03.png "configuring font")

And save your changes

## Configure Linux VM

Open a new tab with the l4win profile.

You should be asked several questions. Configure it to your liking

### Install Java

```bash
sdk install java
sdk install gradle
sdk install maven
```

### Connect Lens to your kubernetes cluster

K3s writes is configuration to `/etc/rancher/k3s/k3s.yaml`.
Copy this file to your Window host `cp /etc/rancher/k3s/k3s.yaml /vagrant`. From there move it where you want it to be located.
In lens add this to add your cluster.
