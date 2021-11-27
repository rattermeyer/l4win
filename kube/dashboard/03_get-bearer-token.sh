#!/bin/sh
sudo k3s kubectl -n kubernetes-dashboard describe secret admin-user-token | grep '^token'
