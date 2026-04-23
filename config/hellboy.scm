;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (hellboy)
  #:use-module (automate common)
  #:use-module (automate packages patches)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gnome)
  ;; #:use-module (gnu packages linux)
  #:use-module (gnu packages)
  #:use-module (gnu services authentication)
  #:use-module (gnu services docker)
  #:use-module (gnu services linux)
  #:use-module (gnu)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rosenthal services networking)
  ;; #:use-module (automate services fwupd)
  #:use-module (srfi srfi-1))

(load "./shared.scm")

(use-service-modules desktop
		     networking
		     mcron)

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

        reject with icmpx type port-unreachable
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
")
  

(operating-system
 (kernel linux-6.19)
 (kernel-arguments (append %default-kernel-arguments
			   ;; adding landlock
			   (list "lsm=\"landlock,yama,loadpin,safesetid,integrity,apparmor,selinux,smack,tomoyo\"")))
 (initrd microcode-initrd)
 (firmware (list linux-firmware sof-firmware))
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"
                                   #:options '("ctrl:nocaps")))
 (host-name "hellboy.local.heyk.org")
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
	   ;; Doesn't work on my X1 carbon at the moment, weird usb issue.
	   ;; lets retry on kernel 7.0
	   ;; (service fprintd-service-type
	   ;; 	    (fprintd-configuration
	   ;; 	     (fprintd fprintd/ph)))
	   ;; (simple-service 'fprintd-pam-login
	   ;; 		   pam-root-service-type
	   ;; 		   (list (pam-extension
	   ;; 			  (transformer
	   ;; 			   (lambda (pam)
	   ;; 			     (if (member (pam-service-name pam) '("sddm"))
	   ;; 				 (pam-service
	   ;; 				  (inherit pam)
	   ;; 				  (auth (cons (pam-entry
	   ;; 					       (control "sufficient")
	   ;; 					       (module (file-append fprintd/ph "/lib/security/pam_fprintd.so")))
	   ;; 					      (pam-service-auth pam))))
	   ;; 				 pam))))))
	   (service nftables-service-type
		    (nftables-configuration
		     (ruleset (plain-file "nftables.rules" %nftables-rules))))
	   (simple-service 'extend-guix
			   guix-service-type
			   (guix-extension
			    (substitute-urls
			     (append (list
				      ;; "https://substitutes.nonguix.org"
				      "https://substitutes.supervoid.org"
				      "https://cache-cdn.guix.moe")
				     %default-substitute-urls))
			    (authorized-keys
			     (append %guix-keyring-all
				     %default-authorized-guix-keys))))
	   (udev-rules-service
	    'probe-rs %probe-rs-udev-rules)
	   ;; (service fwupd-service-type
	   ;; 	    (fwupd-configuration
	   ;; 	     (fwupd fwupd-nonfree)))
	   (service sane-service-type)
	   (service tailscale-service-type)
	   (service zram-device-service-type
		    (zram-device-configuration
		     (size "32G")
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
		 (options "size=40G"
		 (check? #f))
		%base-file-systems)))
