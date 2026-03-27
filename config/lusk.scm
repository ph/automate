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
	     (gnu system)
	     (guix gexp)
	     (nongnu packages linux)
	     (nongnu system linux-initrd)
	     (rosenthal services networking)
	     (rosenthal services web)
	     (gnu services networking)
	     (gnu services nfs)
	     (gnu services base)
	     (gnu services shepherd)
	     (heyk nongnu services arm)
	     (guix packages)
	     (gnu packages ssh))

(use-service-modules cups
		     desktop
		     networking
		     ssh
		     sysctl
		     virtualization)

(define %deploy-key
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiRJsoVbDvQYsRe94WC0kaRrru1+loCl6xZecdR4kEMfuJWz4NvyZNgD2q7KtXmQ+flvIdPuN0uxHbIzm+f1L500ZGoeOSo9GT2HPSJT8nUjgzLzKkwEs35uraxMQicjEnoUf9v+qx7s8Tv/mmKuMPrqMiNt337PlEL6llRkNtJ8srOd8pDXd40WOtHcPjRN0if78VnjESDTufAuqLoGs6yCe5j3QpcGlFneQ164AATwUMcuMQc9TVFc2pRjZRaWOFDSIAqF6NsaE3D4K6NvbTl8YIhi/seGKkvp6jfnv4T53JnY4TwbOEyPUS9dp3yfaz3NThy5r1AYAETz9s8mJC4KT2dKatShzU9tGGCyg409HNe/nOZQZrpBzfYLLwiBkxSZaCesJ0s4tyiKNW26asub0rM9DTnfCbcrEzzRtmCph3yZIC7yvNl3BAhKGIodsC07tk5zCR+kTyLntRBTIvev7Y98jz0/WA2Jaa3tQZCH8vhF0PCeiPh5c+z4A2z19ZdsLauKUs833Tj5amZg6H8t67pyFXGa2N8dptzsssk/BDEdO/YT6hohjEFI9kqtvNQbtTi6vwHjPCkpeV8MDRHWDNZsnLVz/2VR8oLH2suWDKGz4GlY0DfWRnmswu2rijGkD7U8eHt/6xrrtVxWZ9yJGnc90+RKz1LjwReRmkPw== openpgp:0xC6D3E079")

(define (add-key user key)
  (simple-service 'add-user-ssh-keys openssh-service-type
		  `((,user ,(plain-file (format #f "~a.pub" user) key)))))

(define %deploy-user-account
  (user-account
   (name "deploy")
   (comment "deploy")
   (group "users")
   (create-home-directory? #f)
   (supplementary-groups '("wheel"))))

(define (make-deployable os)
  (operating-system
   (inherit os)
   (users (append (list %deploy-user-account)
		  (operating-system-users os)))
   (sudoers-file
    (plain-file
     "sudoers"
     (string-append
      (plain-file-content (operating-system-sudoers-file os))
      "deploy ALL = NOPASSWD: ALL\n")))
   (services (append (list (add-key "deploy" %deploy-key))
		     (operating-system-user-services os)))))


(define docker-arm-abcde-conf-string
  (string-join
   '("CDDBMETHOD=musicbrainz"
     "PADTRACKS=y"
     "EJECTCD=n"
     "INTERACTIVE=n"
     "ACTIONS=musicbrainz,read,encode,tag,move,clean,playlist,getalbumart,embedalbumart"
     "OUTPUTDIR='/home/arm/music/'"
     "OUTPUTTYPE=flac"
     "OUTPUTFORMAT='${ARTISTFILE}/${CDYEAR}-${ALBUMFILE}/${TRACKNUM} - ${TRACKFILE}'"
     "VAOUTPUTFORMAT='Various ${ALBUMFILE}/${TRACKNUM} ${ARTISTFILE} ${TRACKFILE}'"
     "ONETRACKOUTPUTFORMAT=$OUTPUTFORMAT"
     "VAONETRACKOUTPUTFORMAT=$VAOUTPUTFORMAT"
     "MAXPROCS=4"
     "FLACOPTS='-s -e -V -8'"
     "mungefilename ()"
     "{"
     "    echo \"$@\" | sed s,:,\\ -,g | sed s,/,-,g | tr -d \\?\\[:cntrl:\\]"
     "}"
     "ID_SUFFIX=$(cd-discid $CDROM | cut -f1 -d ' ')"
     "mungealbumname ()"
     "{"
     "   mungefilename $(echo \"$@\" | sed s,'Unknown Album','Unknown Album_'$ID_SUFFIX,g)"
     "}")
   "\n"))

(define %my-packages
  (map specification->package (list
			       "nfs-utils"
			       "mosh")))

(define %lusk
  (operating-system
   (locale "en_CA.utf8")
   (timezone "America/Toronto")
   (keyboard-layout (keyboard-layout "us"))
   (host-name "lusk")
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (list linux-firmware
		   amdgpu-firmware))

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
	     ;; (service docker-arm-service-type
	     ;; 	      (docker-arm-configuration
	     ;; 	       (options '(("TZ" . "Toronto")))
	     ;; 	       (network "host")
	     ;; 	       (abcde-conf-file (plain-file "abcde.conf" docker-arm-abcde-conf-string))
	     ;; 	       (extra-arguments '("--device=/dev/sg0"
	     ;; 				  "--device=/dev/sr0"
	     ;; 				  ;; "--gpus=all"
	     ;; 				  "--privileged"))))

	     ;; Install the required dependencies to interact with NFS shares.
	     (service nfs-service-type
		      (nfs-configuration))

	     (service autofs-service-type
		      (autofs-configuration
		       (mounts
			(list
			 (autofs-indirect-map
			  (mount-point "/-")
			  (entries
			   (list
			    (autofs-map-entry
			     (type "nfs")
			     (options '(rw vers=4))
			     (device "ogdru-jahad:/volume1/Music")
			     (mount-point "/var/lib/docker-arm/music"))

			    (autofs-map-entry
			     (type "nfs")
			     (options '(rw vers=4))
			     (device "ogdru-jahad:/volume1/Media")
			     (mount-point "/var/lib/docker-arm/media/completed")))))))))

	     (simple-service 'nfs-ensure-perms
			     shepherd-root-service-type
			     (list (shepherd-timer '(nfs-check-perms)
						   #~(calendar-event #:minutes '(0 10 20 30 40 50))
						   #~("chown" "-R" "arm:arm" "/var/lib/docker-arm/")
						   #:requirement '(user-processes))))

	     (simple-service 'extend-sysctl
			     sysctl-service-type
			     '(("net.ipv4.ip_forward" . "1")
			       ("net.ipv6.conf.all.forwarding" . "1")))

	     (simple-service 'extend-guix
			     guix-service-type
			     (guix-extension
			      (substitute-urls
			       (append (list
					"https://cache-cdn.guix.moe"
					;; "https://substitutes.nonguix.org"
					"https://substitutes.supervoid.org")
				       %default-substitute-urls))
			      (authorized-keys
			       (append %guix-keyring-all
				       %default-authorized-guix-keys))))
	     (service avahi-service-type)
	     (service ntp-service-type)
	     ;; (service tailscale-service-type)
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
			   ,(plain-file "ph.pub" %deploy-key)))))))
	    %base-services))

   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/efi"))
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
		   ;; (needed-for-boot? #t)
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
                   (mount-point "/efi")
                   (device (file-system-label "EFI"))
		   ;; (needed-for-boot? #t)
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
					      file-systems)))))))
(make-deployable %lusk)
