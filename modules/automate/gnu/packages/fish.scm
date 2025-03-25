;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate gnu packages fish)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages shells))

(define-public fish-hydro
  (package
    (name "fish-hydro")
    (version "75ab7168a35358b3d08eeefad4ff0dd306bd80d4")
    (source (origin
	      (method git-fetch)
	      (uri (git-reference
		    (url "https://github.com/jorgebucaran/hydro")
		    (commit version)))
	      (file-name (git-file-name name version))
	      (sha256
	       (base32
		"0cd6fa6g0jdjdsxgy5qja2jx180s26v5hcs71npj5zim9sqvi2j1"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan #~`(("conf.d" "share/")
                         ("functions" "share/"))))
    (inputs
     (list fish))
    (home-page "https://github.com/jorgebucaran/hydro")
    (synopsis "fish lag-free prompt with async git status")
    (description "Ultra-pure, lag-free prompt with async Git status. Designed only for Fish.")
    (license license:expat)))
