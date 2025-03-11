(define-module (packages gnu packages fonts)
  #:use-module (guix packages)
  #:use-module (guix build-system font)
  #:use-module (guix build-system copy)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (srfi srfi-1)
  #:use-module (nonguix build-system binary)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download))

(define-public font-fira-code-nerd
  (package
    (name "font-fira-code-nerd")
    (version "3.0.2")
    (source
     (origin
       (method url-fetch)
       (uri
	(string-append
	 "https://github.com/ryanoasis/nerd-fonts/releases/download/v"
	 version
	 "/FiraCode.zip"))
       (sha256
	(base32
	 "1hn19sigsv6i1dm5lxn0gfldqfcn9yvzhg5cs4v2sv13crwxf0wf"))))
    (build-system font-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
	 (add-before 'install 'make-files-writable
	   (lambda _
	     (for-each
	      make-file-writable
              (find-files "." ".*\\.(otf|otc|ttf|ttc)$"))
	     #t)))))
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Nerd fonts variant of FiraCode font")
    (description
     "Nerd fonts variant of FiraCode font.  Nerd Fonts is a project that patches
developer targeted fonts with a high number of glyphs (icons).  Specifically to
add a high number of extra glyphs from popular 'iconic fonts' such as Font
Awesome, Devicons, Octicons, and others.")
    (license license:silofl1.1)))

(define-public font-fira-code-regular-symbols
  (package
    (name "font-fira-code-regular-symbols")
    (version "6.2") ;;Not version anywhere.
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/tonsky/FiraCode/files/412440/FiraCode-Regular-Symbol.zip")
       (sha256
	(base32 "01sk8cmm50xg2vwf0ff212yi5gd2sxcb5l4i9g004alfrp7qaqxg"))))
    (build-system font-build-system)
    (home-page "https://www.nerdfonts.com/")
    (synopsis "Nerd fonts variant of FiraCode font")
    (description
     "Nerd fonts variant of FiraCode font.  Nerd Fonts is a project that patches
developer targeted fonts with a high number of glyphs (icons).  Specifically to
add a high number of extra glyphs from popular 'iconic fonts' such as Font
Awesome, Devicons, Octicons, and others.")
    (license license:silofl1.1)))
