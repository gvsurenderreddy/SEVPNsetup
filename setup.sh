#!/bin/sh
# SE-VPN script
apt-add-repository ppa:paskal-07/softethervpn -y
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y unzip curl git dnsmasq bc make gcc openssl build-essential upstart-sysv iptables-persistent softether-vpncmd softether-vpnserver

service softether_vpn stop
update-rc.d softether_vpnserver remove
rm -f /etc/init.d/softether_vpnserver
wget -O /etc/init.d/softether_vpnserver https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/vpnserver.init
chmod +x /etc/init.d/softether_vpnserver
update-rc.d softether_vpnserver defaults

wget https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/iptables-vpn.sh
chmod +x iptables-vpn.sh
sh iptables-vpn.sh
rm -f iptables-vpn.sh

wget -O /etc/dnsmasq.conf https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/dnsmasq.conf
wget vpn_server.config https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/vpn_server.config
vpncmd 127.0.0.1:5555 /SERVER /CMD:ConfigSet vpn_server.config
service vpnserver restart
TAP_ADDR=172.16.0.1
TAP_SM=255.240.0.0
ifconfig tap_soft $TAP_ADDR netmask $TAP_SM
service dnsmasq restart
rm -f vpn_server.config

wget -O /usr/bin/sprunge https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/scrunge.sh
chmod 755 /usr/bin/sprunge
wget https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/globe.txt
wget https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/tnt.txt
wget https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/udp.txt
vpncmd 127.0.0.1:5555 /SERVER /CMD:OpenVpnMakeConfig openvpn
unzip openvpn.zip
myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
GLOBE_MGC="$(cat globe.txt)"
TNT="$(cat tnt.txt)"
GLOBE_INET="$(cat udp.txt)"
REMOTE="$(ls *remote*.ovpn)"
SRVHOSTNAMEGLOBE="$(hostname)_tcp_globe_mgc.ovpn"
SRVHOSTNAMETNT="$(hostname)_tcp_tnt.ovpn"
SRVHOSTNAMEUDP="$(hostname)_udp_globe_inet.ovpn"
rm -f *bridge_l2.ovpn
cp $REMOTE $SRVHOSTNAMEGLOBE
cp $REMOTE $SRVHOSTNAMETNT
cp $REMOTE $SRVHOSTNAMEUDP
sed -i '/^\s*[@#]/ d' *.ovpn
sed -i '/^\s*[@;]/ d' *.ovpn
sed -i "s/\(vpn[0-9]*\).v4.softether.net/$myip/" *.ovpn
sed -i 's/udp/tcp/' *tcp*.ovpn
sed -i 's/1194/443/' *tcp*.ovpn
sed -i 's/tcp/udp/' *udp*.ovpn
sed -i 's/1194/9201/' *udp*.ovpn
sed -i 's/443/9201/' *udp*.ovpn
sed -i 's/auth-user-pass/auth-user-pass account.txt/' *.ovpn
sed -i '/^\s*$/d' *.ovpn
sed -i "s#<ca>#$GLOBE_MGC#" *tcp_globe_mgc.ovpn
sed -i "s#<ca>#$TNT#" *tcp_tnt.ovpn
sed -i "s#<ca>#$GLOBE_INET#" *udp_globe_inet.ovpn

wget https://raw.githubusercontent.com/bjdag1234/SEVPNsetup/master/getconfig.sh
chmod +x getconfig.sh
rm -f *.txt
rm -f *.pdf

clear
echo "\033[0;34mFinished Installing SofthEtherVPN."
echo "\033[1;34m"
echo "Go to the these urls to get your OpenVPN config file"
echo "\033[1;33m"
cat *tcp_globe*.ovpn | sprunge
cat *tcp_tnt*.ovpn | sprunge
cat *udp*.ovpn | sprunge
rm -f *.ovpn
echo "\033[1;34m"
echo "Don't forget to make a text file named account.txt to put your username"
echo "and your password, first line username. 2nd line password."
echo "\033[1;34m"
echo "Server WAN/Public IP address: ${myip}"
echo ""
echo "Username and Password pairs for the virtual hub VPN:"
echo "\033[1;35mvpn - vpn ; vpn1 - vpn1 ; vpn2 - vpn2 ; vpn3 - vpn3; vpn4 - vpn4"
echo "\033[1;34musername and password are the same"
echo ""
echo "Ports for SofthEther VPN:"
echo "SEVPN/OpenVPN TCP Ports: 80,82,443,995,992,5555,5242,4244,3128,9200,9201,21,137,8484"
echo "OpenVPN UDP Ports: 80,82,443,5242,4244,3128,9200,9201,21,137,8484,,5243,9785,2000-4499,4501-8000"
echo ""
echo "Please set your server password via SE-VPN Manager."
echo "\033[0m"
