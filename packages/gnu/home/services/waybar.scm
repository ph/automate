(define-module (packages gnu home services waybar)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services)
  #:use-module (gnu packages wm)
  #:use-module (gnu services configuration)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (packages helpers)
  #:use-module (srfi srfi-1)
  #:export (home-waybar-service-type
	    home-waybar-configuration))

(define %waybar-default-extra-content
  '({"temperature": {
    "critical-threshold": 80,
    "format-critical": "{temperatureC}°C ",
    "format": "{temperatureC}°C ",
    "on-click" : "gnome-system-monitor"
    },
    "battery": {
      "bat": "BAT0",
      "format": "{icon} {capacity}%",
      "format-charging": "\udb80\udc84 {capacity}%",
      "format-icons": [
        "\udb80\udc7a",
        "\udb80\udc7b",
        "\udb80\udc7c",
        "\udb80\udc7d",
        "\udb80\udc7e",
        "\udb80\udc7f",
        "\udb80\udc80",
        "\udb80\udc81",
        "\udb80\udc82",
        "\udb80\udc79"
      ],
      "interval": 10,
      "onclick": ""
    },
    "clock": {
      "format": "{:%d/%m %H:%M}",
      "on-click": "",
      "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
   "bluetooth": {
    "format": " {status}",
    "format-connected": " {device_alias}",
    "format-connected-battery": " {device_alias} {device_battery_percentage}%",
    "tooltip-format": "{controller_alias}\t{controller_address}\n\n{num_connections} connected",
    "tooltip-format-connected": "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}",
    "tooltip-format-enumerate-connected": "{device_alias}\t{device_address}",
    "tooltip-format-enumerate-connected-battery": "{device_alias}\t{device_address}\t{device_battery_percentage}%",
    "on-click": "blueman-manager"
    },
    "cpu": {
      "format": "  {usage}%",
      "on-click" : "gnome-system-monitor"
    },
    "height": 30,
    "idle_inhibitor": {
      "format": "{icon} ",
      "format-icons": {
        "activated": "\udb81\udcb3",
        "deactivated": "\udb81\udcb2"
      }
    },
    "layer": "top",
    "margin": "2",
    "memory": {
      "format": "\udb80\udf5b {}%",
      "interval": 5,
      "on-click" : "gnome-system-monitor"
    },
    "mode": "dock",
    "modules-center": [],
    "modules-left": [
      "sway/workspaces",
      "sway/mode"
    ],
    "modules-right": [
      "bluetooth",
      "temperature",
      "cpu",
      "memory",
      "pulseaudio",
      "network",
      "battery",
      "idle_inhibitor",
      "sway/language",
      "clock"
    ],
    "network": {
      "format-disconnected": "",
      "format-ethernet": "\udb80\ude00 Connected",
      "format-wifi": "   {essid}",
      "interval": 3,
      "on-click": "nm-connection-editor",
      "tooltip-format": "{ifname}\n{ipaddr}/{cidr}\nUp: {bandwidthUpBits}\nDown: {bandwidthDownBits}"
    },
    "position": "top",
    "pulseaudio": {
      "format": "{icon}  {volume}%",
      "format-icons": {
        "default": [
          "",
          "",
          ""
        ],
        "headphone": "",
        "headset": "\udb80\udece",
        "portable": ""
      },
      "format-muted": "   0%",
      "on-click": "pavucontrol"
    },
    "sway/window": {
      "max-length": 20
    },
    "sway/workspace": {
      "on-click": "activate"
    },
    "sway/language": {
	"format": "{short} {variant}",
    },
  }
]
    ))

(define-configuration/no-serialization home-waybar-configuration
  (waybar
   (package waybar)
   "The Waybar package to use")
  (extra-content
   (extra-content %waybar-default-extra-content)
   "The Waybar configuration"))

(define (home-waybar-profile-service config)
  (list (home-waybar-configuration-mako config)))

(define (add-waybar-configuration config)
  `((".config/waybar/config"
     ,(plain-file "config"
		  (string-join
		   (home-waybar-configuration-extra-content config) "\n")))))

(define home-waybar-service-type
  (service-type
   (name 'home-waybar-service-type)
   (extensions
    (list
     (service-extension home-files-service-type
			add-waybar-configuration)
     (service-extension home-profile-service-type
			home-waybar-profile-service)))
   (description "Configure Waybar by providing a file @file{~/.config/waybar/config} and @file{~/.config/wa}")
   (default-value (home-waybar-configuration))))
