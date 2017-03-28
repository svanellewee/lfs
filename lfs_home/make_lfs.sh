# http://www.linuxfromscratch.org/lfs/view/stable/chapter04/settingenvironment.html
export LFS=/mnt/lfs
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo "lfs:lfs" | chpasswd
if [[ ! -d ${LFS}/tools ]]; then
    echo "no tools dir yet"
    exit 1;
fi
#chown -v lfs ${LFS}/tools
#su - fs
sudo cp ./dot.bashrc /home/lfs/.bashrc
sudo cp ./dot.bash_profile /home/lfs/.bash_profile
sudo chown lfs:lfs /home/lfs/.bash*

