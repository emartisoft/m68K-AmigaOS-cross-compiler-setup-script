#!/bin/sh
# https://github.com/emartisoft/m68K-AmigaOS-cross-compiler-setup-script
# Written by emarti, Murat Özdemir
# Special Thanks to @Alpyre and @Simon from www.commodore.gen.tr
# See LICENSE file for copyright and license details
# Rev. 2016 Jan 15

# Change the line below to define your own install folder
amigadevFolder=$HOME/AmigaDev

amigadevURL=git://github.com/cahirwpz/amigaos-cross-toolchain.git

calc_wt_size() 
{
  WT_HEIGHT=15
  WT_WIDTH=$(tput cols)
  
  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
}

# About
do_about()
{
  whiptail --title "About" --msgbox "\
m68K AmigaOS Cross Compiler Setup Script \
========================================
On Ubuntu (may be other debian based distrubution) \

to easy setup AmigaOS cross compiler \

[https://github.com/cahirwpz/amigaos-cross-toolchain] 

Special Thanks: \

 @Alpyre [https://github.com/alpyre] \

 @Simon [https://github.com/ozayturay] \



Created by emarti, Murat ÖZDEMİR \


Visit https://github.com/emartisoft/ \

for the latest in this project.\

Stay with Amiga :)
  " 24 60 1
}

# Install extra packages (dependencies and some useful tools)
do_preinstallation()
{
	sudo apt-get -y update && sudo apt-get -y install libncurses-dev python-dev patch gperf bison git 
}

# compile amigaos-cross-toolchain
do_compile()
{
	mkdir -p $amigadevFolder
	cd $amigadevFolder
	git clone $amigadevURL
	cd amigaos-cross-toolchain

	sudo chmod a+w /opt
	./toolchain-m68k --prefix=/opt/m68k-amigaos build
	./toolchain-m68k --prefix=/opt/m68k-amigaos install-sdk ahi cgx mui
	
	export PATH=/opt/m68k-amigaos/bin:$PATH	
}

# Support 32 bit architecture for x64
do_install_32bit_support() {
    	sudo apt-get install gcc-multilib -y
	sudo dpkg --add-architecture i386
	sudo apt-get -y update
	sudo apt-get -y dist-upgrade		
}

# gcc test
do_test()
{
	clear
	echo "     *****************************************"
	echo "     *  m68k-amigaos-gcc version testing  *"
  	echo "     *****************************************"
	export PATH=/opt/m68k-amigaos/bin:$PATH	
	if [ -f "/opt/m68k-amigaos/bin/m68k-amigaos-gcc" ];
	then	
		m68k-amigaos-gcc -v
		echo " "
		echo "     Amigaos-cross-toolchain already installed"
	else
		echo "     Amigaos-cross-toolchain not installed"
	fi
	echo "     *****************************************"
	echo "            Please, wait for 5 seconds..."
	sleep 5
}

# add m68k AmigaOS gcc binaries to .bashrc
do_add_bashrc()
{
	echo "# m68k AmigaOS gcc binaries" >> ~/.bashrc
	echo "export PATH=/opt/m68k-amigaos/bin:$PATH" >> ~/.bashrc
}  

# ld: cannot open -lmui: No such file or directory
do_copy_mui()
{
	cp /opt/m68k-amigaos/m68k-amigaos/libnix/lib/libmui.a /opt/m68k-amigaos/lib/gcc-lib/m68k-amigaos/2.95.3/
	cp /opt/m68k-amigaos/m68k-amigaos/libnix/lib/libdebug.a /opt/m68k-amigaos/lib/gcc-lib/m68k-amigaos/2.95.3/
}

# Amiga LhA
do_install_lha()
{
	if [ $(sudo dpkg-query -W -f='${Status}\n' jlha-utils | grep -c "ok installed") -eq 0 ]; then
		echo "Required packages not found, installing them now..."
		sudo apt-get -y update && sudo apt-get -y install jlha-utils
	#else
	#	do_already_installed	
	fi
}

# Flexible catalogs for Amiga
do_flexible_catalog()
{
	if [ -f "FlexCat-2.18.lha" ];
	then
		echo "FlexCat-2.18.lha file exist"
		sleep 2
	else
		wget aminet.net/dev/misc/FlexCat-2.18.lha
		lha -e FlexCat-2.18.lha FlexCat/Linux-i386/flexcat
		chmod a+x FlexCat/Linux-i386/flexcat
		cp FlexCat/Linux-i386/flexcat /opt/m68k-amigaos/bin/
	fi
}

# setting mui38dev header
do_mui38dev_header()
{
	if [ -f "mui38dev.lha" ];
	then
		echo "mui38dev.lha file exist"
		sleep 2
	else
		wget aminet.net/dev/mui/mui38dev.lha
		lha -e mui38dev.lha
		cp -R MUI/Developer/C/Include/* /opt/m68k-amigaos/lib/gcc-lib/m68k-amigaos/2.95.3/include
	fi
}

# Return to terminal
do_exit()
{
  exit 1
}

# download and compile Amigaos-cross-toolchain
do_install()
{
	do_preinstallation
	do_install_32bit_support
	do_install_lha
	do_compile
	do_add_bashrc
	do_mui38dev_header	
	do_copy_mui
	do_flexible_catalog
	sudo chmod u-w /opt
}

# whiptail?
if [ $(sudo dpkg-query -W -f='${Status}\n' whiptail | grep -c "ok installed") -eq 0 ]; then
	echo "Required packages not found, installing them now..."
	sudo apt-get -y update && sudo apt-get -y install whiptail lua5.2
fi
 
calc_wt_size

while true; do
	FUN=$(whiptail --title "m68K AmigaOS Cross Compiler Setup" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
	  "1 Install     " "Setup Amigaos-cross-toolchain" \
	  "2 GCC Test    " "m68k-amigaos-gcc version testing" \
	  "3 About       " "Information about this script" \
	  "4 Exit        " "Return to terminal" \
	  3>&1 1>&2 2>&3)
	RET=$?
	if [ $RET -eq 0 ]; then
	  case "$FUN" in
		
		1\ *) do_install ;;
		2\ *) do_test ;;
		3\ *) do_about ;;
		4\ *) do_exit ;;
		*) whiptail --msgbox "Programmer error: unrecognized option" 12 40 1 ;;
	  esac || whiptail --msgbox "There was an error running option $FUN" 12 40 1
	else
	  exit 1
	fi
done

