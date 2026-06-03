(define-module (automate user)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages bash)
  #:use-module (gnu system accounts)
  #:use-module (gnu system)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:export (auth
	    <auth>
	    auth-account
	    auth-pubkey
	    %user/deploy
	    %user/beatrice
	    %user/ophelie
	    %user/caroline
	    %user/ph
	    %user/live
	    %user/root-disabled-login-passwd))

(define-record-type* <auth> auth
  make-auth
  auth?
  (account auth-account)
  (pubkey auth-pubkey
	  (default #f)))

(define %user/deploy
  (auth
   (account (user-account
	     (name "deploy")
	     (comment "deploy")
	     (group "users")
	     (create-home-directory? #f)
	     (supplementary-groups '("wheel"))))
   (pubkey "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiRJsoVbDvQYsRe94WC0kaRrru1+loCl6xZecdR4kEMfuJWz4NvyZNgD2q7KtXmQ+flvIdPuN0uxHbIzm+f1L500ZGoeOSo9GT2HPSJT8nUjgzLzKkwEs35uraxMQicjEnoUf9v+qx7s8Tv/mmKuMPrqMiNt337PlEL6llRkNtJ8srOd8pDXd40WOtHcPjRN0if78VnjESDTufAuqLoGs6yCe5j3QpcGlFneQ164AATwUMcuMQc9TVFc2pRjZRaWOFDSIAqF6NsaE3D4K6NvbTl8YIhi/seGKkvp6jfnv4T53JnY4TwbOEyPUS9dp3yfaz3NThy5r1AYAETz9s8mJC4KT2dKatShzU9tGGCyg409HNe/nOZQZrpBzfYLLwiBkxSZaCesJ0s4tyiKNW26asub0rM9DTnfCbcrEzzRtmCph3yZIC7yvNl3BAhKGIodsC07tk5zCR+kTyLntRBTIvev7Y98jz0/WA2Jaa3tQZCH8vhF0PCeiPh5c+z4A2z19ZdsLauKUs833Tj5amZg6H8t67pyFXGa2N8dptzsssk/BDEdO/YT6hohjEFI9kqtvNQbtTi6vwHjPCkpeV8MDRHWDNZsnLVz/2VR8oLH2suWDKGz4GlY0DfWRnmswu2rijGkD7U8eHt/6xrrtVxWZ9yJGnc90+RKz1LjwReRmkPw== openpgp:0xC6D3E079")))

(define %user/ph
  (auth
   (account (user-account
	     (name "ph")
	     (comment "Pier-Hugues Pellerin")
	     (shell (file-append fish "/bin/fish"))
	     (group "users")
	     (home-directory "/home/ph")
	     (supplementary-groups
	      '("lp"
		"kvm"
		"wheel"
		"netdev"
		"docker"
		"audio"
		"plugdev"
		"video"
		"realtime"))))))

(define %user/live
  (auth
   (account (user-account
	     (name "live")
	     (password (crypt "live" "$5$livelive"))
	     (comment "live")
	     (shell (file-append fish "/bin/fish"))
	     (group "users")
	     (home-directory "/home/live")
	     (supplementary-groups
	      '("wheel"))))))

(define %user/beatrice
  (auth
   (account (user-account
	     (name "beatrice")
	     (comment "Béatrice")
	     (shell (file-append bash "/bin/bash"))
	     (group "users")
	     (home-directory "/home/beatrice")))))

(define %user/caroline
  (auth
   (account (user-account
	     (name "caroline")
	     (comment "Caroline")
	     (shell (file-append bash "/bin/bash"))
	     (group "users")
	     (home-directory "/home/caroline")))))

(define %user/ophelie
  (auth
   (account (user-account
	     (name "ophelie")
	     (comment "Ophélie")
	     (shell (file-append bash "/bin/bash"))
	     (group "users")
	     (home-directory "/home/ophelie")))))

(define %user/root-disabled-login-passwd
  (auth
   (account
    (user-account
      (inherit %root-account)
      (password #f)))))
