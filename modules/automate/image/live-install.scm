;;; SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate image live-install)
  #:use-module (automate profile)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages)
  #:use-module (gnu services base)
  #:use-module (gnu services ssh)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services avahi)
  #:use-module (gnu services)
  #:use-module (gnu system install)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages terminals)
  #:use-module (gnu system shadow)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (nonguix transformations)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages zile)
  #:use-module (gnu system)
  #:use-module (gnu system install)
  #:use-module (gnu system linux-initrd)
  #:use-module (nongnu packages firmware)
  #:use-module (nonguix transformations)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd))

;; How to build the image.
;; guix time-machine -C channels.lock.scm -L modules -- system image modules/automate/image/remote-boot.scm
(define %installation-os
  (make-installation-os #:efi-only? #t))

;; (define remote-installation-services
;;   ;; (modify-services (operating-system-services %installation-os)
;;   ;;   (openssh-service-type config =>
;;   ;; 			  (openssh-configuration
;;   ;; 			    (inherit config)
;;   ;; 			    (port-number 22)
;;   ;; 			    (permit-root-login #f)
;;   ;; 			    (allow-empty-passwords? #f)
;;   ;; 			    (password-authentication? #f)
;;   ;; 			    (%auto-start? #t))))
;;   )

;; Based on nonguix channels system.
(define installation-os-nonfree
  ((compose (nonguix-transformation-guix #:guix-source? #t)
	    ;; FIXME: ‘microcode-initrd’ results in unbootable live system.
	    (nonguix-transformation-linux #:initrd base-initrd))
   (operating-system
     (inherit %installation-os)
     (host-name "remote-boot")
     (timezone "America/Toronto")
     (label (format #f "GNU Guix remote boot connect to ~S" host-name))
     (kernel linux-7.1)
     (privileged-programs %default-privileged-programs)
     (packages
      (append
       (list curl
	     git
	     neovim
	     zile)
       (operating-system-packages %installation-os)))
     (services (cons*
		((@@ (gnu system install) cow-store-service))
		%base-services)))))

(define +profile/installation-os-nonfree
  (compose
   +networking/dhcp
   (+service/openssh)
   +system/substitutes
   ;; +profile/live-user
   +profile/deployable ;; still allow remove deploy and configuration
   ))

;; (+profile/remote-boot %live-install-os)
;; %live-install-os
;; installation-os-nonfree
;; guix system image --image-size=7.2GiB /path/to/this/channel/nongnu/system/install.scm
(+profile/installation-os-nonfree installation-os-nonfree)

;; TODO: Install screen + efibootmgr + dos tools make a rescue disc remote boot
