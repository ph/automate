;;; SPDX-FileCopyrightText: 2026 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate config home)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((ice-9 ftw) #:select (scandir))
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services guix)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services pm)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services sway)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services)
  #:use-module (gnu home)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages chromium)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages dns)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages electronics)
  #:use-module (gnu packages emulators)
  #:use-module (gnu packages engineering)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gdb)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages image-viewers)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages librewolf)
  #:use-module (gnu packages license)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages music)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages node)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages scanner)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages web)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system shadow)
  #:use-module (guix build-system copy)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (guix profiles)
  #:use-module (guix store)
  #:use-module (heyk gnu home services avizo)
  #:use-module (heyk gnu home services fish)
  #:use-module (heyk gnu home services waybar)
  #:use-module (heyk gnu home services zathura)
  #:use-module (heyk gnu packages fish)
  #:use-module (heyk gnu packages fonts)
  #:use-module (heyk gnu packages wayland)
  #:use-module (nongnu packages messaging)
  #:use-module (nongnu packages mozilla)
  #:use-module (nonguix utils)
  #:use-module (rosenthal packages rust-apps)
  #:use-module (rosenthal home services desktop)
  #:use-module (rosenthal services shellutils)
  #:use-module (rosenthal services desktop)
  #:use-module (rosenthal utils file)
  #:use-module (supervoid gnu packages shells)
  #:use-module (supervoid gnu packages fonts)
  #:use-module (automate config shared emacs)
  #:export (automate-home-environment))

(define-public font-commit-mono-nerd-font
  (package/inherit font-commit-mono
    (name "font-commit-mono-nerd-font")
    (version "3.4.0-1.143")
    (source
     (origin
       (method url-fetch)
       ;; aggregate the two versions number from nerd font and commit mono.
       (uri
	"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CommitMono.zip")
       (sha256
	(base32
	 "08vzlrx5wdz1czifrmjv5nl68fiq01ki8nb4xa53j153ar08qrgs"))))))

(define-public font-jetbrains-mono-nerd-font
  (package/inherit font-jetbrains-mono
    (name "font-jetbrains-mono-nerd-font")
    (version "3.4.0-2.304")
    (source
     (origin
       (method url-fetch)
       ;; aggregate the two versions number from nerd font and jetbrain font.
       (uri
	"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip")
       (sha256
	(base32 "0g29gj9d6720grfr2vasnvdppzw4hycpfyd5di54d2p4mkrmzw3n"))))))

(define %fish-hydro-config
  " set -g hydro_always_show_user true
set -g hydro_color_pwd \"brcyan\"
set -g fish_key_bindings fish_vi_key_bindings
set -g fish_term24bit 1 ")

(define %current-user "ph")

(define %vcs
  (list git
	difftastic
	lldb
	wezterm
	alacritty
	btop
	jujutsu
	`(,git "send-email")))

(define %dev
  (list node
	gdb
	mosh
	fish-foreign-env
	zathura-pdf-mupdf
	;; (@ (rosenthal packages rust-apps) atuin)
	guile-gcrypt
	guile-readline
	guile-colorized))

(define %browsers
  (list ;; firefox
   ungoogled-chromium
   librewolf))

(define %tools
  (list htop
	`(,isc-bind "utils")
	fish-hydro/ph
	bash
	curl
	b4
	reuse
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
   ;; notmuch
   ;; python-lieer
   mu
   isync
   msmtp
   password-store
   ))

(define %vim
  (list neovim))

(define %editors
  (append
   %vim
   (list
    direnv)))

(define %fonts
  (list
   font-commit-mono-nerd-font
   font-dejavu font-awesome
   font-fira-code
   font-fira-code-nerd
   font-fira-code-regular-symbols
   font-fira-mono
   font-fira-sans
   font-ghostscript
   font-google-material-design-icons
   font-google-noto
   font-google-noto
   font-google-noto-emoji
   font-google-roboto
   font-iosevka
   font-lilex-nerd-font
   font-montserrat
   font-opendyslexic
   font-jetbrains-mono-nerd-font))

(define %wm
  (list
   `(,glib "bin")
   blueman
   imv
   signal-desktop
   mpv
   pamixer
   pulseaudio
   pavucontrol
   playerctl
   yaru-theme
   matcha-theme
   adwaita-icon-theme
   hicolor-icon-theme
   papirus-icon-theme))

(define %games
  (list scummvm
	bsnes
	;; steam
	))

(define %multimedia
  (list
   qtwayland-5
   rofi
   rofi-themes-collection
   wl-clipboard
   foot
   alacritty
   grim
   slurp
   light
   xdg-utils
   xdg-desktop-portal-gnome
   xdg-desktop-portal-gtk
   libwacom
   xournalpp
   blender
   inkscape
   ffmpeg
   kicad
   vlc))

(define* (automate-home-environment #:key
				    (current-user "ph"))
  (home-environment
   (packages (append
	      %browsers
	      %vcs
	      %games
	      %dev
	      %tools
	      %mail
	      %editors
	      %wm
	      %fonts))
   (services
    (cons*
     (service home-shepherd-service-type
	      (home-shepherd-configuration
	       (auto-start? #f))) ;; Sadly we need to start shepherd in the sway boot process to make $WAYLAND_DISPLAY available.
     (service home-dbus-service-type)
     (service home-gpg-agent-service-type
	      (home-gpg-agent-configuration
	       (pinentry-program (file-append pinentry-qt "/bin/pinentry-qt"))
	       (default-cache-ttl-ssh 3600)
	       (default-cache-ttl 3600)
	       (ssh-support? #t)))

     (service home-openssh-service-type
	      (home-openssh-configuration
		(hosts
		 (list
		  (openssh-host
		    (name "supervoid.org")
		    (host-name "supervoid.org")
		    (port 4222))))))

     (service home-xdg-configuration-files-service-type
	      `(("gdb/gdbinit" ,%default-gdbinit)
		(".Xdefaults" ,%default-xdefaults)
		("nano/nanorc" ,%default-nanorc)))

     (service home-syncthing-service-type
	      (for-home
	       (syncthing-configuration
		(user current-user))))

     (service home-dotfiles-service-type
	      (home-dotfiles-configuration
	       (directories
		'("../../../files/dotfiles"))))

     (service home-files-service-type
	      `((".guile" ,%default-dotguile)
		(".face" ,(local-file "../../../files/plain/ph.jpg"))
		(".fennelrc"  ,(plain-file "fennelrc" "
(case package.loaded.readline
  rl   (rl.set_options {:histfile  \"~/.fennel_history\"
			:keeplines 1000}))
" ))
		(".inputrc" ,(local-file "../../../files/plain/inputrc"))))

     (service home-niri-service-type
	      (home-niri-configuration
	       (config
		(computed-substitution-with-inputs
		 "niri.kdl"
		 (local-file "../../../files/plain/niri.kdl")
		 (list xwayland-satellite
		       signal-desktop)))))

     (service home-noctalia-service-type)
     (service home-polkit-gnome-service-type)
     (service home-zathura-service-type)
     (service home-pipewire-service-type)
     (service home-fish-plugin-atuin-service-type)
     (service home-fish-plugin-direnv-service-type)
     (service home-fish-plugin-zoxide-service-type)

     ;; emacs
     (simple-service 'emacs-environment home-environment-variables-service-type
		     `(("EDITOR" . "emacsclient")
		       ("VISUAL" . "$EDITOR")
		       ("LSP_USE_PLISTS" . "true")
		       ("ESHELL" . ,(file-append fish "/bin/fish"))))
     (+home-emacs-service-type)
     (simple-service 'fish-emacs-eat home-fish-service-type
		     (home-fish-extension
		      (config
		       (list (plain-file "emacs-eat.fish" "\
  if test -n \"$EAT_SHELL_INTEGRATION_DIR\"
      source $EAT_SHELL_INTEGRATION_DIR/fish
  end\n")))))

     (service home-fish-hydro-service-type
	      (home-fish-hydro-configuration
	       (fish-hydro fish-hydro/ph)))
     (service home-xdg-mime-applications-service-type
	      (home-xdg-mime-applications-configuration
	       (default
		 '((text/html . librewolf.desktop)
		   (x-scheme-handler/http . librewolf.desktop)
		   (x-scheme-handler/https . librewolf.desktop)))
	       (desktop-entries
		(list (xdg-desktop-entry
		       (file "simple-scan")
		       (name "Scanner")
		       (type 'application)
		       (config
			'((exec . "env LD_LIBRARY_PATH=$HOME/.guix-home/profile/lib/sane SANE_CONFIG_DIR=$HOME/.guix-home/profile/etc/sane.d/ simle-scan"))))))
	       ))
     (service home-fish-service-type
	      (home-fish-configuration
	       (config (list
			     (mixed-text-file
			      "disable-fish-greetings" "set -U fish_greeting")
			     (mixed-text-file
			      "enable-foreign-fish-env"
			      "set fish_function_path $fish_function_path $HOME/.guix-home/profile/share/fish/functions
set -g DIRENV_WARN_TIMEOUT 10m
fenv \"source $HOME/.guix-home/profile/etc/profile\"") ;; ensure all the environments variable are configured.
			     (plain-file "fish-hydro-config.fish" %fish-hydro-config)
			     (plain-file "add-npm-bin.fish" "fish_add_path $HOME/.local/npm/bin")))))
     %base-home-services))))
