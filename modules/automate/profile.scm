(define-module (automate profile)
  #:use-module (automate config home)
  #:use-module (automate config shared)
  #:use-module (automate fragments)
  #:use-module (automate user)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages games)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages scanner)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services docker)
  #:use-module (gnu services guix)
  #:use-module (gnu services linux)
  #:use-module (gnu services mcron)
  #:use-module (gnu services networking)
  #:use-module (gnu services nix)
  #:use-module (gnu services pm)
  #:use-module (gnu services sddm)
  #:use-module (gnu services ssh)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (gnu system accounts)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system pam)
  #:use-module (gnu system privilege)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (nongnu packages video)
  #:use-module (rosenthal packages networking)
  #:use-module (rosenthal services networking)
  #:export (+networking/increase-udp-buffer-size
	    +networking/ip-forwarding
	    +networking/tailscale
	    +networking/dhcp
	    +profile/bluetooth
	    +profile/deployable
	    +profile/desktop
	    +profile/development
	    +profile/gaming
	    +profile/ph
	    +profile/root-disabled-login-passwd
	    +profile/server
	    +service/containers
	    +service/nix
	    +service/openssh
	    +service/sddm-login-manager
	    +system/btrfs
	    +system/pam-realtime-options
	    +system/power-management
	    +system/substitutes
	    +system/zram-device 
	    +vm/qemu-bridge-helper
	    %packages/installer-disk-utilities))

;; (define +hardware/fwupd
;;   (+service (service fwupd-service-type
;; 		     (fwupd-configuration
;; 		      (fwupd fwupd-nonfree)))))

(define +networking/tailscale
  (compose ;;(+packages '(tailscale)) ;; ensure it's available in the PATH to login.
   (+service (service tailscale-service-type))))

(define +networking/ip-forwarding
  (+service (simple-service 'sysctl-ip-forwarding sysctl-service-type
			    '(("net.ipv4.ip_forward" . "1")
			      ("net.ipv6.conf.all.forwarding" . "1")))))

;; Increase UDP buffer size for data transfer, help with syncthing local transfer.
;; https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
(define +networking/increase-udp-buffer-size
  (+service (simple-service 'sysctl-increase-udp-buffer-size sysctl-service-type
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
  (compose (+user
	    (auth-account %user/ph))
	   (+group (user-group
		     (system? #t)
		     (name "plugdev")))
	   (+sudo (user-account-name
		   (auth-account %user/ph)))
	   (+service (service guix-home-service-type
			      `(("ph" ,(automate-home-environment)))))))

(define +profile/root-disabled-login-passwd
  (+user (auth-account %user/root-disabled-login-passwd)))

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
		      (extra-config `(,(format #f "trusted-users = ~a\n" trusted-user)
				      "experimental-features = nix-command flakes\n"
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
		       (openssh openssh-sans-x)
		       ;; (port-number 2222
		       ))))

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

(define (%packages/desktop)
  (list awesome
	bluez
	bluez-alsa
	chili-sddm-theme
	dconf
	egl-wayland
	ghostscript
	git
	hplip
	intel-media-driver/nonfree
	intel-vaapi-driver
	ldacbt
	libfreeaptx
	light
	mesa
	niri
	nix
	openssh
	sane-airscan
	simple-scan
	sway
	swaylock-effects
	wl-clipboard
	xdg-desktop-portal-gnome
	xdg-desktop-portal-gtk
	xdg-utils
	xorg-server-xwayland))

(define +profile/desktop
  (compose
   (+packages (%packages/desktop))
   (+service (service sane-service-type))
   +system/pam-realtime-options
   +service/sddm-login-manager
   +profile/gaming
   +profile/bluetooth))

(define (make/deployable add-user ssh-pubkey)
  (compose (+user add-user)
	   (+sudo (user-account-name add-user))
	   (+ssh-key (user-account-name add-user) ssh-pubkey)))

(define +profile/deployable
  (make/deployable 
   (auth-account %user/deploy)
   (auth-pubkey %user/deploy)))

(define +networking/dhcp
  (+service (service dhcpcd-service-type)))

(define %packages/server
  (list mosh))

(define +profile/server
  (compose
   (+packages %packages/server)
   +service/openssh
   +profile/deployable
   +system/substitutes
   +networking/ip-forwarding
   +networking/dhcp))

;; Reuse the internal tools list from the Guix installer.
(define %packages/installer-disk-utilities
  (@@ (gnu system install) %installer-disk-utilities))
