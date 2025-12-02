;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (home)
  #:use-module (heyk gnu packages fish)
  #:use-module (heyk gnu home services fish)
  #:use-module (heyk gnu home services avizo)
  #:use-module (heyk gnu home services mako)
  #:use-module (heyk gnu home services waybar)
  #:use-module (heyk gnu home services zathura)
  #:use-module (heyk gnu packages fonts)
  #:use-module (heyk gnu packages wayland)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services gnupg)
  #:use-module (gnu home services guix)
  #:use-module (gnu home services pm)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services sound)
  #:use-module (gnu home services sway)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services)
  #:use-module (gnu home)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages chromium)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages docker)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages emulators)
  #:use-module (gnu packages engineering)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages ssh)
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
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages web)
  #:use-module (gnu packages dns)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system shadow)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix store)
  #:use-module (nongnu packages game-client)
  #:use-module (nongnu packages messaging)
  #:use-module (nongnu packages mozilla)
  #:use-module (rosenthal packages rust-apps))

(define rofi/wayland
  (package-input-rewriting/spec
   `(("rofi" . ,(const rofi-wayland)))))

(define-public pinentry-rofi/wayland
  (rofi/wayland pinentry-rofi))

(define %user "ph")

(define %vcs
  (list git
	;; mako
	jujutsu
	`(,git "send-email")))

(define %dev
  (list
   mosh
   fish-foreign-env
   zathura-pdf-mupdf ;; should be added on the home service
   atuin
   guile-gcrypt
   guile-readline
   guile-colorized))

(define %browsers
  (list
   ;; firefox
	librewolf
	ungoogled-chromium))

(define %tools
  (list htop
	`(,isc-bind "utils")
	fish-hydro
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
   ;; notmuch
   ;; python-lieer
   mu
   isync
   msmtp
   password-store))

(define %vim
  (list neovim))

(define %emacs
  (list
   emacs-pgtk
   emacs-guix
   ;; emacs-arei
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
	font-fira-code-nerd
	font-fira-code
	font-fira-code-regular-symbols
	font-iosevka
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
	steam))

(define %multimedia
  (list
   libwacom
   xournalpp
   blender
   inkscape
   ffmpeg
   kicad
   vlc))

(define %scanner
  (list
   simple-scan
   sane-airscan))

(define %sway-extra-content
  '("font pango:monospace 8.0"
    "default_border pixel 2"
    "default_floating_border pixel 2"
    "hide_edge_borders none"
    "focus_wrapping no"
    "focus_follows_mouse yes"
    "focus_on_window_activation smart"
    "mouse_warping output"
    "workspace_layout default"
    "workspace_auto_back_and_forth no"
    "gaps inner 2"
    "gaps outer 2"
    "seat * xcursor_theme Yaru 24"
    "smart_gaps on"
    "smart_borders on"
    "set $laptop eDP-1"
    "floating_modifier $mod normal"

    ;; AFAIK this cannot be set with the sway configuration.
    "client.focused #e9e9f4 #62d6e8 #282936 #62d6e8 #62d6e8"
    "client.focused_inactive #3a3c4e #3a3c4e #e9e9f4 #626483 #3a3c4e"
    "client.unfocused #3a3c4e #282936 #e9e9f4 #3a3c4e #3a3c4e"
    "client.urgent #ea51b2 #ea51b2 #282936 #ea51b2 #ea51b2"
    "client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c"
    "client.background #ffffff"
    "for_window [title=\"(?:Open|Save) (?:File|Folder|As)\"] floating enable, resize set width 1030 height 710"
    "bindswitch --reload --locked lid:on output $laptop disable"
    "bindswitch --reload --locked lid:off output $laptop enable"))

(define %sway-zoom-config
  '("# Zoom Meeting App"
    "# Default for all windows is non-floating."
    "# For pop up notification windows that don't use notifications api"
    "for_window [app_id=\"zoom\" title=\"^zoom$\"] border none, floating enable"
    "# For specific Zoom windows"
    "for_window [app_id=\"zoom\" title=\"^(Zoom|About)$\"] border pixel, floating enable"
    "for_window [app_id=\"zoom\" title=\"Settings\"] floating enable, floating_minimum_size 960 xu700"
    "# Open Zoom Meeting windows on a new workspace (a bit hacky)"
    "for_window [app_id=\"zoom\" title=\"Zoom Meeting(.*)?\"] workspace next_on_output --create, move container to workspace current, floating disable, inhibit_idle open"))

(define %sway-signal-config
  '("# Signal message app"
    "for_window [app_id=\"signal\" title=\"^Signal$\"] resize set 400 400, floating enable"))

(define-public (activate-rofi-theme name)
  `("rofi/config.rasi" ,(mixed-text-file "config.rasi"
					 "@import '" rofi-theme-catppuccin "/share/themes/catppuccin-macchiato'\n"
					 "@theme '" rofi-theme-catppuccin "/share/themes/catppuccin-default'")))

(define %swayish 
  (sway-configuration
   (packages
     (list qtwayland-5
           sway
	   swayidle
	   rofi-wayland
	   rofi-themes-collection
           wl-clipboard
	   foot
	   alacritty
	   grim
	   slurp
	   light
	   xdg-utils
           xdg-desktop-portal-gtk
           xdg-desktop-portal-wlr))
   (variables
    `((mod . "Mod4")))
   (keybindings
    `(($mod+Return . ,#~(string-append "exec " #$alacritty "/bin/alacritty"))
      ($mod+Shift+q . "kill")

      ;; select current workspace
      ($mod+1 . "workspace number 1")
      ($mod+2 . "workspace number 2")
      ($mod+3 . "workspace number 3")
      ($mod+4 . "workspace number 4")
      ($mod+5 . "workspace number 5")
      ($mod+6 . "workspace number 6")
      ($mod+7 . "workspace number 7")
      ($mod+8 . "workspace number 8")
      ($mod+9 . "workspace number 9")

      ;; move current window to a specific workspace
      ($mod+Shift+1 . "move container to workspace number 1")
      ($mod+Shift+2 . "move container to workspace number 2")
      ($mod+Shift+3 . "move container to workspace number 3")
      ($mod+Shift+4 . "move container to workspace number 4")
      ($mod+Shift+5 . "move container to workspace number 5")
      ($mod+Shift+6 . "move container to workspace number 6")
      ($mod+Shift+7 . "move container to workspace number 7")
      ($mod+Shift+8 . "move container to workspace number 8")
      ($mod+Shift+9 . "move container to workspace number 9")

      ($mod+Shift+h . "move left")
      ($mod+Shift+j . "move down")
      ($mod+Shift+k . "move up")
      ($mod+Shift+l . "move right")

      ($mod+Shift+minus . "move scratchpad")
      ($mod+Shift+space . "floating toggle")

      ($mod+a . "focus parent")
      ($mod+b . "splith")

      ($mod+d . ,#~(string-append "exec " #$rofi-wayland "/bin/rofi -modi drun -show drun -show-icons -matching fuzzy"))
      ;; ($mod+d . ,#~(string-append "exec XDG_DATA_DIRS=\"$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$HOME/.guix-home/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share\" " #$rofi-wayland "/bin/rofi -modi drun -show drun -show-icons -matching fuzzy"))

      ($mod+Shift+d . ,#~(string-append "exec " #$mako "/bin/makoctl dismiss -a"))

      ($mod+e . "layout toggle split")
      ($mod+f . "fullscreen toggle")

      ($mod+h . "focus left")
      ($mod+j . "focus down")
      ($mod+k . "focus up")
      ($mod+l . "focus right")


      ($mod+minus . "scratchpad show")
      ($mod+r . "mod resize")
      ($mod+s . "layout stacking")
      ($mod+space . "focus mode_toggle")
      ($mod+v . "splitv")
      ($mod+w . "layout tabbed")

      ($mod+BackSpace . "input \"type:keyboard\" xkb_switch_layout next")

      ($mod+Shift+e . ,#~(string-append "exec " #$sway "/bin/swaynag -t warning -m 'You pressed the  to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'"))
      ($mod+Shift+c . "reload")

      ;; Avizo laptop shortcuts
      (XF86AudioRaiseVolume . "exec volumectl -u up")
      (XF86AudioLowerVolume . "exec volumectl -u down")
      (XF86AudioMute . "exec volumectl toggle-mute")
      (XF86AudioMicMute . "exec volumectl -m toggle-mute")
      (XF86MonBrightnessUp . "exec lightctl up")
      (XF86MonBrightnessDown . "exec lightctl down")

      ;; screenshots
      ;; Take a region
      (mod1+Shift+4 . "exec grim -g \"$(slurp)\" && notify-send \"screenshot taken\"")

      ;; ;; Take active window
      (mod1+Shift+3 . "exec grim -g \"$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | \"\(.x),\(.y) \(.width)x\(.height)\"')\" && notify-send \"screenshot taken\"")

      ;; ;; Take active monitor
      (mod1+Print . "exec grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') && notify-send \"screenshot taken\"")
      ))
   (outputs
    (list
     (sway-output
      (identifier "eDP-1")
      (extra-content '("scale 2")))

     (sway-output
      (identifier "DP-1")
      (extra-content '("scale 1.4")))

     (sway-output
      (identifier "DP-3")
      (extra-content '("scale 1.4"
		       "transform 270"
		       "position 0 0")))
     (sway-output
      ;; (background (local-file "../wallpapers/sea-is-for-cookie.jpg"))
      (background (local-file "../wallpapers/kanagwa.jpg"))
      )))
   (inputs
    (list
     (sway-input
	   (identifier "type:keyboard")
	   (layout
	    (keyboard-layout "us,ca(fr)" #:options '("ctrl:nocaps")))
	   (extra-content
	    '("repeat_delay 180"
	      "repeat_rate 20")))
     (sway-input
      (identifier "type:touchpad")
      (tap #t)
      (extra-content '("natural_scroll enabled"
		       "accel_profile adaptive"
		       "click_method button_areas"
		       "scroll_method two_finger")))))

   (gestures '())
   (startup-programs
    (list
     "pgrep --uid $USER shepherd > /dev/null || shepherd"
     "gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'"
     "gsettings set org.gnome.desktop.interface cursor-size '24'"
     "gsettings set org.gnome.desktop.interface gtk-theme 'Matcha-dark-azul'"
     "gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'"
     "gsettings set org.gnome.desktop.interface font-name 'Fira Code 10'"
     "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"
     "pgrep --uid $USER swayidle || swayidle  timeout 300 'sh $HOME/.config/sway/locker.sh' timeout 360 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' timeout 600 'swaymsg \"output * dpms on\"; sleep 1; loginctl suspend' before-sleep 'sh $HOME/.config/sway/locker.sh'"
     "signal-desktop --use-tray-icon"))
   (modes
    (list
     (sway-mode
      (mode-name "resize")
      (keybindings
       '((Return . "mode default")
	 (Escape . "mode default")
	 (h . "resize shrink width 10 px")
	 (j . "resize grow height 10 px")
	 (k . "resize shrink height 10 px")
	 (l . "resize grow width 10 px"))))))
   (extra-content
    (append
     %sway-extra-content
     %sway-zoom-config
     %sway-signal-config))))

(home-environment
 (packages (append
	    %browsers
	    %vcs
	    %games
	    %dev
	    %scanner
	    %tools
	    %mail
	    %editors
	    %wm
	    %fonts))
 (services
   (cons*
    (simple-service 'additional-channels-service
		    home-channels-service-type
		    (load "../channels.scm"))
    (service home-shepherd-service-type
	     (home-shepherd-configuration
	      (auto-start? #f))) ;; Sadly we need to start shepherd in the sway boot process to make $WAYLAND_DISPLAY available.
    (service home-dbus-service-type)
    (service home-gpg-agent-service-type
	     (home-gpg-agent-configuration
	      (pinentry-program (file-append pinentry-rofi/wayland "/bin/pinentry-rofi"))
	      (ssh-support? #t)))
    ;; Make flatpak applications available for rofi.
    (simple-service 'some-useful-env-vars-service
		    home-environment-variables-service-type
		    `(("XDG_DATA_DIRS" . "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$HOME/.guix-home/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share:$HOME/.guix-profile/share:/run/current-system/profile/share")))
    (service home-xdg-configuration-files-service-type
	     `(("gdb/gdbinit" ,%default-gdbinit)
	       (".Xdefaults" ,%default-xdefaults)
	       ("nano/nanorc" ,%default-nanorc)
	       ,(activate-rofi-theme "nord")))
    (service home-syncthing-service-type
	     (for-home
	      (syncthing-configuration
	       (user %user))))
    (service home-dotfiles-service-type
	     (home-dotfiles-configuration
	      (directories
	       '("../files/dotfiles"))))
    (service home-files-service-type
	     `((".guile" ,%default-dotguile)))
    (service home-sway-service-type
	     %swayish)
    (service home-mako-service-type)
    (service home-waybar-service-type)
    (service home-avizo-service-type)
    (service home-zathura-service-type)
    (service home-pipewire-service-type)
    (service home-batsignal-service-type)
    (service home-fish-hydro-service-type)
    (service home-fish-service-type
	     (home-fish-configuration
	      (config (list
		       (mixed-text-file
			"fish-config-direnv"
			direnv "/bin/direnv hook fish | source")
		       (mixed-text-file
			"fish-config-atuin"
			atuin "/bin/atuin init fish | source")
		       (mixed-text-file
			"disable-fish-greetings" "set -U fish_greeting")
		       (mixed-text-file
			"enable-foreign-fish-env"
			"set fish_function_path $fish_function_path $HOME/.guix-home/profile/share/fish/functions
set -g DIRENV_WARN_TIMEOUT 10m
fenv \"source $HOME/.guix-home/profile/etc/profile\"") ;; ensure all the environments variable are configured.
		       (plain-file
			"fish-hydro-config" "\
set -g hydro_color_pwd \"brcyan\"
set -g fish_key_bindings fish_vi_key_bindings
set -g fish_term24bit 1")
		       ))))
    %base-home-services)))

;; https://guix.gnu.org/manual/en/html_node/Search-Paths.html
;; TODO: Create wrapper for this.
;; LD_LIBRARY_PATH=/home/ph/.guix-home/profile/lib/sane SANE_CONFIG_DIR=/home/ph/.guix-home/profile/etc/sane.d/ simple-scan
