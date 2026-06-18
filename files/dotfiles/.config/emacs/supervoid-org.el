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

(defun ph/org-file-publish-p (file)
  (not (ph/org-file-draft-p file)))

(org-export-define-derived-backend 'blog/html 'html
  :options-alist
  '((:html-doctype nil nil "html5")
    (:html-html5-fancy nil nil t)
    (:html-validation-link nil nil nil)
    (:html-head-include-scripts nil nil nil)))

(defun ph/make-atom-feed-entry (entry-title
				entry-link
				entry-id
				entry-updated
				entry-summary)
  `(entry
    (title ,entry-title)
    (link (@ (href ,entry-link)))
    (id ,entry-id)
    (updated ,entry-updated)
    (summary ,entry-summary)))

(defun ph/make-atom-feed (feed-title
			  blog-link
			  updated-date
			  entries)
  `(feed (@ (xmlns "http://www.w3.org/2005/Atom"))
	 (title ,feed-title)
	 (link (@ (href ,blog-link)))
	 (updated ,updated-date)
	 ,@(mapcar 'ph/make-atom-feed-entry entries)))

;; (sxml-to-xml (ph/make-atom-feed "hello ph"
;; 				"https://supervoid.org/"
;; 				"2026-06-19"
;; 				'(((entry-title  ."Title test 1")
;; 				   (entry-link . "https://supervoid.org/1")
;; 				   (entry-id . "fsjnfksjf")
;; 				   (entry-updated . "2006-06-18")
;; 				   (entry-summary . "lorem ipseum"))
;; 				  ((entry-title  ."Title test 2")
;; 				   (entry-link . "https://supervoid.org/2")
;; 				   (entry-id . "fsjnfsdffksjf")
;; 				   (entry-updated . "2006-06-17")
;; 				   (entry-summary . "lorem ipseum")))))

;; (defun ph/org-publish-sitemap-entry-atom (file style project)
;;   (ph/make-atom-feed-entry (org-publish-find-title file project)
;; 			   "link"
;; 			   (org-publish-find-date file project)
;; 			   (org-publish-find-
;; 			   ))

;; (defun ph/org-publish-sitemap-atom (title list)
;;   )

(defun ph/website-filter-file (base-directory match-predicate-p)
  (let ((base-dir (file-name-as-directory base-directory)))
    (letrec ((files nil)
	     (walk-tree
	      (lambda (dir depth)
		(message dir)
		(when (> depth 100)
		  (error "cycle reference from symbolic links for %S" base-dir))
		(dolist (f (file-name-all-completions "" dir))
		  (pcase f
		    ((or "./" "../") nil)
		    ((pred directory-name-p)
		     (funcall walk-tree
			      (expand-file-name f dir)
			      (+ 1 depth)))
		    ((guard (funcall match-predicate-p
				     (expand-file-name f dir)))
		     (message f)
		     (push (file-relative-name (expand-file-name f dir) base-dir) files))
		    (_ nil))))))
      (funcall walk-tree base-dir 0)
      files)))

(setq org-publish-project-alist
      `(("articles"
	 :exclude ".org"
	 :base-directory ,(ph/make-website-path "articles")
	 :include ,(ph/website-filter-file (ph/make-website-path "articles") #'ph/org-file-publish-p)
	 :base-extension "org"
	 :publishing-directory ,(ph/make-website-path "site")
	 :publishing-function org-html-publish-to-html
	 :auto-sitemap t
	 :sitemap-title "Blog Posts"
	 :sitemap-filename "index.org"
	 :sitemap-sort-files anti-chronologically)
	("website" :components ("articles"))))

(org-publish "website" t)

;; configure tag https://orgmode.org/manual/Setting-Tags.html

(provide 'supervoid-org)
