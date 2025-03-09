(define-module (home)
  #:use-module (guix gexp)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services sound)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages web)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages video)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages python)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages image-viewers)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emulators)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages node)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages music)
  #:use-module (gnu packages image)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages engineering)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages ghostscript)
  #:use-module (nongnu packages game-client)
  #:use-module (nongnu packages mozilla)
  #:use-module (packages gnu home services zathura)
  #:use-module (packages gnu home services mako)
  #:use-module (packages gnu packages wayland))

(define %user "ph")

(define %vcs
  (list git))

(define %browsers
  (list firefox))

(define %tools
  (list htop
	curl
	flatpak
	flatpak-xdg-utils
	fd
	aspell
	aspell-dict-en
	pandoc
	shellcheck
	ispell
	gnutls 
	libnotify
	qemu
	nmap
	docker-compose
	udiskie
	jq
	unzip
	zip
	ripgrep
	rsync
	xdot
	gcr
	python
	bc
	tree))

(define %mail
  (list
   mu
   isync
   msmtp
   password-store
   ))

(define %vim
  (list neovim))

(define %emacs
  (list
   emacs-pgtk
   emacs-guix
   emacs-debbugs
   emacs-vterm
   emacs-geiser))

(define %editors
  (append
   %vim
   %emacs
   (list
    direnv
    node-lts
    tree-sitter-bash
    tree-sitter-scheme
    tree-sitter-rust
    tree-sitter-python
    tree-sitter-go
    tree-sitter-gomod
    tree-sitter-dockerfile
    tree-sitter-c
    tree-sitter-css
    tree-sitter-org
    tree-sitter-json
    tree-sitter-typescript
    tree-sitter-javascript
    tree-sitter-ruby)))

(define %fonts
  (list font-dejavu
	;; font-fira-code-nerd
	;; font-fira-code
	;; font-fira-code-regular-symbols
	;; font-iosevkas
	font-fira-mono
	font-fira-sans
	font-opendyslexic
	font-google-noto
	font-awesome
	font-google-material-design-icons
	font-google-roboto
	font-montserrat
	font-google-noto
	font-google-noto-emoji
	font-ghostscript))

(define %wm
  (list
   blueman
   alacritty
   foot
   imv
   mpv
   xdg-utils
   xdg-desktop-portal
   xdg-desktop-portal-wlr
   avizo
   pamixer
   pulseaudio
   pavucontrol
   playerctl
   sway
   swaybg
   swayidle
   waybar
   grim
   slurp
   wl-clipboard
   yaru-theme
   matcha-theme
   papirus-icon-theme))

(define %games
  (list
   scummvm
   bsnes
   steam))

(define %multimedia
  (list
   blender
   inkscape
   ffmpeg
   kicad
   vlc))

(home-environment
 (packages (append
	    %browsers
	    %vcs
	    %tools
	    %mail
	    %editors
	    %wm
	    %fonts))
 (services
  (list
   (service home-shepherd-service-type
	    (home-shepherd-configuration
	     (auto-start? #f))) ;; We will start during the WM to have access to $DISPLAY
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
             (pinentry-program (file-append pinentry-rofi/wayland "/bin/pinentry-rofi"))
             (ssh-support? #t)))
   (service home-syncthing-service-type
	    (for-home
             (syncthing-configuration
              (user %user))))
   (service home-dbus-service-type)
   (service home-mako-service-type)
   (service home-zathura-service-type)
   (service home-pipewire-service-type)
   (service home-fish-service-type))))
