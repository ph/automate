(define-module (automate system hellboy)
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
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services pm)
  #:use-module (gnu services base)
  #:use-module (gnu services xorg) 
  #:use-module (gnu services docker)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1))

(define %hellboy-os
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

((compose +profile/thinkpad-x1-carbon) %hellboy-os)
