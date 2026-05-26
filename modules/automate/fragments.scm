(define-module (automate fragments)
  #:use-module (gnu system)
  #:export (+group
	    +packages
	    +privileged-program
	    +service
	    +user
	    +kernel-arguments
	    +sudo
	    +ssh-key))

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

(define (+kernel-arguments args)
  (lambda (os)
    (operating-system
      (inherit os)
      (packages (append (operating-system-kernel-arguments os)
			args)))))

(define* (+sudo username
		#:key
		(permissions = "ALL = NOPASSWD: ALL"))
  (lambda (os)
    (let ((existing-content (operating-system-sudoers-file os))
	  (new-sudo-entry (format #f "~a ~a\n" username permissions)))
      (operating-system
	(inherit os)
	(sudoers-file
	 (plain-file "sudoers" (string-append new-sudo-entry
					      existing-content)))))))

(define (+ssh-key user pubkey)
  (+service (simple-service 'add-user-ssh-keys openssh-service-type
			    `((,user ,(plain-file (format #f "~a.pub" user) pubkey))))))
