;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (packages gnu packages wayland)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:))

(define-public rofi-themes-collection
  (package
    (name "rofi-themes-collection")
    (version "c2be059")
    (source (origin
	      (method git-fetch)
	      (uri (git-reference
		    (url "https://github.com/newmanls/rofi-themes-collection/")
		    (commit version)))
	      (file-name (git-file-name name version))
	      (sha256
	       (base32 "19k42i91w70scmabzzkv1dxa1hbvam4grcgd94sindj5njly2wx4"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("themes" "share/themes"))))
    (home-page "https://github.com/newmanls/rofi-themes-collection")
    (synopsis "Themes collection for Rofi Launcher")
    (description
     "Themes collection for Rofi Launcher")
    (license license:gpl3)))
