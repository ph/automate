(define-module (automate system hellboy)
  #:use-module (automate common)
  #:use-module (automate config home)
  #:use-module (automate microvm)
  #:use-module (automate config shared)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages games)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages)
  #:use-module (gnu services authentication)
  #:use-module (gnu services networking)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services linux)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sysctl)
  #:use-module (gnu system privilege)
  #:use-module (gnu)
  #:use-module (guix gexp)
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
   (host-name "hellboy")
   (groups (cons*
	    (user-group (system? #t) (name "realtime"))
	    (user-group (system? #t) (name "plugdev"))
	    %base-groups))
   (users (cons* %ph
		 %base-user-accounts))
   (packages (append
	      %my-packages
	      %base-packages))
   (services
    (append (list
	     (microvm-bridge-networking-service-type)

	   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	     ;; (service microvm-tap-service-type
	     ;; 	    (microvm-tap-configuration
	     ;; 	     (bridge "virbr0")
	     ;; 	     (tap "tap3")))

	     ;; (service microvm-service-type
	     ;; 	    (microvm-configuration
	     ;; 	     (microvm-config
	     ;; 	      (microvm
	     ;; 	       (name "complex-vm")
	     ;; 	       (boot %microvm-base-os)
	     ;; 	       (vmm cloud-hypervisor)
	     ;; 	       (memory 256)
	     ;; 	       (vcpu 1)
	     ;; 	       (net (list (net
	     ;; 			   (name "tap3")
	     ;; 			   (type 'tap)
	     ;; 			   (mac "02:00:00:00:00:05"))))
	     ;; 	       (shares
	     ;; 		(list (share
	     ;; 		       (tag "src")
	     ;; 		       (shared-dir "/home/ph/src/")
	     ;; 		       (mount-point "/home/ph/src/")
	     ;; 		       (readonly? #f)
	     ;; 		       (type "virtiofs")
	     ;; 		       (fs-options
	     ;; 			(fs-options
	     ;; 			 (flags '())
	     ;; 			 (needed-for-boot? #t)
	     ;; 			 (create-mount-point? #t))))
	     ;; 		      (share
	     ;; 		       (tag "creds")
	     ;; 		       (shared-dir "/home/ph/tmp/")
	     ;; 		       (mount-point "/root/creds/")
	     ;; 		       (readonly? #t)
	     ;; 		       (type "virtiofs"))
	     ;; 		      (share
	     ;; 		       (tag "documents")
	     ;; 		       (shared-dir "/home/ph/Documents/")
	     ;; 		       (mount-point "/home/microvm/Documents")
	     ;; 		       (type "virtiofs"))))))))

	   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	     (simple-service 'extend-sysctl
			     sysctl-service-type
			     '(("net.ipv4.ip_forward" . "1")
			       ("net.ipv6.conf.all.forwarding" . "1")))

	     (service guix-home-service-type
		      `(("ph" ,(automate-home-environment))))

	     ;; Doesn't work on my X1 carbon at the moment, weird usb issue.
	     ;; lets retry on kernel 7.0
	     ;; (service fprintd-service-type
	     ;; 	    (fprintd-configuration
	     ;; 	     (fprintd fprintd/ph)));;;

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
		       (ruleset (plain-file "nftables.rules" %microvm-nftables-rules))))
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
   (privileged-programs
    (cons (privileged-program
	   (program (file-append qemu "/libexec/qemu-bridge-helper"))
	   (setuid? #t))
	  %default-privileged-programs))
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

(define* (+group group-name
		 #:key
		 (system #f))
  (lambda (os)
    (operating-system
     (inherit os)
     (groups (cons*
	      (user-group
	       (name group-name)
	       (system? #t))
	      (operating-system-groups os))))))

;; (define (add-service service)   )

;; (define +firewall
;;   (add-service))

 %hellboy
