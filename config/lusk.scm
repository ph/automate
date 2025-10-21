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

(define %my-packages
  (map specification->package (list
			       "mosh")))

(operating-system
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "lusk")
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))

 (users (cons* %ph
	       %base-user-accounts))

 (packages (append
	    %my-packages
	    %base-packages))

 (groups (cons*
	  (user-group (system? #t)
		      (name "realtime"))

	  (user-group (system? #t)
		      (name "plugdev"))
	  %base-groups))

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
	   (service avahi-service-type)
	   (service ntp-service-type)
	   (service tailscale-service-type)
	   (service dhcpcd-service-type)
	   (service containerd-service-type)
	   (service dbus-root-service-type)
	   (service docker-service-type)
	   (service elogind-service-type)
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
		      `(("ph"
			 ,(local-file "/home/ph/.ssh/id_rsa.pub")))))))
	  %base-services))

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))

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
                 (options "subvol=@gnu"))

		(file-system
                 (mount-point "/nix")
                 (device (file-system-label "root-fs"))
                 (type "btrfs")
                 (options "subvol=@nix"))

		(file-system
                 (mount-point "/home")
                 (device (file-system-label "root-fs"))
                 (type "btrfs")
                 (options "subvol=@home"))

		(file-system
                 (mount-point "/.swap")
                 (device (file-system-label "root-fs"))
                 (type "btrfs")
                 (options "subvol=@swap"))

		(file-system
                 (mount-point "/boot/efi")
                 (device (uuid "3045-0217" 'fat32))
                 (type "vfat"))

		(file-system
		 (mount-point "/tmp")
		 (device "tmp")
		 (type "tmpfs")
		 (options "size=40G")
		 (check? #f))
		%base-file-systems))
 ;; This is somewhat problematic, there is no guixy way to create a swapfile
 ;; and creating them on btrfs is still a bit hairy.
 ;;
 ;; https://btrfs.readthedocs.io/en/latest/Swapfile.html
 ;; https://lists.gnu.org/archive/html/bug-guix/2019-02/msg00016.html
 (swap-devices (list (swap-space
		      (target "/.swap/swapfile")
		      (dependencies (filter (file-system-mount-point-predicate "/.swap")
					    file-systems))))))

