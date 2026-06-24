;;; SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate config shared emacs)
  #:use-module (gnu home services)
  #:use-module (gnu home)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-build)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages tree-sitter)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (guix transformations)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (nonguix utils)
  #:use-module (rosenthal home services emacs)
  #:use-module (rosenthal packages emacs-xyz)
  #:use-module (supervoid gnu packages emacs-xyz)
  #:use-module (guix git-download)
  #:export (%emacs-package
	    +home-emacs-service-type))

(define-public emacs-ben/ph
  (package/inherit emacs-ben
		   (name "emacs-ben-ph")
		   (version "0.12.13-git")
		   (source
		    (origin
		     (method git-fetch)
		     (uri (git-reference
			   (url "https://codeberg.org/pastor/ben.el")
			   (commit "259f76f83efb03220e60bd799fb17fc49bddcda0")))
		     (file-name (git-file-name name version))
		     (sha256
		      (base32
		       "12qliyhk9ni10ks2hrwv74dhwakqb0jkvhip44qcfcrnhjvyacka"))))))

(define %emacs-packages
  (list emacs-evil/ph
	emacs-evil-collection/ph
	emacs-ben/ph
	;; Revisit later
	;; emacs-flyover
	emacs-dape
	emacs-fennel-mode/ph
	emacs-xref
	emacs-doom-modeline
	emacs-lambda-line
	emacs-agent-shell
	emacs-rustic/ph
	emacs-treemacs
	emacs-treemacs-extra
	emacs-treemacs-nerd-icons
	emacs-difftastic
	emacs-nerd-icons
	emacs-rust-mode
	emacs-colorful-mode
	emacs-prism
	emacs-symex-core
	emacs-symex
	emacs-symex-ide
	emacs-symex-evil
	emacs-evil-commentary
	emacs-evil-surround
	emacs-ef-themes
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
	emacs-catppuccin-theme
	emacs-gcmh
	emacs-corfu
	emacs-cape
	emacs-kind-icon
	emacs-orderless
	emacs-eglot-x
	emacs-eldoc-box
	emacs-nix-mode
	emacs-yaml-mode
	emacs-json-mode
	emacs-arei
	emacs-geiser
	emacs-geiser-hoot
	emacs-terraform-mode
	emacs-restclient
	emacs-dockerfile-mode
	emacs-go-mode
	emacs-org-modern
	emacs-org-roam
	emacs-htmlize
	emacs-esxml
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
	emacs-marginalia
	emacs-vertico
	emacs-consult
	emacs-consult-eglot
	emacs-kdl-mode
	emacs-rainbow-delimiters
	mu ;; mu4e and mu cli
	emacs-mu4e-dashboard
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

(define* (+home-emacs-service-type #:key
				   (emacs-bin emacs-pgtk)
				   (emacs-packages %emacs-packages))

  (service home-emacs-service-type
	   (home-emacs-configuration
	    (emacs emacs-bin)
	    (packages (packages->manifest emacs-packages))
	    (shepherd-requirement '(graphical-session)))))
