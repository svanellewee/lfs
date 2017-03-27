# https://isotope11.com/blog/linux-from-scratch-part-1
# http://nairobi-embedded.org/transfering_buildroot_fs_data_into_qemu_disk_images.html
IMAGE=disk-img.raw
IMAGE_SIZE=8.1G
# 6 Gig ext2, 2 Gig Swap, 100meg bootn
$(IMAGE):
	qemu-img create -f raw $(IMAGE) $(IMAGE_SIZE)

# loop0: $(IMAGE)
# 	sudo losetup /dev/loop0 $(IMAGE)

# uloop0:
# 	sudo losetup -d /dev/loop0

# make-filesys:
# 	./make-filesys.sh /dev/loop0

clean:
	rm -fr $(IMAGE)
