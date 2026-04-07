;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate common)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages nfs)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages)
  #:use-module (gnu services avahi)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services docker)
  #:use-module (gnu services linux)
  #:use-module (gnu services mcron)
  #:use-module (gnu services nix)
  #:use-module (gnu services pm)
  #:use-module (gnu services sound)
  #:use-module (gnu services sysctl)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (gnu system setuid)
  #:use-module (gnu system shadow)
  #:use-module (gnu system accounts)
  #:use-module (gnu system)
  #:use-module (gnu)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (guix inferior)
  #:use-module (guix packages)
  #:use-module (nongnu packages video)
  #:use-module (rosenthal services networking)
  #:use-module (srfi srfi-1)
  #:export (%ph
	    %my-packages
	    %probe-rs-udev-rules
	    %my-system-services
	    %sudoers-default-content
	    sudoers-content-for-users
	    sudoers-content-for-username
	    sudoers-content-for-groups
	    btrfs-maintenance-service))

(use-service-modules cups
		     desktop
		     virtualization
		     networking
		     linux
		     ssh
		     mcron
		     sddm
		     xorg)

(use-package-modules ssh)

(define-public (btrfs-maintenance-jobs mount-point)
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

(define (sudoers-content-for-account-names names)
  (map  (lambda (name) (format #f "~a ALL=(ALL) ALL" name)) names))

(define (sudoers-content-for-groups groups)
  (map  (lambda (group) (format #f "%~a ALL=(ALL) ALL" group)) groups))

(define (sudoers-content-for-users users)
  (sudoers-content-for-account-names (map user-account-name users)))

(define %sudoers-default-content
  (append (sudoers-content-for-account-names (list "root"))
	  (sudoers-content-for-groups (list "wheel"))))

(define %ph
  (user-account
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

(define %my-packages
  (map specification->package (list "awesome"
				    "bluez"
				    "bluez-alsa"
				    "ghostscript"
				    "dconf"
				    "egl-wayland"
				    "libfreeaptx"
				    "ldacbt"
				    "hplip"
				    "git"
				    "intel-vaapi-driver"
				    "light"
				    "mesa"
				    "nix"
				    "intel-media-driver-nonfree"
				    "openssh"
				    "niri"
				    "dconf"
                                    "wl-clipboard"
                                    "xdg-desktop-portal-gnome"
                                    "xdg-desktop-portal-gtk"
                                    "xdg-utils"
				    "sway"
				    "swaylock-effects"
				    "xorg-server-xwayland"
				    "chili-sddm-theme")))

(define %probe-rs-udev-rules
  (file->udev-rule
   "69-probe-rs.rules"
   (local-file "../../files/udev/69-probe-rs.rules")))

(define %my-system-services
  (append (list
	   ;; (service console-font-service-type
	   ;; 	    (map (lambda (tty)
	   ;; 		   ;; Use a larger font for HIDPI screens
	   ;; 		   (cons tty (file-append
	   ;; 			      font-terminus
	   ;; 			      "/share/consolefonts/ter-132n")))
	   ;; 		 '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))

	   (simple-service 'blueman dbus-root-service-type (list blueman))
           (simple-service 'mtp udev-service-type (list libmtp))
           (service sane-service-type)
           polkit-wheel-service
           fontconfig-file-system-service


           ;; https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
           (simple-service 'udp-buffer-size
                           sysctl-service-type
                           '(("net.core.rmem_max" . "7500000")
                             ("net.core.wmem_max" . "7500000")))

           ;; NetworkManager and its applet.
           (service network-manager-service-type)
           (service wpa-supplicant-service-type)    ;needed by NetworkManager
           (service modem-manager-service-type)
           (service usb-modeswitch-service-type)

	   (service containerd-service-type)
	   (service docker-service-type)

           ;; The D-Bus family of things.
           (service avahi-service-type)
           (service udisks-service-type)
           (service upower-service-type)
           (service accountsservice-service-type)
           (service cups-pk-helper-service-type)
           (service colord-service-type)
           (service geoclue-service-type)
           (service polkit-service-type)
           (service elogind-service-type)
           (service dbus-root-service-type)
           (service ntp-service-type
		    (ntp-configuration
		     (servers (list (ntp-server
				     (type 'pool)
				     (address "2.guix.pool.ntp.org")
				     (options '("iburst")))))))
           (service x11-socket-directory-service-type)
           (service pulseaudio-service-type)
           (service alsa-service-type)

	   (service openssh-service-type
		    (openssh-configuration
		     (openssh openssh-sans-x)))
	   (service tlp-service-type)
	   (udev-rules-service 'light light)
	   (service thermald-service-type)
	   (service nix-service-type
		    (nix-configuration
		     (extra-config '("trusted-users = ph\n"
				     "extra-platforms = aarch64-linux arm-linux"))))
	   (service qemu-binfmt-service-type
		    (qemu-binfmt-configuration
		     (platforms (lookup-qemu-platforms "aarch64"))))
	   (service screen-locker-service-type
		    (screen-locker-configuration
		     (name "swaylock")
		     (program (file-append swaylock "/bin/swaylock"))
		     (using-pam? #t)
		     (using-setuid? #f)))
	   (service sddm-service-type
		    (sddm-configuration
		     (sddm sddm-qt5)
		     (theme "chili")
		     (xorg-configuration
		      (xorg-configuration
		       (keyboard-layout
			(keyboard-layout "us" #:options '("ctrl:nocaps")))))))
	   (service pam-limits-service-type
		    (list
		     (pam-limits-entry "@realtime" 'both 'rtprio 99)
		     (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)
		     (pam-limits-entry "*" 'both 'nofile 524288))))
	  %base-services))
