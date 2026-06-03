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
   (pubkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7WiMbqiYriD1kyTQxUJgpfia8E31rJ6acC5Zp43Yfg openpgp:0x04795C04")))

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
