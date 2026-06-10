(require 'ox-publish)
(require 'esxml)

(defgroup ph/website nil
  "settings for my website"
  :prefix "website configuration")

(defcustom ph/website-root
  (expand-file-name "src/supervoid.org" (getenv "HOME"))
  "website root directory"
  :type 'string
  :group 'ph/website)

(defcustom ph/website-atom-filename
  "atom.xml"
  "Atom file"
  :type 'string
  :group 'ph/website)

(defcustom ph/website-title
  "ph"
  "Atom file"
  :type 'string
  :group 'ph/website)

(defun ph/make-website-path (p)
  (expand-file-name p ph/website-root))

(defun string->bool (v)
  (pcase v
    ("t" t)
    ("true" t)
    ("f" nil)
    ("false" nil)
    (_ nil)))

(defun ph/org-file-draft-p (file)
  (with-temp-buffer
    (insert-file-contents file)
    (org-mode)
    (string->bool (cadr (assoc "DRAFT"
			       (org-collect-keywords '("DRAFT")))))))

(defun ph/org-publish-if-not-draft (plist filename pub-dir)
  (unless (ph/org-file-draft-p filename)
    (org-html-publish-to-html plist filename pub-dir)))

(org-export-define-derived-backend 'blog/html 'html
  :options-alist
  '((:html-doctype nil nil "html5")
    (:html-html5-fancy nil nil t)
    (:html-validation-link nil nil nil)
    (:html-head-include-scripts nil nil nil)))

(defun ph/make-atom-feed-entry (entry)
  `(entry
    (title ,(alist-get 'entry-title entry))
    (link (@ (href ,(alist-get 'entry-link entry))))
    (id (alist-get 'entry-id entry))
    (updated ,(alist-get 'entry-updated entry))
    (summary ,(alist-get 'entry-summary entry))))

(defun ph/make-atom-feed (feed-title
			  blog-link
			  updated-date
			  entries)
  `(feed (@ (xmlns "http://www.w3.org/2005/Atom"))
	 (title ,feed-title)
	 (link (@ (href ,blog-link)))
	 (updated ,updated-date)
	 ,@(mapcar 'ph/make-atom-feed-entry entries)))

(sxml-to-xml (ph/make-atom-feed "hello ph"
				"https://supervoid.org/"
				"2026-06-19"
				'(((entry-title  ."Title test 1")
				   (entry-link . "https://supervoid.org/1")
				   (entry-id . "fsjnfksjf")
				   (entry-updated . "2006-06-18")
				   (entry-summary . "lorem ipseum"))
				  ((entry-title  ."Title test 2")
				   (entry-link . "https://supervoid.org/2")
				   (entry-id . "fsjnfsdffksjf")
				   (entry-updated . "2006-06-17")
				   (entry-summary . "lorem ipseum")))))

(setq org-publish-project-alist
      `(("pages"
	 :base-directory ,(ph/make-website-path "articles")
	 :base-extension "org"
	 :recursive t
	 :publishing-directory ,(ph/make-website-path "site")
	 :publishing-function ph/org-publish-if-not-draft)
	("website" :components ("pages"))))

;; (org-publish "website" t)
;; configure tag https://orgmode.org/manual/Setting-Tags.html
