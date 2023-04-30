#!/bin/bash

export KERNEL_VERSION="6.3"
export BUSYBOX_VERSION="1.33.2"

[[ $KERNEL_VERSION =~ ([0-9]*)\..* ]]
KERNEL_MAJOR_VERSION=${BASH_REMATCH[1]}

mkdir src
cd src
    if [ ! -f "linux-$KERNEL_VERSION.tar.xz" ]; then
        wget "https://cdn.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VERSION.x/linux-$KERNEL_VERSION.tar.xz"
    fi
    if [ ! -f "busybox-$BUSYBOX_VERSION.tar.bz2" ]; then
        wget "https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2"
    fi

    if [ ! -d "linux-$KERNEL_VERSION" ]; then
        tar -xvf linux-$KERNEL_VERSION.tar.xz
    fi

    if [ ! -d "busybox-$BUSYBOX_VERSION" ]; then
        tar -xvf busybox-$BUSYBOX_VERSION.tar.bz2
    fi

    cd ./linux-$KERNEL_VERSION
        make defconfig
        make -j8 || exit
    cd ../

    cd ./busybox-$BUSYBOX_VERSION
        make defconfig
        echo "CONFIG_STATIC=y" >> .config
        make -j8 || exit
    cd ../
cd ../

cp src/linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage ./

mkdir initrd
cd initrd
    mkdir bin dev proc sys
    cd bin
        cp ../../src/busybox-$BUSYBOX_VERSION/busybox .
        for i in $(busybox --list); do
            ln -s busybox $i
        done
    cd ../
    cat > init <<'EOF'
#!/bin/sh
mount -t sysfs sysfs /sysfs
mount -t proc proc /proc
mount -t devtmpfs udev /dev
clear
echo "I have booted"
ln -sf /dev/console /dev/tty2
ln -sf /dev/console /dev/tty3
ln -sf /dev/console /dev/tty3
/bin/sh
echo "You have killed me. I shall retun on the next boot!!!!!!!!!!!"
poweroff -f
EOF

    find . | cpio -o -H newc > ../initrd.img
cd ../