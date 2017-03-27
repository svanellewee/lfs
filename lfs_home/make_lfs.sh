export LFS=/mnt/lfs
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo lfs | passwd lfs --stdin
if [[ ! -d ${LFS}/tools ]]; then
    echo "no tools dir yet"
    exit 1;
fi
#chown -v lfs ${LFS}/tools
#su - fs
