;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(use-modules (gnu)
	     (guix packages)
	     (gnu services networking)
	     (gnu services dbus)
	     (gnu services docker)
	     (gnu services linux)
	     (rosenthal services web)
	     (automate common)
	     (gnu packages ssh))

(use-service-modules cups
		     desktop
		     networking
		     ssh
		     sysctl
		     virtualization)

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

(define %my-packages
  (map specification->package (list
			       "neovim"
			       "rsync"
			       "mosh")))

(define %deploy-web
  (user-account
   (name "deploy-web")
   (comment "deploy web")
   (group "users")
   (supplementary-groups '("caddy"))))

(operating-system
 (host-name "azzael.supervoid.org")
 (timezone "America/Toronto")
 (locale "en_US.utf8")
 (bootloader (bootloader-configuration
	      (bootloader grub-bootloader)
	      (targets '("/dev/vda"))
	      (terminal-outputs '(console))))
 (groups (cons*
	  (user-group (system? #t)
		      (name "realtime"))

	  (user-group (system? #t)
		      (name "plugdev"))
	  %base-groups))
 (packages (append
	    %my-packages
	    %base-packages))

 (users (cons* %ph
	       %deploy-web
	       %base-user-accounts))

 (file-systems (cons (file-system
		      (mount-point "/")
		      (device "/dev/vda2")
		      (type "ext4"))
		     %base-file-systems))
 (services
  (append (list (service dhcpcd-service-type)
		(service caddy-service-type
			 (caddy-configuration
			  (caddyfile (local-file "caddyfile"))))
		(simple-service 'www activation-service-type
				(with-imported-modules '((guix build utils))
				  #~(begin
				      (use-modules (guix build utils))

				      (let* ((paths (list "/var/www"
							  "/var/www/supervoid.org"))
					     (pw (getpwnam "caddy"))
					     (caddy-user (passwd:uid pw))
					     (caddy-group (passwd:gid pw)))

					     (for-each (lambda (p)
							 (mkdir-p p)
							 (chown p caddy-user caddy-group)
							 (chmod p #o775)) paths)))))
		(service nftables-service-type
			 (nftables-configuration
			  (ruleset (local-file "nftables.conf"))))
		(service ntp-service-type)
		(service containerd-service-type)
		(service dbus-root-service-type)
		(service docker-service-type)
		(service elogind-service-type)
		(service earlyoom-service-type)
		(service openssh-service-type
			 (openssh-configuration
			  (openssh openssh-sans-x)
			  (permit-root-login #f)
			  (password-authentication? #f)
			  (authorized-keys
			   `(("root" ,(local-file "/home/ph/.ssh/id_rsa.pub"))
			     ("ph" ,(local-file "/home/ph/.ssh/id_rsa.pub"))
			     ("deploy-web" ,(local-file "../secrets/deploy.pub")))))))
	  %my-base-services)))
