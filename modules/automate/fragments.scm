(define-module (automate fragments)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu services ssh)
  #:use-module (srfi srfi-13)
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
		(permissions "ALL = NOPASSWD: ALL"))
  (lambda (os)
    (let ((existing-content (plain-file-content (operating-system-sudoers-file os)))
	  (new-sudo-entry (format #f "~a ~a\n" username permissions)))
      (operating-system
	(inherit os)
	(sudoers-file
	 (plain-file "sudoers" (string-append new-sudo-entry
					      existing-content)))))))

(define* (short-sha long-sha #:optional
		    (sha-length  10))
  ;; Skip the prefix of the key like `ssh-rsa` and start with the actual key.
  (let ((str-length (string-length long-sha)))
    (substring long-sha
	       (or (string-contains long-sha " ")
		   0)
	       (or (and (> sha-length str-length) str-length)
		   sha-length))))

(define (+ssh-key user pubkey)
  (let* ((key-id (short-sha pubkey))
	 (service-name (string->symbol (format #f "add-user-ssh-keys-~a-~a" user key-id))))
    (+service (simple-service service-name openssh-service-type
			      `((,user ,(plain-file (format #f "~a.pub" user) pubkey)))))))
