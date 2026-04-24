(define-module (automate microvm)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system vm)
  #:use-module (gnu packages vim)
  #:use-module (gnu services virtualization)
  #:export (%microvm-os
	    %microvm-nftables-rules
	    microvm
	    microvm-bridge-networking-service-type
	    microvm-extra-special-file-qemu-host-conf))

(use-service-modules networking ssh)
(use-package-modules bash certs)


;; TODO(ph): This will need to be another key if the vm is hacked or compromised.
(define %pubkey
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiRJsoVbDvQYsRe94WC0kaRrru1+loCl6xZecdR4kEMfuJWz4NvyZNgD2q7KtXmQ+flvIdPuN0uxHbIzm+f1L500ZGoeOSo9GT2HPSJT8nUjgzLzKkwEs35uraxMQicjEnoUf9v+qx7s8Tv/mmKuMPrqMiNt337PlEL6llRkNtJ8srOd8pDXd40WOtHcPjRN0if78VnjESDTufAuqLoGs6yCe5j3QpcGlFneQ164AATwUMcuMQc9TVFc2pRjZRaWOFDSIAqF6NsaE3D4K6NvbTl8YIhi/seGKkvp6jfnv4T53JnY4TwbOEyPUS9dp3yfaz3NThy5r1AYAETz9s8mJC4KT2dKatShzU9tGGCyg409HNe/nOZQZrpBzfYLLwiBkxSZaCesJ0s4tyiKNW26asub0rM9DTnfCbcrEzzRtmCph3yZIC7yvNl3BAhKGIodsC07tk5zCR+kTyLntRBTIvev7Y98jz0/WA2Jaa3tQZCH8vhF0PCeiPh5c+z4A2z19ZdsLauKUs833Tj5amZg6H8t67pyFXGa2N8dptzsssk/BDEdO/YT6hohjEFI9kqtvNQbtTi6vwHjPCkpeV8MDRHWDNZsnLVz/2VR8oLH2suWDKGz4GlY0DfWRnmswu2rijGkD7U8eHt/6xrrtVxWZ9yJGnc90+RKz1LjwReRmkPw== openpgp:0xC6D3E079")

(define %microvm-nftables-rules
  "
table ip nat {
    chain postrouting {
	type nat hook postrouting priority srcnat; policy accept;
	# Masquerade traffic from the bridge network going out via the uplink
	iifname \"virbr0\" oifname \"wlp0s20f3\" masquerade
    }
}

table ip filter {
    chain forward {
        type filter hook forward priority filter; policy drop;
        # Allow forwarding from bridge to uplink
        iifname \"virbr0\" oifname \"wlp0s20f3\" accept
        # Allow established/related traffic back
        iifname \"wlp0s20f3\" oifname \"virbr0\" ct state established,related accept
    }
}
")

(define %microvm-bridge-name-default "virbr0")
(define %microvm-cidr-range-default "192.168.100.1/24")

(define* (microvm-bridge-networking-service-type #:optional
						 (bridge-name %microvm-bridge-name-default)
						 (cidr-range %microvm-cidr-range-default))
  (service static-networking-service-type
	   (list (static-networking
		   ;; The default provision is 'networking; if you're using any
		   ;; other service with this provision, such as
		   ;; `network-manager-service-type`, then you need to change the
		   ;; default.
		   (provision '(static-networking))
		   (links
		    (list (network-link
			   (name bridge-name)
			   (type 'bridge)
			   (arguments '()))))
		   (addresses
		    (list (network-address
			   (device bridge-name)
			   (value cidr-range))))))))

(define* (microvm-extra-special-file-qemu-host-conf #:optional (bridge-name %microvm-bridge-name-default))
  (extra-special-file "/etc/qemu/bridge.conf"
		      (plain-file "bridge.conf" (format #f "allow ~a\n" bridge-name))))

(define %microvm-os
  (operating-system
    (host-name "microvm")
    (timezone "UTC")
    (locale "en_US.utf8")
    (bootloader (bootloader-configuration
		  (bootloader grub-bootloader)
		  (targets '("/dev/vda"))))

    (file-systems (cons (file-system
			  (device (file-system-label "root"))
			  (mount-point "/")
			  (type "ext4"))
			%base-file-systems))

    (users (cons (user-account
		   (name "ph")
		   (group "users")
		   (supplementary-groups '("wheel"))
		   (password (crypt "abc123" "$6$somesalt")))
		 ;; (password "!"))  ; only with ssh keys
		 %base-user-accounts))
    (packages (append (list neovim)
		      %base-packages))
    (services (append
	       (list
		(service static-networking-service-type
			 (list (static-networking
				 (addresses
				  (list (network-address
					  (device "eth0")
					  (value "192.168.100.2/24"))))
				 (routes
				  (list (network-route
					  (destination "default")
					  (gateway "192.168.100.1"))))
				 (name-servers '("8.8.8.8")))))
		(service qemu-guest-agent-service-type)
		(service openssh-service-type
			 (openssh-configuration
			   (permit-root-login #f)
			   (allow-empty-passwords? #f)
			   (authorized-keys
			    `(("ph" ,(plain-file "ph.key" %pubkey)))))))
	       %base-services))))

(define (microvm os)
  (virtual-machine
    (operating-system os)
    (memory-size (* 8 1024))))

(microvm %microvm-os)
