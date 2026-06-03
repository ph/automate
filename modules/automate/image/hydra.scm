(define-module (automate image hydra)
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

(define %hydra-os
  (operating-system
   (host-name "hydra")
   (timezone "America/Toronto")
   (locale "en_US.utf8")
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))
   (swap-devices
    (list (swap-space (target (uuid "d84161ba-0dcc-4450-bc21-110537840390"))
		      (priority 10))))
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
		   (device (uuid "4912-E257" 'fat32))
		   (type "vfat"))

		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=50G")
		   (check? #f))
		  %base-file-systems))))

(define +profile/hydra
  (compose +profile/desktop
	   +service/openssh
	   +system/substitutes
	   +system/power-management
	   +profile/deployable
	   +profile/ph))

(+profile/hydra %hydra-os)
