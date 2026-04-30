#!/gnu/store/vhkg4avy9zf0kj70dcsmfpymnllkjq1y-bash-5.2.37/bin/sh
exec /gnu/store/vnnas5c9q6xdw6k1zk22sjdqb7yij8x0-qemu-minimal-10.2.1/bin/qemu-system-x86_64 \
     -M microvm \
     -nographic \
     -kernel /gnu/store/kkx6n9fgaayspnnkxxmn6546rf41vyc4-linux-libre-6.18.22/bzImage \
     -initrd /gnu/store/kz83h1nf41yh6asakb3fz9nabhwcx9nc-system/initrd \
     -append "console=ttyS0 root=/dev/vda1 gnu.system=/gnu/store/kz83h1nf41yh6asakb3fz9nabhwcx9nc-system gnu.load=/gnu/store/kz83h1nf41yh6asakb3fz9nabhwcx9nc-system/boot modprobe.blacklist=usbmouse,usbkbd quiet" \
     -enable-kvm \
     -object rng-random,filename=/dev/urandom,id=guix-vm-rng \
     -virtfs local,path=/gnu/store,security_model=none,mount_tag=TAGjoptajej2oynju6yvboauz7pl6uj \
     -drive file=/gnu/store/97qalzs17a8ph6g4i1vjbg20mljn8myr-disk-image,format=raw,if=virtio,cache=writeback,werror=report,readonly=on \
     -m 256 \
     -nic bridge,model=virtio-net-pci,br=virbr0,helper=/run/setuid-programs/qemu-bridge-helper "$@"

     # -device virtio-rng-pci,rng=guix-vm-rng \
