(define-module (automate microvm)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system vm)
  #:use-module (gnu packages vim)
  #:use-module (gnu services virtualization)
  #:export (%microvm-os
	    %microvm-nftables-rules
	    microvm-bridge-networking-service-type
	    microvm-extra-special-file-qemu-host-conf))

(use-service-modules networking ssh)
(use-package-modules bash certs)

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
(define %microvm-memory-size-default 256)

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


