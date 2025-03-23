;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate helpers)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:export (extra-content?
	    string-or-gexp?))

(define (extra-content? content)
  (every string-or-gexp? content))

(define (string-or-gexp? s)
  (or (gexp? s)
      (string? s)))
