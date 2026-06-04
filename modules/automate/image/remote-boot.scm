(define-module (automate image remote-boot)
  #:use-module (automate profile)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages)
  #:use-module (gnu services base)
  #:use-module (gnu services)
  #:use-module (gnu system install)
  #:use-module (gnu system shadow)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd))

(define %installation-os
  (make-installation-os))

(define %remote-boot-os
  (operating-system
    (inherit %installation-os)
    (kernel linux-7.0)
    (initrd microcode-initrd)
    (firmware (list linux-firmware
		    sof-firmware))
    (host-name "remote-boot")
    (label (format #f "GNU Guix remote boot connect to ~S" host-name))
    (users %base-user-accounts)
    (services (cons*
	       (simple-service 'channel-file etc-service-type
			       (list `("channels.scm" ,(local-file "../../../channels.lock.scm"))))
	       %base-services))))

(define +profile/remote-boot
  (compose +networking/dhcp
	   (+service/openssh)
	   +system/substitutes
	   +profile/root-disabled-login-passwd
	   +profile/deployable))

(+profile/remote-boot %remote-boot-os)

;; guix time-machine -C channels.lock.scm -L modules -- system image modules/automate/image/remote-boot.scm
