(define-module (packages gnu home services waybar)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu packages wm)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (packages helpers)
  #:use-module (srfi srfi-1)
  #:export (home-waybar-service-type
	    home-waybar-configuration))

(define-configuration/no-serialization home-waybar-configuration
  (waybar
   (package waybar)
   "The Waybar package to use"))

(define (home-waybar-profile-service config)
  (list (home-waybar-configuration-waybar config)))

(define (home-waybar-shepherd-services config)
  (list (shepherd-service
	 (provision '(waybar))
	 (requirement '(dbus))
	 (documentation "Run the Waybar daemon.")
	 (start #~(make-forkexec-constructor
		   (list #$(file-append waybar "/bin/waybar"))))
	 (stop #~(make-kill-destructor)))))

(define home-waybar-service-type
  (service-type
   (name 'home-waybar-service-type)
   (extensions
    (list
     (service-extension home-shepherd-service-type
			home-waybar-shepherd-services)
     (service-extension home-profile-service-type
			home-waybar-profile-service)))
   (description "Configure Waybar by providing a file @file{~/.config/waybar/config}")
   (default-value (home-waybar-configuration))))
