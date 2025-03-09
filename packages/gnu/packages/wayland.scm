(define-module (packages gnu packages wayland)
  #:use-module (guix packages)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gnupg))

(define rofi/wayland
  (package-input-rewriting/spec
   `(("rofi" . ,(const rofi-wayland)))))

(define-public pinentry-rofi/wayland
  (rofi/wayland pinentry-rofi))
