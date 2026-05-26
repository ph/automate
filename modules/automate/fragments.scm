(define-module (automate fragments)
  #:use-module (gnu system)
  #:export (+group
	    +user
	    +service
	    +privileged-program
	    +packages))

(define (+service . args)
  (lambda (os)
    (operating-system
      (inherit os)
      (services (append args
			(operating-system-user-services os))))))

(define (+user user)
  (lambda (os)
    (operating-system
      (inherit os)
      (users (cons* user
		    (operating-system-users os))))))

(define (+group group)
  (lambda (os)
    (operating-system
      (inherit os)
      (groups (cons* group
		     (operating-system-groups os))))))

(define (+privileged-program programs)
  (lambda (os)
    (operating-system
      (inherit os)
      (privileged-programs (cons programs
				 (operating-system-privileged-programs os))))))

(define (+packages system-packages)
  (lambda (os)
    (operating-system
      (inherit os)
      (packages (append (operating-system-packages os)
			system-packages)))))
