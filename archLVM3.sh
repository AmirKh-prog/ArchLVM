#!/bin/bash
#part 3 of my arch installation script
#please make sure you edited the <> parts
#run this after you got into / (after chrooted into /mnt)
GREEN='\033[0;32m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

enter_to_continue()
{
    echo -e "${MAGENTA}Press Enter to continue${RESET}"
    read && clear
}
clear

#installing Kernel headers
echo -e "${GREEN}Installing kernel headers...${RESET}\n"
pacman -S linux-lts-headers linux-headers
enter_to_continue

#install some packages
echo -e "${GREEN}Installing some packages...${RESET}\n"
pacman --needed -S vim base-devel networkmanager wpa_supplicant wireless_tools netctl dialog lvm2 git reflector cups
enter_to_continue

#enable network manager & cups
echo -e "${GREEN}Enabling networkmanager and cups${RESET}\n"
systemctl enable NetworkManager
systemctl enable org.cups.cupsd
enter_to_continue

#enable lvm support
echo -e "${GREEN}Edit this file by adding ${RESET}${RED}lvm2 betweem block and filesystems in line HOOKS${RESET}"
enter_to_continue
vim /etc/mkinitcpio.conf
mkinitcpio -p linux
mkinitcpio -p linux-lts
enter_to_continue

#Edit this <>
#Time Zone
echo -e "${GREEN}Seting the timezone...${RESET}\n"
ln -sf /usr/share/zoneinfo/<Region/City> /etc/localtime #if you dont know about your region and city just type 'ls /usr/share/zoneinfo/' and find it
hwclock --systohc

#gen locale
echo -e "${GREEN}Uncomment your locale${RESET}"
enter_to_continue
vim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
enter_to_continue

#Hostname and hosts configs
echo -e "${GREEN}choose your hostname${RESET}"
read h
echo "$h" > /etc/hostname
echo -e "127.0.0.1         localhost\n::1               localhost\n127.0.1.1         $h.localdomain   $h" > /etc/hosts
clear

#password and creating normal user
echo -e "${GREEN}choose a root password${RESET}"
passwd
echo -e "${GREEN}Enter a username${RESET}"
read u
useradd -m -g users -G wheel "$u"
echo -e "${GREEN}and a password for $u${RESET}"
passwd "$u"
enter_to_continue

#configure sudo
echo -e "${GREEN}configuring sudo${RESET}"
echo -e "${RED}uncomment wheel ALL=(ALL) ALL${RESET}"
enter_to_continue
visudo

#setup grub
echo -e "${GREEN}installing grub...${RESET}"
pacman -S grub efibootmgr dosfstools mtools ntfs-3g
clear
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
echo -e "${GREEN}Press Enter and add \"lvm\" to the GRUB_PRELOAD_MODULES line ((if it's not already added))${RESET}"
read
vim /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
enter_to_continue

#creat swap file
#EDIT THIS
echo -e "${GREEN}Creating Swap file...${RESET}"
fallocate -l <2G> /swapfile #size of the swap file
chmod 600 /swapfile
mkswap /swapfile
cp /etc/fstab /etc/fstab.bak
echo "/swapfile none swap sw 0 0" >> /etc/fstab
enter_to_continue

#EDIT THIS (based on your pc drivers, you can look it up in 'lspci' command)

echo -e "${GREEN}Installing some driver and microcode...${RESET}"
#for intel and  nvidia
#pacman --needed -S intel-ucode xf86-video-intel libgl mesa nvidia nvidia-lts nvidia-utils nvidia-libgl nvidia-settings
#amd
#pacman --neede -S amd-ucode xf86-video-amdgpu mesa libgl

#To load microcodes you need to regenrate grub config
#grub-mkconfig -o /boot/grub/grub.cfg

#for virtual box
#pacman -S virtualbox-guest-utils xf86-video-vmware mesa

echo -e "${GREEN}type exit and press enter, then run 'umount -a'\nthen reboot the system or shut it down\n${RESET}${RED}GOOD LUCK!${RESET}"
