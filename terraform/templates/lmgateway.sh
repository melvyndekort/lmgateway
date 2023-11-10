#!/bin/sh

# Retrieve a parameter value from SSM by parameter name
get_ssm_param() {
  aws ssm get-parameter --with-decryption --name "$1" --query "Parameter.Value" --output text
}

# Set root password
USER_PASSWORD="$(get_ssm_param ${user_password})"
echo "root:$USER_PASSWORD" | chpasswd -e

# User config
useradd -G wheel -s /bin/bash -m -p "$USER_PASSWORD" melvyn

mkdir -p /home/melvyn/.ssh

cat << EOF > /home/melvyn/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFJhPTPfNQuNCuz9AESupcGOwLtg8Xp+qTnv2+qU94O ed25519
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuyHMuKWZIxf63X1Ve6nU6+D/Ku+Y6c2pC8OYMDbzQrxr1AQCvoxP/zVimLbl4cur66GXE3RqcRH6UHC1q6YR2vlWBcZvDlojnHWRmqvcFlsuv7RxdF5DVatzrfQ6l1m0jy+Ey3djBGKwH5fIxKTpMZVkERFXYSNDLwyMqTisbBI9e32nOHFeG5dcH6mdloAyICbdMnDTn5pl1ztjEOqZ+TKtv0ZEf4o0iHMCKFwJBJnJ2OGTqNycjt6VeTPaMdpGetfCxCuA7lmdGV6IoooEkxKTp9J1+DBmTTGgo1ivfb6EZVSL6EQysieL+eYhcASKkiKaoQOylqysHbk49TJUBMX2H3yLq9N80h6dhDjtdWtCpuaD0KKpnxF5J3agi9z2gywVgzv38hik2ApE1T0ny/ZtwnnXOw3sNMaS6yBp9yw/KqsuKBrSqDYufqQbsce/sAjzR4B4ELauvol0AvlK+5gSDTZoDI6VgbOyJkFVFZbkOqAXTZZ/cBPJ8+ZzSBsNjW6YHvl7mJsdi9ZuUT2OhH2CKF3+rcVaBBcdzMqSMcwUWYf5J4n7yTleCuPau+klkHzM+QbHEPN+65dSqdk0nwgSiwK0OaalHuYNVlNPyji1lkLVLFwsgpE7lIpRxPrYOI6fVY/Fo0EhW3oIktvyohKRF1TaISsILRr2m/b7VLQ== rsa
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCse8TLb47f+zddmzm0EvO6+RK8eeQouClEFA33ftG6+ioiJxkNf+vXwtWVlmA4JzwhLDQ5tKk+SQ9OTg/JMB8O9VfaK9LHxhJhLdiNo+P8W/vK9BI6CNCA1F+rbzN3OtEavYum7eHxeUrnYM+VkGyUpi5zmbHYF30VgxYeLMoK66eriFo+EHoQwv137uUgGYxe1BLGwkHjWdZ6wgjPkZTu4QoAsdxptVZH16TsFJKEQJdetJbJQ+I86yPjZ4AU5ImzdWUbUA4ic8gIZDhZeLz2UCmRB/EilNVKzQb+m54rE+cRH7f63zcEkqnAb5Ugz+XRMtdtqxcx2x9Eza2ohk8ZblyE8s3D2c4KR4YKzZJhuakK/sQ9FKOJo6vy2G6Mq1PMUhMF3rn+whUzXBpV2A0XK8P0H7/D+7zsGnQH+NZb6akgE+SqonL+zK430xWhWvoE7irtPh9CeG8+AF9OD+nbGBs22HpXCeR+yW2tPfJQtHLBOkaWyzJIsqfl4cMWaCRMnRKl/QEJuu9dG3rtOcZyBvkBnKd0X1GNIN5t1BMuhKghkipBgrG2oMM3hBRafHafrg26ikIImuImqVvaWZWeKKjU5tsivu/PELa4vyF/PqJ7meFqf1V2Jpw2Z21nSVQsgXK34Kbx5r6GSIdea+9cdEsJabKS7VrqwmSY8NjCZQ== yubikey
EOF

cat << EOF > /home/melvyn/.ssh/config
Host lmrouter
  Hostname 10.204.10.1
  User root

Host lm-ap-1 lmap1 ap1
  Hostname 10.204.50.11
  User root

Host lm-ap-2 lmap2 ap2
  Hostname 10.204.50.12
  User root

Host lm-ap-3 lmap3 ap3
  Hostname 10.204.50.13
  User root

Host lm-ap-4 lmap4 ap4
  Hostname 10.204.50.14
  User root

Host lmserver
  Hostname 10.204.10.2
  User core

Host melvynpc
  Hostname melvynpc.mdekort.lan
  User melvyn

Host tuinhuis
  Hostname tuinhuis.mdekort.lan
  User pi
EOF

chmod 700 /home/melvyn/.ssh
chmod 600 /home/melvyn/.ssh/config
chown -R melvyn:melvyn /home/melvyn/.ssh

# Hostname
hostnamectl hostname lmgateway
cat << EOF >> /etc/hosts
127.0.1.1   lmgateway lmgateway.localdomain
EOF

# Timezone
ln -fs /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

# Enable time synchronization
echo 'NTP=169.254.169.123' >> /etc/systemd/timesyncd.conf
systemctl enable --now systemd-timesyncd

# Configure aws-cli
aws configure set default.region eu-west-1

# Configure DNF to use IPv6
echo 'ip_resolve=IPv6' >> /etc/dnf/dnf.conf

# Install and enable SSM
case "${arch}" in
  "x86_64")
    dnf install -y https://s3.dualstack.us-east-1.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm;;
  "arm64")
    dnf install -y https://s3.dualstack.us-east-1.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm;;
esac
systemctl enable --now amazon-ssm-agent

# Install and enable Fluent Bit for logging to New Relic
cat << 'EOF' > /etc/yum.repos.d/fluent-bit.repo
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/amazonlinux/2022/$basearch/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
enabled=1
EOF

dnf install -y fluent-bit

mkdir -p /etc/fluent-bit/lib /run/fluent-bit
case "${arch}" in
  "x86_64")
    aws s3 cp --endpoint-url https://s3.dualstack.eu-west-1.amazonaws.com s3://mdekort.artifacts/out_newrelic-linux-amd64-1.17.3.so /etc/fluent-bit/lib/out_newrelic.so;;
  "arm64")
    aws s3 cp --endpoint-url https://s3.dualstack.eu-west-1.amazonaws.com s3://mdekort.artifacts/out_newrelic-linux-arm64-1.17.3.so /etc/fluent-bit/lib/out_newrelic.so;;
esac

cat << EOF > /etc/fluent-bit/plugins.conf
[PLUGINS]
  Path /etc/fluent-bit/lib/out_newrelic.so
EOF

NEWRELIC_KEY="$(get_ssm_param ${newrelic_key})"

cat << EOF > /etc/fluent-bit/fluent-bit.conf
[SERVICE]
    flush            1
    daemon           Off
    log_level        info
    parsers_file     parsers.conf
    plugins_file     plugins.conf
    http_server      On
    http_listen      0.0.0.0
    http_port        2020
    storage.metrics  on

[INPUT]
    Name                systemd
    Path                /var/log/journal
    DB                  /run/fluent-bit/journal.db
    Tag                 journal.*
    Systemd_Filter      _SYSTEMD_UNIT=amazon-ssm-agent.service
    Systemd_Filter      _SYSTEMD_UNIT=fluent-bit.service
    Systemd_Filter      _SYSTEMD_UNIT=sshd.service
    Systemd_Filter      _SYSTEMD_UNIT=systemd-logind.service
    Systemd_Filter      _SYSTEMD_UNIT=wg-quick@wg0.service
    Systemd_Filter_Type Or

[FILTER]
    Name   modify
    Match  journal.*
    Copy   _HOSTNAME hostname

[OUTPUT]
    Name        newrelic
    Match       *
    endpoint    https://log-api.eu.newrelic.com/log/v1
    licenseKey  $NEWRELIC_KEY
EOF

systemctl enable --now fluent-bit

# Install extra tools
dnf install -y vim-enhanced nmap telnet dnsutils tmux ncurses-term htop git wireguard-tools

# Configure WireGuard connection
cat << EOF > /etc/systemd/network/wg0.netdev
[NetDev]
Name=wg0
Kind=wireguard
Description=WireGuard tunnel wg0

[WireGuard]
ListenPort=51820
PrivateKey=${private_key}

[WireGuardPeer]
PublicKey=${public_key}
AllowedIPs=10.204.0.0/16
Endpoint=vpn6.mdekort.nl:51820
EOF

chown root:systemd-network /etc/systemd/network/wg0.netdev
chmod 640 /etc/systemd/network/wg0.netdev

cat << EOF > /etc/systemd/network/wg0.network
[Match]
Name=wg0

[Network]
Address=10.204.40.2/24
Domains=mdekort.lan
DNS=10.204.40.1

[Route]
Gateway=10.204.40.1
Destination=10.204.0.0/16
EOF

networkctl reload

# Install and configure dnsmasq
dnf install -y dnsmasq

cat << EOF >> /etc/dnsmasq.d/wireguard.conf
# Don't needlessly read /etc/resolv.conf
no-resolv

# Upstream DNS servers (Amazon)
server=169.254.169.253
server=fd00:ec2::253

# Forward all domains ending in mdekort.lan to 10.204.40.1
server=/mdekort.lan/10.204.40.1

# Add custom domain to hosts in the network
local=/mdekort.lan/
domain=mdekort.lan
expand-hosts
EOF

systemctl enable --now dnsmasq

# Use custom dnsmasq as system-wide dns resolver
cat << EOF >> /etc/resolv.conf.dnsmasq
search mdekort.lan
nameserver 127.0.0.1
EOF

ln -sf /etc/resolv.conf.dnsmasq /etc/resolv.conf
