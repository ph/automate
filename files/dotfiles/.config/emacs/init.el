;;; -*- lexical-binding: t -*-
;; records use-package time to reduce startup time.
(setq use-package-compute-statistics t)

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
  :custom
  ;; TAB cycle if there are only few candidates
  (completion-cycle-threshold 3)

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

  ;; Less keys to type on confirmation.
  (fset 'yes-or-no-p 'y-or-n-p)


  ;; TODO(ph): experimenting wiht paren-face
  ;; Highlight matching paren.
  ;; (show-paren-mode 1)
  ;; Three options for paren-style: 'expression, 'parenthesis, and
  ;; 'mixed The first one highlights the complete region between
  ;; parens, the second only highlights the matching paren, the third
  ;; does 'expression when the matching paren is not visible.
  ;; (show-paren-style 'mixed)

  :config
  (setq
   ;; Disable customs files
   custom-file null-device

   ;; When recompiling kill current process, in rust case it
   ;; could be `cargo run` or `cargo test`.
   compilation-always-kill t

   ;; Reduce elisp compilation warning in the buffers on startup.
   byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local)
   native-comp-async-report-warnings-errors nil

   ;; Dont' bug me to save.
   compilation-ask-about-save nil
   
   ;; If new changes load them.
   load-prefer-newer t

   ;; Opinions how backups are done.
   backup-directory-alist '((".*" . "~/.config/emacs-backup"))
   revert-without-query '(".*")
   make-backup-files nil
   create-lockfiles nil
   auto-save-default nil

   ;; Minibuffer options
   minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt)
   enable-recursive-minibuffers t

   ;; Load the squash buffer directly.
   inhibit-splash-screen t

   ;; Skip Fontification During Input
   ;; Delay syntax highlight to after we are done typing.
   redisplay-skip-fontification-on-input t

   ;; Only edit left-to-right files so we can make reduce runtime cost.
   ;; This is not really visible in small buffer but in large yes.
   bidi-display-reordering 'left-to-right
   bidi-paragraph-direction 'left-to-right
   bidi-inhibit-bpa t)

  ;; Make the UI less clunky.
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (add-to-list 'default-frame-alist '(alpha-background . 95))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (set-frame-parameter nil 'alpha-background 95)

  ;; Fonts
  ;; TODO(ph): more work is needed here
  (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font 10"))

  ;; Create a closing pair automatically
  ;; TODO(ph): evaluate with symex if needed.
  ;; (electric-pair-mode 1)

  (global-auto-revert-mode 1)
  (global-hl-line-mode)
  (global-display-line-numbers-mode t)
  (pixel-scroll-precision-mode)
  (transient-mark-mode 1)
  ;; Change obsolete buffer behavior to just ignore.
  (defun ask-user-about-supersession-threat (fn)
    "ignore"))

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

(use-package modus-catppuccin
  :config
  (load-theme 'modus-catppuccin-macchiato :no-confirm))

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
  :init (which-key-mode)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environment
(use-package envrc
  :config
  (envrc-global-mode))

(use-package inheritenv
  :after envrc)

;; Exec the command and keep some of the shell environment values.
(use-package exec-path-from-shell
  :config
  (setq exec-path-from-shell-variables '("SSH_AUTH_SOCK"
					 "PATH"
					 "MANPATH"
					 "SSH_AGENT_PID"
					 "GPG_AGENT_INFO"
					 "LANG"
					 "LC_CTYPE"))
  (setq exec-path-from-shell-arguments nil)
  (when (daemonp)
    (exec-path-from-shell-initialize)))

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
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Manage multiples autocomplete sources.
(use-package cape
  :init
  (defun ph/eglot-capf ()
    (setq-local completion-at-point-functions
		(list (cape-capf-super
		       #'eglot-completion-at-point
		       #'cape-file
		       #'cape-dabbrev
		       #'cape-keyword))))
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  (add-hook 'eglot-managed-mode-hook #'ph/eglot-capf))

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
  :custom
  (setq org-directory (expand-file-name "src/notes" (getenv "HOME")))
  (setq org-agenda-files (list org-directory))

  (setq org-capture-templates
	`(("i" "📥 Inbox" entry (file+headline ,(expand-file-name "inbox.org" org-directory) "Inbox")
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; email
(use-package mu4e
  :general
  (ph/leader-key
    "om" '(mu4e :wk "mail"))
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
	mu4e-compose-signature (concat "Thanks\n" "ph"))
  (evil-collection-init 'mu4e)
  :custom
  (require 'smtpmail)
  (setq sendmail-program (executable-find "msmtp")
	mail-host-address "heykimo.com"
	send-mail-function #'smtpmail-send-it
	message-sendmail-f-is-evil t
	message-sendmail-extra-arguments '("--read-envelope-from")
	message-send-mail-function #'message-send-mail-with-sendmail))

(use-package mu4e-thread-folding
  :after mu4e
  :custom
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
(use-package lin)

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

(use-package consult-eglot
  :after (consult eglot))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax and prog mode.

(use-package geiser
  :when (locate-library "arei.el")
  :custom (geiser-mode-auto-p nil))

(use-package arei
  :when (locate-library "arei.el")
  :init (global-arei-mode))

(use-package nix-mode
  :mode "\\.nix\\'")

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

  ;; Make them available in org mode.
  (add-to-list 'org-src-lang-modes '("dockerfile" . dockerfile-ts))
  (add-to-list 'org-src-lang-modes '("go" . go-ts))
  (add-to-list 'org-src-lang-modes '("rust" . rust-ts))
  (add-to-list 'org-src-lang-modes '("typescript" . typescript-ts))
  (add-to-list 'org-src-lang-modes '("yaml" . yaml-ts))
  :hook
  (after-init . global-treesit-auto-mode))

(use-package eglot
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
  (add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
  (advice-add 'jsonrpc--log-event :override #'ignore))

;; Add extension to eglot to be similar to LSP.
(use-package eglot-x
  :config
  (eglot-x-setup)
  (define-key eglot-mode-map (kbd "s-.") #'eglot-x-find-refs))

(use-package rustic
  :init
  (setq rust-mode-treesitter-derive t)
  :config
  (setq rustic-lsp-client 'eglot)
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

(defcustom ph/agent-sandbox-packages '("bash" "openssl" "nss-certs" "coreutils" "grep" "gawk" "sed" "jq" "git" "node" "rust" "rust:cargo" "nix")
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

;; TODO(ph): to evaluate, not sure I like all the colors in the code.
;; (use-package prism
;;   :hook
;;   ((emacs-lisp-mode . prism-mode)
;;    (scheme-mode . prism-mode)
;;    (lisp-mode . prism-mode))
;;   :custom
;;   (prism-parens t))
