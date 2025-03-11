(define-module (packages gnu packages wayland)
	       )

(define-public rofi-nord-theme
  (package
    (name "rofi-nord-theme")
    (version "cffb111 ")
    (source
     (origin
       (method git-fetch)
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

