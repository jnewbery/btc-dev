Resize a Hard Disk for a Virtual Machine
========================================

Our Virtual Machines are provisioned using Vagrant from a Linux base box to run using VirutalBox. If the Hard Disk space runs out and you cannot remove files to free-up space, you can resize the Hard Disk using some VirtualBox and Linux commands.

Some assumptions
----------------

The following steps assume you've got a set-up like mine, where:

- you use a Cygwin or Linux command-line terminal on your host machine
- the VirtualBox install path is in your Windows (and therefore Cygwin bash) PATH environment variable
- the vagrant boxes live at the path `provisioning/boxes/mybox`
- your Cygwin `HOME` path is the same as your Windows `%USERPROFILE%` (see [How do I change my Cygwin HOME folder after installation](http://stackoverflow.com/questions/1494658/how-can-i-change-my-cygwin-home-folder-after-installation/11182877#11182877))
- VirtualBox creates new Virtual Machines in the default location `~/VirtualBox\ VMs/` 

Steps to resize the hard disk
-----------------------------

1. Stop the virtual machine using Vagrant.

        # cd provisioning/boxes/mybox
        # vagrant halt

2. Locate the VirtuaBox VM and the HDD attached to its SATA Controller. In this instance we're assuming the VM is located in the default location and is named `mybox_default_1382400620`.

        # cd ~/VirtualBox\ VMs/mybox_default_1382400620
        # VBoxManage showvminfo mybox_default_1382400620 | grep ".vmdk"

    The `showvminfo` command should show you the location on the file-system of the HDD of type VMDK along with the name of the Controller it is attached to - it will look something like this:
    
        SATA Controller (0, 0): C:\Users\user.name\VirtualBox VMs\mybox_default_1382400620\box-disk1.vmdk (UUID: 2f79610e-6c06-46d5-becb-448386ea40ec)

3. clone the VMDK type disk to a VDI type disk so it can be resized.

        # cd ~/VirtualBox\ VMs/mybox_default_1382400620
        # VBoxManage clonehd "box-disk1.vmdk" "clone-disk1.vdi" --format vdi

    _NOTE: We do this because VMDK type disks cannot be resized by VirtualBox. It has the added benefit of allowing us to keep our original disk backed-up during the resize operation._

3. Find out how big the disk is currently, to determine how large to make it when resized. The information will show the current size and the Format variant. If Dynamic Allocation was used to create the disk, the Format variant will be "dynamic default".

        # VBoxManage showhdinfo "clone-disk1.vdi"

3. Resize the cloned disk to give it more space. The size argument below is given in Megabytes (1024 Bytes = 1 Megabyte). Because this disk was created using _dynamic allocation_ I'm going to resize it to 100 Gigabytes. 
 
        # VBoxManage modifyhd "clone-disk1.vdi" --resize 102400

    _NOTE: If the disk was created using_ dynamic allocation _(see previous step) then the_ physical size _of the disk will not need to match its_ logical size _- meaning you can create a very large logical disk that will increase in physical size only as space is used._

    _TIP: To [convert a Gigabyte value into Megabytes](http://www.conversion-metric.org/filesize/gigabytes-to-megabytes) use an online calculator._

3. Find out the name of the Storage Controller to attach the newly resized disk to. 

        # VBoxManage showvminfo mybox_default_1382400620 | grep "Storage"

3. Attach the newly resized disk to the Storage Controller of the Virtual Machine. In our case we're going to use the same name for the Storage Controller, `SATA Controller`, as revealed in the step above. 

        # VBoxManage storageattach mybox_default_1382400620 --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium clone-disk1.vdi

3. Reboot the Virtual Machine using Vagrant.

        # cd provisioning/boxes/mybox
        # vagrant up

3. Open a command-line shell as root on the Virtual Machine via ssh.

        # vagrant ssh
        # sudo su -

3. Find the name of the logical volume mapping the file-system is on (ie. `/dev/mapper/VolGroupOS-lv_root`).

        # df 

4. Find the name of the physical volume (or device) that all the partitions are created on (ie. `/dev/sda`).

        # fdisk -l

3. Create a new primary partition for use as a Linux LVM

        # fdisk /dev/sda

    1. Press `p` to print the partition table to identify the number of partitions. By default there are two - `sda1` and `sda2`.
    1. Press `n` to create a new primary partition. 
    1. Press `p` for primary.
    1. Press `3` for the partition number, depending the output of the partition table print.
    1. Press Enter two times to accept the default First and Last cylinder.
    1. Press `t` to change the system's partition ID
    1. Press `3` to select the newly creation partition
    1. Type `8e` to change the Hex Code of the partition for `Linux LVM`
    1. Press `w` to write the changes to the partition table.


3. Reboot the machine, then ssh back in when it is up again and switch to the root user once more.

        # reboot
        # vagrant ssh
        # sudo su -

3. Create a new physical volume using the new primary partition just created.

        # pvcreate /dev/sda3

3. Find out the name of the Volume Group that the Logical Volume mapping belongs to (ie. `VolGroupOS`).

        # vgdisplay

3. Extend the Volume Group to use the newly created physical volume.

        # vgextend VolGroupOS /dev/sda3

3. Extend the logical volume to use more of the Volume Group size now available to it. You can either tell it to add a set amount of space in Megabytes, Gigabytes or Terabytes, and control the growth of the Disk:

        # lvextend -L+20G /dev/mapper/VolGroupOS-lv_root

    Or if you want to use all the free space now available to the Volume Group:

        # lvextend -l +100%FREE /dev/mapper/VolGroupOS-lv_root

3. Resize the file-system to use up the space made available in the Logical Volume 

        # resize2fs /dev/mapper/VolGroupOS-lv_root

3. Verfiy that there is now more space available

        # df -h 

3. A restart of the VM using vagrant may be a good idea here, to ensure that all services are running correctly now that there is more space available. Exit the root user, exit the vagrant user and ssh session, then tell vagrant to restart the machine.

        # exit
        # exit
        # vagrant reload --provision

