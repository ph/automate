;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(use-modules (gnu)
	     (guix packages)
	     (gnu services networking)
	     (gnu packages ssh)
	     (nongnu packages linux)
	     (nongnu system linux-initrd)
	     (rosenthal services networking))
(use-service-modules cups desktop networking ssh sysctl)


(define %my-base-services
  (modify-services %base-services
		   (sysctl-service-type config =>
					(sysctl-configuration
					 (settings (append '(("net.ipv4.ip_forward" . "1")
							     ("net.ipv6.conf.all.forwarding" . "1"))
							   %default-sysctl-settings))))
		   (guix-service-type config => (guix-configuration
						 (inherit config)
						 (substitute-urls
						  (append (list
							   "https://nonguix-proxy.ditigal.xyz/"
							   ;;"https://substitutes.nonguix.org"
							   )
							  %default-substitute-urls))
						 (authorized-keys
						  (append (list (plain-file "nonguix-signing-key.pub"
									    "(public-key (ecc (curve ed25519) (q #c1fd53e5d4ce971933ec50c9f307ae2171a2d3b52c804642a7a35f84f3a4ea98#)))")
								(plain-file "babayaga-key.pub"
									    "(public-key (ecc (curve Ed25519) (q #36C0C6FEDCD7DD8BE2C0F26487618395B69D1806CE07943179A1305978716AC7#)))")
								(plain-file "hellboy-key.pub"
									    "(public-key (ecc (curve Ed25519) (q #9ED5CA01AED283053ACBF3D766D3A646D23EBF2A171DEFA92D29CA0485AC4DA7#)))"))
							  %default-authorized-guix-keys))))
		   (delete console-font-service-type)))

(operating-system
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "lusk.local.heyk.org")
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (users (cons*
	 (user-account
	  (name "ph")
	  (comment "Pier-Hugues Pellerin")
	  (group "users")
	  (home-directory "/home/ph")
	  (supplementary-groups '("wheel" "netdev" "audio" "video")))
	 %base-user-accounts))

 (services
  (append (list
	   (service wpa-supplicant-service-type
                  (wpa-supplicant-configuration
                   (interface "wlp2s0")
                   (dbus? #f)
                   (config-file (local-file "../secrets/lusk-wpa-supplicant.conf"))))
	   (service ntp-service-type)
	   (service tailscale-service-type)
	   (service dhcp-client-service-type)
	   (service openssh-service-type
		    (openssh-configuration
		     (openssh openssh-sans-x)
		     (permit-root-login #t)
		     (allow-empty-passwords? #f))))
          %my-base-services))

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


