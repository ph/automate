;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define %guix-channel
  (channel
   (name 'guix)
   (url "https://codeberg.org/guix/guix.git")
   (branch "master")
   (introduction
    (make-channel-introduction
     "9edb3f66fd807b096b48283debdcddccfea34bad"
     (openpgp-fingerprint
      "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))

(define %nonguix-channel
  (channel
   (name 'nonguix)
   (url "https://gitlab.com/nonguix/nonguix")
   (branch "master")
   (introduction
    (make-channel-introduction
     "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
     (openpgp-fingerprint
      "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5")))))

(define %rosenthal-channel
  (channel
   (name 'rosenthal)
   (url "https://codeberg.org/hako/rosenthal.git")
   (branch "trunk")
   (introduction
    (make-channel-introduction
     "7677db76330121a901604dfbad19077893865f35"
     (openpgp-fingerprint
      "13E7 6CD6 E649 C28C 3385  4DF5 5E5A A665 6149 17F7")))))

(define %heyk-channel
  (channel
   (name 'heyk)
   (url "https://github.com/ph/heyk")
   (branch "trunk")
   (introduction
    (make-channel-introduction
     "fa96f4b8e25dba3b5ea47f1365cbe9cf9ef0358c"
     (openpgp-fingerprint
      "AB8D 7699 282F 5F12 4949 547E C6CD 2C3D B524 1054")))))

(define %guix-rusty-channel
  (channel
   (name 'guix-rusty)
   (url "https://github.com/ph/guix-rusty")
   (branch "main")))

(define %emacs-master-channel
  (channel
    (name 'emacs-master)
    (url "https://github.com/gs-101/emacs-master.git")
    (branch "main")
    (introduction
      (make-channel-introduction
	"568579841d0ca41a9d222a2cfcad9a7367f9073b"
	(openpgp-fingerprint
	  "3049 BF6C 0829 94E4 38ED  4A15 3033 E0E9 F7E2 5FE4")))))

(list %guix-channel
      %nonguix-channel
      %rosenthal-channel
      %heyk-channel
      %emacs-master-channel)
