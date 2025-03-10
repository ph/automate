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
  '("max-visible=5"
    "sort=-time"
    "layer=top"
    "anchor=top-right"
    "font=Fira Sans 10"
    "background-color=#282936dd"
    "text-color=#e9e9f4dd"
    "width=400"
    "height=150"
    "margin=10"
    "padding=5"
    "border-size=1"
    "border-color=#626483dd"
    "border-radius=0"
    "progress-color=over #5588AAFF"
    "icons=true"
    "max-icon-size=64"
    "markup=true"
    "actions=true"
    "format=<b>%s</b>\\n%b"
    "default-timeout=12000"
    "ignore-timeout=false"))

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
		   (list #$(file-append mako "/bin/mako"))))
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
