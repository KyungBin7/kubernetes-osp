#!/bin/bash

dnf remove bind -y
dnf install bind -y

cat <<EOF>> /etc/named.rfc1912.zones
zone "demo.io" IN {
 type master;
  file "demo.io.zone";
  allow-update { none; };
};
EOF

cat <<EOF> /var/named/demo.io.zone
\$TTL 7200
demo.io. IN SOA storage.example.com. admin.demo.io. (
    2024061802 ; Serial
    7200 ; Refresh
    3600 ; Retry
    604800 ; Expire
    7200) ; NegativeCacheTTL

                   IN NS storage.example.com.
registry           IN A 192.168.10.100
registry-dashboard IN A 192.168.10.100
git                IN A 192.168.10.100
demo.io.           IN A 192.168.10.240
www                IN CNAME demo.io.
EOF

sed -i '11s/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { any; };/' /etc/named.conf
sed -i '19s/allow-query     { localhost; };/allow-query     { any; };/' /etc/named.conf

cd /var/named/
chown named. demo.io.zone

systemctl enable --now named
systemctl is-active named

echo "********** append nameserver go to file: vi /etc/resolv.conf**********"