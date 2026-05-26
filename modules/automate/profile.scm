(define-module (automate profile)
  #:use-module (automate fragments)
  #:use-module (gnu services)
  #:use-module (gnu system accounts)
  #:use-module (gnu services sysctl)
  #:use-module (guix gexp)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu system)
  #:use-module (gnu system pam)
  #:use-module (automate config shared)
  #:use-module (automate config home)
  #:use-module (gnu services base)
  #:use-module (gnu services nix)
  #:use-module (gnu services xorg)
  #:use-module (gnu services pm)
  #:use-module (gnu services sddm)
  #:use-module (gnu services ssh)
  #:use-module (gnu services desktop)
  #:use-module (gnu system keyboard)
  #:use-module (gnu packages ssh)
  #:use-module (gnu services mcron)
  #:use-module (gnu services docker)
  #:use-module (gnu services guix)
  #:use-module (rosenthal services networking)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu system privilege)
  #:use-module (gnu packages games)
  #:export (+networking/increase-udp-buffer-size
	    +networking/ip-forwarding
	    +networking/tailscale
	    +profile/bluetooth
	    +profile/desktop
	    +profile/development
	    +profile/gaming
	    +profile/ph
	    +service/containers
	    +service/nix
	    +service/openssh
	    +service/sddm-login-manager
	    +system/btrfs
	    +system/pam-realtime-options
	    +system/power-management
	    +system/substitutes
	    +system/zram-device 
	    +vm/qemu-bridge-helper))

;; (define +hardware/fwupd
;;   (+service (service fwupd-service-type
;; 		     (fwupd-configuration
;; 		      (fwupd fwupd-nonfree)))))

(define +networking/tailscale
  (compose ;;(+packages '(tailscale)) ;; ensure it's available int PATH to login.
   (+service (service tailscale-service-type))))

(define +networking/ip-forwarding
  (+service (simple-service 'sysctl-ip-forwarding
			    sysctl-service-type
			    '(("net.ipv4.ip_forward" . "1")
			      ("net.ipv6.conf.all.forwarding" . "1")))))

;; Increase UDP buffer size for data transfer, help with syncthing local transfer.
;; https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
(define +networking/increase-udp-buffer-size
  (+service (simple-service 'udp-buffer-size sysctl-service-type
			    '(("net.core.rmem_max" . "7500000")
			      ("net.core.wmem_max" . "7500000")))))

(define +vm/qemu-bridge-helper
  (+privileged-program
   (privileged-program
    (program (file-append qemu "/libexec/qemu-bridge-helper"))
    (setuid? #t))))

(define +profile/gaming
  (+service (udev-rules-service 'steam-devices steam-devices-udev-rules)))

(define +profile/ph
  (compose (+user (user-account
		   (name "ph")
		   (comment "Pier-Hugues Pellerin")
		   (shell (file-append fish "/bin/fish"))
		   (group "users")
		   (home-directory "/home/ph")
		   (supplementary-groups
		    '("lp"
		      "kvm"
		      "wheel"
		      "netdev"
		      "docker"
		      "audio"
		      "plugdev"
		      "video"
		      "realtime"))))
	   (+group (user-group
		    (system? #t)
		    (name "plugdev")))
	   (+service (service guix-home-service-type
			      `(("ph" ,(automate-home-environment)))))))

(define +system/substitutes
  (+service (simple-service 'extend-guix
			    guix-service-type
			    (guix-extension
			     (substitute-urls
			      (append (list
				       "https://substitutes.supervoid.org"
				       "https://cache-cdn.guix.moe")
				      %default-substitute-urls))
			     (authorized-keys
			      (append %guix-keyring-all
				      %default-authorized-guix-keys))))))

(define (btrfs-maintenance-jobs mount-point)
  (list
   #~(job '(next-hour '(3))
	  (string-append #$btrfs-progs "/bin/btrfs "
			 "scrub " "start " "-c " "idle "
			 #$mount-point))
   #~(job '(next-hour '(5))
	  (string-append #$btrfs-progs "/bin/btrfs "
			 "balance " "start "
			 "-dusage=50,limit=3 "
			 "-musage=50,limit=1 "
			 #$mount-point))))

(define (btrfs-maintenance-service mount-points)
  (service mcron-service-type
	   (mcron-configuration
	    (jobs
	     (apply append (map btrfs-maintenance-jobs mount-points))))))

(define +system/btrfs
  (+service (btrfs-maintenance-service '("/"))))


(define* (+system/zram-device #:key
			      (ram-size "32G"))
  (+service (service zram-device-service-type
		     (zram-device-configuration
		      (size ram-size)
		      (compression-algorithm 'zstd)
		      (priority 100)))))

(define +profile/bluetooth
  (lambda (os) 
    ((+service (service bluetooth-service-type
			(bluetooth-configuration
			 (bluez bluez)
			 (name (operating-system-host-name os))
			 (auto-enable? #t)
			 (multi-profile 'multiple)))) os)))

(define +service/containers
  (+service (service containerd-service-type)
	    (service docker-service-type)))

(define +system/pam-realtime-options
  (compose
   (+group (user-group
	    (system? #t)
	    (name "realtime")))
   (+service (service pam-limits-service-type
		      (list
		       (pam-limits-entry "@realtime" 'both 'rtprio 99)
		       (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)
		       (pam-limits-entry "*" 'both 'nofile 524288))))))

(define* (+service/nix #:key
		       (trusted-user "ph"))
  (+service (service nix-service-type
		     (nix-configuration
		      (extra-config '((format #f "trusted-users = ~a\n" trusted-user)
				      "extra-platforms = aarch64-linux arm-linux"))))))

(define %probe-rs-udev-rules
  (file->udev-rule
   "69-probe-rs.rules"
   (local-file "../../files/udev/69-probe-rs.rules")))

(define +system/udev/probe-rs
  (+service (udev-rules-service 'probe-rs %probe-rs-udev-rules)))

(define +profile/development
  (compose +networking/ip-forwarding
	   +service/containers
	   +system/udev/probe-rs
	   (+service/nix)
	   +vm/qemu-bridge-helper))

(define +system/power-management
  (+service (service tlp-service-type
		     (tlp-configuration
		      (cpu-scaling-governor-on-ac (list "balanced"
							"performance"))
		      (cpu-scaling-governor-on-bat (list "low-power"))
		      (cpu-boost-on-ac? #t)
		      (cpu-boost-on-bat? #f)
		      (sched-powersave-on-bat? #t)))))

(define +service/openssh
  (+service (service openssh-service-type
		     (openssh-configuration
		      (openssh openssh-sans-x)))))

(define +service/sddm-login-manager
  (+service (service sddm-service-type
		     (sddm-configuration
		      (sddm sddm-qt5)
		      (theme "chili")
		      (xorg-configuration
		       (xorg-configuration
			(keyboard-layout
			 (keyboard-layout "us"
					  #:options '("ctrl:nocaps")))))))))

(define +profile/desktop
  (compose (+service (service sane-service-type))
	   +system/pam-realtime-options
	   +service/sddm-login-manager
	   +profile/gaming
	   +profile/bluetooth))

(define +profile/deployable
  (compose (+user (user-account
		    (name "deploy")
		    (comment "deploy")
		    (group "users")
		    (create-home-directory? #f)
		    (supplementary-groups '("wheel"))))
	   (+sudo "deploy")
	   (+ssh-key "deploy" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiRJsoVbDvQYsRe94WC0kaRrru1+loCl6xZecdR4kEMfuJWz4NvyZNgD2q7KtXmQ+flvIdPuN0uxHbIzm+f1L500ZGoeOSo9GT2HPSJT8nUjgzLzKkwEs35uraxMQicjEnoUf9v+qx7s8Tv/mmKuMPrqMiNt337PlEL6llRkNtJ8srOd8pDXd40WOtHcPjRN0if78VnjESDTufAuqLoGs6yCe5j3QpcGlFneQ164AATwUMcuMQc9TVFc2pRjZRaWOFDSIAqF6NsaE3D4K6NvbTl8YIhi/seGKkvp6jfnv4T53JnY4TwbOEyPUS9dp3yfaz3NThy5r1AYAETz9s8mJC4KT2dKatShzU9tGGCyg409HNe/nOZQZrpBzfYLLwiBkxSZaCesJ0s4tyiKNW26asub0rM9DTnfCbcrEzzRtmCph3yZIC7yvNl3BAhKGIodsC07tk5zCR+kTyLntRBTIvev7Y98jz0/WA2Jaa3tQZCH8vhF0PCeiPh5c+z4A2z19ZdsLauKUs833Tj5amZg6H8t67pyFXGa2N8dptzsssk/BDEdO/YT6hohjEFI9kqtvNQbtTi6vwHjPCkpeV8MDRHWDNZsnLVz/2VR8oLH2suWDKGz4GlY0DfWRnmswu2rijGkD7U8eHt/6xrrtVxWZ9yJGnc90+RKz1LjwReRmkPw== openpgp:0xC6D3E079")))
