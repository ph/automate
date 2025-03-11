;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (packages gnu packages rust-apps)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages version-control)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (packages gnu packages rust-crates))

(define-public jujutsu
  (package
    (name "jujutsu")
    (version "0.27.0")
    (source (origin
	      (method git-fetch)
	      (uri (git-reference
		    (url "https://github.com/jj-vcs/jj")
		    (commit (string-append "v" version))))
	      (file-name (git-file-name name version))
	      (sha256
	       (base32
		"106r26fjkpmbbfl76nn7400pablq76cv5dvv6jz8w7r552nhj63w"))))
    (build-system cargo-build-system)
    ;;;;;;;;;;
    (arguments
     (list
      #:install-source? #f
      #:phases
      #~(modify-phases %standard-phases
		       (replace 'install
				(lambda* (#:key outputs #:allow-other-keys)
				  (let* ((out (assoc-ref outputs "out")))
				    (mkdir-p out)
				    (setenv "CARGO_TARGET_DIR" "./target")
				    (invoke "cargo" "install" "--no-track" "--path" "cli" "--root" out)))))
      ))
    (inputs
     (cons* openssl
	    openssh
	    git
	    jujutsu-cargo-inputs))
    (home-page "https://jj-vcs.github.io")
    (synopsis "A Git-compatible VCS that is both simple and powerful")
    (description
     "Jujutsu provides a @command{jj}
Jujutsu is a powerful version control system for software projects.
You use it to get a copy of your code, track changes to the code,
and finally publish those changes for others to see and use. It is
 designed from the ground up to be easy to use—whether you're new
 or experienced, working on brand new projects alone, or large scale
 software projects with large histories and teams.")
    (license license:apsl2)))
