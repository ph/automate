;;; SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;;; -*- lexical-binding: t -*-
;; records use-package time to reduce startup time.
(setq use-package-compute-statistics t)

(setopt custom-file (locate-user-emacs-file "custom.el"))
(if (not (file-exists-p custom-file))
    (make-empty-file custom-file)
  (load custom-file))

(defvar ph/emacs-backup-directory
  (expand-file-name ".config/emacs-backup" (getenv "HOME")))

(if (not (file-exists-p ph/emacs-backup-directory))
    (make-directory ph/emacs-backup-directory))

(use-package gcmh
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
			   (let ((gc-time (k-time (garbage-collect))))
			     ;; (message "Garbage Collector has run for %.06fsec" gc-time)
			     )))))
(use-package emacs
  :hook
  ((before-save . delete-trailing-whitespace)
   ;; Automatic parenthesis pairing.
   (after-init . electric-pair-mode)

   ;; Show matching parens
   ;; (after-init . show-paren-mode)

   (after-init . transient-mark-mode)

   ;; Make the UI less clunky.
   (after-init . tool-bar-mode)
   (after-init . menu-bar-mode)
   (after-init . scroll-bar-mode)
   (after-init . global-auto-revert-mode)
   (after-init . pixel-scroll-precision-mode)

   ;; Show line number for prog or text mode and leave them out for treemacs and
   ;; similar mode.
   (prog-mode . hl-line-mode)
   (text-mode . hl-line-mode)

   ;; enable pretty symbols for lisp/scheme
   (lisp-mode . prettify-symbols-mode)
   (scheme-mode . prettify-symbols-mode)
   (fennel-mode . prettify-symbols-mode)

   (minibuffer-setup . cursor-intangible-mode))
  :custom
  ;; Three options for paren-style: 'expression, 'parenthesis, and
  ;; 'mixed The first one highlights the complete region between
  ;; parens, the second only highlights the matching paren, the third
  ;; does 'expression when the matching paren is not visible.
  ;; (show-paren-style 'mixed)

  ;; TAB cycle if there are only few candidates
  (completion-cycle-threshold 3)

  (show-paren-style 'expression)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  (window-sides-vertical t)

  ;; replace `(lambda () ...)' to `(λ () ... )'
  (prettify-symbols-alist '(("lambda" . λ)))

  ;; Larger read to improve lsp-mode.
  (read-process-output-max (* 1024 1024)) ;; 1mb

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p)

  ;; Idle time delay before ‘which-function-mode‘ updates its display.
  (which-func-update-delay 1.0)

  ;; UTF-8
  (locale-coding-system   'utf-8)

  ;; When recompiling kill current process, in rust case it
  ;; could be `cargo run` or `cargo test`.
  (compilation-always-kill t)

  (make-backup-files nil)

  ;; Only edit left-to-right files so we can make reduce runtime cost.
  ;; This is not really visible in small buffer but in large yes.
  (bidi-display-reordering 'left-to-right)
  (bidi-paragraph-direction 'left-to-right)
  (bidi-inhibit-bpa t)

  ;; Dont' bug me to save.
  (compilation-ask-about-save nil)

  (revert-without-query '(".*"))
  (create-lockfiles nil)
  (auto-save-default nil)

  ;; Reduce elisp compilation warning in the buffers on startup.
  (byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))
  (native-comp-async-report-warnings-errors nil)

  ;; If new changes load them.
  (load-prefer-newer t)

  ;; Opinions how backups are done.
  (backup-directory-alist `(("." . ,ph/emacs-backup-directory)))

  ;; Minibuffer options
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (enable-recursive-minibuffers t)

  ;; Load the squash buffer directly.
  (inhibit-splash-screen t)

  ;; Skip Fontification During Input
  ;; Delay syntax highlight to after we are done typing.
  (redisplay-skip-fontification-on-input t)

  :config
  ;; Ensure UTF-8
  (set-language-environment    "UTF-8")
  (prefer-coding-system        'utf-8)
  (set-default-coding-systems  'utf-8)
  (set-terminal-coding-system  'utf-8)
  (set-keyboard-coding-system  'utf-8)
  (set-selection-coding-system 'utf-8)

  (add-to-list 'default-frame-alist '(alpha-background . 95))
  (set-frame-parameter nil 'alpha-background 95)

  ;; Fonts
  ;; (set-face-attribute 'default nil :font "Lilex Nerd Font Mono" :height 120)
  (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 100)

  ;; Less keys to type on confirmation.
  (fset 'yes-or-no-p 'y-or-n-p))

(use-package uniquify
  :custom
  ;; Disambiguate buffers with same name using path.
  (uniquify-buffer-name-style 'forward))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environment
(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package inheritenv
  :after envrc)

;; Exec the command and keep some of the shell environment values.
(use-package exec-path-from-shell
  :after (envrc inheritenv)
  :custom
  (exec-path-from-shell-variables '("SSH_AUTH_SOCK"
				    "PATH"
				    "MANPATH"
				    "LSP_USE_PLISTS"
				    "SSH_AGENT_PID"
				    "GPG_AGENT_INFO"
				    "LANG"
				    "LC_CTYPE"))
  (exec-path-from-shell-arguments nil)
  :config
  (when (daemonp)
    (exec-path-from-shell-initialize)))

;; Clean old buffers.
(use-package midnight
  :config
  (midnight-delay-set 'midnight-delay "3:00am"))

;; Save history of commands.
(use-package savehist
  :init
  (savehist-mode))

(use-package general
  :config
  (general-evil-setup)
  (general-define-key
   "s-k" 'eldoc-doc-buffer)
  (general-create-definer ph/leader-key
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC"))

;; VIM keybinding
(use-package evil
  :after general
  :init
  (setq evil-want-integration 1
	evil-want-keybinding nil
	evil-want-C-u-scroll t
	evil-want-C-i-jump nil)

  :config
  (evil-mode 1)

  (defun ph/hjkl-only
      (interactive)
    (message "hjkl only"))

  ;; Disable non-vim-like movements keys
  (define-key evil-normal-state-map (kbd "<left>") 'ph/hjk-only)
  (define-key evil-normal-state-map (kbd "<right>") 'ph/hjkl-only)
  (define-key evil-normal-state-map (kbd "<down>") 'ph/hjkl-only)
  (define-key evil-normal-state-map (kbd "<up>") 'ph/hjkl-only)

  (evil-global-set-key 'motion (kbd "<left>") 'ph/hjkl-only)
  (evil-global-set-key 'motion (kbd "<right>") 'ph/hjkl-only)
  (evil-global-set-key 'motion (kbd "<down>") 'ph/hjkl-only)
  (evil-global-set-key 'motion (kbd "<up>") 'ph/hjkl-only)

  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-select-search-module 'evil-search-module 'evil-search)
  (global-set-key (kbd "C-M-u") 'universal-argument)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)

  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

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

    ;; search relates functions
    "s" '(:ignore t :wk "search & replace")
    "sp" '(consult-ripgrep :wk "search in project")
    "sG" '(project-org-external-find-regexp :wk "external find regexp")
    "sr" '(project-query-replace-regexp :wk "search & replace")

    "bp" '(previous-buffer :wk "previous buffer")
    "bn" '(next-buffer :wk "next buffer")))

;; (use-package modus-catppuccin
;;   :config
;;   ;; (load-theme 'modus-catppuccin-macchiato :no-confirm)
;;   (load-theme 'modus-catppuccin-latte :no-confirm))

;; (use-package ef-themes
;;   :ensure t
;;   :init
;;   ;; This makes the Modus commands listed below consider only the Ef
;;   ;; themes.  For an alternative that includes Modus and all
;;   ;; derivative themes (like Ef), enable the
;;   ;; `modus-themes-include-derivatives-mode' instead.  The manual of
;;   ;; the Ef themes has a section that explains all the possibilities:
;;   ;;
;;   ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
;;   ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
;;   (ef-themes-take-over-modus-themes-mode 1)
;;   :bind
;;   (("<f5>" . modus-themes-rotate)
;;    ("C-<f5>" . modus-themes-select)
;;    ("M-<f5>" . modus-themes-load-random))
;;   :config
;;   ;; All customisations here.
;;   (setq modus-themes-mixed-fonts t)
;;   (setq modus-themes-italic-constructs t)
;;   (setq modus-themes-bold-constructs t)
;;   (setq modus-themes-prompts '(bold intense))

;;   ;; Finally, load your theme of choice (or a random one with
;;   ;; `modus-themes-load-random', `modus-themes-load-random-dark',
;;   ;; `modus-themes-load-random-light').
;;   (modus-themes-load-theme 'ef-dream))

(use-package catppuccin-theme
  :custom
  (catppuccin-flavor 'latte) ;; or 'latte, 'macchiato, or 'mocha
  :config
  (load-theme 'catppuccin :no-confirm))

;; Improved termibal experience
(use-package eat
  :custom
  (eat-kill-buffer-on-exit t)
  (eshell-visual-commands nil)
  :hook
  (eshell-load . eat-eshell-mode)
  :general
  (ph/leader-key
    "pv" '(eat :wk "open term")))


;; Make emacs commenting behave as vim.
(use-package evil-commentary
  :after (evil)
  :config
  (evil-commentary-mode))

;; Manipulate inside of quote or brackets easily, this is a port of evil-surround.
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

;; Display bindings.
(use-package which-key
  :after (evil)
  :init
  (which-key-mode)
  :config
  (which-key-setup-minibuffer))

;; The best git client ever created.
(use-package magit
  :config
  (setq transient-default-level 5
	;; show diff in selected hunk of code.
	magit-diff-refine-hunk t
	;; Don't autosave repository buffers, let the uses do it.
	magit-save-repository-buffers nil
	;; hide related parent refs in the commit buffers, reduce runtime costs.
	magit-revision-insert-related-refs nil
	;; trust the user.
	magit-no-confirm '(stage-all-changes unstage-all-changes))
  ;; propagate projects into magit windows.
  (add-hook 'after-save-hook 'magit-after-save-refresh-status t)
  :general
  (ph/leader-key
    "g"  '(:ignore t :wk "magit")
    "gg" '(magit :wk "status")
    "gG" '(magit-status-here :wk "git status here")
    "gB" '(magit-blame-addition :wk "blame")
    "gl" '(magit-log-current :wk "log")))

;; Allow magit to interact with web forge like github.
(use-package forge
  :after magit)

;; ;; Add vim-like-command to common libraries.
(use-package evil-collection
  :after (evil forge)
  :config
  ;; TODO: we need to go back here and lazy enable them per mode.
  ;; https://github.com/emacs-evil/evil-collection?tab=readme-ov-file#installation
  (evil-collection-init))

;; Manage project in emacs.
(use-package project
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

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0))

(use-package git-gutter-fringe
  :after git-gutter
  :config
  ;; this is from doom emacs
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))


;; Reformat the current buffer at point.
(use-package apheleia
  :config
  (setq apheleia-hide-log-buffers t)
  (apheleia-global-mode +1))

;; Show the source code of the function.
(use-package helpful
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows and popups

;; Control overrides for the popups or windows.
(use-package shackle
  :config
  (setq shackle-rules '(("*Messages*" :select t :popup t :align right :size 0.3)
			("*Occur*" :select t :popup t :align below :size 0.2)
			("*scratch*" :select t :popup t :align below :size 0.2)
			("*eat*" :select t :popup t :align below :size 0.2)
			("*Geiser Guile REPL*", :select t :popup below :size 0.2)
			("*Fennel Proto REPL.*?", :select t :popup below :size 0.2)
			("*arei.*?", :regexp t :select t :popup below :size 0.2)
			("*cargo-run*" :select t)
			(helpful-mode :select t :popup t :align right :size 0.35)
			(help-mode :select t :popup t :align right :size 0.3)))
  (shackle-mode 1))

;; Provide ultra smooth scrolling
(use-package ultra-scroll
  :init
  (setq scroll-conservatively 3 ; or whatever value you prefer, since v0.4
        scroll-margin 0)        ; important: scroll-margin>0 not yet supported
  :config
  (ultra-scroll-mode 1))

(use-package popper
  :after project
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
	  "*Fennel Proto REPL.*"
	  "*helpful"
          "\\*Async Shell Command\\*"
	  "*rustic-compilation*"
	  "lsp-help"
	  "*vterm*"
	  "*eldoc*"
	  "arei-debugger*"
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Autocomplete popup
(use-package corfu
  :config

  (setq corfu-auto t
	corfu-auto-delay 0.1
	corfu-auto-prefix 2
	corfu-quit-no-match 'separator
	corfu-count 16
	corfu-max-width 120)

  (add-hook 'evil-insert-state-exit-hook #'corfu-quit)
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-preview-current 'insert)
  (corfu-preselect 'prompt)
  (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  :bind
  (:map corfu-map
	("TAB" . corfu-next)
	([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))

  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  ;; Enable optional extension modes:
  (corfu-history-mode)
  (corfu-popupinfo-mode))

;; Add relevent icons next to the autocomplete item in the overlay.
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-blend-background t)
  (kind-icon-default-face 'corfu-default) ; only needed with blend-background
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Manage multiples autocomplete sources.
(use-package cape)

(use-package orderless
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Create auto complete snippets
(use-package tempel
  :bind (("M-+" . tempel-complete)
         ("M-*" . tempel-insert))
  :config
  (setq tempel-path (expand-file-name "my-templates/*" user-emacs-directory))
  :init
  (global-tempel-abbrev-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org
(use-package org
  :config
  (setq org-directory (expand-file-name "src/notes" (getenv "HOME")))
  (setq org-agenda-files (list org-directory))

  (setq org-capture-templates
	`(("i" "󱉰 Inbox" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "Inbox")
	   "**  %?\n%i\n%a" :preprend t :jump-to-captured t)))

  (setq org-todo-keywords
	'((sequence "TODO(t)" "|" "NEXT(n)"  "|" "PROGRESS(p)" "|" "WAIT(w)" "|" "HOLD(h)" "|" "DELEGATED(l)" "|" "DONE(d)" "|" "KILL(k)")))

  (setq org-refile-targets
	`((,(expand-file-name "todo.org" org-directory) :maxlevel . 1))
	org-refile-use-outline-path 'file
	org-outline-path-complete-in-steps nil)

  (setq org-archive-location (concat (expand-file-name "archives.org" org-directory) "::datetree/* Archived Tasks"))

  ;; ensure files is saved after refile
  (add-hook 'org-after-refile-insert-hook #'save-buffer)

  (ph/leader-key
    "x" '(:ignore t :wk "org")
    "xo" '((lambda ()
	     (interactive)
	     (find-file-other-window (expand-file-name "todo.org" org-directory))) :wk "open todo" )
    "xc" '(org-capture :wk "capture")
    "xi" '((lambda () (interactive) (org-capture nil "i")) :wk "capture todo")
    "xn" '(org-roam-capture :wk "new note")
    "xf" '(org-roam-find-file :wk "find note")))

(use-package org-roam
  :after org
  :defer t
  :custom
  (org-roam-directory (concat (org-directory) "roam"))
  (org-roam-setup))

(use-package org-modern
  :after org
  :config
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda))


;; Ligatures
(use-package ligature
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
			    ;; ;; www wwww
			    ;; ("w" (rx (+ "w")))
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; email
(use-package mu4e
  :general
  (ph/leader-key
    "om" '(mu4e :wk "mail"))
  :hook
  (mu4e-thread-mode . mu4e-thread-fold-apply-all)
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
	mu4e-get-mail-command "mbsync -a"
	mu4e-change-filenames-when-moving t
	mu4e-confirm-quit nil
	;; this is coming from base
	user-mail-address "ph@heykimo.com"
	user-full-name  "Pier-Hugues Pellerin"
	message-kill-buffer-on-exit t
	mu4e-headers-draft-mark     '("D" . "")
	mu4e-headers-flagged-mark   '("F" . "󰈿")
	mu4e-headers-new-mark       '("N" . "󰈸")
	mu4e-headers-passed-mark    '("P" . "❯")
	mu4e-headers-replied-mark   '("R" . "󰑚") ;;❮
	mu4e-headers-seen-mark      '("S" . "")
	mu4e-headers-trashed-mark   '("T" . "󰚌")
	mu4e-headers-attach-mark    '("a" . "󰁦")
	mu4e-headers-encrypted-mark '("x" . "")
	mu4e-headers-signed-mark    '("s" . "󰌆")
	mu4e-headers-unread-mark    '("u" . "")
	mu4e-headers-list-mark      '("l" . "󱜽")
	mu4e-headers-personal-mark  '("p" . "󰙃")
	mu4e-headers-calendar-mark  '("c" . "")
	mu4e-compose-signature (concat "Thanks\n" "ph")
	mu4e-split-view 'vertical
	mu4e-headers-visible-columns 40
	mm-discouraged-alternatives '("text/html" "text/richtext"))

  (setq mu4e-maildir-shortcuts
	'((:maildir "/ph@heykimo.com/inbox"     :name "Inbox"   :key  ?i)
	  (:maildir "/ph@heykimo.com/drafts"    :name "Drafts"  :key  ?d)
	  (:maildir "/ph@heykimo.com/sent"      :name "Sent"    :key  ?s)
	  (:maildir "/ph@heykimo.com/archive"   :name "Archive" :key  ?a)
	  (:maildir "/ph@heykimo.com/spam"      :name "Spam" :key  ?p)
	  (:maildir "/ph@heykimo.com/trash"     :name "Trash" :key  ?t)
	  (:maildir "/ph@heykimo.com/lists"     :name "Lists" :key  ?l)))

  (setq mu4e-bookmarks
	'((:name "Unread" :query "flag:unread and not flag:list and not from:ph@heykimo.com and not from:phpellerin@gmail.com and maildir:/ph@heykimo.com/inbox" :key ?u)
	  (:name "Flagged" :query "flag:flagged and not flag:list" :key ?f)
	  (:name "Today" :query "date:today..now and not flag:list" :key ?t)
	  (:name "Yesterday" :query "date:2d..today and not flag:list" :key ?y)
	  (:name "Last Week" :query "date:7d..now and not flag:list" :key ?w)
	  (:name "Last Month" :query "date:4w..now and not flag:list" :key ?m)
	  (:name "me" :query "from:ph@heykimo.com or from:phpellerin@gmail.com" :key ?p)
	  (:name "Caroline" :query "from:caro.champ@gmail.com" :key ?c)
	  (:name "Anaïs" :query "from:anais@heykimo.com" :key  ?a)
	  (:name "Guix Devel" :query "list:guix-devel.gnu.org and not maildir:/ph@heykimo.com/archive" :key ?g)
	  (:name "Guix Help" :query "list:guix-help.gnu.org" :key ?h)))

  (defgroup ph-mu4e nil
    "Custom mu4e settings.")

  (defun ph/same-day? (date-a date-b)
    "Return true if the DATE-A and DATE-B are on the same day."
    (let ((a (decode-time date-a))
	  (b (decode-time date-b)))
      (and (eq (nth 3 a) (nth 3 b))
	   (eq (nth 4 a) (nth 4 b))
	   (eq (nth 5 a) (nth 5 b)))))

  (defun ph/last-year? (date)
    (let ((date (decode-time date))
	  (today (decode-time (current-time))))
      (>= (- (nth 5 today) (nth 5 date)) 1)))

  (defcustom ph/mu4e-relative-date-format "%H:%M"
    "Date format for relative date"
    :type 'string
    :group 'ph-mu4e)

  (defcustom ph/mu4e-current-year-format "%e %b"
    "Date format for the current year"
    :type 'string
    :group 'ph-mu4e)

  (defcustom ph/mu4e-after-a-year-format "%m/%d/%Y"
    "Date format after a year"
    :type 'string
    :group 'ph-mu4e)

  (defcustom ph/mu4e-maildir-root-path-to-remove "/ph@heykimo.com/"
    "The path of the maildir to hide in the UI"
    :type 'string
    :group 'ph-mu4e)

  (defun ph/remove-root-path-in-maildir (target)
    "Return a new path without the part defined in {ph/mu4e-maildir-path-to-remove}."
    (string-replace ph/mu4e-maildir-root-path-to-remove "" target))

  (defun ph/prepend-icon-to-string-when-matched (match icon)
    "Return a lambda that will prepend an icon to a string in argument."
    (lambda (target)
      (if (string= target match)
	  (concat icon target)
	target)))

  (setf (plist-get (alist-get 'move mu4e-marks) :show-target)
	(lambda (target)
	  (funcall (ph/prepend-icon-to-string-when-matched "archive" " ")
		   (ph/remove-root-path-in-maildir target))))

  (setf (plist-get (alist-get 'trash mu4e-marks) :show-target)
	(lambda (target)
	  (funcall (ph/prepend-icon-to-string-when-matched "trash" " ")
		   (ph/remove-root-path-in-maildir target))))

  (defun ph/mu4e-headers-relative-date (msg)
    "Show a \"relative\" date for MSG.
    If the date is today, show the time, otherwise, show the date.
    The formats used for date and time are `mu4e-headers-date-format'
    and `mu4e-headers-time-format'."
    (let ((date (mu4e-msg-field msg :date)))
      (if (equal date '(0 0 0))
	  "None"
	(let ((today (current-time)))
	  (cond
	   ((ph/same-day? date today)
	    (format-time-string ph/mu4e-relative-date-format date))
	   ((ph/last-year? date)
	    (format-time-string ph/mu4e-after-a-year-format date))
	   ((format-time-string ph/mu4e-current-year-format date)))))))


  (add-to-list 'mu4e-header-info-custom
	       '(:ph-relative-date . ( :name "Date"
				       :shortname "Date"
				       :help "Date received"
				       :function ph/mu4e-headers-relative-date)))

  (setq mu4e-headers-visible-flags
	'(flagged attach calendar trashed signed encrypted))

  (setq mu4e-headers-fields
	'((:from . 22)
	  (:subject . 80)
	  (:flags . 6)
	  (:ph-relative-date . 12)))

  (evil-collection-init 'mu4e)
  (require 'smtpmail)
  (setq sendmail-program (executable-find "msmtp")
	mail-host-address "heykimo.com"
	send-mail-function #'smtpmail-send-it
	message-sendmail-f-is-evil t
	message-sendmail-extra-arguments '("--read-envelope-from")
	message-send-mail-function #'message-send-mail-with-sendmail))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pass
(use-package pass)

(use-package password-store
  :after pass)

(use-package auth-source-pass
  :after pass
  :custom
  (auth-source-pass-enable)
  (auth-source-search :host "github"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package circe
  :general
  (ph/leader-key
    "oi" '(circe :wk "irc"))
  :config
  (setq
   circe-network-defaults '()
   circe-network-options '(("libera"
			    :tls t
			    :port 6697
			    :host "irc.libera.chat"
			    :nick "ph"
			    :sasl-username "ph"
			    :sasl-password (lambda (&rest _) (password-store-get "irc/libera.chat/password"))
			    :channels ("#heyk")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;; Display a simple mod line.
(use-package lambda-line
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

;; Make the HL line more suitable for selection UI.
(use-package lin
  :init
  (lin-mode))

;; Highlight TODO, FIXME, HACK and other
(use-package hl-todo
  :hook
  ;; only useful for programming.
  (prog-mode-hook . hl-todo-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mini-buffer
;; Add description of the command in the minibuffer
(use-package marginalia
  :bind
  (:map minibuffer-local-map ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode 1))

;; Vertico provides a performant and minimalistic vertical completion
;; UI based on the default completion system.
(use-package vertico
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

;; Example configuration for Consult
(use-package consult
  :general
  (ph/leader-key
    "b" '(:ignore t :wk "buffer")
    "bb" '(consult-project-buffer :wk "buffer")
    "ba" '(consult-buffer :wk "all buffer")
    "h" '(:ignore t :wk "help")
    "hm" '(consult-man :wk "man")
    "ai" '(consult-imenu :wk "imenu")
    "aI" '(consult-imenu-multi :wk "imenu multi"))

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

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
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax and prog mode.

(use-package geiser
  :when (locate-library "arei.el")
  :custom (geiser-mode-auto-p nil))


(defun ph/start-ares-nrepl ()
  (interactive)
  (inheritenv
   (let ((default-directory (project-root (project-current t))))
     (if default-directory
	 (start-process "run make ares" "make ares" "make" "ares")))))

(use-package arei
  :when (locate-library "arei.el")
  :init (global-arei-mode)
  :general
  (ph/leader-key
    "am" '(ph/start-ares-nrepl :wk "arei nrepl")))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package kdl-mode
  :mode "\\.kdl\\'")

(use-package yaml-mode
  :mode "\\.yml\\'")

(use-package json-mode
  :mode "\\.json\\'")

(use-package dockerfile-mode
  :mode "^(dockerfile|Dockerfile)$"
  :custom
  (put 'dockerfile-image-name 'safe-local-variable #'stringp))

(use-package go-mode
  :mode "\\.go\\'")

(use-package terraform-mode
  :mode "\\.tf\\'")

(use-package restclient
  :mode (("\\.http\\'" . restclient-mode)))

;; Major mode for editing protobuf files.
(use-package protobuf-mode
  :mode "\\.proto\\'")

(use-package flymake
  :after project
  :custom
  (flymake-mode))

(use-package treesit-auto
  :config
  (require 'dockerfile-ts-mode)
  (require 'go-ts-mode)
  (require 'rust-ts-mode)
  (require 'typescript-ts-mode)
  (require 'yaml-ts-mode)
  (require 'lua-ts-mode)

  ;; Make them available in org mode.
  (add-to-list 'org-src-lang-modes '("dockerfile" . dockerfile-ts))
  (add-to-list 'org-src-lang-modes '("go" . go-ts))
  (add-to-list 'org-src-lang-modes '("rust" . rust-ts))
  (add-to-list 'org-src-lang-modes '("typescript" . typescript-ts))
  (add-to-list 'org-src-lang-modes '("yaml" . yaml-ts))
  (add-to-list 'org-src-lang-modes '("lua" . lua-ts))
  :hook
  (after-init . global-treesit-auto-mode))

(use-package rustic
  :init
  (setq rust-mode-treesitter-derive t)
  :config
  (setq rustic-format-on-save nil)
  :custom
  (rustic-cargo-use-last-stored-arguments t))

;; (use-package lispy
;; NOTE(ph): Do not make it automatic for now.
;; :hook
;; ((emacs-lisp-mode . lispy-mode)
;;  (lisp-mode . lispy-mode)
;;  (scheme-mode .lispy-mode))
;; )

;; (use-package lispyville
;;   :after lispy
;;   :hook (lispy-mode . lispyville-mode))

;; (use-package rainbow-delimiters
;;   :hook
;;   (prog-mode . rainbow-delimiters-mode))

;; (use-package paredit
;;   :commands paredit-mode
;;   :hook
;;   ((emacs-lisp-mode . lispy-mode)
;;    (lisp-mode . lispy-mode)
;;    (scheme-mode .lispy-mode)))

;; (use-package enhanced-evil-paredit
;;   :commands enhanced-evil-paredit-mode
;;   :hook (paredit-mode . enhanced-evil-paredit-mode))


(defcustom ph/files-for-agentic-projects '("CLAUDE.md" "AGENT.md")
  "Files used to identify agent-aware projects directories."
  :type '(repeat string)
  :group 'agent)

(defcustom ph/agent-sandbox-packages '("bash"
				       "openssl"
				       "nss-certs"
				       "coreutils"
				       "grep"
				       "gawk"
				       "sed"
				       "jq"
				       "git"
				       "node"
				       "rust"
				       "rust:cargo"
				       "nix")
  "Packages installed in the agent sandbox."
  :type '(repeat string)
  :group 'agent)

(defcustom ph/default-sandbox-shares `(,(expand-file-name ".local/npm" (getenv "HOME"))
				       ,(expand-file-name ".claude" (getenv "HOME"))
				       ,(expand-file-name ".local/share/claude" (getenv "HOME"))
				       ,(expand-file-name ".local/bin/claude" (getenv "HOME"))
				       ,(expand-file-name ".cache/claude" (getenv "HOME"))
				       ,(expand-file-name ".config/claude" (getenv "HOME"))
				       ,(expand-file-name ".cargo" (getenv "HOME"))
				       ,(expand-file-name ".claude.json" (getenv "HOME")))
  "Default shares to expose to the sandbox."
  :type '(repeat string)
  :group 'agent)

(defcustom ph/project-customs-share '()
  "Addition shares path for project."
  :type '(repeat string)
  :group 'agent)

(defun ph/make-share-path (path)
  (concat "--share=" path))

(defun ph/project-root-from-buffer (buffer)
  (with-current-buffer buffer
    default-directory))

(defun ph/claude-agent-container-environment-mapping ()
  (concat "--share="
	  (expand-file-name ".local/bin/claude-agent-acp-wrapper" (getenv "HOME"))
	  "=/bin/claude-agent-acp"))

(defun ph/guix-container-prefix (&optional buffer)
  `("guix"
    "shell"
    "--container"
    "--network"
    "--emulate-fhs"
    ,(ph/claude-agent-container-environment-mapping)
    ,@(mapcar 'ph/make-share-path ph/default-sandbox-shares)
    ,@(mapcar 'ph/make-share-path ph/project-customs-share)
    ,(ph/make-share-path (ph/project-root-from-buffer buffer))
    ,@ph/agent-sandbox-packages
    "--"))

(use-package agent-shell
  :config
  ;; Evil state-specific RET behavior: insert mode = newline, normal mode = send
  (evil-define-key 'insert agent-shell-mode-map (kbd "RET") #'newline)
  (evil-define-key 'normal agent-shell-mode-map (kbd "RET") #'comint-send-input)

  ;; Configure *agent-shell-diff* buf
  ;; Configure *agent-shell-diff* buffers to start in Emacs state
  (add-hook 'diff-mode-hook
	    (lambda ()
	      (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
		(evil-emacs-state))))
  (setq agent-shell-anthropic-authentication
	(agent-shell-anthropic-make-authentication :login t))
  (setq agent-shell-anthropic-claude-environment
	(agent-shell-make-environment-variables :inherit-env t))
  ;; TODO(ph): just use the proc directly.
  (setq agent-shell-command-prefix (lambda (buffer) (ph/guix-container-prefix buffer))))

(use-package symex-core)

(use-package symex
  :after symex-core
  :config
  (symex-mode)
  :general
  (ph/leader-key
    ";" '(symex-mode-interface :wk "symex")))

(use-package  symex-ide
  :after (symex)
  :config
  (symex-ide-mode 1))

(use-package symex-evil
  :after (symex evil)
  :config
  (defvar-local entered-insert-from-symex nil
    "Did buffer's most recent entry into insert state come from symex state?")
  (add-hook 'evil-insert-state-entry-hook
	    (lambda ()
	      (setq entered-insert-from-symex (eq evil-previous-state 'symex))))

  ;; when returning from insert state, go back to symex state if it's whence we came
  (advice-add 'evil-normal-state :after
	      (lambda (&rest _)
		(when (and (eq evil-previous-state 'insert) entered-insert-from-symex) ; when we're coming from insert state, and got thither from symex state
					;(setq entered-insert-from-symex nil) ; this seems to be redundant, but would make doubly sure it's just a one-shot
		  (symex-mode-interface))))
  (symex-evil-mode 1))

;; (use-package mu4e-dashboard
;;   :config
;;   (setq mu4e-dashboard-file "~/src/automate/files/dotfiles/.config/emacs/side-dashboard.org"))

;; TODO(ph): to evaluate, not sure I like all the colors in the code.
;; (use-package prism
;;   :hook
;;   ((emacs-lisp-mode . prism-mode)
;;    (scheme-mode . prism-mode)
;;    (lisp-mode . prism-mode))
;;   :custom
;;   (prism-parens t))

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;; For a more ergonomic Emacs and `dape' experience
(use-package repeat
  :custom
  (repeat-mode +1))

(use-package lsp-mode
  :custom
  (lsp-completion-provider :none)
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-auto-install-server nil)
  (setq lsp-enable-suggest-server-download nil)
  (setq lsp-auto-guess-root t)
  (setq lsp-enable-snippet nil)
  (setq lsp-log-io nil)
  (setq lsp-keep-workspace-alive nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-auto-guess-root nil)
  (defvar lsp-modeline-code-actions-segments '(count icon name))
  (defun ph/orderless-dispatch-flex-first (_pattern index _total)
    (and (eq index 0) 'orderless-flex))
  (defun ph/autocomplete-cape ()
    (list (cape-capf-buster #'lsp-completion-at-point)
	  #'cape-file
	  #'cape-dabbrev
	  #'cape-keyword))
  (defun ph/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
	  '(orderless))
    ;; Optionally configure the first word as flex filtered.
    (setq-local orderless-style-dispatchers (list #'ph/orderless-dispatch-flex-first))
    ;; Optionally configure the cape-capf-buster.
    (setq-local completion-at-point-functions (ph/autocomplete-cape)))
  :hook ((lsp-completion-mode . ph/lsp-mode-setup-completion)
	 (rust-ts-mode . lsp-deferred)
	 (fennel-mode . lsp-deferred)
	 (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package dap-mode
  :custom
  (add-hook 'rustic-mode-hook (lambda ()
				(dap-register-debug-template "Rust LLDB Debug Configuration"
							     (list :type "cppdbg"
								   :request "launch"
								   :name "Rust::Run"
								   :MIMode "lldb"
								   :gdbpath "rust-lldb"
								   :program (concat
									     (project-root (current-project))
									     "target/debug/"
									     (project-name (current-project)))
								   :environment []
								   :cwd (project-root (current-project)))))))


;; (use-package lsp-ui
;;   :commands lsp-ui-mode)

(use-package lsp-ui
  :ensure t
  :commands
  (lsp-ui-doc-show
   lsp-ui-doc-glance)
  :bind (:map lsp-mode-map
	      ("C-c C-d" . 'lsp-ui-doc-glance))
  :after (lsp-mode evil)
  :config (setq lsp-ui-doc-enable t
                evil-lookup-func #'lsp-ui-doc-glance
                lsp-ui-doc-show-with-cursor nil
                lsp-ui-doc-include-signature t
		lsp-ui-doc-position 'top))

(use-package consult-lsp)

(use-package fennel-mode
  :after (envrc inheritenv)
  :mode "\\.fnl\\'"
  :hook (fennel-mode-hook . fennel-proto-repl-minor-mode)
  :config
  (advice-add 'fennel-repl :around #'envrc-propagate-environment))

(use-package colorful-mode
  :custom
  (colorful-use-prefix t)
  (colorful-only-strings 'only-prog)
  (css-fontify-colors nil)
  :config
  (global-colorful-mode t)
  (add-to-list 'global-colorful-modes 'helpful-mode))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-buffer-name-function            #'treemacs-default-buffer-name
          treemacs-buffer-name-prefix              " *Treemacs-Buffer-"
          treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-hide-dot-jj-directory           t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-files-by-mouse-dragging    t
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("<f2>"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-projectile
  :after (treemacs project))

(use-package nerd-icons
  :custom
  (nerd-icons-font-family "JetBrainsMono Nerd Font"))

(use-package treemacs-nerd-icons
  :after (treemacs)
  :config
  (treemacs-load-theme "nerd-icons"))

;; monokai-pro-machine
;; return {
;;   dark2 = "#161b1e",
;;   dark1 = "#1d2528",
;;   background = "#273136",
;;   text = "#f2fffc",
;;   accent1 = "#ff6d7e",
;;   accent2 = "#ffb270",
;;   accent3 = "#ffed72",
;;   accent4 = "#a2e57b",
;;   accent5 = "#7cd5f1",
;;   accent6 = "#baa0f8",
;;   dimmed1 = "#b8c4c3",
;;   dimmed2 = "#8b9798",
;;   dimmed3 = "#6b7678",
;;   dimmed4 = "#545f62",
;;   dimmed5 = "#3a4449",
;; }

;; VIM mode, file with shorthen path, project, branch, changes in directory, LSP, position, major mode, smaller.
