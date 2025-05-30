;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (babayaga)
  #:use-module (automate common)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1))

(use-service-modules desktop
		     networking
		     mcron
		     linux)

(operating-system
 (kernel linux-xanmod)
 (initrd microcode-initrd)
 (firmware (list linux-firmware sof-firmware))
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"
				   #:options '("ctrl:nocaps")))
 (host-name "babayaga.local.heyk.org")
 (groups (cons*
	  (user-group (system? #t)
		      (name "realtime"))

	  (user-group (system? #t)
		      (name "plugdev"))

	  %base-groups))
 (users (cons* %ph
	       %base-user-accounts))
 (packages (append
	    %my-packages
	    %base-packages))
 (services
  (append (list
	   (udev-rules-service
	    'probe-rs %probe-rs-udev-rules)
	   (service sane-service-type)

	   (service guix-publish-service-type
		    (guix-publish-configuration
		     (host "0.0.0.0")
		     (port 8181)
		     (advertise? #t)))

	   (service zram-device-service-type
		    (zram-device-configuration
		     (size "128G")
		     (compression-algorithm 'zstd)
		     (priority 100)))

	   (service bluetooth-service-type
		    (bluetooth-configuration
		     (bluez bluez)
		     (name host-name)
		     (auto-enable? #t)
		     (multi-profile 'multiple)))

	   (udev-rules-service 'steam-devices steam-devices-udev-rules)
	   (btrfs-maintenance-service '("/")))
	  %my-system-services))

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
		%base-file-systems)))
