;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (packages gnu home services fish)
  #:use-module (packages gnu packages fish)
  #:use-module (gnu home services)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu services configuration)
  :export (home-fish-hydro-service-type
	   home-fish-hydro-configuration))

(define-configuration/no-serialization home-fish-hydro-configuration
  (fish-hydro
   (package fish-hydro)
   "The fish-hydro package to use"))

(define (add-fish-hydro-configuration config)
  `(("fish/conf.d/hydro.fish" ,(file-append (home-fish-hydro-configuration-fish-hydro config) "/share/conf.d/hydro.fish"))
    ("fish/functions/fish_mode_prompt.fish" ,(file-append (home-fish-hydro-configuration-fish-hydro config) "/share/functions/fish_mode_prompt.fish"))
    ("fish/functions/fish_prompt.fish" ,(file-append (home-fish-hydro-configuration-fish-hydro config) "/share/functions/fish_prompt.fish"))))

(define (home-fish-hydro-profile-service config)
  (list (home-fish-hydro-configuration-fish-hydro config)))

(define home-fish-hydro-service-type
  (service-type
   (name 'home-fish-hydro-service-type)
   (extensions
    (list
     (service-extension home-xdg-configuration-files-service-type
			add-fish-hydro-configuration)
     (service-extension home-profile-service-type
			home-fish-hydro-profile-service)))
   (description "Configure fish hydro prompt")
   (default-value (home-fish-hydro-configuration))))

