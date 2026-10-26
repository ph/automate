(define-module (automate gnu packages wm)
  #:use-module (guix build-system copy)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (gnu packages window-management)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:))

(define-public niri/ph
  (define niri-touch-patches
    (let ((version "26.04.20"))
      (origin
       (method git-fetch)
       (uri (git-reference
	     (url "https://github.com/GGEZUS/niri-tablet")
	     (commit (string-append "v" version))))
       (file-name (string-append "niri-table-" version))
       (sha256 (base32 "1rch8rm2sdc8vqq1mjw0hwgwsbcm9qam18a7crl7zvz42kvm9ygp")))))

  (package/inherit niri
		   (name "niri-touch-ph")
		   (source
		    (origin
		     (inherit (package-source niri))
		     (patches
		      (map (lambda (path)
			     (file-append niri-touch-patches "/pkg/" path))
			   (list "0001-feat-input-add-touchscreen-3-finger-swipe-gestures.patch"
				 "0002-feat-config-add-touchscreen-swipe-gesture-configurat.patch"
				 "0003-docs-document-touchscreen-swipe-gestures.patch"
				 "0004-feat-input-touchscreen-tap-and-bottom-edge-swipe-ges.patch"
				 "0005-feat-input-discrete-4-finger-vertical-swipe-gestures.patch"
				 "0006-fix-input-count-late-joining-fingers-and-fix-deadloc.patch"
				 "0007-test-config-refresh-the-parse-insta-snapshot-for-the.patch"
				 "0008-feat-ui-show-touch-points-compositor-rendered-touch-.patch"
				 "0009-feat-input-hold-swipe-touchscreen-gestures-move-wind.patch"
				 "0010-fix-input-own-multi-finger-touch-sequences-gestures-.patch"
				 "0011-fix-input-latch-gesture-ownership-through-smithay-s-.patch"
				 "0012-fix-input-clear-touch-gesture-state-when-a-touch-dev.patch"
				 "0013-feat-input-gesture-debug-logging-behind-gestures-deb.patch"
				 "0014-feat-input-single-finger-edge-and-corner-swipe-gestu.patch"
				 "0015-docs-document-touchscreen-edge-and-corner-swipe-gest.patch"
				 "0016-fix-test-edge-swipe-test-helper-rectangle-constructi.patch"
				 "0017-feat-input-horizontal-swipe-column-resize-mode.patch"
				 "0018-docs-document-the-touchscreen-swipe-action-options.patch"
				 "0019-feat-gestures-derive-the-tap-flick-tier-from-fingers.patch"
				 "0020-feat-gestures-swipe-more-left-right-for-extra-finger.patch")))))))
