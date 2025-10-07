(use-modules (gnu services avahi)
	     (gnu services networking)
	     (gnu services ssh)
	     (gnu bootloader)
	     (gnu bootloader grub)
	     (gnu services base)
	     (gnu services sysctl)
	     (gnu services dbus)
	     (gnu services linux)
	     (gnu services desktop)
	     (gnu services docker)
	     (gnu system file-systems)
	     (gnu system keyboard)
	     (guix gexp)
	     (gnu packages)
	     (gnu packages disk)
	     (gnu packages rsync)
	     (rosenthal services web)
	     (gnu packages cryptsetup)
	     (gnu packages file-systems)
	     (gnu packages linux))


;; based on the list defined in guix/system/install.scm
(define %installer-disk-utilities
  (list parted
	gptfdisk
	ddrescue
	lvm2-static
	cryptsetup
	mdadm
	dosfstools
	btrfs-progs
	e2fsprogs
	rsync
	f2fs-tools
	jfsutils
	xfsprogs))

(define %packages
  (append %installer-disk-utilities
	  %base-packages))

(define %user/deploy/key
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiRJsoVbDvQYsRe94WC0kaRrru1+loCl6xZecdR4kEMfuJWz4NvyZNgD2q7KtXmQ+flvIdPuN0uxHbIzm+f1L500ZGoeOSo9GT2HPSJT8nUjgzLzKkwEs35uraxMQicjEnoUf9v+qx7s8Tv/mmKuMPrqMiNt337PlEL6llRkNtJ8srOd8pDXd40WOtHcPjRN0if78VnjESDTufAuqLoGs6yCe5j3QpcGlFneQ164AATwUMcuMQc9TVFc2pRjZRaWOFDSIAqF6NsaE3D4K6NvbTl8YIhi/seGKkvp6jfnv4T53JnY4TwbOEyPUS9dp3yfaz3NThy5r1AYAETz9s8mJC4KT2dKatShzU9tGGCyg409HNe/nOZQZrpBzfYLLwiBkxSZaCesJ0s4tyiKNW26asub0rM9DTnfCbcrEzzRtmCph3yZIC7yvNl3BAhKGIodsC07tk5zCR+kTyLntRBTIvev7Y98jz0/WA2Jaa3tQZCH8vhF0PCeiPh5c+z4A2z19ZdsLauKUs833Tj5amZg6H8t67pyFXGa2N8dptzsssk/BDEdO/YT6hohjEFI9kqtvNQbtTi6vwHjPCkpeV8MDRHWDNZsnLVz/2VR8oLH2suWDKGz4GlY0DfWRnmswu2rijGkD7U8eHt/6xrrtVxWZ9yJGnc90+RKz1LjwReRmkPw== openpgp:0xC6D3E079")

(define %user/deploy
  (user-account
   (name "deploy")
   (group "users")
   (comment "deploy configuration")
   (supplementary-groups '("audio" "video" "wheel"))
   (shell (file-append (specification->package "bash") "/bin/bash"))))

(define %user/root
  (user-account
    (inherit %root-account)
    (password #f)))

(define %user/deploy-web
  (user-account
   (name "deploy-web")
   (comment "deploy web")
   (group "users")
   (supplementary-groups '("caddy"))))

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

(define %os-remote-install
  (operating-system
   (host-name "azzael")
   (timezone "America/Toronto")
   (locale "en_US.utf8")
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))
   (swap-devices
    (list (swap-space (target (uuid "d84161ba-0dcc-4450-bc21-110537840390"))
		      (priority 10))
	  (swap-space (target (uuid "6da527c2-f4cc-4836-b226-64ba52ca71d5"))
		      (priority 5))))
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
		   (options "subvol=@gnu,compress=zstd"))

		  (file-system
		   (mount-point "/home")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@home"))

		  (file-system
		   (mount-point "/var/log")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@log,compress=zstd"))

		  (file-system
		   (mount-point "/.snapshots")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@snapshots"))

		  (file-system
		   (mount-point "/boot/efi")
		   (device (uuid "4912-E257" 'fat32))
		   (type "vfat"))

		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=100G")
		   (check? #f))
		  %base-file-systems))
   (users (cons*
	   %user/deploy
	   %user/deploy-web
	   ;; %user/root
	   %base-user-accounts))
   (sudoers-file
    (plain-file
     "sudoers" "deploy ALL = NOPASSWD: ALL\n"))
   (packages %packages)
   (services
    (cons*
     (service dhcpcd-service-type)
     (service nftables-service-type
	      (nftables-configuration
	       (ruleset (local-file "../files/plain/nftables.conf"))))
     (service ntp-service-type)
     (service containerd-service-type)
     (service dbus-root-service-type)
     (service earlyoom-service-type)
     (service docker-service-type)
     (service elogind-service-type)
     (service caddy-service-type
	      (caddy-configuration
	       (caddyfile (local-file "../files/plain/caddyfile"))))
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
     (service openssh-service-type
	      (openssh-configuration
	       (openssh (specification->package "openssh-sans-x"))
	       (password-authentication? #f)
	       (port-number 4222)
	       (authorized-keys
		`(("deploy" , (plain-file "deploy.pub" %user/deploy/key))
		  ("deploy-web" , (local-file "../secrets/deploy.pub" ))))))
     %my-base-services))))

%os-remote-install
