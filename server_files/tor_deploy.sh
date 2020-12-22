RELEASE='bionic'
IS_EXIT=true
IS_BRIDGE=false
INSTALL_NYX=false
CHECK_IPV6=false
ENABLE_AUTO_UPDATE=true
OBFS4PORT_LT_1024=true

C_RED="\e[31m"
C_GREEN="\e[32m"
C_CYAN="\e[36m"
C_DEFAULT="\e[39m"

function echoInfo() {
  echo -e "${C_CYAN}$1${C_DEFAULT}"
}

function echoError() {
  echo -e "${C_RED}$1${C_DEFAULT}"
}

function echoSuccess() {
  echo -e "${C_GREEN}$1${C_DEFAULT}"
}

function handleError() {
  echoError "-> ERROR"
  sudo /etc/init.d/tor stop
  echoError "An error occured on the last setup step."
  echoError "If you think there is a problem with this script please share information about the error and you system configuration for debugging: tor@flxn.de"
}

echo -e $C_CYAN #cyan
cat << "EOF"

 _____            ___     _
|_   _|__ _ _ ___| _ \___| |__ _ _  _   __ ___
  | |/ _ \ '_|___|   / -_) / _` | || |_/ _/ _ \
  |_|\___/_|     |_|_\___|_\__,_|\_, (_)__\___/
                                 |__/

EOF

echo -e $C_DEFAULT #default
echo "              [Relay Setup]"
echo "This script will ask for your sudo password."
echo "----------------------------------------------------------------------"

echoInfo "Updating package list..."
sudo apt-get -y update > /dev/null && echoSuccess "-> OK" || handleError

echoInfo "Installing necessary packages..."
sudo apt-get -y install apt-transport-https psmisc dirmngr ntpdate curl > /dev/null && echoSuccess "-> OK" || handleError

echoInfo "Updating NTP..."
sudo ntpdate pool.ntp.org > /dev/null && echoSuccess "-> OK" || handleError

echoInfo "Adding Torproject apt repository..."
sudo touch /etc/apt/sources.list.d/tor.list && echoSuccess "-> touch OK" || handleError
echo "deb https://deb.torproject.org/torproject.org $RELEASE main" | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null && echoSuccess "-> tee1 OK" || handleError
echo "deb-src https://deb.torproject.org/torproject.org $RELEASE main" | sudo tee --append /etc/apt/sources.list.d/tor.list > /dev/null && echoSuccess "-> tee2 OK" || handleError

echoInfo "Adding Torproject GPG key..."
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | sudo apt-key add - && echoSuccess "-> OK" || handleError

echoInfo "Updating package list..."
sudo apt-get -y update > /dev/null && echoSuccess "-> OK" || handleError

if $INSTALL_NYX
then
  echoInfo "Installing NYX..."
  NYX_INSTALL_OK=false
  sudo apt-get -y install python3-distutils &> /dev/null
  sudo apt-get -y install nyx > /dev/null && NYX_INSTALL_OK=true && echoSuccess "-> OK" || echoError "-> Error installing NYX via apt"

  if [ ! NYX_INSTALL_OK ]
  then
    echoInfo "Trying again via pip..."
    sudo apt-get -y install python3-pip > /dev/null
    sudo pip3 install nyx > /dev/null && echoSuccess "-> OK" || echoError "-> pip install failed too.\nPlease check the nyx homepage: https://nyx.torproject.org/#download"
  fi
fi

echoInfo "Installing Tor..."
sudo apt-get -y install tor deb.torproject.org-keyring > /dev/null && echoSuccess "-> install OK" || handleError
sudo chown -R debian-tor:debian-tor /var/log/tor && echoSuccess "-> chown OK" || handleError

if $IS_BRIDGE
then
  echoInfo "Installing obfs4proxy..."
  sudo apt-get -y install obfs4proxy > /dev/null && echoSuccess "-> OK" || handleError

  if $OBFS4PORT_LT_1024
  then
    echoInfo "Setting net_bind_service capability for non-root user"
    sudo setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy && echoSuccess "-> OK" || handleError
  fi

  sudo sed -i -e 's/NoNewPrivileges=yes/NoNewPrivileges=no/' /lib/systemd/system/tor@default.service && echoSuccess "-> sed OK" || handleError
  systemctl daemon-reload && echoSuccess "-> daemon-reload OK" || handleError
fi

echoInfo "Setting Tor config..."
cat << 'EOF' | sudo tee /etc/tor/torrc > /dev/null && echoSuccess "-> OK" || handleError
SocksPort 0
RunAsDaemon 1
ORPort 9001
Nickname testServer
ContactInfo test(at)testmail(dot)com [tor-relay.co]
Log notice file /var/log/tor/notices.log
DirPort 80
DirPortFrontPage /etc/tor/tor-exit-notice.html
ExitPolicy accept *:20-23     # FTP, SSH, telnet
ExitPolicy accept *:43        # WHOIS
ExitPolicy accept *:53        # DNS
ExitPolicy accept *:79-81     # finger, HTTP
ExitPolicy accept *:88        # kerberos
ExitPolicy accept *:110       # POP3
ExitPolicy accept *:143       # IMAP
ExitPolicy accept *:194       # IRC
ExitPolicy accept *:220       # IMAP3
ExitPolicy accept *:389       # LDAP
ExitPolicy accept *:443       # HTTPS
ExitPolicy accept *:464       # kpasswd
ExitPolicy accept *:465       # URD for SSM (more often: an alternative SUBMISSION port, see 587)
ExitPolicy accept *:531       # IRC/AIM
ExitPolicy accept *:543-544   # Kerberos
ExitPolicy accept *:554       # RTSP
ExitPolicy accept *:563       # NNTP over SSL
ExitPolicy accept *:587       # SUBMISSION (authenticated clients [MUA's like Thunderbird] send mail over STARTTLS SMTP here)
ExitPolicy accept *:636       # LDAP over SSL
ExitPolicy accept *:706       # SILC
ExitPolicy accept *:749       # kerberos
ExitPolicy accept *:873       # rsync
ExitPolicy accept *:902-904   # VMware
ExitPolicy accept *:981       # Remote HTTPS management for firewall
ExitPolicy accept *:989-990   # FTP over SSL
ExitPolicy accept *:991       # Netnews Administration System
ExitPolicy accept *:992       # TELNETS
ExitPolicy accept *:993       # IMAP over SSL
ExitPolicy accept *:994       # IRCS
ExitPolicy accept *:995       # POP3 over SSL
ExitPolicy accept *:1194      # OpenVPN
ExitPolicy accept *:1220      # QT Server Admin
ExitPolicy accept *:1293      # PKT-KRB-IPSec
ExitPolicy accept *:1500      # VLSI License Manager
ExitPolicy accept *:1533      # Sametime
ExitPolicy accept *:1677      # GroupWise
ExitPolicy accept *:1723      # PPTP
ExitPolicy accept *:1755      # RTSP
ExitPolicy accept *:1863      # MSNP
ExitPolicy accept *:2082      # Infowave Mobility Server
ExitPolicy accept *:2083      # Secure Radius Service (radsec)
ExitPolicy accept *:2086-2087 # GNUnet, ELI
ExitPolicy accept *:2095-2096 # NBX
ExitPolicy accept *:2102-2104 # Zephyr
ExitPolicy accept *:3128      # SQUID
ExitPolicy accept *:3389      # MS WBT
ExitPolicy accept *:3690      # SVN
ExitPolicy accept *:4321      # RWHOIS
ExitPolicy accept *:4643      # Virtuozzo
ExitPolicy accept *:5050      # MMCC
ExitPolicy accept *:5190      # ICQ
ExitPolicy accept *:5222-5223 # XMPP, XMPP over SSL
ExitPolicy accept *:5228      # Android Market
ExitPolicy accept *:5900      # VNC
ExitPolicy accept *:6660-6669 # IRC
ExitPolicy accept *:6679      # IRC SSL
ExitPolicy accept *:6697      # IRC SSL
ExitPolicy accept *:8000      # iRDMI
ExitPolicy accept *:8008      # HTTP alternate
ExitPolicy accept *:8074      # Gadu-Gadu
ExitPolicy accept *:8080      # HTTP Proxies
ExitPolicy accept *:8082      # HTTPS Electrum Bitcoin port
ExitPolicy accept *:8087-8088 # Simplify Media SPP Protocol, Radan HTTP
ExitPolicy accept *:8332-8333 # Bitcoin
ExitPolicy accept *:8443      # PCsync HTTPS
ExitPolicy accept *:8888      # HTTP Proxies, NewsEDGE
ExitPolicy accept *:9418      # git
ExitPolicy accept *:9999      # distinct
ExitPolicy accept *:10000     # Network Data Management Protocol
ExitPolicy accept *:11371     # OpenPGP hkp (http keyserver protocol)
ExitPolicy accept *:19294     # Google Voice TCP
ExitPolicy accept *:19638     # Ensim control panel
ExitPolicy accept *:50002     # Electrum Bitcoin SSL
ExitPolicy accept *:64738     # Mumble
ExitPolicy reject *:*
IPv6Exit 0
RelayBandwidthRate 100 MBits
RelayBandwidthBurst 100 MBits
AccountingStart month 1 00:00
AccountingMax 5000 GB

EOF

if $IS_EXIT
then
  echoInfo "Downloading Exit Notice to /etc/tor/tor-exit-notice.html..."
  echo -e "\e[1mPlease edit this file and replace FIXME_YOUR_EMAIL_ADDRESS with your e-mail address!"
  echo -e "\e[1mAlso note that this is the US version. If you are not in the US please edit the file and remove the US-Only sections!\e[0m"
  sudo wget -q -O /etc/tor/tor-exit-notice.html "https://raw.githubusercontent.com/flxn/tor-relay-configurator/master/misc/tor-exit-notice.html" && echoSuccess "-> OK" || handleError
fi

function disableIPV6() {
  sudo sed -i -e '/INSERT_IPV6_ADDRESS/d' /etc/tor/torrc
  sudo sed -i -e 's/IPv6Exit 1/IPv6Exit 0/' /etc/tor/torrc
  sudo sed -i -e '/\[..\]/d' /etc/tor/torrc
  echoError "IPv6 support has been disabled!"
  echo "If you want to enable it manually find out your IPv6 address and add this line to your /etc/tor/torrc"
  echo "ORPort [YOUR_IPV6_ADDRESS]:YOUR_ORPORT (example: \"ORPort [2001:123:4567:89ab::1]:9001\")"
  echo "or for a bridge: ServerListenAddr obfs4 [..]:YOUR_OBFS4PORT"
  echo "Then run \"sudo /etc/init.d/tor restart\" to restart Tor"
}

if $CHECK_IPV6
then
  echoInfo "Testing IPV6..."
  IPV6_GOOD=false
  ping6 -c2 2001:858:2:2:aabb:0:563b:1526 && ping6 -c2 2620:13:4000:6000::1000:118 && ping6 -c2 2001:67c:289c::9 && ping6 -c2 2001:678:558:1000::244 && ping6 -c2 2607:8500:154::3 && ping6 -c2 2001:638:a000:4140::ffff:189 && IPV6_GOOD=true
  if [ ! IPV6_GOOD ]
  then
    sudo /etc/init.d/tor stop
    echoError "Could not reach Tor directory servers via IPV6"
    disableIPV6
  else
    echoSuccess "Seems like your IPV6 connection is working"

    IPV6_ADDRESS=$(ip -6 addr | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
    if [ -z "$IPV6_ADDRESS" ]
    then
      echoError "Could not automatically find your IPv6 address"
      echo "If you know your global (!) IPv6 address you can enter it now"
      echo "Please make sure that you enter it correctly and do not enter any other characters"
      echo "If you want to skip manual IPv6 setup leave the line blank and just press ENTER"
      read -p "IPv6 address: " IPV6_ADDRESS

      if [ -z "$IPV6_ADDRESS" ]
      then
        disableIPV6
      else
        sudo sed -i "s/INSERT_IPV6_ADDRESS/$IPV6_ADDRESS/" /etc/tor/torrc
        echoSuccess "IPv6 Support enabled ($IPV6_ADDRESS)"
      fi
    else
      sudo sed -i "s/INSERT_IPV6_ADDRESS/$IPV6_ADDRESS/" /etc/tor/torrc
      echoSuccess "IPv6 Support enabled ($IPV6_ADDRESS)"
    fi
  fi
fi

if $ENABLE_AUTO_UPDATE
then
  echoInfo "Enabling unattended upgrades..."
  sudo apt-get install -y unattended-upgrades apt-listchanges > /dev/null && echoSuccess "-> install OK" || handleError
  DISTRO=$(lsb_release -is)
  sudo wget -q -O /etc/apt/apt.conf.d/50unattended-upgrades "https://raw.githubusercontent.com/flxn/tor-relay-configurator/master/misc/50unattended-upgrades.$DISTRO" && echoSuccess "-> wget OK" || handleError
  echoInfo "Don't install recommends..."
  sudo wget -q -O /etc/apt/apt.conf.d/40norecommends "https://raw.githubusercontent.com/flxn/tor-relay-configurator/master/misc/40norecommends" && echoSuccess "-> wget OK" || handleError
fi

sleep 10

echoInfo "Reloading Tor config..."
sudo /etc/init.d/tor restart

echo ""
echoSuccess "=> Setup finished"
echo ""
echo "Tor will now check if your ports are reachable. This may take up to 20 minutes."
echo "Check /var/log/tor/notices.log for an entry like:"
echo "\"Self-testing indicates your ORPort is reachable from the outside. Excellent.\""
echo ""

sleep 5

if [ ! -f /var/log/tor/notices.log ]; then
  echoError "Could not find Tor logfile."
  echo "This could indicate an error. Check syslog for error messages from Tor:"
  echo "  /var/log/syslog | grep -i tor"
  echo "It could also be a false positive. Wait a bit and check the log file again."
  echo "If you chose to install nyx you can check nyx to see if Tor is running."
fi
