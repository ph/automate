(define-module (automate system lusk)
  #:use-module (automate common)
  #:use-module (automate fragments)
  #:use-module (automate profile)
  #:use-module (automate config home)
  #:use-module (automate config shared)
  #:use-module (automate microvm)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu system)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system uuid)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system keyboard)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages)
  #:use-module (gnu services authentication)
  #:use-module (gnu services desktop)
  #:use-module (gnu services nix)
  #:use-module (gnu services linux)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services pm)
  #:use-module (gnu services dbus)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services xorg)
  #:use-module (gnu services docker)
  #:use-module (nongnu packages firmware)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (srfi srfi-1))

(define %lusk-os
  (operating-system
   (locale "en_CA.utf8")
   (timezone "America/Toronto")
   (keyboard-layout (keyboard-layout "us"))
   (host-name "lusk")
   (kernel linux)
   (initrd microcode-initrd)
   (firmware (list linux-firmware
		   amdgpu-firmware))

   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/efi"))
		(keyboard-layout keyboard-layout)))
   (services (append
	      (list (service dbus-root-service-type)
		    (service elogind-service-type))
	      %base-services))
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

(define +profile/lusk
  (compose +networking/increase-udp-buffer-size
	   +service/containers
	   (+packages %packages/server)
	   (+service/openssh)
	   +profile/deployable
	   +system/substitutes
	   +networking/ip-forwarding
	   +profile/root-disabled-login-passwd
	   +networking/dhcp
	   +system/pam-realtime-options
	   +profile/ph-shell))

(+profile/lusk %lusk-os)
