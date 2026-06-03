(define %babayaga
  (machine
   (operating-system (load "../modules/automate/system/babayaga.scm"))
   (environment managed-host-environment-type)
   (configuration (machine-ssh-configuration
		   (build-locally? #f)
		   (host-name "192.168.1.128")
		   (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBD5BQYB6Wl3j+C5psYg9WsxhMsLffTmdfoN+/wNpqoS")
		   (user "deploy")
		   (system "x86_64-linux")))))

(define %lusk
  (machine
   (operating-system (load "../modules/automate/system/lusk.scm"))
   (environment managed-host-environment-type)
   (configuration (machine-ssh-configuration
		   (build-locally? #f)
		   (host-name "192.168.1.10")
		   (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImlnWGsg8AN+zXcmWfy+BbPjlwW/EzNdH6MZ+ARvg2U")
		   (user "deploy")
		   (system "x86_64-linux")))))
(list %lusk
      %babayaga)
