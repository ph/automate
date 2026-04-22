;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (home)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (heyk gnu packages fish)
  #:use-module (heyk gnu home services fish)
  #:use-module (heyk gnu home services avizo)
  #:use-module (heyk gnu home services waybar)
  #:use-module (heyk gnu home services zathura)
  #:use-module (heyk gnu packages fonts)
  #:use-module (heyk gnu packages wayland)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services guix)
  #:use-module (gnu home services pm)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services sway)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services niri)
  #:use-module (gnu home services)
  #:use-module (gnu home)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages chromium)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emulators)
  #:use-module (gnu packages engineering)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages electronics)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages image-viewers)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages librewolf)
  #:use-module (gnu packages license)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages music)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages node)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages scanner)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages web)
  #:use-module (gnu packages dns)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system shadow)
  #:use-module (guix channels)
  #:use-module (guix build-system emacs)
  #:use-module (guix gexp)
  #:use-module (guix profiles)
  #:use-module (guix packages)
  #:use-module (guix store)
  #:use-module (guix transformations)
  #:use-module (nongnu packages messaging)
  #:use-module (nongnu packages mozilla)
  #:use-module (nonguix utils)
  #:use-module (rosenthal packages rust-apps)
  #:use-module (rosenthal packages emacs-xyz)
  #:use-module (rosenthal services desktop)
  #:use-module (rosenthal home services emacs)
  #:use-module (rosenthal utils file)
  #:use-module (guix git-download)
  #:use-module ((ice-9 ftw) #:select (scandir))
  #:use-module (guix build-system copy)
  #:use-module (automate packages patches)
  )
(define-public fish-pure
  (package
   (name "fish-pure")
   (version "4.16.0")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/pure-fish/pure")
	   (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "1qvi5wwwh60n9jc9nxxp43pjcbf77il468jp1j118dv13ghbpq1i"))))
   (build-system copy-build-system)
   (arguments
    (list
     #:install-plan #~`(("conf.d" "share/")
			("functions" "share/"))))
   (inputs
    (list fish))
   (home-page "https://github.com/pure-fish/pure")
   (synopsis "Pretty, minimal and fast Fish 🐟 prompt, ported from zsh.")
   (description "Pretty, minimal and fast Fish 🐟 prompt, ported from zsh.")
   (license license:expat)))

(define-public fish-hydro/ph
  (package
    (inherit
     (package-with-extra-patches fish-hydro
				 ;; Add username and hostname in container or with remote hosts.
				 ;; https://github.com/jorgebucaran/hydro/pull/62
				 (list (local-file "patches/username-hostname.patch"))))
    (name "fish-hydro-ph")))

(define %fish-hydro-config
  "
set -g hydro_always_show_user true
set -g hydro_color_pwd \"brcyan\"
set -g fish_key_bindings fish_vi_key_bindings
set -g fish_term24bit 1
")


;; Use git version for emacs-evil so it can run on emacs 31.
(define emacs-evil/ph
  (let ((revision  "0")
	(commit "729d9a58b387704011a115c9200614e32da3cefc")
	(sha "0scdws40fg4k9lqyznjghnn8svn7l0c6mq7h2aq5pzkm6hanzqn3"))
    (package
      (inherit emacs-evil)
      (name "emacs-evil-ph")
      (version (git-version "1.15.0" revision commit))
      (source
       (origin
	 (method git-fetch)
	 (uri (git-reference
	     (url "https://github.com/emacs-evil/evil")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 sha))))
      (arguments
       `(
	 ;; Turning off the suite since the test suite required eask-cli
	 ;; to run them. This is a nodejs application which are notoriously hard to package.
	 ;; There is an open PR at https://codeberg.org/guix/guix/pulls/2792
	 #:tests? #f
         #:phases
         (modify-phases %standard-phases
           (add-before 'check 'fix-test-helpers
             (lambda _
               (substitute* "evil-test-helpers.el"
                 (("\\(undo-tree-mode 1\\)") ""))
               #t))
           (add-before 'install 'make-info
             (lambda _
               (with-directory-excursion "doc/build/texinfo"
                   (invoke "makeinfo" "--no-split"
                           "-o" "evil.info" "evil.texi"))))))))))

(define emacs-evil-collection/ph
  (let ((revision "0")
	(commit "4ad1646964638322302dfb167aec40a2455bfb78")
	(sha "0ajb81dp7qfn5x0bjgjqmwqqvqfmwfpk2rpkd6dl0h0j7bbl1v51"))
    (package
     (inherit emacs-evil-collection)
     (name "emacs-evil-collection-ph")
     (version (git-version "0.0.10" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/emacs-evil/evil-collection")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 sha)))))))

(define emacs-modus-catppuccin
  (let ((commit "5ce8a86a6844acdc368c8a25ac85df60e2c1352a")
	(revision "0"))
    (package
     (name "emacs-modus-catppuccin")
     (version (git-version "0.0.1" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://codeberg.org/alex-iam/modus-catppuccin")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "05hvniayr1zcayk33f1qxih58fjnkbrljjqrk2w506j1d5vhkh0x"))))
     (build-system emacs-build-system)
     (propagated-inputs
      (list emacs-modus-themes))
     (arguments (list #:tests? #f))   ;; no tests.
     (home-page "https://codeberg.org/alex-iam/modus-catppuccin")
     (synopsis "Catppuccin color themes for Emacs, built on the modus-themes framework.")
     (description " Catppuccin color themes for Emacs, built on the modus-themes framework.")
     (license license:gpl3+))))

(define emacs-lambda-line
  ;; no tags or version available in the git repository.
  (let ((commit "0ca6b32b591f6201c342d6c5ef14577aea7cfb49")
	(revision "0"))
    (package
     (name "emacs-lambda-line")
     (version (git-version "0.0.1" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/Lambda-Emacs/lambda-line")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "1kdk1zfk61qc0r9pfg91bb4gxfjh8wzd2936zzk3dnrc1b6cqrfl"))))
     (build-system emacs-build-system)
     (arguments (list #:tests? #f))   ;; no tests.
     (home-page "https://github.com/Lambda-Emacs/lambda-line")
     (synopsis "Lambda-line a configurable status line for Emacs")
     (description "Lambda-line is a custom status-line (or “mode-line) for Emacs.
 It is configurable for use either as a header-line or as a footer-line.")
     (license license:gpl3+))))

(define emacs-mu4e-thread-folding
  ;; no tags or version available in the git repository.
  (let ((commit "0575994abb4827e93b7f31b7871f89b888f3e51c")
	(revision "0"))
    (package
     (name "emacs-mu4e-thread-folding")
     (version (git-version "0.0.1" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/rougier/mu4e-thread-folding")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "1kqlxr56lljxj1xm3n42r1mxw190zj6ja3kvp0a8dczlz5546gd0"))))
     (build-system emacs-build-system)
     (propagated-inputs
      (list mu))
     (arguments (list #:tests? #f))   ;; no tests.
     (home-page "https://github.com/rougier/mu4e-thread-folding")
     (synopsis "mu4e-thread-folding are functions for folding threads in mu4e headers view")
     (description "mu4e-thread-folding.el is a small library to enable threads folding in mu4e. This works by using overlays with an invisible property and setting hooks at the right place. It is possible to configure colors to better highlight a thread and also to have a prefix string indicating if a thread is folded or not. Note that when a thread is folded, any unread child remains visible.")
     (license license:gpl3+))))

(define emacs-rustic/ph
  ;; ensure we are on the bleeding edge.
  (let ((commit "b6c7e095145bb1fd0dc9cfb90ce36884e944556d")
	(revision "0"))
    (package
     (inherit emacs-rustic)
     (name "emacs-rustic-ph")
     (version (git-version "3.5" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/emacs-rustic/rustic")
	     (commit version)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "1kbhad1lc7jy7frp3lk14ch8g53zh28rwy8v7nb8fixlxbla0jml")))))))

(define emacs-enhanced-evil-paredit
  (package
   (name "emacs-enhanced-evil-paredit")
   (version "1.0.4")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/jamescherti/enhanced-evil-paredit.el")
	   (commit version)))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0kkfnnqd2pzzm92pi13ngh63frp33z2mfb1prkqaw62nq4yrw6d8"))))
   (build-system emacs-build-system)
   (propagated-inputs
    (list emacs-evil
	  emacs-paredit))
   (arguments (list #:tests? #f))   ;; no tests.
   (home-page "https://github.com/jamescherti/enhanced-evil-paredit.el")
   (synopsis "Emacs: Improved Paredit support with Evil keybindings")
   (description "The enhanced-evil-paredit package prevents parenthesis imbalance when using evil-mode with paredit. It intercepts evil-mode commands such as delete, change, and paste, blocking their execution if they would break the parenthetical structure. This guarantees that your Lisp code remains syntactically correct while retaining the editing features of evil-mode.")
   (license license:gpl3+)))

(define-public emacs-acp/ph
  (package
    (name "emacs-acp-ph")
    (version "0.11.3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/xenodium/acp.el")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hr1176sy8xrx6wkqadmvwdjm1sv7aq8ddrw8h3ha6sn74glx8ws"))))
    (build-system emacs-build-system)
    (home-page "https://github.com/xenodium/acp.el")
    (synopsis "@acronym{ACP, Agent Client Protocol} for Emacs")
    (description
     "This package implements the @uref{https://agentclientprotocol.com/,
Agent Client Protocol} (ACP) for Emacs, a standardized protocol for
communicating with LLM agents.")
    (license license:gpl3+)))

(define-public emacs-shell-maker/ph
  (let ((commit "6377cbdb49248d670170f1c8dbe045648063583e")
	(revision "0"))
    (package
     (name "emacs-shell-maker-ph")
     (version (git-version "0.90.1" revision commit))
     (source (origin
	      (method git-fetch)
	      (uri (git-reference
		    (url "https://github.com/xenodium/shell-maker")
		    (commit commit)))
	      (file-name (git-file-name name version))
	      (sha256
	       (base32 "0v2iqvr2ywng5d22sw88k90i2jzl3cf2ybp9q6qpqirhvlsbgq19"))))
     (build-system emacs-build-system)
     (arguments
      (list #:tests? #f ; There are no tests.
	    #:phases
	    #~(modify-phases %standard-phases
			     (add-after 'unpack 'patch-curl
					(lambda* (#:key inputs #:allow-other-keys)
					  (emacs-substitute-variables "shell-maker.el"
								      ("shell-maker-curl-executable"
								       (search-input-file inputs "/bin/curl"))))))))
     (inputs (list curl))
     (home-page "https://github.com/xenodium/shell-maker")
     (synopsis "Create Emacs shells")
     (description "Shell Maker is a convenience wrapper around Comint mode.")
     (license license:gpl3+))))

(define-public emacs-agent-shell/ph
  (package
   (name "emacs-agent-shell-ph")
   (version "0.50.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/xenodium/agent-shell")
	   (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0njajpz51pbz4hqaq7lcvwaypilq1c9sdxsk6sdxgk1xpivqlxfb"))))
   (build-system emacs-build-system)
   (propagated-inputs (list emacs-shell-maker/ph
			    emacs-acp/ph))
   (home-page "https://github.com/xenodium/agent-shell")
   (synopsis "Native agentic integrations for Claude Code, Gemini CLI, etc")
   (description
    "This package offers a native comint shell experience to interact with any agent
powered by @uref{https://agentclientprotocol.com/, Agent Client Protocol} (ACP).")
   (license license:gpl3+)))


(define-public emacs-pubsub
  (let ((commit "51a6a052984d02d0d11c9be4aad421d2d34017af")
	(revision "0"))
    (package
     (name "emacs-pubsub")
     (version (git-version "0.1" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/countvajhula/pubsub")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "0d12dq2cyaz86vs1md0n111wmlpd09nnnrdhbij7sbphqxw8vlrx"))))
     (build-system emacs-build-system)
     (arguments
      `(#:tests? #f))
     (home-page "https://github.com/countvajhula/pubsub")
     (synopsis "A basic publish/subscribe system for Emacs")
     (description "Pubsub is for decoupling — allowing different pieces of code to talk to each other without being directly connected. A function call, for instance, is the simplest way to pass data from one place to another, and it can be thought of as entailing a single, directly connected, publisher and subscriber pair.")
     (license license:public-domain))))

(define-public emacs-lithium
  (let ((commit "d8a8e1287df0d42e0357f8dda450d2c2c0294a75")
	(revision "0"))
    (package
     (name "emacs-lithium")
     (version (git-version "0.1.1" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/countvajhula/lithium")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "0vyd3y0ndksg3dyxhgzrgwfpzqc7mdmq1ma3jmzxlqsnb8jby49d"))))
     (build-system emacs-build-system)
     (arguments
      `(#:tests? #f))
     (propagated-inputs
      (list emacs-pubsub))
     (home-page "https://github.com/countvajhula/lithium")
     (synopsis "Lightweight persistent modal interfaces for Emacs")
     (description
      "Lithium allows you to define Vim-like modes using Emacs's minor mode infrastructure. Modes may either be local to a buffer or global across all of Emacs.")
     (license license:public-domain))))

(define-public emacs-mantra
    (package
     (name "emacs-mantra")
     (version "0.3")
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/countvajhula/mantra")
	     (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
	(base32 "0hxjjb68swaggp1z2r0dmc441iz7gsvykm2njizrkp9aimj59h55"))))
     (build-system emacs-build-system)
     (arguments
      `(#:tests? #f))
     (propagated-inputs
      (list emacs-pubsub))
     (home-page "https://github.com/countvajhula/mantra")
     (synopsis "Parse and compose editing activity in Emacs")
     (description
      "Parse and compose keyboard activity in Emacs.")
     (license license:public-domain)))

(define-public emacs-virtual-ring
  (package
   (name "emacs-virtual-ring")
   (version "0.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
	   (url "https://github.com/countvajhula/virtual-ring")
	   (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "1v986w4d315fmrmr0ik9v0srrsf48pmiwa6cqw0v4s6qdhccvcal"))))
   (build-system emacs-build-system)
   (arguments
    `(#:tests? #f))
   ;; (propagated-inputs (list emacs-pubsub))
   (home-page "https://github.com/countvajhula/virtual-ring")
   (synopsis "Fixed size rings with virtual rotation")
   (description
    "A thin wrapper around Emacs's ring data structure that layers stateful, \"virtual,\" rotation on top of the underlying fixed-size recency-aware ring.

Virtual rings are a good fit in cases where you need to keep track both of recency of insertion as well as have an independent notion of stateful rotation to track a current \"selection.\"")
   (license license:public-domain)))

(define-public emacs-repeat-ring
    (package
     (name "emacs-repeat-ring")
     (version "0.1")
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/countvajhula/repeat-ring")
	     (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
	(base32
	 "0z2hzfiaq7ml1fj1wnfxy8dx8805iyz0mimskr2x98pa8wvbclbl"))))
     (build-system emacs-build-system)
     (arguments
      `(#:tests? #f))
     (propagated-inputs
      (list emacs-pubsub
	    emacs-mantra
	    emacs-virtual-ring))
     (home-page "https://github.com/countvajhula/repeat-ring")
     (synopsis "A structured and configurable way to repeat key sequences in Emacs.")
     (description
"A structured and general way to record and replay your activity within Emacs, inspired by both Vim and Emacs keyboard macros.")
     (license license:public-domain)))

(define (emacs-symex-package name path inputs)
  (let ((commit "4025d17ba260c893d58848258647005b58964b42")
	(revision "0"))
    (package
     (name name)
     (version (git-version "0.50.1" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/drym-org/symex.el")
	     (commit commit)))
       (file-name (git-file-name name version))
       (sha256
	(base32 "1bn4fs064l6g1yllbbimq33and9admhsadzlh6a74dgc6z1xcmza"))
       (modules '((guix build utils)
		  (srfi srfi-26)
		  (ice-9 ftw)))
       (snippet `(begin
		   (define (delete-other-except directory keep-paths)
		     (with-directory-excursion directory
					       (let* ((predicate (negate (cut member <> (append '("." "..") (list keep-paths)))))
						      (files-to-delete (or (scandir "." predicate) '())))
						 (for-each delete-file-recursively files-to-delete))))
		   (delete-other-except "." ,path)
		   (for-each (lambda (f)
			       (rename-file (in-vicinity ,path f)  (basename f)))
			     (scandir ,path (negate (cut member <> '("." "..")))))
		   (rmdir ,path)))))
     (build-system emacs-build-system)
     (propagated-inputs inputs)
     (home-page "https://github.com/drym-org/symex.el")
      (synopsis "An expressive modal way to write code (esp. Lisp) in Emacs")
      (description "Symex (pronounced sim-ex) is an intuitive modal way to edit code,
 built on top of an expressive domain-specific language (DSL) for te-oriented operations.")
      (license license:public-domain))))

(define-public emacs-symex-core
  (emacs-symex-package "emacs-symex-core"
		       "symex-core"
		       (list emacs-paredit)))

(define-public emacs-symex
  (emacs-symex-package "emacs-symex"
		       "symex"
		       (list emacs-lithium
			     emacs-mantra
			     emacs-pubsub
			     emacs-repeat-ring
			     emacs-symex-core)))

(define-public emacs-symex-ide
  (emacs-symex-package "emacs-symex-ide"
		       "symex-ide"
		       (list emacs-symex)))

(define-public emacs-symex-evil
  (emacs-symex-package "emacs-symex-evil"
		       "symex-evil"
		       (list emacs-symex
			     emacs-evil)))

(define-public emacs-symex-rigpa
  (emacs-symex-package "emacs-symex-rigpa"
		       "symex-rigpa"
		       (list emacs-symex
			     ;; need https://github.com/countvajhula/rigpa
			     ;; need https://github.com/countvajhula/lithium
			     emacs-symex-evil)))


(define %emacs-packages
  (list emacs-evil/ph
	emacs-evil-collection/ph
	emacs-agent-shell/ph
	emacs-rustic/ph
	emacs-rust-mode
	emacs-prism
	emacs-symex-core
	emacs-symex
	emacs-symex-ide
	emacs-symex-evil
	emacs-evil-commentary
	emacs-evil-surround
	emacs-general
	emacs-magit
	emacs-guix
	emacs-rainbow-delimiters
	emacs-paredit
	emacs-enhanced-evil-paredit
	emacs-lispy
	emacs-lispyville
	emacs-eat/dolly
	emacs-lin
	emacs-hl-todo
	emacs-forge
	emacs-modus-catppuccin
	emacs-gcmh
	emacs-corfu
	emacs-cape
	emacs-kind-icon
	emacs-orderless
	emacs-eglot-x
	emacs-nix-mode
	emacs-yaml-mode
	emacs-json-mode
	emacs-arei
	emacs-geiser
	emacs-terraform-mode
	emacs-restclient
	emacs-dockerfile-mode
	emacs-go-mode
	emacs-org-modern
	emacs-org-roam
	emacs-pass
	emacs-password-store
	emacs-auth-source-pass
	emacs-envrc
	emacs-inheritenv
	emacs-circe
	emacs-git-gutter
	emacs-git-gutter-fringe
	emacs-ligature
	emacs-helpful
	emacs-apheleia
	emacs-exec-path-from-shell
	emacs-ultra-scroll
	emacs-tempel
	emacs-popper
	emacs-shackle
	emacs-lambda-line
	emacs-marginalia
	emacs-vertico
	emacs-consult
	emacs-consult-eglot
	mu ;; mu4e and mu cli
	emacs-mu4e-thread-folding
	;; treesitter
	emacs-treesit-auto
	tree-sitter-bash
	tree-sitter-cmake
	tree-sitter-dockerfile
	tree-sitter-go
	tree-sitter-gomod
	tree-sitter-javascript
	tree-sitter-json
	tree-sitter-org
	tree-sitter-python
	tree-sitter-rust
	tree-sitter-scheme
	tree-sitter-yaml
	tree-sitter-kdl
	tree-sitter-typescript))

(define %user "ph")

(define %vcs
  (list git
	fprintd/ph
	;; mako
	jujutsu
	`(,git "send-email")))

(define %dev
  (list
   node
   mosh
   fish-foreign-env
   zathura-pdf-mupdf ;; should be added on the home service
   atuin
   guile-gcrypt
   guile-readline
   guile-colorized))

(define %browsers
  (list ;; firefox
   ungoogled-chromium
   librewolf))

(define %tools
  (list htop
	`(,isc-bind "utils")
	fish-hydro/ph
	bash
	curl
	b4
	reuse
	flatpak
	flatpak-xdg-utils
	fd
	aspell
	aspell-dict-en
	pandoc
	shellcheck
	ispell
	gnutls 
	libnotify
	qemu
	nmap
	udiskie
	jq
	unzip
	zip
	ripgrep
	rsync
	xdot
	gcr
	python
	bc
	tree))

(define %mail
  (list
   ;; notmuch
   ;; python-lieer
   mu
   isync
   msmtp
   password-store
   ))

(define %vim
  (list neovim))

;; (define %emacs
;;   (list
;;    ;; emacs-next-pgtk
;;    ;; emacs-guix
;;    ;; emacs-arei
;;    ;; emacs-debbugs
;;    ;; emacs-vterm
;;    ;; emacs-geiser))

(define %editors
  (append
   %vim
   (list
    direnv
    )))

(define %fonts
  (list font-dejavu
	font-fira-code-nerd
	font-fira-code
	font-fira-code-regular-symbols
	font-iosevka
	font-fira-mono
	font-fira-sans
	font-opendyslexic
	font-google-noto
	font-awesome
	font-google-material-design-icons
	font-google-roboto
	font-montserrat
	font-google-noto
	font-google-noto-emoji
	font-ghostscript))

(define %wm
  (list
   `(,glib "bin")
   blueman
   imv
   signal-desktop
   mpv
   pamixer
   pulseaudio
   pavucontrol
   playerctl
   yaru-theme
   matcha-theme
   adwaita-icon-theme
   hicolor-icon-theme
   papirus-icon-theme))

(define %games
  (list scummvm
	bsnes
	;; steam
	))

(define %multimedia
  (list
   libwacom
   xournalpp
   blender
   inkscape
   ffmpeg
   kicad
   vlc))

(define %scanner
  (list
   simple-scan
   sane-airscan))

(define %sway-extra-content
  '("font pango:monospace 8.0"
    "default_border pixel 2"
    "default_floating_border pixel 2"
    "hide_edge_borders none"
    "focus_wrapping no"
    "focus_follows_mouse yes"
    "focus_on_window_activation smart"
    "mouse_warping output"
    "workspace_layout default"
    "workspace_auto_back_and_forth no"
    "gaps inner 2"
    "gaps outer 2"
    "seat * xcursor_theme Yaru 24"
    "smart_gaps on"
    "smart_borders on"
    "set $laptop eDP-1"
    "floating_modifier $mod normal"

    ;; AFAIK this cannot be set with the sway configuration.
    "client.focused #e9e9f4 #62d6e8 #282936 #62d6e8 #62d6e8"
    "client.focused_inactive #3a3c4e #3a3c4e #e9e9f4 #626483 #3a3c4e"
    "client.unfocused #3a3c4e #282936 #e9e9f4 #3a3c4e #3a3c4e"
    "client.urgent #ea51b2 #ea51b2 #282936 #ea51b2 #ea51b2"
    "client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c"
    "client.background #ffffff"
    "for_window [title=\"(?:Open|Save) (?:File|Folder|As)\"] floating enable, resize set width 1030 height 710"
    "bindswitch --reload --locked lid:on output $laptop disable"
    "bindswitch --reload --locked lid:off output $laptop enable"))

(define %sway-zoom-config
  '("# Zoom Meeting App"
    "# Default for all windows is non-floating."
    "# For pop up notification windows that don't use notifications api"
    "for_window [app_id=\"zoom\" title=\"^zoom$\"] border none, floating enable"
    "# For specific Zoom windows"
    "for_window [app_id=\"zoom\" title=\"^(Zoom|About)$\"] border pixel, floating enable"
    "for_window [app_id=\"zoom\" title=\"Settings\"] floating enable, floating_minimum_size 960 xu700"
    "# Open Zoom Meeting windows on a new workspace (a bit hacky)"
    "for_window [app_id=\"zoom\" title=\"Zoom Meeting(.*)?\"] workspace next_on_output --create, move container to workspace current, floating disable, inhibit_idle open"))

(define %sway-signal-config
  '("# Signal message app"
    "for_window [app_id=\"signal\" title=\"^Signal$\"] resize set 400 400, floating enable"))

(define-public (activate-rofi-theme name)
  `("rofi/config.rasi" ,(mixed-text-file "config.rasi"
					 "@import '" rofi-theme-catppuccin "/share/themes/catppuccin-macchiato'\n"
					 "@theme '" rofi-theme-catppuccin "/share/themes/catppuccin-default'")))


(define %emacs)

(define %swayish 
  (sway-configuration
   (packages
     (list qtwayland-5
           sway
	   swayidle
	   rofi
	   rofi-themes-collection
           wl-clipboard
	   foot
	   alacritty
	   grim
	   slurp
	   light
	   xdg-utils
           xdg-desktop-portal-gtk
           xdg-desktop-portal-wlr))
   (variables
    `((mod . "Mod4")))
   (keybindings
    `(($mod+Return . ,#~(string-append "exec " #$alacritty "/bin/alacritty"))
      ($mod+Shift+q . "kill")

      ;; select current workspace
      ($mod+1 . "workspace number 1")
      ($mod+2 . "workspace number 2")
      ($mod+3 . "workspace number 3")
      ($mod+4 . "workspace number 4")
      ($mod+5 . "workspace number 5")
      ($mod+6 . "workspace number 6")
      ($mod+7 . "workspace number 7")
      ($mod+8 . "workspace number 8")
      ($mod+9 . "workspace number 9")

      ;; move current window to a specific workspace
      ($mod+Shift+1 . "move container to workspace number 1")
      ($mod+Shift+2 . "move container to workspace number 2")
      ($mod+Shift+3 . "move container to workspace number 3")
      ($mod+Shift+4 . "move container to workspace number 4")
      ($mod+Shift+5 . "move container to workspace number 5")
      ($mod+Shift+6 . "move container to workspace number 6")
      ($mod+Shift+7 . "move container to workspace number 7")
      ($mod+Shift+8 . "move container to workspace number 8")
      ($mod+Shift+9 . "move container to workspace number 9")

      ($mod+Shift+h . "move left")
      ($mod+Shift+j . "move down")
      ($mod+Shift+k . "move up")
      ($mod+Shift+l . "move right")

      ($mod+Shift+minus . "move scratchpad")
      ($mod+Shift+space . "floating toggle")

      ($mod+a . "focus parent")
      ($mod+b . "splith")

      ($mod+d . ,#~(string-append "exec " #$rofi "/bin/rofi -modi drun -show drun -show-icons -matching fuzzy"))
      ;; ($mod+d . ,#~(string-append "exec XDG_DATA_DIRS=\"$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$HOME/.guix-home/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share\" " #$rofi-wayland "/bin/rofi -modi drun -show drun -show-icons -matching fuzzy"))

      ;; ($mod+Shift+d . ,#~(string-append "exec " #$mako "/bin/makoctl dismiss -a"))

      ($mod+e . "layout toggle split")
      ($mod+f . "fullscreen toggle")

      ($mod+h . "focus left")
      ($mod+j . "focus down")
      ($mod+k . "focus up")
      ($mod+l . "focus right")


      ($mod+minus . "scratchpad show")
      ($mod+r . "mod resize")
      ($mod+s . "layout stacking")
      ($mod+space . "focus mode_toggle")
      ($mod+v . "splitv")
      ($mod+w . "layout tabbed")

      ($mod+BackSpace . "input \"type:keyboard\" xkb_switch_layout next")

      ($mod+Shift+e . ,#~(string-append "exec " #$sway "/bin/swaynag -t warning -m 'You pressed the  to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'"))
      ($mod+Shift+c . "reload")

      ;; Avizo laptop shortcuts
      (XF86AudioRaiseVolume . "exec volumectl -u up")
      (XF86AudioLowerVolume . "exec volumectl -u down")
      (XF86AudioMute . "exec volumectl toggle-mute")
      (XF86AudioMicMute . "exec volumectl -m toggle-mute")
      (XF86MonBrightnessUp . "exec lightctl up")
      (XF86MonBrightnessDown . "exec lightctl down")

      ;; screenshots
      ;; Take a region
      (mod1+Shift+4 . "exec grim -g \"$(slurp)\" && notify-send \"screenshot taken\"")

      ;; ;; Take active window
      (mod1+Shift+3 . "exec grim -g \"$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | \"\(.x),\(.y) \(.width)x\(.height)\"')\" && notify-send \"screenshot taken\"")

      ;; ;; Take active monitor
      (mod1+Print . "exec grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') && notify-send \"screenshot taken\"")
      ))
   (outputs
    (list
     (sway-output
      (identifier "eDP-1")
      (extra-content '("scale 2")))

     (sway-output
      (identifier "DP-1")
      (extra-content '("scale 1.4")))

     (sway-output
      (identifier "DP-3")
      (extra-content '("scale 1.4"
		       "transform 270"
		       "position 0 0")))
     (sway-output
      ;; (background (local-file "../wallpapers/sea-is-for-cookie.jpg"))
      (background (local-file "../wallpapers/kanagwa.jpg"))
      )))
   (inputs
    (list
     (sway-input
	   (identifier "type:keyboard")
	   (layout
	    (keyboard-layout "us,ca(fr)" #:options '("ctrl:nocaps")))
	   (extra-content
	    '("repeat_delay 180"
	      "repeat_rate 20")))
     (sway-input
      (identifier "type:touchpad")
      (tap #t)
      (extra-content '("natural_scroll enabled"
		       "accel_profile adaptive"
		       "click_method button_areas"
		       "scroll_method two_finger")))))

   (gestures '())
   (startup-programs
    (list
     ;; "pgrep --uid $USER shepherd > /dev/null || shepherd"
     "gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'"
     "gsettings set org.gnome.desktop.interface cursor-size '24'"
     "gsettings set org.gnome.desktop.interface gtk-theme 'Matcha-dark-azul'"
     "gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
     "gsettings set org.gnome.desktop.interface font-name 'Fira Code 10'"
     "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"
     "pgrep --uid $USER swayidle || swayidle  timeout 300 'sh $HOME/.config/sway/locker.sh' timeout 360 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' timeout 600 'swaymsg \"output * dpms on\"; sleep 1; loginctl suspend' before-sleep 'sh $HOME/.config/sway/locker.sh'"
     "signal-desktop --use-tray-icon"))
   (modes
    (list
     (sway-mode
      (mode-name "resize")
      (keybindings
       '((Return . "mode default")
	 (Escape . "mode default")
	 (h . "resize shrink width 10 px")
	 (j . "resize grow height 10 px")
	 (k . "resize shrink height 10 px")
	 (l . "resize grow width 10 px"))))))
   (extra-content
    (append
     %sway-extra-content
     %sway-zoom-config
     %sway-signal-config))))

(home-environment
 (packages (append
	    %browsers
	    %vcs
	    %games
	    %dev
	    %scanner
	    %tools
	    %mail
	    %editors
	    ;; %emacs-packages
	    %wm
	    %fonts))
 (services
   (cons*
    (simple-service 'additional-channels-service
		    home-channels-service-type
		    (load "../channels.scm"))
(service home-shepherd-service-type
	     (home-shepherd-configuration
	      (auto-start? #f))) ;; Sadly we need to start shepherd in the sway boot process to make $WAYLAND_DISPLAY available.
    (service home-dbus-service-type)
    (service home-gpg-agent-service-type
	     (home-gpg-agent-configuration
	      ;; (pinentry-program (file-append pinentry-rofi "/bin/pinentry-rofi"))
	      (pinentry-program (file-append pinentry-qt "/bin/pinentry-qt"))
	      (ssh-support? #t)))
    (service home-xdg-configuration-files-service-type
	     `(("gdb/gdbinit" ,%default-gdbinit)
	       (".Xdefaults" ,%default-xdefaults)
	       ("nano/nanorc" ,%default-nanorc)
	       ,(activate-rofi-theme "nord")))
    (service home-syncthing-service-type
	     (for-home
	      (syncthing-configuration
	       (user %user))))
    (service home-dotfiles-service-type
	     (home-dotfiles-configuration
	      (directories
	       '("../files/dotfiles"))))
    (service home-files-service-type
	     `((".guile" ,%default-dotguile)
	       (".face" ,(local-file "../files/plain/ph.jpg"))))
    (service home-sway-service-type
	     %swayish)
    (service home-niri-service-type
	     (home-niri-configuration
	      (config
	       (computed-substitution-with-inputs
		"niri.kdl"
		(local-file "../files/plain/niri.kdl")
		(list xwayland-satellite
		      signal-desktop)))))
    ;; (service home-mako-service-type)
    (service home-noctalia-shell-service-type)
    (service home-polkit-gnome-service-type)
    (service home-zathura-service-type)
    (service home-pipewire-service-type)
    (service home-batsignal-service-type)

    ;; emacs
    (simple-service 'emacs-environment home-environment-variables-service-type
		    `(("EDITOR" . "emacsclient")
		      ("VISUAL" . "$EDITOR")
		      ("ESHELL" . ,(file-append fish "/bin/fish"))))

    (service home-emacs-service-type
	     (home-emacs-configuration
	      (emacs emacs-pgtk)
	      (packages
	       (with-transformation
		(compose (options->transformation
			  '((without-tests . "emacs-el-mock")))
			 (package-input-rewriting
			  `((,(@ (gnu packages emacs) emacs)         . ,emacs)
			    (,(@ (gnu packages emacs) emacs-minimal) . ,emacs)
			    (,(@ (gnu packages emacs) emacs-no-x)    . ,emacs))))
		(packages->manifest %emacs-packages)))
	      (shepherd-requirement '(graphical-session))))

    (simple-service 'fish-emacs-eat home-fish-service-type
		    (home-fish-extension
		     (config
		      (list (plain-file "emacs-eat.fish" "\
  if test -n \"$EAT_SHELL_INTEGRATION_DIR\"
      source $EAT_SHELL_INTEGRATION_DIR/fish
  end\n")))))

    (service home-fish-hydro-service-type
	     (home-fish-hydro-configuration
	      (fish-hydro fish-hydro/ph)))

    (service home-fish-service-type
	     (home-fish-configuration
	      (config (list
		       (mixed-text-file
			"fish-config-direnv"
			direnv "/bin/direnv hook fish | source")
		       (mixed-text-file
			"fish-config-atuin"
			atuin "/bin/atuin init fish | source")
		       (mixed-text-file
			"disable-fish-greetings" "set -U fish_greeting")
		       (mixed-text-file
			"enable-foreign-fish-env"
			"set fish_function_path $fish_function_path $HOME/.guix-home/profile/share/fish/functions
set -g DIRENV_WARN_TIMEOUT 10m
fenv \"source $HOME/.guix-home/profile/etc/profile\"") ;; ensure all the environments variable are configured.
		       (plain-file "fish-hydro-config.fish" %fish-hydro-config)
		       (plain-file "add-npm-bin.fish" "fish_add_path $HOME/.local/npm/bin")))))
    %base-home-services)))

;; https://guix.gnu.org/manual/en/html_node/Search-Paths.html
;; TODO: Create wrapper for this.
;; LD_LIBRARY_PATH=/home/ph/.guix-home/profile/lib/sane SANE_CONFIG_DIR=/home/ph/.guix-home/profile/etc/sane.d/ simple-scan
