;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (babayaga)
  #:use-module (automate common)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (guix records)
  #:use-module (gnu services)
  #:use-module (gnu services admin)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services configuration)
  #:use-module (gnu services containers)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages)
  #:use-module (guix modules)
  #:use-module (gnu)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages printers)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26))

(load "./shared.scm")

;;

(define (user-or-group-id? val)
  (or (integer? val)
      (eqv? val #f)))

(define-configuration/no-serialization  docker-arm-configuration
  (data-directory
   (string "/var/lib/docker-arm")
   "Directory to store Docker ARM data.")
  (log-file
   (string "/var/log/docker-arm.log")
   "Path to log file.")
  (shepherd-requirement
   (list-of-symbols '())
   "List of Shepherd service dependencies.")
  (group-id
   (user-or-group-id 1001)
   "Group ID/GID")
  (user-id
   (user-or-group-id 1001)
   "User ID/UID")
  (image
   (string "automaticrippingmachine/automatic-ripping-machine:latest")
   "Image to user for docker, default will use the latest")
  (options
   (alist '(
	    ))
   "Alist of Docker ARM configuration.  See also
@url{https://github.com/automatic-ripping-machine/automatic-ripping-machine/wiki/docker}.")
  (extra-arguments
   (list '())
   "List of extra Docker arguments."))

(define arm-account
  (match-record-lambda <docker-arm-configuration>
		       (group-id user-id data-directory)
		       (list (user-group
			      (name "arm")
			      (id group-id)
			      (system? #t))
			     (user-account
			      (name "arm")
			      (group "arm")
			      (uid user-id)
			      (system? #t)
			      (comment "Automatic Ripping Machine user")
			      (home-directory data-directory)))))

(define arm-activation
  (match-record-lambda <docker-arm-configuration>
		       (data-directory)
		       (with-imported-modules
			(source-module-closure '((guix build utils)
						 (gnu build activation)))
			#~(begin
			    (use-modules (srfi srfi-26)
					 (guix build utils)
					 (gnu build activation))
			    (let ((user (getpwnam "arm"))
				  (home-dir (cut string-append #$data-directory <>)))
			      (mkdir-p/perms (home-dir "") user #o750)
			      (mkdir-p/perms (home-dir "/music") user #o755)
			      (mkdir-p/perms (home-dir "/logs") user #o755)
			      (mkdir-p/perms (home-dir "/media") user #o755)
			      (mkdir-p/perms (home-dir "/config") user #o755))))))

(define docker-arm-oci
  (match-record-lambda <docker-arm-configuration>
		       (data-directory log-file shepherd-requirement image options extra-arguments user-id group-id)
		       (let ((docker-arm-path (cut string-append data-directory <>)))
			 (oci-extension
			  (containers
			   (list (oci-container-configuration
				  (provision "docker-arm")
				  (network "host")
				  (environment `(("ARM_UID" . ,(number->string user-id))
						 ("ARM_GID" . ,(number->string group-id))
						 ,@options))
				  (log-file log-file)
				  (requirement shepherd-requirement)
				  (image image)
				  (volumes
				   `((,(docker-arm-path "") . "/home/arm")
				     (,(docker-arm-path "/music") . "/home/arm/music")
				     (,(docker-arm-path "/logs") . "/home/arm/logs")
				     (,(docker-arm-path "/media") . "/home/arm/media")
				     (,(docker-arm-path "/config") . "/etc/arm/config")))
				  (extra-arguments extra-arguments))))))))

(define docker-arm-service-type
  (service-type
   (name 'docker-arm)
   (extensions
    (list
     (service-extension account-service-type
			arm-account)
     (service-extension activation-service-type
			arm-activation)
     (service-extension oci-service-type
			     docker-arm-oci)
	  (service-extension log-rotation-service-type
			     (compose list docker-arm-configuration-log-file))))
   (default-value (docker-arm-configuration))
   (description "Run Docker Automatic Ripping Machine.")))

(use-service-modules desktop
		     cups
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

	 (service docker-arm-service-type
		  (docker-arm-configuration
		   (options '("TZ" . "Toronto"))))

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
			   (append (list "https://substitutes.nonguix.org"
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
