(use-modules
 (blue build)
 (blue computation)
 (blue configuration find)
 (blue configuration states)
 (blue file-system path)
 (blue configuration find)
 (blue oop)
 (blue preferences)
 (blue stencils standard configuration)
 (blue types blueprint)
 (blue types buildable)
 (blue types configuration)
 (blue types variable)
 (blue utils strings)
 (srfi srfi-1)
 (oop goops))

(define-preferences
  (blue.stencils.tangle:emacs
   #:default (const (delay (or (getenv "EMACS") (find-binary "emacs"))))
   #:valid-values string?
   #:documentation "The binary to use for `emacs(1)`.  `emacs' if the environment is defined, otherwise
`emacs'."))

(define-blue-class <tangle> (<buildable>)
  (executable
   #:getter tangle-executable
   #:init-value #%~#%?EMACS
   #:init-keyword #:executable
   #:type string?))

(define %tangle-configuration
  (configuration
   (variables
    (list
     (variable
      (name "EMACS")
      (value (delay (blue.stencils.tangle:emacs))))))))

(define-method (ask-build-configurations (this <tangle>))
  (list %tangle-configuration))

(define-method (ask-build-manifest (this <tangle>) (inputs <list>) (outputs <list>))
  (make-build-manifest
   (format #f "TANGLE ~a to ~a" (string-join inputs ",") (string-join outputs ","))
   (lambda()
     `((tangle-executable this) ,@(emacs-arguments (first inputs))))))

(define (emacs-arguments file)
  `(list "--quick"
	 "--batch"
	 "--load" "ob-tangle"
	 "--eval" "(setopt org-babel-load-languages '((shell . t)))"
	 "--eval" "(setopt org-confirm-babel-evaluate nil)"
	 "--eval" "(setopt org-id-track-globally nil)"
	 "--eval" ,(format #f "(org-babel-tangle-file ~s)" file)))

(define %guix-emacs-minimal
  "guix shell emacs-minimal -- emacs")

(define tangle-emacs
  (tangle
   (inputs '("org-config/home.org"))
   (outputs '("home.scm"))
   (executable %guix-emacs-minimal)))

(blueprint
 (buildables (list tangle-emacs)))
