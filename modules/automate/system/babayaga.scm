(define-module (automate system babayaga)
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

(define %babayaga-os
  (operating-system
   (kernel linux-7.0)
   (initrd microcode-initrd)
   (firmware (list linux-firmware sof-firmware))
   (locale "en_CA.utf8")
   (timezone "America/Toronto")
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (host-name "babayaga")
   (services %my-system-services)
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))

   (mapped-devices (list
		    (mapped-device
		     (source (uuid
			      "8ca0f0c0-f61a-4b38-ac71-0b67f7ee6528"))
		     (target "cryptroot-1")
		     (type luks-device-mapping))

		    (mapped-device
		     (source (uuid
			      "499fd9f1-a482-4e81-9fd4-6825c4fc54bb"))
		     (target "cryptroot-2")
		     (type luks-device-mapping))

		    (mapped-device
		     (source (uuid
			      "a7886b6b-6515-4b82-917d-f698d806c94b"))
		     (target "cryptboot")
		     (type luks-device-mapping))

		    (mapped-device
		     (source (uuid
			      "786c6f5d-b211-497b-9675-b45a6d47bc3e"))
		     (target "cryptsys")
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
		   (mount-point "/home/ph")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@ph")
		   (dependencies mapped-devices))

		  (file-system
		   (mount-point "/var/log")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@log")
		   (dependencies mapped-devices))

		  (file-system
		   (mount-point "/boot")
		   (device (file-system-label "boot-fs"))
		   (type "btrfs")
		   (options "subvol=@boot")
		   (dependencies mapped-devices))

		  (file-system
		   (mount-point "/boot/efi")
		   (device (uuid "BD1F-1A01" 'fat32))
		   (type "vfat"))

		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=40G")
		   (check? #f))
		  %base-file-systems))))

(define +profile/babayaga
  (compose +networking/increase-udp-buffer-size
	   +profile/desktop
	   +profile/development
	   +service/openssh
	   +system/substitutes
	   +networking/tailscale
	   +networking/dhcp
	   (+system/zram-device #:ram-size "129G")
	   +profile/ph))

(+profile/babayaga %babayaga-os)
