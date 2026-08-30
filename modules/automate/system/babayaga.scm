;;; SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

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
  #:use-module (gnu packages vim)
  #:use-module (gnu packages)
  #:use-module (gnu services authentication)
  #:use-module (gnu services desktop)
  #:use-module (gnu services nix)
  #:use-module (gnu services)
  #:use-module (gnu services containers)
  #:use-module (gnu services linux)
  #:use-module (guix gexp)
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
   (kernel linux-7.1)
   (initrd microcode-initrd)
   (firmware (cons* linux-firmware
		    amdgpu-firmware
		    %base-firmware))
   (locale "en_CA.utf8")
   (timezone "America/Toronto")
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (host-name "babayaga")
   (services %my-system-services)
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/efi"))
		(keyboard-layout keyboard-layout)))
   (mapped-devices
    (list (mapped-device
	   (source (uuid "a9b14713-e26c-43db-b8b5-111ab42962dd"))
	   (target "cryptroot-1") ;; /dev/nvme1n1p4
	   (type luks-device-mapping))

	  (mapped-device
	   (source (uuid "3294e5b1-6de2-4ba0-ad80-581896b86afb"))
	   (target "cryptroot-2") ;; /dev/nvme2n1p1
	   (type luks-device-mapping))

	  (mapped-device
	   (source (uuid "220eb590-1ddc-4613-93d1-7869db2d37ba"))
	   (target "cryptboot") ;; /dev/nvme1n1p3
	   (type luks-device-mapping))

	  (mapped-device
	   (source (uuid "a38a78fe-d839-45e0-a87b-3976c9cccaf5"))
	   (target "cryptsys") ;; /dev/nvme1n1p2
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
		   (create-mount-point? #t)
		   (mount-point "/nix")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@nix")
		   (dependencies mapped-devices))

		  (file-system
		   (create-mount-point? #t)
		   (mount-point "/home")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@home")
		   (dependencies mapped-devices))

		  (file-system
		   (mount-point "/home/ph")
		   (create-mount-point? #t)
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
		   (create-mount-point? #t)
		   (mount-point "/.snapshots")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@snapshots")
		   (dependencies mapped-devices))

		  (file-system
		   (mount-point "/boot")
		   (device (file-system-label "boot-fs"))
		   (type "btrfs")
		   (options "subvol=@boot")
		   (dependencies mapped-devices))

		  (file-system
		   (mount-point "/efi")
		   (check? #f)
                   (device (uuid "2451-0156" 'fat32))
		   (type "vfat"))

		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (check? #f)
		   (options "size=40G"))
		  %base-file-systems))))

(define +profile/babayaga
  (compose +profile/deployable
	   +profile/desktop
	   +profile/ph
	   +service/containers
	   (+service/nix)
	   (+service/openssh)
	   +system/substitutes
	   +networking/increase-udp-buffer-size
	   (+system/zram-device #:ram-size "129G")))

(+profile/babayaga %babayaga-os)

 ;; sudo guix time-machine -C ./channels.lock.scm -- \
 ;;   system init -L ./modules ./modules/automate/system/babayaga.scm /mnt/newroot

;; (+service
;;  (simple-service 'lemonade-directory activation-service-type
;; 		 #~(begin
;; 		     (use-modules (guix build utils))
;; 		     (mkdir-p "/var/lemonade/cache")
;; 		     (mkdir-p "/var/lemonade/llama")
;; 		     (mkdir-p "/var/lemonade/recipe"))))
;; (+service
;;  (simple-service 'lemonade-container oci-service-type
;; 		 (oci-extension
;; 		  (containers
;; 		   (list (oci-container-configuration
;; 			  ;; (image "ghcr.io/lemonade-sdk/lemonade-server:latest")
;; 			  (image "ghcr.io/lemonade-sdk/lemonade-server:latest")
;; 			  (provision "lemonade-server")
;; 			  (log-file "/var/log/lemonade-server.log")
;; 			  (ports '(("13305" . "13305")
;; 				   ("9000" . "9000")))
;; 			  (volumes '(("/var/lemonade/cache" . "/root/.cache/huggingface")
;; 				     ("/var/lemonade/llama" . "/opt/lemonade/llama")
;; 				     ("/var/lemonade/recipe" . "/root/.cache/lemonade")))
;; 			  (extra-arguments '("--device" "/dev/kfd"
;; 					     "--device" "/dev/dri"))))))))
