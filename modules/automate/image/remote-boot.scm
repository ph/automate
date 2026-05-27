(define-module (automate image remote-boot)
  #:use-module (automate profile)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu bootloader)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages)
  #:use-module (gnu services base)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system shadow)
  #:use-module (gnu system)
  #:use-module (gnu system install)
  #:use-module (guix gexp)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  ;; #:use-module (gnu packages cryptsetup)
  ;; #:use-module (gnu packages disk)
  ;; #:use-module (gnu packages file-systems)
  ;; #:use-module (gnu services avahi)
  ;; #:use-module (gnu services networking)
  ;; #:use-module (gnu services ssh)
  )

(define %installation-os
  (make-installation-os #:efi-only? #f))

(define %remote-boot-os
  (operating-system
    (inherit %installation-os)
    (kernel linux-7.0)
    (initrd microcode-initrd)
    (firmware (list linux-firmware sof-firmware))
    (host-name "remote-boot")
    (users %base-user-accounts)))

;; (define +profile/remote-boot
;;   (compose +networking/dhcp
;; 	   +service/openssh
;; 	   +profile/root-disabled-login-passwd
;; 	   +profile/deployable))

;; (+profile/remote-boot %remote-boot-os)

%remote-boot-os
