export LFS=/mnt/lfs
DISK_IMAGE=disk-img.raw
IMAGE_SIZE=8.1G
function make_image {
    echo "making image"
    qemu-img create -f raw ${DISK_IMAGE} ${IMAGE_SIZE}
}

function partition {
    echo "Setting up partitions"
    if [[ ! -f ${DISK_IMAGE} ]]; then
	echo "but let's first"
	make_image;
    fi
# taken from   https://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DISK_IMAGE}
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +100M # 100 MB boot parttion
  a # make bootable
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
  +2048M # default, extend partition to end of disk
  n # root partition
  p # 
  3 # 
    #
  +6000M #
  w # write the partition table
  q # and we're done
EOF

}


# Should now look like this
# fdisk -l disk-img.raw
#
# Disk disk-img.raw: 8.1 GiB, 8697309184 bytes, 16986932 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: dos
# Disk identifier: 0x06905a80

# Device        Boot   Start      End  Sectors  Size Id Type
# disk-img.raw1 *       2048   206847   204800  100M 83 Linux
# disk-img.raw2       206848  4401151  4194304    2G 83 Linux
# disk-img.raw3      4401152 16689151 12288000  5.9G 83 Linux

#
function do_losetup {
    echo "Now making loopbacks"
    if [[ ! -f ${DISK_IMAGE} ]]; then
       echo "but before that even.."
       partition;
    fi
    sudo losetup  /dev/loop0  ${DISK_IMAGE}
    sudo losetup --offset $((2048*512))    --sizelimit 100M  /dev/loop1 /dev/loop0
    sudo losetup --offset $((206848*512))  --sizelimit 2G    /dev/loop2 /dev/loop0
    sudo losetup --offset $((4401152*512)) --sizelimit 5.8G  /dev/loop3 /dev/loop0  # made sizelimit slightly smaller (5.8 instead of 5.9), seems puppylinux that I was overstating the number of valid blocks.
}

function format_fs {
    if [[ ! -f ${DISK_IMAGE} ]]; then
       echo "but before that even.."
       do_losetup;
    fi
    
    sudo mkfs -v -t ext4 /dev/loop1
    sudo mkfs -v -t ext4 /dev/loop3
    sudo mkswap /dev/loop2
}

function mount_root {
    if [[ ! -f ${DISK_IMAGE} ]]; then
	echo "format first..."
	format_fs;
    fi
    echo "mounting"
    sudo mkdir -p ${LFS}
    sudo mount -v -t ext4 /dev/loop3 ${LFS} 
}

SOURCE_DIR=./source
function get_sources {
    mkdir -p ${SOURCE_DIR}
    wget --input-file=wget-list --continue --directory-prefix=${SOURCE_DIR}
    pushd ${SOURCE_DIR}
    md5sum -c md5sums
    popd
}


opt=$1
case "${opt}" in
    "image")
	make_image
	;;
    "part")
	partition
	;;
    "lo")
	do_losetup
	;;
    "dof")
	format_fs
	;;
    "mnts")
	mount_root
	;;
    "src")
	get_sources
	;;
    "clean")
	sudo umount ${LFS}
	sudo losetup -d /dev/loop3
	sudo losetup -d /dev/loop2
	sudo losetup -d /dev/loop1
	sudo losetup -d /dev/loop0
	rm -fr ${DISK_IMAGE}
	;;
esac
