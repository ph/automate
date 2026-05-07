;;; -*- lexical-binding: t -*-

(add-to-list 'mu4e-header-info-custom

	     )

(setq mu4e-headers-fields
      '((:from . 22)
	(:subject . 80)
	(:flags . 6)
	(:human-date . 12)))

(defun ph/same-day? (date-a date-b)
  "Return true if the DATE-A and DATE-B are on the same day."
  (let ((a (decode-time date-a))
	(b (decode-time date-b)))
    ))

(defun ph/headers-relative-date (msg)
  "Show a \"human\" date for MSG.
  If the date is today, show the time, otherwise, show the date.
  The formats used for date and time are `mu4e-headers-date-format'
  and `mu4e-headers-time-format'."
  (let ((date (mu4e-msg-field msg :date)))
    (if (equal date '(0 0 0))
	"None"
      (let ((email-date (decode-time date))
	    (today (decode-time (current-time))))
	(if (and
	     (eq (nth 3 email-date) (nth 3 today))     ;; day
	     (eq (nth 4 email-date) (nth 4 today))     ;; month
	     (eq (nth 5 email-date) (nth 5 today)))    ;; year
	    (format-time-string mu4e-headers-time-format date)
	  (format-time-string mu4e-headers-date-format date))))))

;; (:human-date (propertize (mu4e~headers-human-date msg)
;;                          'help-echo (format-time-string
;;                                      mu4e-headers-long-date-format
;;                                      (mu4e-msg-field msg :date))))
