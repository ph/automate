;;; -*- lexical-binding: t -*-

(setq package-enable-at-startup nil)
(setenv "LSP_USE_PLISTS" "true")
(add-hook 'emacs-startup-hook
          (lambda ()
	    (tool-bar-mode -1)
	    (menu-bar-mode -1)
	    (scroll-bar-mode -1)
	    (message "Configuration loaded in %s."
		     (emacs-init-time))))


(setq-default pgtk-wait-for-event-timeout 0)

(setq inhibit-splash-screen t ;; no thanks
      use-file-dialog nil ;; don't use system file dialog
      )

