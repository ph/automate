;;; SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

;;; -*- lexical-binding: t -*-

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
    (> (- (nth 5 today) (nth 5 date)) 1)))

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

(defun ph/mu4e-headers-relative-date (msg)
  "Show a \"human\" date for MSG.
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
      '(flagged attach calendar trashed))

(setq mu4e-headers-fields
      '((:from . 22)
	(:subject . 80)
	(:flags . 6)
	(:ph-relative-date . 12)))
