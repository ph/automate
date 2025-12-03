;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later
(load "./shared.scm")
(use-modules (gnu services avahi)
	     (gnu services networking)
	     (gnu services ssh)
	     (gnu bootloader)
	     (gnu bootloader grub)
	     (gnu services base)
	     (gnu services sysctl)
	     (gnu services dbus)
	     (gnu services linux)
	     (gnu services desktop)
	     (gnu services docker)
	     (gnu services cuirass)
	     (gnu services virtualization)
	     (gnu services security)
	     (gnu services databases)
	     (gnu system file-systems)
	     (gnu system keyboard)
	     (guix gexp)
	     (gnu packages)
	     (gnu packages disk)
	     (gnu packages rsync)
	     (rosenthal services web)
	     (rosenthal services networking)
	     (gnu packages cryptsetup)
	     (gnu packages file-systems)
	     (gnu packages linux))

(define %packages
  (append %installer-disk-utilities
	  %base-packages))

(define %os
  (operating-system
   (host-name "azzael")
   (timezone "America/Toronto")
   (locale "en_US.utf8")
   (keyboard-layout (keyboard-layout "us"
				     #:options '("ctrl:nocaps")))
   (bootloader (bootloader-configuration
		(bootloader grub-efi-bootloader)
		(targets (list "/boot/efi"))
		(keyboard-layout keyboard-layout)))
   (swap-devices
    (list (swap-space (target (uuid "d84161ba-0dcc-4450-bc21-110537840390"))
		      (priority 10))
	  (swap-space (target (uuid "6da527c2-f4cc-4836-b226-64ba52ca71d5"))
		      (priority 5))))
   (file-systems (cons*
		  (file-system
		   (mount-point "/")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@"))

		  (file-system
		   (mount-point "/gnu")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@gnu,compress=zstd"))

		  (file-system
		   (mount-point "/home")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@home"))

		  (file-system
		   (mount-point "/var/log")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@log,compress=zstd"))

		  (file-system
		   (mount-point "/.snapshots")
		   (device (file-system-label "root-fs"))
		   (type "btrfs")
		   (options "subvol=@snapshots"))

		  (file-system
		   (mount-point "/boot/efi")
		   (device (uuid "4912-E257" 'fat32))
		   (type "vfat"))

		  (file-system
		   (mount-point "/tmp")
		   (device "tmp")
		   (type "tmpfs")
		   (options "size=100G")
		   (check? #f))
		  %base-file-systems))
   (users (cons*
	   %user/deploy
	   %user/deploy-web
	   %base-user-accounts))
   (sudoers-file
    (plain-file
     "sudoers" "deploy ALL = NOPASSWD: ALL\n"))
   (packages %packages)
   (services
    (cons*
     (simple-service 'extend-sysctl
		     sysctl-service-type
		     '(("net.ipv4.ip_forward" . "1")
		       ("net.ipv6.conf.all.forwarding" . "1")))

     (simple-service 'extend-guix
		     guix-service-type
		     (guix-extension
		      (substitute-urls
		       (append (list "https://substitutes.nonguix.org"
				     "https://ci.supervoid.org")
			       %default-substitute-urls))
		      (authorized-keys
		       (append %guix-keyring-all
			       %default-authorized-guix-keys))))

     (service postgresql-service-type
	      (postgresql-configuration
	       (postgresql (specification->package "postgresql@16"))
	       (config-file
		(postgresql-config-file
		 (log-destination "stderr")
		 (extra-config
		  '(("max_connections" 500)
		    ("shared_buffers" "16GB")
		    ("effective_cache_size" "48GB")
		    ("maintenance_work_mem" "2GB")
		    ("checkpoint_completion_target" 0.9)
		    ("wal_buffers" "16MB")
		    ("default_statistics_target" 100)
		    ("random_page_cost" 4)
		    ("effective_io_concurrency" 2)
		    ("work_mem" "80659kB")
		    ("huge_pages" "try")
		    ("min_wal_size" "1GB")
		    ("max_wal_size" "4GB")
		    ("max_worker_processes" 8)
		    ("max_parallel_workers_per_gather" 4)
		    ("max_parallel_workers" 8)
		    ("max_parallel_maintenance_workers" 4)
		    ("logging_collector" #t)
		    ("log_directory" "/var/log/postgresql")))))))
     (service avahi-service-type)
     (service cuirass-service-type
	      (cuirass-configuration
	       (parameters
		(plain-file "cuirass-parameters"
			    (call-with-output-string
			      (lambda (port)
				(write
				 '(begin
				    (%cuirass-url "https://ci.supervoid.org"))
				 port)))))
	       (remote-server
		(cuirass-remote-server-configuration
		 (trigger-url "http://localhost:49637")
		 (publish? #f)))
	       (port 17732)
	       (specifications #~(list
				  (specification
				   (name "rosenthal")
				   (build '(channels rosenthal))
				   (channels
				    (cons* (channel
					    (name 'rosenthal)
					    (url "https://codeberg.org/hako/rosenthal.git")
					    (branch "trunk")
					    (introduction
					     (make-channel-introduction
					      "7677db76330121a901604dfbad19077893865f35"
					      (openpgp-fingerprint
					       "13E7 6CD6 E649 C28C 3385  4DF5 5E5A A665 6149 17F7"))))
					   %default-channels))
				   (priority 5)
				   (systems '("x86_64-linux" "aarch64-linux")))
				  (specification
				   (name "emacs-master")
				   (build '(channels emacs-master))
				   (channels
				    (cons* (channel
					    (name 'emacs-master)
					    (url "https://github.com/gs-101/emacs-master.git")
					    (branch "main")
					    (introduction
					     (make-channel-introduction
					      "568579841d0ca41a9d222a2cfcad9a7367f9073b"
					      (openpgp-fingerprint
					       "3049 BF6C 0829 94E4 38ED  4A15 3033 E0E9 F7E2 5FE4"))))
					   %default-channels))
				   (priority 3)
				   (systems '("x86_64-linux")))

				  (specification
				   (name "guix")
				   (build '(channels guix))
				   (channels
				    (cons*
				     (channel
				      (name 'guix)
				      (url "https://codeberg.org/guix/guix.git")
				      (branch "master")
				      (introduction
				       (make-channel-introduction
					"9edb3f66fd807b096b48283debdcddccfea34bad"
					(openpgp-fingerprint
					 "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))) %default-channels))
				   (priority 0)
				   (systems '("x86_64-linux" )))

				  (specification
				   (name "nonguix")
				   (build '(channels nonguix))
				   (channels
				    (cons* (channel
					    (name 'nonguix)
					    (url "https://gitlab.com/nonguix/nonguix")
					    (introduction
					     (make-channel-introduction
					      "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
					      (openpgp-fingerprint
					       "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
					   %default-channels))
				   (priority 0)
				   (systems '("x86_64-linux" )))
				  
				  (specification
				   (name "heyk")
				   (build '(channels heyk))
				   (channels
				    (cons* (channel
					    (name 'heyk)
					    (url "https://github.com/ph/heyk")
					    (branch "trunk")
					    (introduction
					     (make-channel-introduction
					      "fa96f4b8e25dba3b5ea47f1365cbe9cf9ef0358c"
					      (openpgp-fingerprint
					       "AB8D 7699 282F 5F12 4949 547E C6CD 2C3D B524 1054"))))
					   %default-channels))
				   (priority 5)
				   (systems '("x86_64-linux" "aarch64-linux")))))))

     (service cuirass-remote-worker-service-type
	      (cuirass-remote-worker-configuration
	       (publish-port 5558)
	       (workers 1)
	       (systems '("x86_64-linux"))
	       (server "127.0.0.1:5555")
	       (substitute-urls
		`("https://ci.supervoid.org"
		  ,@%default-substitute-urls))))


  (simple-service 'extend-kernel-module-loader
		  kernel-module-loader-service-type
		  '("sch_fq_pie" "tcp_bbr"))

  (simple-service 'extend-sysctl
		  sysctl-service-type
		  '(("net.core.default_qdisc" . "fq_pie")
		    ("net.ipv4.tcp_congestion_control" . "bbr")
		    ;; https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
		    ("net.core.rmem_max" . "7500000")
		    ("net.core.wmem_max" . "7500000")))

  (service guix-publish-service-type
    (guix-publish-configuration
      (port 49637)
      (compression '(("zstd" 19)))
      (cache "/var/cache/guix/publish")
      ;; 6 months
      (ttl (* 6 30 24 3600))
      ;; 2 minutes
      (negative-ttl (* 2 60))))

     (service dhcpcd-service-type)
     (service nftables-service-type
	      (nftables-configuration
	       (ruleset (local-file "../files/plain/nftables.conf"))))
     (service ntp-service-type)
     (service containerd-service-type)
     ;; (service dbus-root-service-type)
     (service earlyoom-service-type)
     (service docker-service-type
	      (docker-configuration
	       (enable-iptables? #f)))
     (service tailscale-service-type)
     (service fail2ban-service-type
	      (fail2ban-configuration
	       (extra-jails
		(list (fail2ban-jail-configuration
		       (name "sshd")
		       (enabled? #t))))))
     ;; build for aarch64
     (service qemu-binfmt-service-type
	      (qemu-binfmt-configuration
	       (platforms (lookup-qemu-platforms "aarch64"))))
     (service elogind-service-type)
     (service caddy-service-type
	      (caddy-configuration
	       (caddyfile (local-file "../files/plain/caddyfile"))))
     (simple-service 'www activation-service-type
		     (with-imported-modules '((guix build utils))
					    #~(begin
						(use-modules (guix build utils))

						(let* ((paths (list "/var/www"
								    "/var/www/supervoid.org"))
						       (pw (getpwnam "caddy"))
						       (caddy-user (passwd:uid pw))
						       (caddy-group (passwd:gid pw)))

						  (for-each (lambda (p)
							      (mkdir-p p)
							      (chown p caddy-user caddy-group)
							      (chmod p #o775)) paths)))))
     (service openssh-service-type
	      (openssh-configuration
	       (openssh (specification->package "openssh-sans-x"))
	       (password-authentication? #f)
	       (port-number 4222)
	       (authorized-keys
		`(("deploy" , (plain-file "deploy.pub" %user/deploy/key))
		  ("deploy-web" , (local-file "../secrets/deploy.pub" ))))))
     %base-services))))

%os
