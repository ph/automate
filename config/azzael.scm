;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(use-modules (gnu)
	     (guix packages)
	     (gnu services networking)
	     (gnu packages ssh))
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
 (host-name "azzael")
 (timezone "America/Toronto")
 (locale "en_US.utf8")
 (bootloader (bootloader-configuration
	      (bootloader grub-bootloader)
	      (targets '("/dev/vda"))
	      (terminal-outputs '(console))))

 (file-systems (cons (file-system
		      (mount-point "/")
		      (device "/dev/vda1")
		      (type "ext4"))
		     %base-file-systems))
 (services
  (append (list (service dhcp-client-service-type)
	   (service ntp-service-type)
	   (service openssh-service-type
		    (openssh-configuration
		     (openssh openssh-sans-x)
		     (permit-root-login 'prohibit-password)
		     (allow-empty-passwords? #f))))
	  %my-base-services)))
