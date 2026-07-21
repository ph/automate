;;; -*- lexical-binding: t; -*-
(defun ph/modeline--buffer-name ()
  (ph/modeline--abbreviate-path (buffer-file-name)))

(defun ph/modeline--abbreviate-directory (d)
  (substring d 0 1))

(defun ph/modeline--abbreviate-path (path)
  (let* ((path (abbreviate-file-name path))
         (dir (file-name-directory path))
         (file (file-name-nondirectory path))
         (parts (split-string (directory-file-name dir))))
    (concat (mapconcat #'ph/modeline--abbreviate-directory
		       parts "/")
	    "/"
	    file)))

(defvar-local ph/modeline-buffer-name
  '(:eval
    (ph/modeline--buffer-name)))

(put 'ph/modeline-buffer-name 'risky-local-variable t)

(setq-default mode-line-format
	      '("%e"
		ph/modeline-buffer-name))

(kill-local-variable 'mode-line-format)
(force-mode-line-update)

;; path
;; vim mode
;; major-mode
;; direnv
;; eglot
;; line/column
;; encoding?
