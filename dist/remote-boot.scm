;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
(use-modules (gnu services avahi)
	     (gnu services networking)
	     (gnu services ssh)
	     (gnu bootloader)
	     (gnu bootloader grub)
	     (gnu services base)
	     (gnu system file-systems)
	     (guix gexp)
	     (gnu packages)
	     (gnu packages disk)
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

(define %os-remote-install
  (operating-system
   (host-name "remote")
   (bootloader
    (bootloader-configuration
     (bootloader grub-efi-bootloader)
     (targets '("/boot/efi"))
     (theme
      (grub-theme
       (inherit (grub-theme))
       (resolution #f)))))
   (file-systems (cons*
		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=40G")
		   (check? #f))
		  %base-file-systems))
   (users (cons*
	   %user/deploy
	   %user/root
	   %base-user-accounts))
   (sudoers-file
    (plain-file
     "sudoers" "deploy ALL = NOPASSWD: ALL\n"))
   (packages %packages)
   (services
    (cons*
     (service dhcpcd-service-type)
     (service openssh-service-type
	      (openssh-configuration
	       (openssh (specification->package "openssh-sans-x"))
	       (password-authentication? #f)
	       (authorized-keys
		`(("deploy" , (plain-file "deploy.pub" %user/deploy/key))))))
     %base-services))))

%os-remote-install
