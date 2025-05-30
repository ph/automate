(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p)
  (add-hook 'scheme-mode-hook 'guix-devel-mode)

  (fset 'yes-or-no-p 'y-or-n-p)
  :config
  (setq
   ;; evil-want-keybinding nil
   custom-file null-device
   geiser-mode-auto-p nil
   compilation-always-kill t
   byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local)
   compilation-ask-about-save nil
   native-comp-async-report-warnings-errors nil
   load-prefer-newer t
   backup-directory-alist '((".*" . "~/.config/emacs-backup"))
   revert-without-query '(".*")
   make-backup-files nil
   inhibit-splash-screen t
   create-lockfiles nil
   auto-save-default nil
   make-backup-files nil
   minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)
   enable-recursive-minibuffers t
   bidi-inhibit-bpa t
   bidi-paragraph-direction 'left-to-right)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (electric-pair-mode 1)
  (global-auto-revert-mode 1)
  (global-hl-line-mode)
  (global-display-line-numbers-mode t)
  (pixel-scroll-precision-mode)
  (transient-mark-mode 1)

  (with-eval-after-load 'geiser-guile   (add-to-list 'geiser-guile-load-path "~/src/automate"))
  (with-eval-after-load 'geiser-guile   (add-to-list 'geiser-guile-load-path "~/src/guix"))

  (defun ask-user-about-supersession-threat (fn) "ignore")
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (add-to-list 'default-frame-alist '(alpha-background . 95))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font 10"))
  (set-frame-parameter nil 'alpha-background 95)
  (add-to-list 'default-frame-alist '(alpha-background . 95))
  (require 'midnight))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package gcmh
  :ensure (gcmh :host gitlab :repo "koral/gcmh")
  :init
  (gcmh-mode 1)
  (defmacro k-time (&rest body)
    "Measure and return the time it takes evaluating BODY."
    `(let ((time (current-time)))
       ,@body
       (float-time (time-since time))))

  
  ;; Set garbage collection threshold to 1GB.
  (setq gc-cons-threshold #x40000000)

  ;; When idle for 15sec run the GC no matter what.
  (defvar k-gc-timer
    (run-with-idle-timer 15 t
			 (lambda ()
                           (message "Garbage Collector has run for %.06fsec"
                                    (k-time (garbage-collect)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; keybinds
(use-package general
  :ensure (:wait t)
  :demand t
  :config
  (general-evil-setup) ;
  (general-create-definer ph/leader-key
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC"))

(defun ph/hjkl-only()
  (interactive)
  (message "hjkl only"))

(use-package evil
  :after (general)
  :ensure t
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil
	evil-want-C-u-scroll t
	evil-want-C-i-jump nil)
  
  :config
  (evil-mode 1)

  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-select-search-module 'evil-search-module 'evil-search)
  (global-set-key (kbd "C-M-u") 'universal-argument)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)

  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Disable arrow keys in normal and visual modes
  (define-key evil-normal-state-map (kbd "<left>") 'ph/hjk-only)
  (define-key evil-normal-state-map (kbd "<right>") 'ph/hjkl-only)
  (define-key evil-normal-state-map (kbd "<down>") 'ph/hjkl-only)
  (define-key evil-normal-state-map (kbd "<up>") 'ph/hjkl-only)

  (evil-global-set-key 'motion (kbd "<left>") 'ph/hjkl-only)
  (evil-global-set-key 'motion (kbd "<right>") 'ph/hjkl-only)
  (evil-global-set-key 'motion (kbd "<down>") 'ph/hjkl-only)
  (evil-global-set-key 'motion (kbd "<up>") 'ph/hjkl-only)
  (ph/leader-key
    ;; "f" '(:ignore t :wk "flymake")
    "f" '(consult-flymake :wk "toggle flymake")
    ;;"f" '(consult-flycheck :wk "toggle flycheck")

    ;; window
    "w" '(:ignore t :wk "window")
    "wc" '(evil-window-delete :wk "close window")
    "wV" '(evil-window-vnew :wk "vsplit window")
    "wH" '(evil-window-split :wk "split window")
    "wm" '(maximize-window :wk "maximine window")
    "wb" '(balance-window :wk "balance window")

    "wn" '(evil-window-next :wk "next window")
    "wp" '(evil-window-prev :wk "prev window")

    ;; applications
    "o" '(:ignore t :wk "apps")
    "om" '(mu4e :wk "mail")
    "oi" '(circe :wk "irc")

    ;; search relates functions
    "s" '(:ignore t :wk "search & replace")
    "sp" '(consult-ripgrep :wk "search in project")
    "sG" '(project-org-external-find-regexp :wk "external find regexp")
    "sr" '(project-query-replace-regexp :wk "search & replace")

    "bp" '(previous-buffer :wk "previous buffer")
    "bn" '(next-buffer :wk "next buffer")))

(use-package evil-collection
  :ensure (evil-collection :host github :repo "emacs-evil/evil-collection")
  :after (evil)
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-collection-init))

(use-package which-key
  :ensure t
  :after (evil)
  :init (which-key-mode)
  :config
  (which-key-setup-minibuffer))

(use-package org-modern
  :ensure t
  :config
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda))

(use-package evil-commentary
  :ensure t
  :after (evil)
  :config
  (evil-commentary-mode))

(use-package evil-easymotion
  :ensure t
  :config
  (evilem-default-keybindings "`"))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package yaml-mode
  :ensure t
  :mode "\\.yml\\'")

(use-package nix-mode
  :ensure (nix-mode :host github :repo "NixOS/nix-mode")
  :mode "\\.nix\\'")


(use-package docker-compose-mode
  :ensure t
  :mode "docker-compose.yml")

(use-package json-mode
  :ensure t
  :mode "\\.json\\'")

(use-package dockerfile-mode
  :ensure t
  :config
  (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package go-mode
  :ensure t
  :mode "\\.go\\'")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package pass
  :ensure t)
(use-package password-store
  :after (pass)
  :ensure t)
(use-package auth-source-pass
  :after (pass)
  :init
  (auth-source-pass-enable)
  (auth-source-search :host "github"))

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode))

(use-package inheritenv
  :ensure t
  :after envrc)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cargo-mode
  :ensure t
  :after (rustic)
  :init
  (add-hook 'rustic-mode-hook 'cargo-minor-mode))

(use-package rustic
  :ensure (rustic :host github :repo "emacs-rustic/rustic")
  :after (inheritenv envrc eglot)
  :mode ("\\.rs\\'" . rustic-mode)
  :init
  (setq rustic-lsp-client 'eglot))

(use-package ultra-scroll
  :ensure (ultra-scroll :host github :repo "jdtsmith/ultra-scroll")
  :init
  (setq scroll-conservatively 101
	scroll-margin 0)
  :config
  (ultra-scroll-mode 1))

(use-package exec-path-from-shell
  :ensure t
  :config
  (setq exec-path-from-shell-variables '("SSH_AUTH_SOCK"
					 "PATH"
					 "MANPATH"
					 "SSH_AGENT_PID"
					 "GPG_AGENT_INFO"
					 "LANG" "LC_CTYPE"))
  (setq exec-path-from-shell-arguments nil)
  (when (daemonp)
    (exec-path-from-shell-initialize)))

(unload-feature 'eldoc t)
(setq custom-delayed-init-variables '())
(defvar global-eldoc-mode nil)

(elpaca eldoc
  (require 'eldoc)
  (global-eldoc-mode)) ;; This is usually enabled by default by Emacs

(use-package jsonrpc :ensure (:wait t) :defer t)

(use-package flymake
  :ensure t
  :config
  (flymake-mode))

(use-package eglot
  :defer t
  :ensure (:wait t)
  :after (emacs flymake exec-path-from-shell envrc)
  :general
  (ph/leader-key
    "a" '(:ignore t :wk "actions")
    "aR" '(eglot-rename :wk "rename")
    "aa" '(eglot-code-actions :wk "code action")
    "aq" '(eglot-code-action-quickfix :wk "quickfix")
    "ae" '(eglot-code-action-extract :wk "extract")
    "ai" '(eglot-code-action-organize-imports :wk "organize imports")
    "aI" '(eglot-code-action-inline :wk "inline"))
  :config
  (setq eglot-sync-connect 1
	eglot-autoreconnect t
	eglot-send-changes-idle-time 0.5
	eglot-auto-display-help-buffer nil
	eglot-events-buffer-size 0
	eglot-extend-to-xref nil
	;;eglot-stay-out-of '(flymake)
	eglot-ignored-server-capabilities
	'(
	  ;; :hoverProvider
	  :documentHighlightProvider
	  :documentFormattingProvider
	  :documentRangeFormattingProvider
	  ;; :documentOnTypeFormattingProvider
	  :colorProvider
	  ;; :foldingRangeProvider
	  ))
  (advice-add 'jsonrpc--log-event :override #'ignore))

(use-package eglot-x
  :ensure (eglot-x :host github :repo "nemethf/eglot-x")
  :after (eglot)
  :config 
  (with-eval-after-load 'eglot (require 'eglot-x))
  :config
  (eglot-x-setup)
  (define-key eglot-mode-map (kbd "s-.") #'eglot-x-find-refs))

(use-package consult-eglot
  :ensure t)

(use-package tempel
  :ensure t
  :bind (("M-+" . tempel-complete)
         ("M-*" . tempel-insert))
  :config
  (setq tempel-path (expand-file-name "my-templates/*" user-emacs-directory))
  :init
  (global-tempel-abbrev-mode))

(use-package corfu
  :ensure t
  :config
  (setq corfu-auto t
	corfu-auto-delay 0.1
	corfu-auto-prefix 2
	corfu-quit-no-match 'separator
	corfu-count 16
	corfu-max-width 120)

  (add-hook 'evil-insert-state-exit-hook #'corfu-quit)
  :custom
  (corfu-cycle t)
  (corfu-preview-current 'insert)
  (corfu-preselect 'prompt)     
  :bind
  (:map corfu-map
	("TAB" . corfu-next)
	([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))
  :init
  (global-corfu-mode))

(use-package cape
  :ensure t
  :after eglot
  :init
  (defun my/eglot-capf ()
    (setq-local completion-at-point-functions
		(list (cape-capf-super
		       #'eglot-completion-at-point
		       #'cape-file
		       #'cape-dabbrev
		       #'cape-keyword))))
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  (add-hook 'eglot-managed-mode-hook #'my/eglot-capf))

(use-package orderless
  :ensure t
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package catppuccin-theme
  :ensure t
  :config
  ;; (setq catppuccin-flavor 'latte) ;; or 'latte, 'macchiato, or 'mocha
  (setq catppuccin-flavor 'macchiato) ;; or 'latte, 'macchiato, or 'mocha
  (load-theme 'catppuccin :no-confirm)
  (catppuccin-reload))

(use-package highlight-parentheses
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'highlight-parentheses-mode))

;; Spacious-padding: add more space around UI elements.
;; (use-package spacious-padding
;;   :ensure t
;;   :custom
;;   (setq
;;    ;; spacious-padding-subtle-mode-line `(:mode-line-active 'default :mode-line-inactive vertical-border)
;;    spacious-padding-widths `(:internal-border-width 0))
;;   :init
;;   (spacious-padding-mode 1))

;; (use-package mood-line
;;   :ensure t
;;   :init
;;   (mood-line-mode))

(use-package lambda-line
  :ensure (lambda-line :ensure t :host github :repo "lambda-emacs/lambda-line")
  :custom
  ;; (lambda-line-icon-time t) ;; requires ClockFace font (see below)
  ;; (lambda-line-clockface-update-fontset "ClockFaceRect") ;; set clock icon
  (lambda-line-position 'bottom) ;; Set position of status-line 
  (lambda-line-abbrev t) ;; abbreviate major modes
  (lambda-line-hspace "  ")  ;; add some cushion
  (lambda-line-prefix t) ;; use a prefix symbol
  (lambda-line-prefix-padding nil) ;; no extra space for prefix 
  (lambda-line-status-invert nil)  ;; no invert colors
  (lambda-line-gui-ro-symbol  " ⨂") ;; symbols
  (lambda-line-gui-mod-symbol " ⬤") 
  (lambda-line-gui-rw-symbol  " ◯") 
  (lambda-line-vc-symbol "")
  (lambda-line-space-top +.50)  ;; padding on top and bottom of line
  (lambda-line-space-bottom -.50)
  (lambda-line-symbol-position 0.1) ;; adjust the vertical placement of symbol
  :config
  ;; activate lambda-line 
  (lambda-line-mode) 
  ;; set divider line in footer
  (when (eq lambda-line-position 'top)
    (setq-default mode-line-format (list "%_"))
    (setq mode-line-format (list "%_"))))

(use-package vterm
  :ensure nil
  :config
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 5000)
  :general
  (ph/leader-key
    "pv" '(vterm :wk "open vterm")))

(use-package project
  :ensure nil
  :general
  (general-define-key :states 'normal
		      "SPC SPC" '(project-find-file :wk "find file"))
  (ph/leader-key
    "p" '(:ignore t :wk "project")
    "pp" '(project-switch-project :wk "switch project")
    "p!" '(project-shell-command :wk "shell command")
    "p&" '(project-async-shell-command :wk "async command")
    "pD" '(project-dired :wk "dired")
    "pc" '(project-compile :wk "compile")
    "px" '(project-execute-extended-command :wk "extended command"))

  :config
  (setq project-switch-commands #'project-find-file))

(use-package arei
  :ensure nil
  :after (project)
  (setq arei-mode-auto t))

(use-package lin
  :ensure t)

(use-package hl-todo
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'hl-todo-mode))

(use-package vertico
  :ensure (vertico :ensure t :files (:defaults "extensions/*") ) 
  :general
  (:keymaps 'vertico-map
	    "<escape>" #'minibuffer-keyboard-quit
	    "C-k" #'vertico-next
	    "C-j" #'vertico-previous)
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 12)
  (vertico-resize t)
  (vertico-cycle t)
  (keymap-set vertico-map "TAB" #'minibuffer-complete)
  :init
  (vertico-mode)
  (vertico-reverse-mode))

(use-package marginalia
  :ensure t
  :bind
  (:map minibuffer-local-map ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode 1))

(use-package terraform-mode
  :ensure t
  :mode "\\.tf\\'")

(use-package restclient
  :ensure t
  :mode (("\\.http\\'" . restclient-mode)))

(use-package protobuf-mode
  :ensure t)

(use-package copilot
  :ensure (copilot :ensure t :host github :repo "zerolfx/copilot.el")
  :hook
  (prog-mode . (lambda () (when ph/copilot-enabled (copilot-mode))))
  :general
  (ph/leader-key
    "cc" '(lambda()
	    (interactive)
	    (setq ph/copilot-enabled (not ph/copilot-enabled))
	    (message (if ph/copilot-enabled "Enabled copilot-mode" "Disabled copilot-mode"))
	    (copilot-mode (if ph/copilot-enabled 1 -1))))
  :bind
  (:map copilot-completion-map
	("<right>" . 'copilot-accept-completion)
	("C-<return>" . 'copilot-accept-completion)
	("S-TAB" . 'copilot-accept-completion-by-word)
	("S-<tab>" . 'copilot-accept-completion-by-word)
	("C-g" . #'copilot-clear-overlay)
	("C-n" . #'copilot-next-completion)
	("C-p" . #'copilot-previous-completion))
  :init
  (setq ph/copilot-enabled nil)
  :config
  (setq copilot-completion-style 'overlay)
  (setq copilot-node-executable "~/.guix-home/profile/bin/nodeq"))

(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :general
  (ph/leader-key
    "b" '(:ignore t :wk "buffer")
    "bb" '(consult-project-buffer :wk "buffer") 
    "ba" '(consult-buffer :wk "all buffer")
    "h" '(:ignore t :wk "help")
    "hm" '(consult-man :wk "man")
    "ai" '(consult-imenu :wk "imenu") 
    "aI" '(consult-imenu-multi :wk "imenu multi") 
    )
  :bind (
	 ;; C-c bindings in `mode-specific-map'
         ;; ("C-c M-x" . consult-mode-command)
         ;; ("C-c h" . consult-history)
         ;; ("C-c k" . consult-kmacro)
         ;; ("C-c m" . consult-man)
         ;; ("C-c i" . consult-info)
         ;; ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ;; ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ;; ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ;; ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ;; ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ;; ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ;; ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ;; ("M-#" . consult-register-load)
         ;; ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ;; ("C-M-#" . consult-register)
         ;; Other custom bindings
         ;; ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ;; ("M-g e" . consult-compile-error)
         ;;("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ;; ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ;; ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ;; ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ;; ("M-g m" . consult-mark)
         ;; ("M-g k" . consult-global-mark)
         ;; ("M-g i" . consult-imenu)
         ;; ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ;; ("M-s d" . consult-find)
         ;; ("M-s D" . consult-locate)
         ;; ("M-s g" . consult-grep)
         ;; ("M-s G" . consult-git-grep)
         ;; ("M-s r" . consult-ripgrep)
         ;; ("M-s l" . consult-line)
         ;; ("M-s L" . consult-line-multi)
         ;; ("M-s k" . consult-keep-lines)
         ;; ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ;; ("M-s e" . consult-isearch-history)
         ;; :map isearch-mode-map
         ;; ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ;; ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ;; ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ;; ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         ;; :map minibuffer-local-map
         ;; ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ;; ("M-r" . consult-history)
	 )                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  )

(use-package helpful
  :ensure t
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

(use-package apheleia
  :ensure t
  :config
  (setq apheleia-hide-log-buffers t)
  (apheleia-global-mode +1))

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 'prog-mode
			  '(;; == === ==== => =| =>>=>=|=>==>> ==< =/=//=// =~
			    ;; =:= =!=
			    ("=" (rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
			    ;; ;; ;;;
			    (";" (rx (+ ";")))
			    ;; && &&&
			    ("&" (rx (+ "&")))
			    ;; !! !!! !. !: !!. != !== !~
			    ("!" (rx (+ (or "=" "!" "\." ":" "~"))))
			    ;; ?? ??? ?:  ?=  ?.
			    ("?" (rx (or ":" "=" "\." (+ "?"))))
			    ;; %% %%%
			    ("%" (rx (+ "%")))
			    ;; |> ||> |||> ||||> |] |} || ||| |-> ||-||
			    ;; |->>-||-<<-| |- |== ||=||
			    ;; |==>>==<<==<=>==//==/=!==:===>
			    ("|" (rx (+ (or ">" "<" "|" "/" ":" "!" "}" "\]"
					    "-" "=" ))))
			    ;; \\ \\\ \/
			    ("\\" (rx (or "/" (+ "\\"))))
			    ;; ++ +++ ++++ +>
			    ("+" (rx (or ">" (+ "+"))))
			    ;; :: ::: :::: :> :< := :// ::=
			    (":" (rx (or ">" "<" "=" "//" ":=" (+ ":"))))
			    ;; // /// //// /\ /* /> /===:===!=//===>>==>==/
			    ("/" (rx (+ (or ">"  "<" "|" "/" "\\" "\*" ":" "!"
					    "="))))
			    ;; .. ... .... .= .- .? ..= ..<
			    ("\." (rx (or "=" "-" "\?" "\.=" "\.<" (+ "\."))))
			    ;; -- --- ---- -~ -> ->> -| -|->-->>->--<<-|
			    ("-" (rx (+ (or ">" "<" "|" "~" "-"))))
			    ;; *> */ *)  ** *** ****
			    ("*" (rx (or ">" "/" ")" (+ "*"))))
			    ;; www wwww
			    ("w" (rx (+ "w")))
			    ;; <> <!-- <|> <: <~ <~> <~~ <+ <* <$ </  <+> <*>
			    ;; <$> </> <|  <||  <||| <|||| <- <-| <-<<-|-> <->>
			    ;; <<-> <= <=> <<==<<==>=|=>==/==//=!==:=>
			    ;; << <<< <<<<
			    ("<" (rx (+ (or "\+" "\*" "\$" "<" ">" ":" "~"  "!"
					    "-"  "/" "|" "="))))
			    ;; >: >- >>- >--|-> >>-|-> >= >== >>== >=|=:=>>
			    ;; >> >>> >>>>
			    (">" (rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
			    ;; #: #= #! #( #? #[ #{ #_ #_( ## ### #####
			    ("#" (rx (or ":" "=" "!" "(" "\?" "\[" "{" "_(" "_"
					 (+ "#"))))
			    ;; ~~ ~~~ ~=  ~-  ~@ ~> ~~>
			    ("~" (rx (or ">" "=" "-" "@" "~>" (+ "~"))))
			    ;; __ ___ ____ _|_ __|____|_
			    ("_" (rx (+ (or "_" "|"))))
			    ;; Fira code: 0xFF 0x12
			    ("0" (rx (and "x" (+ (in "A-F" "a-f" "0-9")))))
			    ;; Fira code:
			    "Fl"  "Tl"  "fi"  "fj"  "fl"  "ft"
			    ;; The few not covered by the regexps.
			    "{|"  "[|"  "]#"  "(*"  "}#"  "$>"  "^="))
  (global-ligature-mode t))


(use-package shackle
  :ensure t
  :config
  (setq shackle-rules '(("*Messages*" :select t :popup t :align right :size 0.3)
			("*Occur*" :select t :popup t :align below :size 0.2)
			("*scratch*" :select t :popup t :align below :size 0.2)
			("*vterm*" :select t :popup t :align below :size 0.2)
			("*Geiser Guile REPL*", :select t :popup below :size 0.2)
			("*cargo-run*" :select t)
			(helpful-mode :select t :popup t :align right :size 0.35)
			(help-mode :select t :popup t :align right :size 0.3)))
  (shackle-mode 1))

(use-package popper
  :ensure t
  :after (project)
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :general
  (ph/leader-key
    "wh" '(evil-window-left :wk "go left")
    "wl" '(evil-window-right :wk "go right")
    "wj" '(evil-window-bottom :wk "go down")
    "wk" '(evil-window-top :wk "go top"))
  :init
  (setq popper-display-function #'display-buffer-in-child-frame)
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
	  "*cargo-test"
	  "*cargo-run"
	  "*Geiser Guile REPL*"
	  "*helpful"
          "\\*Async Shell Command\\*"
	  "*rustic-compilation*"
	  "lsp-help"
	  "*vterm*"
	  "*eldoc*"
	  "*Backtrace*"
	  "*cargo-clippy"
          help-mode
          compilation-mode))
  (setq popper-display-control 'user)
  (setq popper-group-function #'popper-group-by-project)
  (popper-mode +1)
  (popper-echo-mode +1)
  (defun rustic-process-kill-p (proc &optional no-error)
    "Don't allow two rust processes at once.

If NO-ERROR is t, don't throw error if user chooses not to kill running process."
    (if (or compilation-always-kill
	    (yes-or-no-p (format "`%s' is running; kill it? " proc)))
	(condition-case ()
            (progn
	      (interrupt-process proc)
	      (sit-for 0.5)
	      (delete-process proc))
          (error nil))
      (unless no-error
	(error "Cannot have two rust processes at once")))))

(use-package git-gutter
  :ensure t
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0))

(use-package git-gutter-fringe
  :ensure t
  :config
  ;; this is from doom emacs
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

(use-package transient
  :ensure t)

(use-package magit
  :ensure t
  :init
  ;; (require 'magit)
  (setq transient-default-level 5
	magit-diff-refine-hunk t ; show granular diffs in selected hunk
	;; Don't autosave repo buffers. This is too magical, and saving can
	;; trigger a bunch of unwanted side-effects, like save hooks and
	;; formatters. Trust the user to know what they're doing.
	magit-save-repository-buffers nil
	;; Don't display parent/related refs in commit buffers; they are rarely
	;; helpful and only add to runtime costs.
	magit-revision-insert-related-refs nil
	magit-no-confirm '(stage-all-changes unstage-all-changes))
  :custom
  (git-commit-summary-max-length 50)
  (git-commit-fill-column 72)
  :general
  :config
  (add-hook 'after-save-hook 'magit-after-save-refresh-status t)
  ;; (add-to-list 'git-commit-finish-query-functions #'my-git-commit-check-style-conventions)
  (ph/leader-key
    "g"  '(:ignore t :wk "magit")
    "gg" '(magit :wk "magit status")
    "gG" '(magit-status-here :wk "magit status here")
    "gB" '(magit-blame-addition :wk "blame")
    "gl" '(magit-log-current :wk "log")))

(use-package forge
  :ensure t
  :after magit)


(use-package circe
  :ensure t
  :after (password-store)
  :config
  (setq circe-network-options
	'(("libera"
	   :tls t
	   :port 6697
	   :host "irc.libera.chat"
	   :nick "ph"
	   :sasl-username "ph"
	   :sasl-password (lambda (&rest _) (password-store-get "irc/libera.chat/password"))
	   :channels ("#heyk")
	   ))))

(use-package mu4e-thread-folding
  :ensure (mu4e-thread-folding :host github
			       :repo "rougier/mu4e-thread-folding")

  :after (mu4e)
  :config
  (require 'mu4e-thread-folding)

  (define-key mu4e-headers-mode-map (kbd "<tab>")     'mu4e-headers-toggle-at-point)
  (define-key mu4e-headers-mode-map (kbd "<left>")    'mu4e-headers-fold-at-point)
  (define-key mu4e-headers-mode-map (kbd "<S-left>")  'mu4e-headers-fold-all)
  (define-key mu4e-headers-mode-map (kbd "<right>")   'mu4e-headers-unfold-at-point)
  (define-key mu4e-headers-mode-map (kbd "<S-right>") 'mu4e-headers-unfold-all)
  (add-to-list 'mu4e-header-info-custom
	       '(:empty . (:name "Empty"
				 :shortname ""
				 :function (lambda (msg) "  "))))
  (setq mu4e-headers-fields '((:empty         .    2)
			      (:human-date    .   12)
			      (:flags         .    6)
			      (:mailing-list  .   10)
			      (:from          .   22)
			      (:subject       .   nil)))
  (mu4e-thread-folding-mode))

(use-package mu4e
  :ensure nil
  :config
  (setq mail-user-agent 'mu4e-user-agent
	mu4e-drafts-folder "/ph@heykimo.com/drafts"
	mu4e-sent-folder   "/ph@heykimo.com/sent"
	mu4e-trash-folder  "/ph@heykimo.com/trash"
	mu4e-refile-folder  "/ph@heykimo.com/archive"
	mu4e-sent-messages-behavior 'delete
	mu4e-update-interval 300
	mu4e-compose-format-flowed t
	mu4e-use-fancy-chars t
	mu4e-index-lazy-check t
	mu4e-headers-date-format "%y.%m.%d"
	mu4e-search-include-related t
	mu4e-search-skip-duplicates t
	mu4e-get-mail-command "mbsync gmail"
	mu4e-change-filenames-when-moving t
	mu4e-confirm-quit nil
	;; this is coming from base
	user-mail-address "ph@heykimo.com"
	user-full-name  "Pier-Hugues Pellerin"
	message-kill-buffer-on-exit t
	mu4e-headers-draft-mark     '("D" . "💈")
	mu4e-headers-flagged-mark   '("F" . "📍")
	mu4e-headers-new-mark       '("N" . "🔥")
	mu4e-headers-passed-mark    '("P" . "❯")
	mu4e-headers-replied-mark   '("R" . "❮")
	mu4e-headers-seen-mark      '("S" . "☑")
	mu4e-headers-trashed-mark   '("T" . "💀")
	mu4e-headers-attach-mark    '("a" . "📎")
	mu4e-headers-encrypted-mark '("x" . "🔒")
	mu4e-headers-signed-mark    '("s" . "🔑")
	mu4e-headers-unread-mark    '("u" . "⎕")
	mu4e-headers-list-mark      '("l" . "🔈")
	mu4e-headers-personal-mark  '("p" . "👨")
	mu4e-headers-calendar-mark  '("c" . "📅")
	mu4e-compose-signature (concat "Thanks\n" "ph")))

(require 'smtpmail)
(setq sendmail-program (executable-find "msmtp")
      mail-host-address "heykimo.com"
      send-mail-function #'smtpmail-send-it
      message-sendmail-f-is-evil t
      message-sendmail-extra-arguments '("--read-envelope-from")
      message-send-mail-function #'message-send-mail-with-sendmail)


(use-package org-roam
  :ensure t
  :after (org)
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/src/notes/roam")
  (org-roam-setup))

(use-package org
  :mode
  ("\\.org\\'" . org-mode)
  :custom
  (setq org-capture-templates
	'(("t" "todo" entry (file "~/src/notes/inbox.org"))))
  :config
  (setq org-todo-keywords
	'((sequence "TODO(t)" "|" "PROGRESS(p)" "|" "DONE(d)")
	  (sequence "REPORT(r)" "BUG(b)" "KNOWNCAUSE(k)" "|" "FIXED(f)")
	  (sequence "|" "CANCELED(c)")))
  (ph/leader-key
    "x" '(:ignore t :wk "org")
    "xc" '(org-capture :wk "capture")
    "xn" '(org-roam-capture :wk "new note")
    "xf" '(org-roam-find-file :wk "find note")))

;; (use-package eglot-booster
;;   :ensure (eglot-booster :host github :repo "jdtsmith/eglot-booster")
;;   :after eglot
;;   :config
;;   (setq eglot-booster-io-only t)
;;   (eglot-booster-mode))

(use-package kind-icon
  :ensure t
  :after corfu
					;:custom
					; (kind-icon-blend-background t)
					; (kind-icon-default-face 'corfu-default) ; only needed with blend-background
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;;(use-package flycheck
;;  :ensure t
;;  :init (global-flycheck-mode))
;;
;;(use-package flycheck-eglot
;;  :ensure t
;;  :after (flycheck eglot)
;;  :config (global-flycheck-eglot-mode 1))
;;
;;(use-package consult-flycheck
;;  :ensure t)

(use-package aidermacs
  :ensure (aidermacs :host github :repo "MatthewZMD/aidermacs")
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
  (ph/leader-key
    "ag" '(aidermacs-transient-menu :wk "AI"))
  (add-hook 'aidermacs-before-run-backend-hook
	    (lambda ()
	      (setenv "OPENAI_API_KEY" (password-store-get "open_ai"))))
  :custom
  (aidermacs-use-architect-mode t)
  (aidermacs-default-model "o3-mini"))

(use-package jsonnet-mode
  :ensure t)

(push 'mu4e elpaca-ignored-dependencies)
(use-package mu4e-dashboard
  :ensure (:host github :repo "rougier/mu4e-dashboard" :build (:not elpaca--byte-compile))
  :config
  (setq mu4e-dashboard-file "~/.config/emacs/mu4e-dashboard.org")
  :custom
  (defun ph/open-dashboard ()
    (interactive)
    (with-current-buffer
	(find-file mu4e-dashboard-file)
      (mu4e-dashboard-mode 1))))

(use-package flymake-guile
  :ensure t
  :hook (scheme-mode-hook . flymake-guile))

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "REPORT(r)" "BUG(b)" "KNOWNCAUSE(k)" "|" "FIXED(f)")
        (sequence "|" "CANCELED(c)")))
