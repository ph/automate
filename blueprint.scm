(use-modules
 (blue oop)
 (blue build)
 (blue subprocess)
 (blue computation)
 (blue preferences)
 (blue types buildable)
 (blue types configuration)
 (blue types variable)
 (blue types blueprint)
 (oop goops))

;; Based on https://codeberg.org/lapislazuli/blue/src/branch/main/blue/stencils/tarball.scm
(define-preferences
  (blue.stencils.tangle:emacs
   #:default (const (delay (or (getenv "EMACS-PROGRAM") "emacs")))
   #:valid-values string?
   #:documentation "The binary to use for emacs, 'EMACS' if the environment is defined otherwise 'emacs'"))

(define-blue-class <tangle> (<buildable>)
  (options
   #:getter tangle-options
   #:init-value '()
   #:init-keyword #:options
   #:type (list-of? string?))
  (emacs-program
   #:getter tangle-emacs-program
   #:init-value #%~#%?EMACS-PROGRAM
   #:init-keyword #:options
   #:type (list-of? string?)))

(define %tangle-configuration
  (configuration
   (variables
    (list
     (variable
      (name "EMACS-PROGRAM")
      (value (delay (blue.stencils.tangle:emacs-program))))))))

(define-method (ask-build-configuration (this <tangle>))
  (list %tangle-configuration))

(define-method (ask-build-manifest (this <tangle>)
				   (input <string>)
				   (output <string>))
  (make-build-manifest
   (format #f "TANGLE\t~a to ~a" input output)
   (lambda ()
     `(popen "emacs"
	     ("--quick"
	      "--batch"
	      "--load" "ob-tangle"
	      "--eval" "(setopt org-babel-load-languages '((shell . t)))"
	      "--eval" "(setopt org-confirm-babel-evaluate nil)"
	      "--eval" "(setopt org-id-track-globally nil)"
	      "--eval" ,(format #f "(org-babel-tangle-file ~s)" input))))))

(define tangle-home
  (tangle
   (inputs (list "org-config/home.org"))
   (outputs (list "target/tangled/home.scm"))))

(blueprint
 (buildables (list tangle-home)))
