(define-module (home)
  #:use-module (guix gexp)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages ghostscript)
  #:use-module (packages gnu home services zathura)
  #:use-module (packages gnu home services mako)
  #:use-module (packages gnu packages wayland))

(define %user "ph")

(define %tools
  (list htop))

(define %vim
  (list neovim))

(define %fonts
  (list font-dejavu
	;; font-fira-code-nerd
	;; font-fira-code
	;; font-fira-code-regular-symbols
	;; font-iosevkas
	font-fira-mono
	font-fira-sans
	font-opendyslexic
	font-google-noto
	font-awesome
	font-google-material-design-icons
	font-google-roboto
	font-montserrat
	font-google-noto
	font-google-noto-emoji
	font-ghostscript))

(home-environment
 (packages (append
	    %tools
	    %vim
	    %fonts))
 (services
  (list
   (service home-shepherd-service-type
	    (home-shepherd-configuration
	     (auto-start? #f))) ;; We will start during the WM to have access to $DISPLAY
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
             (pinentry-program (file-append pinentry-rofi/wayland "/bin/pinentry-rofi"))
             (ssh-support? #t)))
   (service home-syncthing-service-type
	    (for-home
             (syncthing-configuration
              (user %user))))
   (service home-dbus-service-type)
   (service home-mako-service-type)
   (service home-zathura-service-type)
   (service home-fish-service-type))))
