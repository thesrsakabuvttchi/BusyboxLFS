# BusyboxLFS
A simple implementation of a minimal Linux system created with busybox.

The code download and compiles the linux kernel and busybox and generates images for both the kernel and initrd.

To use the system run
` qemu-system-x86_64 -kernel bzImage -initrd initrd.img `
