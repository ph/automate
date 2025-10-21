;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(use-modules (gnu packages disk)
	     (gnu packages cryptsetup)
	     (gnu packages rsync)
	     (gnu packages)
	     (guix gexp)
	     (gnu packages file-systems)
	     (gnu packages linux))

(define %guix-authorized-key-azzael
  (plain-file "azzael.pub"
	      "(public-key (ecc (curve Ed25519) (q #3AD8F8EEE317921EA26D2D735751060057C9D7E48D579DF22C3ABD28D050D394#)))"))

(define %guix-authorized-key-lusk
  (plain-file "lusk.pub"
	      "(public-key (ecc (curve Ed25519) (q #4F4C0B9B2688822F4E0AD65C930EDD6FC56610B5077C917E053FEAE2D952046C#)))"))

(define %guix-authorized-key-babayaga
  (plain-file "babayaga.pub"
	      "(public-key (ecc (curve Ed25519) (q #36C0C6FEDCD7DD8BE2C0F26487618395B69D1806CE07943179A1305978716AC7#)))"))

(define %guix-authorized-key-hellboy
  (plain-file "hellboy.pub"
	      "(public-key (ecc (curve Ed25519) (q #9ED5CA01AED283053ACBF3D766D3A646D23EBF2A171DEFA92D29CA0485AC4DA7#)))"))

(define %guix-authorized-key-w1
  (plain-file "w1.pub"
	      "(public-key (ecc (curve Ed25519) (q #36E9B90D648F6A16888C7A098884BBBD006252578204BA5882361CA7BED40E0A#)))"))

(define %guix-authorized-key-w2
  (plain-file "w2.pub"
	      "(public-key (ecc (curve Ed25519) (q #D9F5A476DF14AD4C62A24140DA9C45BF7CCB1AD1B8A8100F84BB5F61419748A1#)))"))

(define %guix-authorized-key-w3
  (plain-file "w3.pub"
	      "(public-key (ecc (curve Ed25519) (q #955F776520CC086E0F6CB8F40C85451FDA8A390D10F709A03FC705063C581BCC#)))"))

(define %nonguix-authorized-key
  (plain-file "nonguix.pub"
	      "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))

(define %guix-keyring-ephemeral-workers
  (list %guix-authorized-key-w1
	%guix-authorized-key-w2
	%guix-authorized-key-w3))

(define %guix-keyring-build-farm
  (list %guix-keyring-ephemeral-workers
	%guix-authorized-key-azzael
	%guix-authorized-key-lusk
	%guix-authorized-key-babayaga))

(define %guix-keyring-lan
  (list %guix-authorized-key-babayaga
	%guix-authorized-key-hellboy))

(define %guix-keyring-other
  (list %nonguix-authorized-key))

(define %guix-keyring-all
  (append %guix-keyring-lan
	  %guix-keyring-ephemeral-workers
	  %guix-keyring-other))

(define %user/deploy/key
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiRJsoVbDvQYsRe94WC0kaRrru1+loCl6xZecdR4kEMfuJWz4NvyZNgD2q7KtXmQ+flvIdPuN0uxHbIzm+f1L500ZGoeOSo9GT2HPSJT8nUjgzLzKkwEs35uraxMQicjEnoUf9v+qx7s8Tv/mmKuMPrqMiNt337PlEL6llRkNtJ8srOd8pDXd40WOtHcPjRN0if78VnjESDTufAuqLoGs6yCe5j3QpcGlFneQ164AATwUMcuMQc9TVFc2pRjZRaWOFDSIAqF6NsaE3D4K6NvbTl8YIhi/seGKkvp6jfnv4T53JnY4TwbOEyPUS9dp3yfaz3NThy5r1AYAETz9s8mJC4KT2dKatShzU9tGGCyg409HNe/nOZQZrpBzfYLLwiBkxSZaCesJ0s4tyiKNW26asub0rM9DTnfCbcrEzzRtmCph3yZIC7yvNl3BAhKGIodsC07tk5zCR+kTyLntRBTIvev7Y98jz0/WA2Jaa3tQZCH8vhF0PCeiPh5c+z4A2z19ZdsLauKUs833Tj5amZg6H8t67pyFXGa2N8dptzsssk/BDEdO/YT6hohjEFI9kqtvNQbtTi6vwHjPCkpeV8MDRHWDNZsnLVz/2VR8oLH2suWDKGz4GlY0DfWRnmswu2rijGkD7U8eHt/6xrrtVxWZ9yJGnc90+RKz1LjwReRmkPw== openpgp:0xC6D3E079")

(define %user/deploy
  (user-account
   (name "deploy")
   (group "users")
   (comment "deploy configuration")
   (supplementary-groups '("audio" "video" "wheel"))
   (shell (file-append (specification->package "bash") "/bin/bash"))))

(define %user/deploy-web
  (user-account
   (name "deploy-web")
   (comment "deploy web")
   (group "users")
   (supplementary-groups '("caddy"))))

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
