;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2025 Hilton Chain <hako@ultrarare.space>
;;; Copyright © 2026 Pier-Hugues Pellerin <ph@heykimo.com>

(define-module (automate overrides noctalia-greeter)
  ;; Utilities
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (rosenthal utils contract combinators)
  #:use-module (rosenthal utils file)
  #:use-module (rosenthal utils records)
  #:use-module (rosenthal utils packages)
  ;; Guix System - services
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  ;; Guix packages
  #:use-module (gnu packages admin)
  #:use-module (gnu packages bash)
  #:use-module (rosenthal packages admin)
  #:use-module (rosenthal packages wm)
  #:export (noctalia-greeter-configuration
            noctalia-greeter-service-type
            greetd-noctalia-greeter-session))


;;;
;;; noctalia-greeter
;;;

(define-record-type/dolly <noctalia-greeter-configuration>
  noctalia-greeter-configuration
  make-noctalia-greeter-configuration
  noctalia-greeter-configuration?
  this-noctalia-greeter-configuration
  (package
   noctalia-greeter-configuration-package
   (default noctalia-greeter)
   (contract file-like?)
   (documentation
    "Noctalia greeter package."))
  (greeter-yaml
   noctalia-greeter-configuration-greeter-yaml
   (default #f)
   (contract (or/c #f file-like?))
   (documentation
    "Greeter config")))

(define (noctalia-greeter-activation-service _)
  #~(mkdir-p/perms "/var/lib/noctalia-greeter" (getpwnam "greeter") #o750))

(define noctalia-greeter-special-files-service
  (match-record-lambda/dolly <noctalia-greeter-configuration>
      (greeter-yaml)
    (if greeter-yaml
	`(("/var/lib/noctalia-greeter/greeter.toml"
	   ,greeter-yaml)
	'()))))

(define noctalia-greeter-service-type
  (service-type
    (name 'noctalia-greeter)
    (extensions
     (list (service-extension activation-service-type
                              noctalia-greeter-activation-service)
           (service-extension special-files-service-type
                              noctalia-greeter-special-files-service)
           (service-extension polkit-service-type
                              (compose list noctalia-greeter-configuration-package))
           (service-extension profile-service-type
                              (compose list noctalia-greeter-configuration-package))))
    (default-value (noctalia-greeter-configuration))
    (description "Set up environment for @command{noctalia-greeter-session}.")))

(define-record-type/dolly <greetd-noctalia-greeter-session>
  greetd-noctalia-greeter-session
  make-greetd-noctalia-greeter-session
  greetd-noctalia-greeter-session?
  this-greetd-noctalia-greeter-session
  (noctalia-greeter-session
   greetd-noctalia-greeter-session-noctalia-greeter-session
   (default (file-append noctalia-greeter "/bin/noctalia-greeter-session"))
   (contract (or/c file-like? string?))
   (documentation
    "@command{noctalia-greeter-session} executable file.")))

(define-gexp-compiler (greetd-noctalia-greeter-session-compiler
                       (session <greetd-noctalia-greeter-session>)
                       system target)
  (match-record/dolly session <greetd-noctalia-greeter-session> (noctalia-greeter-session)
    (lower-object
     (program-file "noctalia-greeter-wrapper"
       #~(execl #$noctalia-greeter-session #$noctalia-greeter-session)))))
