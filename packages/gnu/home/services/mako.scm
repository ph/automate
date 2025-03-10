(define-module (packages gnu home services mako)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu packages wm)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (packages helpers)
  #:use-module (srfi srfi-1)
  #:export (home-mako-service-type
	    home-mako-configuration))

(define %mako-default-extra-content
  '("map <C-=> zoom in"
   "map <C--> zoom out"
   "set font \"Iosevka 14\""
   "set selection-clipboard clipboard"
   "set default-bg rgba(0,43,53,0.8)"
   "set recolor true"
   "set recolor-lightcolor rgba(0,43,53,0)"
   "set recolor-darkcolor rgb(131,148,150)"
   "set adjust-open \"width\""))

(define-configuration/no-serialization home-mako-configuration
  (mako
   (package mako)
   "The Mako package to use")
  (extra-content
   (extra-content %mako-default-extra-content)
   "The Mako configuration"))

(define (home-mako-profile-service config)
  (list (home-mako-configuration-mako config)))

(define (add-mako-configuration config)
  `((".config/mako/config"
     ,(plain-file "config"
		  (string-join
		   (home-mako-configuration-extra-content config) "\n")))))

(define (home-mako-shepherd-services config)
  (list (shepherd-service
	 (provision '(mako))
	 (documentation "Run the Mako daemon.")
	 (start #~(make-forkexec-constructor
		   (#$(file-append mako "/bin/mako"))))
	 (stop #~(make-kill-destructor)))))

(define home-mako-service-type
  (service-type
   (name 'home-mako-service-type)
   (extensions
    (list
     (service-extension home-shepherd-service-type
			home-mako-shepherd-services)
     (service-extension home-files-service-type
			add-mako-configuration)
     (service-extension home-profile-service-type
			home-mako-profile-service)))
   (description "Configure Mako by providing a file @file{~/.config/mako/config}")
   (default-value (home-mako-configuration))))
