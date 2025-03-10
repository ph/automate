(define-module (packages gnu home services avizo)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu packages wm)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (packages helpers)
  #:use-module (srfi srfi-1)
  #:export (home-avizo-service-type
	    home-avizo-configuration))

(define-configuration/no-serialization home-avizo-configuration
  (avizo
   (package avizo)
   "The Avizo package to use"))

(define (home-avizo-profile-service config)
  (list (home-avizo-configuration-avizo config)))

(define (home-avizo-shepherd-services config)
  (list (shepherd-service
	 (provision '(avizo))
	 (documentation "Run the Avizo daemon.")
	 (start #~(make-forkexec-constructor
		   (list #$(file-append avizo "/bin/avizo-service"))))
	 (stop #~(make-kill-destructor)))))

(define home-avizo-service-type
  (service-type
   (name 'home-avizo-service-type)
   (extensions
    (list
     (service-extension home-shepherd-service-type
			home-avizo-shepherd-services)
     (service-extension home-profile-service-type
			home-avizo-profile-service)))
   (description "Configure Avizo and start it with shepherd")
   (default-value (home-avizo-configuration))))
