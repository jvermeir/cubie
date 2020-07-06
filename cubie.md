# Cubie board
## Hardware Version

v2/A20

## Image

	https://www.armbian.com/cubieboard-2/

this image worked in July 2020:

    # Armbian_20.05.4_Cubieboard2_focal_current_5.4.45.img
	https://dl.armbian.com/cubieboard2/Focal_current
	
convert img file for use in virtual box (TODO: vm doesn't start yet): 

    http://www.kombitz.com/2009/10/06/how-to-mount-an-img-file-on-virtualbox/
    
    VBoxManage convertfromraw -format VDI Armbian_20.05.4_Cubieboard2_focal_current_5.4.45.img Armbian_20.05.4_Cubieboard2_focal_current_5.4.45.vdi	
	
## Install

### Copy image to sd card with Etcher

	https://www.etcher.io/
	
Connect display, keyboard, network cable
Set root password, secondary user is created.

### ssh

    ssh-keygen (to generate folders with correct permissions)
    scp <user@host>:/Users/<user>/.ssh/cubie* .
    
    vi ~/.ssh/authorized_keys
    # add id_rsa.pub from mac 
    
### git 
   
use cubie_rsa key for git

 ```bash
 # ~/.ssh/config
 Host cubie
     Hostname github.com
     User git
     IdentityFile ~/.ssh/cubie_rsa
 ```

Set identity

     git config --global user.email "you@example.com"
     git config --global user.name "Your Name"
     
### Source

clone repo using (note: user=cubie):

    cd
    mkdir dev
    cd dev
    git clone git@cubie:jvermeir/cubie.git
      
### Webserver

    cd
    cd dev/cubie/web
    python3 webserver.py    

### iptables 

see https://help.ubuntu.com/community/IptablesHowTo

    cd ~/dev/cubie/install
    source iptables_install.sh
    
### Ip address

add to `/boot/armbianEnv.txt`
    
    ethaddr=00:e0:4c:9b:33:4f
    eth0addr=00:e0:4c:9b:33:4f
    eth1addr=00:e0:4c:9b:33:4f
        
### OSX network 

show routing table:

    netstat -rn
    
----
----
----

### Meuk below

use `nmcli`

    https://www.golinuxcloud.com/nmcli-command-examples-cheatsheet-centos-rhel/
    https://www.tecmint.com/nmcli-configure-network-connection/

start nmcli tool for connection named `internet`
    
    nmcli con edit ethernet

    # make sure router always gives out the same address: ???
    set 802-3-ethernet.mac-address 06:4f:fb:48:bf:d0
    set 802-3-ethernet.cloned-mac-address 06:4f:fb:48:bf:d0

    save
    quit 
        

obsolete network settings:
    
    set ipv4.addresses 192.168.2.250
    set ipv4.gateway 192.168.2.254
    set ipv4.dns 8.8.8.8
    
somehow connecting with ssh stops working if we've got a static ip address


### Settings

color settings for vi:

Copy `install/.vimrc` to home folder

### mac address problems

	https://github.com/debian-pi/raspbian-ua-netinst/issues/471
	
	edit /etc/network/interfaces.d/wlan0 file and put there:

	auto wlan0
	iface wlan0 inet dhcp
  		pre-up /sbin/ip link set dev wlan0 address xx:xx:xx:xx:xx:xx
      


## 1st try

Set up network for static IP

	https://linuxconfig.org/how-to-setup-a-static-ip-address-on-debian-linux
	
vi /etc/network/interfaces
	
replace eth0 config with:

	auto eth0
	iface eth0 inet static
	      address 192.168.2.250
	      netmask 255.0.0.0
	      gateway 192.168.2.254
	      dns-nameservers 8.8.8.8 8.8.4.4
	      pre-up ifconfig eth0 hw ether 22:22:6a:31:2f:ec

or try (TODO: check if this works) 

    https://github.com/armbian/config
    
### Firewall rules

	https://forum.armbian.com/topic/152-firewall-to-install-on-armbian/
	https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-iptables-on-ubuntu-14-04
	https://kerneltalks.com/virtualization/how-to-reset-iptables-to-default-settings/
	
Copy `install/iptables_install.sh` and execute. Then

	iptables-save > /etc/iptables/rules.v4
	
This causes loss of ipv4 address. Connecting to the ipv6 address doesn't work (https://www.myhowtoonline.com/how-to-ssh-to-an-ipv6-address/)

Assign ipv4 address:

    # https://www.wikihow.com/Assign-an-IP-Address-on-a-Linux-Computer)	
    ifconfig eth0 192.168.2.250

Add this to ~/.bashrc in root home folder:

    ifconfig eth0 192.168.2.250
    	



doesn't work yet, see:

	https://askubuntu.com/questions/119393/how-to-save-rules-of-the-iptables	
nope:
	
	echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
	echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
	sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
	apt-get -o Acquire::Check-Valid-Until=false update	
	
disabled network service. nope	
	# systemctl stop NetworkManager.service
    # systemctl disable NetworkManager.service


http://docs.cubieboard.org/resources

https://www.raspberrypi.org/documentation/installation/installing-images/linux.md

http://www.kaltpost.de/?p=1752

nand (not for sd card) image: http://dl.cubieboard.org/software/a20-cubieboard/debian/cb2-debian-zh/
sudo dd if=cb2-debian-desktop-nand-zh.img of=/dev/sdc bs=4M

lubuntu image:

	http://dl.cubieboard.org/software/a20-cubieboard/lubuntu/
	curl http://dl.cubieboard.org/software/a20-cubieboard/lubuntu/cb-a20-lubuntu-server-13.06-v1.00.img.gz > cb-a20-lubuntu-server-13.06-v1.00.img.gz
	gunzip cb-a20-lubuntu-server-13.06-v1.00.img.gz
	
	no filesytem:
	sudo dd if=cb-a20-lubuntu-server-13.06-v1.00.img of=/dev/sdb1 bs=4M
	
	no filesystem:
	sudo dd if=cb-a20-lubuntu-server-13.06-v1.00.img of=/dev/sdb bs=4M
	
	wrong imgage? 
	curl http://dl.cubieboard.org/software/a20-cubieboard/lubuntu/cb-a20-lubuntu-desktop-card-v105.img.gz > cb-a20-lubuntu-desktop-card-v105.img.gz
	gunzip cb-a20-lubuntu-desktop-card-v105.img.gz
	sudo dd if=cb-a20-lubuntu-desktop-card-v105.img of=/dev/sdb bs=4M

https://github.com/cubieplayer/Cubian

https://wiki.debian.org/InstallingDebianOn/Allwinner

https://wiki.debian.org/InstallingDebianOn/Allwinner

