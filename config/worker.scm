;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
(load "./shared.scm")
(use-modules (gnu)
	     (automate common)
	     (gnu packages ssh)
	     (gnu services dbus)
	     (gnu services docker)
	     (gnu services cuirass)
	     (gnu services avahi)
	     (nongnu packages linux)
	     (nongnu system linux-initrd)
	     (rosenthal services networking)
	     (gnu services networking)
	     (guix packages)
	     (gnu packages ssh))

(use-service-modules cups
		     desktop
		     networking
		     ssh
		     sysctl
		     virtualization)


(define (worker-node host)
  (operating-system
   (locale "en_CA.utf8")
   (timezone "America/Toronto")
   (keyboard-layout (keyboard-layout "us"))
   (host-name host)
   (kernel linux)
   (bootloader (bootloader-configuration
		(bootloader grub-bootloader)
		(targets (list "/dev/sda"))
		(keyboard-layout keyboard-layout)))
   (initrd microcode-initrd)
   (initrd-modules
    (cons* "sd_mod"
	   "virtio_scsi" ;; for vm
	   %base-initrd-modules))
   (firmware (list linux-firmware))
   (sudoers-file
    (plain-file
     "sudoers" "deploy ALL = NOPASSWD: ALL\n"))
   (kernel-arguments
    (cons* "kernel.sysrq=0"
	   "zswap.enabled=1"
	   "zswap.max_pool_percent=90"
	   %default-kernel-arguments))

   (users (cons*
	   %user/deploy
	   %base-user-accounts))

   (packages (append
	      %installer-disk-utilities
	      %base-packages))

   (services
    (append (list
	     (simple-service 'extend-sysctl
			     sysctl-service-type
			     '(("net.ipv4.ip_forward" . "1")
			       ("net.ipv6.conf.all.forwarding" . "1")))
	     (simple-service 'extend-guix
			     guix-service-type
			     (guix-extension
			      (substitute-urls
			       (append (list "https://substitutes.nonguix.org"
					     "https://ci.supervoid.org")
				       %default-substitute-urls))
			      (authorized-keys
			       (append %guix-keyring-all
				       %default-authorized-guix-keys))))
	     (service dhcpcd-service-type)
	     (service avahi-service-type)
	     (service ntp-service-type)
	     (service tailscale-service-type)
	     (service cuirass-remote-worker-service-type
		      (cuirass-remote-worker-configuration
		       (publish-port 5558)
		       (workers 1)
		       (systems '("x86_64-linux"))
		       (server "100.71.180.83:5555")
		       (substitute-urls
			`("https://ci.supervoid.org"
			  ,@%default-substitute-urls))))
	     (service openssh-service-type
		      (openssh-configuration
		       (openssh openssh-sans-x)
		       (permit-root-login #f)
		       (authorized-keys
			`(("deploy" , (plain-file "deploy.pub" %user/deploy/key))
			  ("deploy-web" , (local-file "../secrets/deploy.pub" )))))))
	    %base-services))
   (file-systems (cons*
		  (file-system
		   (device "/dev/sda1")
		   (mount-point "/")
		   (type "ext4"))
		  %base-file-systems))))
