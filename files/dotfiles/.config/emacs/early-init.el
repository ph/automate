(setq package-enable-at-startup nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Configuration loaded in %s."
                     (emacs-init-time))))

(setq-default pgtk-wait-for-event-timeout 0)

(setq inhibit-splash-screen t ;; no thanks
      use-file-dialog nil ;; don't use system file dialog
      ) ;; don't show tab close button
