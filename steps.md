Update the system clock
```bash
timedatectl status
```

## DISK PARTITION
```bash
fdisk -l
fdisk /dev/the_disk_to_be_partitioned
```

## INSTALLATION

``` bash
pacstrap /mnt base linux linux-firmware linux-headers grub efibootmgr vim nvim git
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock --systohc
```

Generate the fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Edit `/etc/locale.gen` and uncomment en_US.UTF-8 UTF-8. 
```
vim /etc/locale.gen
```
Generate the locales by running:
```bash
locale-gen
```

Create the `locale.conf` and set the LANG variable accordingly:
```bash
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```

Create the hostname file: /etc/hostname
```bash
myhostname
```

edit /etc/mkinitcpio.conf: add `encrypt` hook before `filesystem`


Create a new initramfs:
```bash
mkinitcpio -P
```

Set the root password:
```
passwd
```

## GRUB:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="logLevel=3 quiet splash vt.global_cursor_default=0 threadirqs iomen=relaxed"
```
```bash
grub-install --target=x86_64-efi --efi-directory=<boot> --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```


## AUDIO:
```bash
echo 2048 > /sys/class/rtc/rtc0/max_user_freq
echo 2048 > /proc/sys/dev/hpet/max-user-freq
```
Add `noatime` to /etc/fstab
```
#/dev/<rootpartition>
UUID=<UUID>     /       ext4    rw,relatime,noatime 0 1
```
