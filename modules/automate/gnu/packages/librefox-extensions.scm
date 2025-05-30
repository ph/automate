(define-module (automate gnu packages librefox-extensions)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu build icecat-extension))

(define-public tridactyl
  (package
    (name "tridactyl")
    (version "1.24.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/tridactyl/tridactyl")
	     (commit version)))
       (file-name (git-file-name name version))
       (sha256
	(base32
	 "0px06bd4958ihsh6lb1k1gdyfc3ia6b0whvd8jyaqms868xijs8d"))))
    (build-system copy-build-system)
    (arguments
     (list #:install-plan
	   #~'(("." #$(assq-ref (package-properties this-package) 'addon-id)))))
    (home-page "https://github.com/tridactyl/tridactyl")
    (synopsis "Adaptive tab bar colour")
    (description "Vim, but in your browser. Replace Firefox's control mechanism with one modelled on Vim. This addon is very usable, but is in an early stage of development. We intend to implement the majority of Vimperator's features.")
    (license license:asl2.0)
    (properties '((addon-id . "tridactyl.vim@cmcaine.co.uk")))))

(define-public tridactyl/icecat
  (make-icecat-extension tridactyl))

;; tridactyl
