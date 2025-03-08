(define-module (home)
  #:use-module (srfi srfi-1)
  #:use-module (guix gexp)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages ghostscript))

(define %user "ph")

(define (extra-content? content)
  (every string-or-gexp? content))

(define (string-or-gexp? s)
  (or (gexp? s)
      (string? s)))

(define %zathura-default-extra-content
  '("map <C-=> zoom in"
   "map <C--> zoom out"
   "set font \"Iosevka 14\""
   "set selection-clipboard clipboard"
   "set default-bg rgba(0,43,53,0.8)"
   "set recolor true"
   "set recolor-lightcolor rgba(0,43,53,0)"
   "set recolor-darkcolor rgb(131,148,150)"
   "set adjust-open \"width\""))

(define-configuration/no-serialization home-zathura-configuration
  (zathura
   (package zathura)
   "The zathura package to use")
  (extra-content
   (extra-content %zathura-default-extra-content)
   "The Zathura configuration"))

(define (home-zathura-profile-service config)
  (list (home-zathura-configuration-zathura config)))

(define (add-zathura-configuration config)
  `((".config/zathura/zathurarc"
     ,(plain-file "zathurarc"
		  (string-join
		   (home-zathura-configuration-extra-content config) "\n")))))

(define home-zathura-service-type
  (service-type
   (name 'home-zathura-service-type)
   (extensions
    (list
     (service-extension home-files-service-type
			add-zathura-configuration)
     (service-extension home-profile-service-type
			home-zathura-profile-service)))
   (description "Configure Zathura by providing a file @file{~/.config/zathura/zathurarc}")
   (default-value (home-zathura-configuration))))

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
  (packages (list htop))
 (services
  (list
   (service home-syncthing-service-type
	    (for-home
             (syncthing-configuration
              (user %user))))
   (service home-dbus-service-type)
   (service home-zathura-service-type)
   (service home-fish-service-type))))
