(define-module (koku))

(use-modules (gnu system)
	     (gnu system keyboard)
	     (gnu system file-systems)
	     (gnu system accounts)
	     (gnu system shadow)
	     (guix gexp)
	     (gnu bootloader)
	     (gnu bootloader grub)
	     (gnu machine)
	     (gnu machine digital-ocean))

(define koku-os
  (operating-system
    (locale "en_US.utf8")
    (timezone "America/Toronto")
    (keyboard-layout (keyboard-layout "us" "altgr-intl"))
    (bootloader (bootloader-configuration
                 (bootloader grub-bootloader)
                 (targets '("/dev/sda"))
                 (keyboard-layout keyboard-layout)))
    (file-systems (cons* (file-system
                          (mount-point "/")
                          (device "/dev/sda1")
                          (type "ext4"))
                         %base-file-systems))
    (host-name "koku.stove.io")
    (users (cons* (user-account
                   (name "ph")
                   (group "users")
                   (home-directory "/home/ph")
                   (supplementary-groups
                    '("wheel" "netdev" "audio" "video")))
                  %base-user-accounts))
    (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL\n"))
    (services (append
               (list (service openssh-service-type
                              (openssh-configuration
                               (permit-root-login #t)))
                     (service dhcp-client-service-type))
               %base-services))))

(list (machine
       (operating-system koku-os)
       (environment digital-ocean-environment-type)
       (configuration (digital-ocean-configuration
		       (region "tor1")
		       (size "s-1vcpu-1gb")
		       (tags (list "stove.io"))
		       (enable-ipv6? #t)
		       (ssh-public-key "/home/ph/.ssh/id_rsa.pub")))))
