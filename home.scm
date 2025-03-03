(define-module (home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services emacs)

  #:use-module (gnu services)

  #:use-module (gnu packages vim))

(define %home-packages
  (list neovim))

(home-environment
 (packages %home-packages)
 (services
  (list
   (service home-emacs-service-type
	    (home-emacs-configuration
	      (emacs emacs-pgtk))))))
