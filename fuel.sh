#!/usr/bin/env bash
echo "Fuel starting up."

echo "Adding host as nameserver"
echo "nameserver 10.20.0.1" >> /etc/resolv.conf
sed -i "s/8.8.8.8/10.20.0.1/" /etc/fuel/astute.yaml

echo "Enable advanced and experimental features"
sed -i "/\"FEATURE_GROUPS\":/a  - \"experimental\"\n- \"advanced\"" /etc/fuel/astute.yaml

echo "Waiting for bootstrap image. This will take 20-30 minutes ..."

tail -f /var/log/puppet/bootstrap_admin_node.log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"There is no active bootstrap"* ]] && pkill -P $$ tail
   echo $LOGLINE
done

sleep 10

tail -f /var/log/fuel-bootstrap-image-build.log | while read LOGLINE
do
   [[ "${LOGLINE}" == *"has been activated"* ]] && pkill -P $$ tail
   echo $LOGLINE
done

while ! egrep "Bootstrap image (.*) has been activated" /var/log/fuel-bootstrap-image-build.log &>/dev/null; do :; sleep 5; echo '.'; done

echo "Bootstrap image available"

iptables -t nat -A POSTROUTING -j MASQUERADE
