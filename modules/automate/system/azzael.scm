(define-module (automate system azzael)
  #:use-module (automate common)
  #:use-module (automate fragments)
  #:use-module (automate profile)
  #:use-module (automate config home)
  #:use-module (automate config shared)
  #:use-module (automate microvm)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu system)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system uuid)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system keyboard)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages)
  #:use-module (gnu services authentication)
  #:use-module (gnu services desktop)
  #:use-module (gnu services nix)
  #:use-module (gnu services linux)
  #:use-module (gnu services security)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services pm)
  #:use-module (gnu services dbus)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services xorg)
  #:use-module (gnu services docker)
  #:use-module (guix gexp)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1))

(define %nftables-rules
"
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state invalid drop
        ct state { established, related } accept
        iif lo accept # loopback
        iif != lo ip daddr 127.0.0.1/8 drop
        iif != lo ip6 daddr ::1/128 drop

        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        tcp dport 4222 accept
        tcp dport 22 accept

	# Mosh will log the user in via SSH, then start.
	# connection on a UDP port between 60000 and 61000.
	# from: https://mosh.org/
        udp dport 60000-61000 accept

	# allow tailscale
        tcp dport 41641 accept

        reject with icmpx type port-unreachable
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}"
  )

(define %azzael-os
  (operating-system
   (host-name "azzael")
   (timezone "America/Toronto")
   (locale "en_US.utf8")
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (list linux-firmware))
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))
   (swap-devices
    (list (swap-space (target (file-system-label "swap-1"))
		      (priority 10))
	  (swap-space (target (file-system-label "swap-2"))
		      (priority 5))))
   (file-systems (cons*
		  (file-system
		   (mount-point "/")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@"))

		  (file-system
		   (mount-point "/gnu")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@gnu,compress=zstd"))

		  (file-system
		   (mount-point "/nix")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@nix,compress=zstd"))

		  (file-system
		   (mount-point "/home")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@home"))

		  (file-system
		   (mount-point "/var/log")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@log,compress=zstd"))

		  (file-system
		   (mount-point "/.snapshots")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@snapshots"))

		  (file-system
		   (mount-point "/boot/efi")
		   ;; (device (uuid "4912-E257" 'fat32))
		   (device (file-system-label "EFIBOOT"))
		   (type "vfat"))

		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=100G")
		   (check? #f))
		  %base-file-systems))
   (services
    (cons*
     (service dbus-root-service-type)
     (service elogind-service-type)
     (service nftables-service-type
	      (nftables-configuration
	       (ruleset (plain-file "nftables.conf" %nftables-rules))))
     (service earlyoom-service-type)
     (service fail2ban-service-type
	      (fail2ban-configuration
	       (extra-jails
		(list (fail2ban-jail-configuration
		       (name "sshd")
		       (enabled? #t))))))
     %base-services))))

(define +profile/azzael
  (compose +networking/increase-udp-buffer-size
	   +service/containers
	   +profile/server
	   +system/pam-realtime-options
	   +profile/ph-shell))

(+profile/azzael %azzael-os)
