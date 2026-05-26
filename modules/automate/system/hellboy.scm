(define-module (automate system hellboy)
  #:use-module (automate common)
  #:use-module (automate fragments)
  #:use-module (automate profile)
  #:use-module (automate config home)
  #:use-module (automate config shared)
  #:use-module (automate microvm)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages)
  #:use-module (gnu services authentication)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services nix)
  #:use-module (gnu services linux)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services pm)
  #:use-module (gnu services xorg) 
  #:use-module (gnu services docker)
  #:use-module (gnu services ssh)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sysctl)
  #:use-module (gnu system privilege)
  #:use-module (gnu)
  #:use-module (guix gexp)
  #:use-module (guix profiles)
  #:use-module (microvm config microvm)
  #:use-module (microvm gnu services microvm)
  #:use-module (microvm gnu services tap)
  #:use-module (microvm os)
  #:use-module (microvm vmm cloud-hypervisor)
  #:use-module (microvm)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rosenthal services networking)
  #:use-module (srfi srfi-1))

(define %hellboy
  (operating-system
   (kernel linux-7.0)
   (kernel-arguments (cons*
		      (format #f "lsm=~s"
			      (string-join '("landlock"
					     "yama"
					     "loadpin"
					     "safesetid"
					     "integrity"
					     "apparmor"
					     "selinux"
					     "smack"
					     "tomoyo") ","))
		      %default-kernel-arguments))
   (initrd microcode-initrd)
   (firmware (list linux-firmware sof-firmware))
   (locale "en_CA.utf8")
   (timezone "America/Toronto")
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (services %my-system-services)
   (host-name "hellboy")
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets '("/boot/efi"))
		(keyboard-layout keyboard-layout)))
   (mapped-devices (list
		    (mapped-device
		     (source (uuid "06068380-2848-4a1e-960f-a74aa930ba8f"))
		     (target "cryptroot")
		     (type luks-device-mapping))))
   (file-systems (cons*
		  (file-system
		   (mount-point "/")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@")
		   (dependencies mapped-devices))
		  (file-system
		   (mount-point "/gnu")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@gnu")
		   (dependencies mapped-devices))
		  (file-system
		   (mount-point "/nix")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@nix")
		   (dependencies mapped-devices))
		  (file-system
		   (mount-point "/home")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@home")
		   (dependencies mapped-devices))
		  (file-system
		   (mount-point "/boot/efi")
		   (device (uuid "4714-3B94" 'fat32))
		   (type "vfat"))
		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=40G")
		   (check? #f))
		  %base-file-systems))))

;; (define +hardware/fwupd
;;   (+service (service fwupd-service-type
;; 		     (fwupd-configuration
;; 		      (fwupd fwupd-nonfree)))))

(define +networking/tailscale
  (compose ;;(+packages '(tailscale)) ;; ensure it's available int PATH to login.
	   (+service (service tailscale-service-type))))

(define +networking/ip-forwarding
  (+service (simple-service 'sysctl-ip-forwarding
			    sysctl-service-type
			    '(("net.ipv4.ip_forward" . "1")
			      ("net.ipv6.conf.all.forwarding" . "1")))))


;; Increase UDP buffer size for data transfer, help with syncthing local transfer.
;; https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
(define +networking/increase-udp-buffer-size
  (+service (simple-service 'udp-buffer-size sysctl-service-type
			    '(("net.core.rmem_max" . "7500000")
			      ("net.core.wmem_max" . "7500000")))))

(define +vm/qemu-bridge-helper
  (+privileged-program
   (privileged-program
    (program (file-append qemu "/libexec/qemu-bridge-helper"))
    (setuid? #t))))

(define +profile/gaming
  (+service (udev-rules-service 'steam-devices steam-devices-udev-rules)))

(define +profile/ph
  (compose (+user %ph)
	   (+group (user-group
		    (system? #t)
		    (name "plugdev")))
	   (+service (service guix-home-service-type
			      `((,(user-account-name %ph) ,(automate-home-environment)))))))

(define +system/substitutes
  (+service (simple-service 'extend-guix
			    guix-service-type
			    (guix-extension
			     (substitute-urls
			      (append (list
				       "https://substitutes.supervoid.org"
				       "https://cache-cdn.guix.moe")
				      %default-substitute-urls))
			     (authorized-keys
			      (append %guix-keyring-all
				      %default-authorized-guix-keys))))))

(define +system/btrfs
  (+service (btrfs-maintenance-service '("/"))))

(define* (+system/zram-device #:key
			      (ram-size "32G"))
  (+service (service zram-device-service-type
		     (zram-device-configuration
		      (size ram-size)
		      (compression-algorithm 'zstd)
		      (priority 100)))))

(define +profile/bluetooth
  (lambda (os) 
    ((+service (service bluetooth-service-type
			(bluetooth-configuration
			 (bluez bluez)
			 (name (operating-system-host-name os))
			 (auto-enable? #t)
			 (multi-profile 'multiple)))) os)))

(define +service/containers
  (+service (service containerd-service-type)
	    (service docker-service-type)))

(define +system/pam-realtime-options
  (compose
   (+group (user-group
	    (system? #t)
	    (name "realtime")))
   (+service (service pam-limits-service-type
		      (list
		       (pam-limits-entry "@realtime" 'both 'rtprio 99)
		       (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)
		       (pam-limits-entry "*" 'both 'nofile 524288))))))

(define* (+service/nix #:key
		       (trusted-user "ph"))
  (+service (service nix-service-type
		     (nix-configuration
		      (extra-config '((format #f "trusted-users = ~a\n" trusted-user)
				      "extra-platforms = aarch64-linux arm-linux"))))))

(define +profile/development
  (compose +networking/ip-forwarding
	   +service/containers
	   (+service/nix)
	   +vm/qemu-bridge-helper))

(define +system/power-management
  (+service (service tlp-service-type
		     (tlp-configuration
		      (cpu-scaling-governor-on-ac (list "balanced"
							"performance"))
		      (cpu-scaling-governor-on-bat (list "low-power"))
		      (cpu-boost-on-ac? #t)
		      (cpu-boost-on-bat? #f)
		      (sched-powersave-on-bat? #t)))))

(define +service/openssh
  (+service (service openssh-service-type
		     (openssh-configuration
		      (openssh openssh-sans-x)))))

(define +service/sddm-login-manager
  (+service (service sddm-service-type
		     (sddm-configuration
		      (sddm sddm-qt5)
		      (theme "chili")
		      (xorg-configuration
		       (xorg-configuration
			(keyboard-layout
			 (keyboard-layout "us"
					  #:options '("ctrl:nocaps")))))))))

(define +profile/desktop
  (compose (+service (service sane-service-type)
		     (udev-rules-service 'probe-rs %probe-rs-udev-rules))
	   +system/pam-realtime-options
	   +service/sddm-login-manager
	   +profile/gaming
	   +profile/bluetooth))

(define +profile/thinkpad-x1-carbon
  (compose (+packages %my-packages)
	   (+service (udev-rules-service 'light light))
	   +networking/increase-udp-buffer-size
	   +profile/desktop
	   +profile/development
	   +service/openssh
	   +system/substitutes
	   +networking/tailscale
	   ;; +system/zram-device
	   +system/power-management
	   +profile/ph))

((compose +profile/thinkpad-x1-carbon) %hellboy)
