(define-module (automate packages hack)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (guix inferior)
  #:use-module (guix channels)
  #:use-module (srfi srfi-1))

(define javascript-team-branch
  (list (channel
	 (name 'guix)
	 (url "https://codeberg.org/guix/guix.git")
	 (introduction
	  (make-channel-introduction
	   "9edb3f66fd807b096b48283debdcddccfea34bad"
	   (openpgp-fingerprint
	    "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))
	 (branch "javascript-team"))))

(define javascript-team-inferior
  (inferior-for-channels javascript-team-branch))

;; make next node lts version available to the current guix to
;; run https://pi.dev.
(define-public node-next
  (first (lookup-inferior-packages javascript-team-inferior "node")))
