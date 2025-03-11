;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (packages gnu home services zathura)
  #:use-module (gnu home services)
  #:use-module (gnu packages pdf)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (packages helpers)
  #:use-module (srfi srfi-1)
  #:export (home-zathura-service-type
	    home-zathura-configuration))

(define %zathura-default-extra-content
  '("map <C-=> zoom in"
   "map <C--> zoom out"
   "set font \"Iosevka 14\""
   "set selection-clipboard clipboard"
   "set default-bg rgba(0,43,53,0.8)"
   "set recolor true"
   "set recolor-lightcolor rgba(0,43,53,0)"
   "set recolor-darkcolor rgb(131,148,150)"
   "set adjust-open \"width\""))

(define-configuration/no-serialization home-zathura-configuration
  (zathura
   (package zathura)
   "The zathura package to use")
  (extra-content
   (extra-content %zathura-default-extra-content)
   "The Zathura configuration"))

(define (home-zathura-profile-service config)
  (list (home-zathura-configuration-zathura config)))

(define (add-zathura-configuration config)
  `((".config/zathura/zathurarc"
     ,(plain-file "zathurarc"
		  (string-join
		   (home-zathura-configuration-extra-content config) "\n")))))

(define home-zathura-service-type
  (service-type
   (name 'home-zathura-service-type)
   (extensions
    (list
     (service-extension home-files-service-type
			add-zathura-configuration)
     (service-extension home-profile-service-type
			home-zathura-profile-service)))
   (description "Configure Zathura by providing a file @file{~/.config/zathura/zathurarc}")
   (default-value (home-zathura-configuration))))
