;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (babayaga)
  #:use-module (automate common)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gnome)
  #:use-module (guix records)
  #:use-module (gnu services)
  #:use-module (gnu services admin)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services nfs)
  #:use-module (gnu services configuration)
  #:use-module (gnu services containers)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages)
  #:use-module (guix modules)
  #:use-module (guix gexp)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages printers)
  #:use-module (nongnu system linux-initrd)
  #:use-module (automate microvm)
  #:use-module (microvm)
  #:use-module (microvm gnu services virtiofsd)
  #:use-module (microvm gnu services microvm)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26))

(load "./shared.scm")


(use-service-modules desktop
		     cups
		     networking
		     mcron
		     linux)

(operating-system
 (kernel linux-6.19)
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

 (sudoers-file
  (plain-file "sudoers"
	      (string-join
	       (append %sudoers-default-content
		       (sudoers-content-for-users (list %ph)))
	       "\n")))
 (packages (append
	    %my-packages
	    %base-packages))
 (services
  (append (list
	   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	   (microvm-bridge-networking-service-type)
	   (microvm-extra-special-file-qemu-host-conf)

	   (service microvm-service-type
		    (microvm-configuration
		     (microvm-config
		      (microvm
		       (name "test-machine-1")
		       (os %microvm-base-os)
		       (hypervisor hypervisor-cloud-hypervisor)
		       (memory 1024)
		       (vcpu 1)
		       ;; TODO(ph): required or not?
		       ;; (update-filesystem? #t)
		       (shares
			(list (microvm-share
			       (tag "store")
			       (shared-dir "/gnu/")
			       (mount-point "/gnu")
			       (type "virtiofs")
			       (readonly? #t))
			      ;; (microvm-share
			      ;;  (tag "tmp")
			      ;;  (shared-dir "/home/ph/tmp/")
			      ;;  (mount-point "/home/ph/tmp")
			      ;;  (type "virtiofs"))
			      ))))))

	   (simple-service 'microvm-tap
			   shepherd-root-service-type
			   (list (shepherd-service
				  (provision '(microvm-tap))
				  (requirement '(static-networking))
				  ;; (one-shot? #t)
				  (start #~(lambda _
					     (let (($ip #$(file-append iproute "/sbin/ip")))
					       (every (lambda (command)
							(zero? (apply system* command)))
						      (list `(,$ip "tuntap" "add" "name" "tap3" "mode" "tap")
							    `(,$ip "link" "set" "tap3" "master" "virbr0") ;; This might be static-networking
							    `(,$ip "link" "set" "tap3" "up")))))))))
	   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	   (udev-rules-service
	    'probe-rs %probe-rs-udev-rules)
	   (service sane-service-type)
	   (service cups-service-type
		    (cups-configuration
		     (web-interface? #t)
		     (log-level 'debug2)
		     (extensions
		      (list cups-filters
			    foomatic-filters
			    hplip-plugin))
		     (default-paper-size "A4")))

	 (service guix-publish-service-type
		  (guix-publish-configuration
		    (port 49637)
		    (compression '(("zstd" 19)))
		    (cache "/var/cache/guix/publish")
		    (ttl (* 180 24 3600))
		    (negative-ttl (* 2 60))))


	 (simple-service 'extend-kernel-module-loader
			 kernel-module-loader-service-type
			 '("sch_fq_pie" "tcp_bbr"))

	 (simple-service 'extend-sysctl
			 sysctl-service-type
			 '(("net.core.default_qdisc" . "fq_pie")
			   ("net.ipv4.tcp_congestion_control" . "bbr")
			   ;; https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
			   ("net.core.rmem_max" . "7500000")
			   ("net.core.wmem_max" . "7500000")))

	 (simple-service 'extend-guix
			 guix-service-type
			 (guix-extension
			  (substitute-urls
			   (append (list
				    "https://cache-cdn.guix.moe"
				    ;; "https://substitutes.nonguix.org"
				    "https://substitutes.supervoid.org")
				   %default-substitute-urls))
			  (authorized-keys
			   (append %guix-keyring-all
				   %default-authorized-guix-keys))))

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
