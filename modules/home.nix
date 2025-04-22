{ inputs, catpuccin, config, pkgs, lib, ... }: 
{
  home.file."${config.xdg.configHome}" = {
    source = ../files/dotfiles/.config;
    recursive = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "lastpass-password-manager"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "spotify"
      "zoom"
    ];

  home.username = "ph";
  home.homeDirectory = "/home/ph";
  home.packages = with pkgs; [
    # shells
    grc
    nix-search-cli
    ripgrep

    # fonts
    dejavu_fonts
    font-awesome
    iosevka
    material-design-icons
    montserrat
    nerd-fonts.fira-code
    nerd-fonts.open-dyslexic
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-emoji-blob-bin 
    roboto
    roboto-mono

    # vcs
    jujutsu

    # tools
    aspell
    b4
    bc
    curl
    docker-compose
    fd
    gnutls 
    htop
    ispell
    jq
    nmap
    qemu
    reuse
    ripgrep
    rsync
    shellcheck
    tree
    udiskie
    unzip
    xdot
    zip

    # emacs
    emacsPackages.mu4e

    # desktop
    gnupg
    adwaita-icon-theme
    hicolor-icon-theme
    imv
    matcha-gtk-theme
    mpv
    pamixer
    papirus-icon-theme  
    pavucontrol
    playerctl
    signal-desktop-bin
    yaru-theme
    spotify
    zoom-us

    # games
    bsnes-hd
    scummvm
    steam

    # multimedia
    blender
    ffmpeg
    inkscape
    kicad
    vlc

    # editors
    emacs-pgtk
    neovim

    # mail
    isync
    msmtp
    mu

    # languages
    nodejs_23

    # secrets
    pass

    # sway
    grim
    jq
    libnotify
    light
    slurp
    swaylock-effects
  ];

  programs.zathura.enable = true;

  programs.librewolf = {
    enable = true; 

    profiles.default = {
      isDefault = true;

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.profiles._name_.containersForce
      containersForce = true;
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.profiles._name_.search.force
      search.force = true;

      settings = {
        "extensions.autoDisableScopes" = 0; # auto-enable addons
      };

      extensions.packages = with pkgs.firefox-addons; [
        tridactyl
        ublock-origin
        lastpass-password-manager
      ];
    };
  };

  programs.direnv.enable = true;
  programs.atuin.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set -g hydro_color_pwd "brcyan"
        set -g fish_key_bindings fish_vi_key_bindings
        set -g fish_term24bit 1
    '';
    plugins = [ # see wiki https://nixos.wiki/wiki/Fish for more examples
      { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];
  };


	programs.git = {
		enable = true;
		userEmail = "phpellerin@gmail.com";
    userName = "ph";
    extraConfig = {
      core = {
        editor = "nvim";
      };
      user = {
        signingkey = "8703943BA35F230EE9BDC0D98BAEC3055E5388F2";
      };
      alias = {
        graph = "log --decorate --oneline --graph";
        st = "status";
        b = "branch";
        c = "commit";
        cl = "clone";
        t = "tag";
      };
      init = {
        defaultBranch = "main";
      };
      commit = {
        gpgsign = true;
        template = "~/.config/git/gitmessage";
      };
      github = {
        user = "ph";
      };
    };
  };

	programs.rofi = {
		enable = true;
	};

	programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
* {
    font-family: "FiraCode Nerd Font", "Symbols Nerd Font";
    font-size: 10pt;
    padding: 0 8px;
}
.modules-right {
    margin-right: -15px;
}
.modules-left {
    margin-left: -15px;
}
window#waybar.top {
    opacity: 0.95;
    background-color: @base;
}

window#waybar {
    color: @text;
    border: 2px solid @lavender;
}

#workspaces button {
    background-color: @lavender;
    color: @base;
    margin: 2px;
    border-radius: 0px;
}
#workspaces button.hidden {
    opacity: 0;
}
#workspaces button.focused,
#workspaces button.active {
    background-color: @sky;
    color: @base;
}
#clock {
    background-color: @lavender;
    color: @base;
    padding-left: 15px;
    padding-right: 15px;
    margin-top: 0;
    margin-bottom: 0;
}
'';
    settings = [{
      height = 30;
      margin = "2";
      layer = "top";
      position = "top";
      modules-center = [];
      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];
      "modules-right" = [
        "tray"
        "bluetooth"
        "temperature"
        "cpu"
        "memory"
        "pulseaudio"
        "network"
        "battery"
        "idle_inhibitor"
        "sway/language"
        "clock"
      ];
      "clock" = {
        "format" = "{:%d/%m %H:%M}";
        "on-click" = "";
        "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };
      "tray" = {
        "spacing" = 10;
      };
      "cpu" = {
        "format" = " {usage}%";
        "on-click" = "gnome-system-monitor";
      };
      "idle_inhibitor" = {
        "format" = "{icon}";
        "format-icons" = {
          "activated" = "󰒲";
          "deactivated" = "󰒳";
        };
      };
      "sway/window" = {
        "max-length" = 20;
      };
      "sway/workspace" ={
        "on-click" = "activate";
      };
      "sway/language" = {
        "format" = "{short} {variant}";
      };
      "memory" = {
        "format" = "󰍛 {}%";
        "interval" = 5;
        "on-click" = "gnome-system-monitor";
      };
      "temperature" = {
        "critical-threshold" = 80;
        "format-critical" = "{temperatureC}°C ";
        "format" = "{temperatureC}°C ";
        "on-click" = "gnome-system-monitor";
      };
      "battery" = {
        "bat" = "BAT0";
        "format" = "{icon} {capacity}%";
        "format-charging" = "󰂄 {capacity}%";
        "format-icons" = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂁"
          "󰂂"
          "󱟢"
        ];
        "interval" = 10;
        "onclick" = "";
      };
      "pulseaudio" = {
        "format" = "{icon} {volume}%";
        "format-icons" = {
          "default" = [
            ""
            ""
            ""
          ];
          "headphone" = "";
          "headset" = "";
          "portable" = "";
        };
        "format-muted" = " 0%";
        "on-click" = "pavucontrol";
      };
      "bluetooth" = {
        "format" = " {status}";
        "format-connected" = " {device_alias}";
        "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
        "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
        "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        "on-click" = "blueman-manager";
      };
      "network" = {
        "format-disconnected" = "";
        "format-ethernet" = " Connected";
        "format-wifi" = " {essid}";
        "interval" = 3;
        "on-click" = "nm-connection-editor";
        "tooltip-format" = "{ifname}\n{ipaddr}/{cidr}\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}";
      };
    }];
  };

	programs.alacritty = {
		enable = true;
    settings = {
      env.TERM = "xterm-256color";
      colors = {
        draw_bold_text_with_bright_colors = true;
      };
      font = {
        size = 12;

        bold = {
          family = "FiraCode Nerd Font";
        };

        italic = {
          family = "FiraCode Nerd Font";
        };

        normal = {
          family = "FiraCode Nerd Font";
        };
			};
      window = {
        opacity = 0.9;
      };
			scrolling.multiplier = 5;
			selection.save_to_clipboard = true;
		};
	};

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures = {gtk = true;};

    extraConfig =''
default_border pixel 2
default_floating_border pixel 2
hide_edge_borders none
focus_wrapping no
focus_follows_mouse yes
focus_on_window_activation smart
mouse_warping output
workspace_auto_back_and_forth no
seat * xcursor_theme Yaru 24
set $laptop eDP-1

# target                 title     bg    text   indicator  border
client.focused           $lavender $base $text  $rosewater $lavender
client.focused_inactive  $overlay0 $base $text  $rosewater $overlay0
client.unfocused         $overlay0 $base $text  $rosewater $overlay0
client.urgent            $peach    $base $peach $overlay0  $peach
client.placeholder       $overlay0 $base $text  $overlay0  $overlay0
client.background        $base

output * {
       bg ${inputs.self}/wallpapers/sea-is-for-cookie.jpg fill
}

output "eDP-1" {
    scale 2
}

output "DP-1" {
    scale 1.4
}

output "DP-3" {
    scale 1.4
    transform 270
    position 0 0
}

bindswitch --reload --locked lid:on output $laptop disable
bindswitch --reload --locked lid:off output $laptop enable
'';
    config = rec {
      gaps = {
        inner = 2;
        outer = 2;
        smartGaps = true;
        smartBorders = "on";
      };
      workspaceLayout = "default";
      modifier = "Mod4";
      terminal = "alacritty";
      workspaceAutoBackAndForth = true;
      bars = lib.mkForce [];

      fonts = {
        names = ["Fira Code"];
        size = "8.0";
      };

      input = {
        "type:keyboard"= {
          xkb_layout = "us,ca(fr)";
          xkb_options = "ctrl:nocaps";
          repeat_delay = "180";
          repeat_rate = "20";
        };
        # NOTE(ph): laptop seulement.
        "type:touchpad" = {
          tap = "emabled";
          natural_scroll = "enabled";
          accel_profile = "adaptive";
          click_method = "button_areas";
          scroll_method = "two_finger";
        };
      };

      modes = {
        resize = {
          Escape = "mode default";
          Return = "mode default";
          h = "resize shrink width 10 px";
          j = "resize grow height 10 px";
          k = "resize shrink height 10 px";
          l = "resize grow width 10 px";
        };

        session = {
          # session = launch:
          # [h]ibernate [p]oweroff [r]eboot
          # [s]uspend [l]ockscreen log[o]ut
          Escape = "mode default";
          Return = "mode default";
          "h" = "exec systemctl hibernate, mode default";
          "p" = "exec systemctl poweroff, mode default";
          "r" = "exec systemctl reboot, mode default";
          "s" = "exec systemctl suspend, mode default";
          "l" = "exec swaylock, mode default";
          "o" = "exec swaymsg exit, mode default";
        };
      };

      floating = {
        modifier = "${modifier}";
        border = 2;
        titlebar = false;
        criteria = [
          { class = "zoom"; }
          { class = "zoom"; }
          { class = "zoom"; }
          { app_id = "signal"; }
        ];
      };

      keybindings = lib.mkOptionDefault {
        # app shortcuts
        "${modifier}+Return" = "exec --no-startup-id ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun,run";
        "${modifier}+Shift+d" = "exec --no-startup-id ${pkgs.mako}/bin/makoctl dismiss -a";
        "${modifier}+Alt+l" = "exec ${pkgs.swaylock-effects}/bin/swaylock --screenshots";

        # screenshots
        # take active window
        "${modifier}+Ctrl+3" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -j '.. | select(.type?) | select(.focused).rect | \"\(.x),\(.y) \(.width)x\(.height)\"')\" && ${pkgs.libnotify}/bin/notify-send \"screenshot taken\"";
        # take region
        "${modifier}+Ctrl+4" = "exec ${pkgs.grim} -g \"\$(${pkgs.slurp}/bin/slurp)\" && notify-send \"screeenshot taken\"";
        # take active monitor
        "${modifier}+Print" = "exec grim -o $(${pkgs.sway}/bin/swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') && ${pkgs.libnotify}/bin/notify-send \"screenshot taken\"";

        # modes switches
        "${modifier}+Shift+s" = "mode sessions";
        "${modifier}+r" = "mode resize";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";

        "${modifier}+h" = "focus left";
        "${modifier}+l" = "focus right";
        "${modifier}+k" = "focus up";
        "${modifier}+j" = "focus down";

        "${modifier}+Ctrl+h" = "focus left";
        "${modifier}+Ctrl+l" = "focus right";
        "${modifier}+Ctrl+k" = "focus up";
        "${modifier}+Ctrl+j" = "focus down";

        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+c" = "exec swaymsg reload";
        "${modifier}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'You pressed the  to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        "${modifier}+a" = "focus parent";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+g" = "split h";
        "${modifier}+s" = "layout stacking";
        "${modifier}+v" = "split v";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+minus" = "scratchpad show";
        "${modifier}+space" = "focus mode_toggle";

        # switch keyboard us->ca
        "${modifier}+BackSpace" = "input \"type:keyboard\" xkb_switch_layout next";

        # laptops
        # multimedias keys
        "XF86AudioRaiseVolume" = "exec ${pkgs.avizo}/bin/volumectl -u up";
        "XF86AudioLowerVolume" = "exec ${pkgs.avizo}/bin/volumectl -u down";
        "XF86AudioMute" = "exec ${pkgs.avizo}/bin/volumectl toggle-mute";
        "XF86AudioMicMute" = "exec ${pkgs.avizo}/bin/volumectl -m toggle-mute";
        "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/lightctl up";
        "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/lightctl down";
      };
		};
	};

  programs.swaylock = {
    package = pkgs.swaylock-effects;
    enable = true;
    settings = {
	    effect-blur = "7x5";
      font = "Fira Code";
    };
  };

	home.pointerCursor = {
		name = "Adwaita";
		package = pkgs.adwaita-icon-theme;
		size = 24;
		x11 = {
			enable = true;
			defaultCursor = "Adwaita";
		};
	};

  services.blueman-applet.enable = true;
  services.mako.enable = true;
  # TODO(ph): Only activate on laptop
  services.avizo.enable = true;
  services.batsignal.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-rofi;
  };

  services.swayidle = {
    enable = true;
    events = [
      { event = "after-resume"; command = "${pkgs.sway}/bin/swaymsg \"output * dpms on\""; }
      { event = "before-sleep"; command = "${pkgs.swaylock-effects}}/bin/swaylock --screenshots"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots"; }
      { timeout = 360; command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\""; }
      { timeout = 600; command = "${pkgs.sway}/bin/swaymsg \"output * dpms on\";sleep 1;${pkgs.systemd}/bin/systemctl suspend"; }
    ];
  };

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
	home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
	programs.home-manager.enable = true;
}
