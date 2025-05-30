;;; SPDX-FileCopyrightText: 2025 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (automate gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages check)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages python-build)
  #:use-module ((guix licenses) #:prefix license:))

(define-public python-lieer
  (package
    (name "python-lieer")
    (version "5c9ca43")
    (source (origin
	     (method git-fetch)
	     (uri (git-reference
		   (url
		    "https://github.com/gauteh/lieer/")
		   (commit version)))
	     (file-name (git-file-name name version))
	     (sha256
	      (base32
	       "19hvdkksal622wsdxlvl1jwmbf8pwpl1cd9bfgdswkf69c89pxjd"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list
			python-google-api-python-client
			python-google-auth-oauthlib python-notmuch2
			python-tqdm))
    (native-inputs (list
		    nss-certs-for-test
		    python-pyparsing
		    python-pip
		    python-pytest
		    python-setuptools
		    python-wheel))
    (home-page "https://github.com/gauteh/lieer")
    (synopsis "Fast fetch and two-way tag synchronization between notmuch and GMail")
    (description "Fast fetch and two-way tag synchronization between notmuch and GMail.")
    (license license:gpl3+)))

(define-public python-google-auth-httplib2-0.2.0
  (package
    (name "python-google-auth-httplib2")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "google-auth-httplib2" version))
       (sha256
        (base32 "018fckshilc6z2qpj1pclh8haanbq3lr85w6p4g4z5wgyjnppaiq"))))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-google-auth python-httplib2))
    (native-inputs (list
		    nss-certs-for-test
		    python-pip
		    python-setuptools
		    python-flask
		    python-pytest
		    python-mock
		    python-pytest-localserver
		    python-wheel))
    (home-page
     "https://github.com/GoogleCloudPlatform/google-auth-library-python-httplib2")
    (synopsis "Google Authentication Library: httplib2 transport")
    (description "Google Authentication Library: httplib2 transport.")
    (license license:asl2.0)))

(define-public python-google-api-python-client
  (package
    (name "python-google-api-python-client")
    (version "2.169.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "google_api_python_client" version))
       (sha256
        (base32 "0l9cs6s987vsn191j7c1dk818njc7rcj9xjbipnz6nszpnbvp185"))))
    (arguments
     `(#:tests? #f))
    (build-system pyproject-build-system)
    (propagated-inputs (list python-google-api-core python-google-auth
                             python-google-auth-httplib2-0.2.0
			     python-httplib2
			     python-uritemplate))
    (native-inputs (list
		    nss-certs-for-test
		    python-oauth2client
		    python-setuptools
		    python-parameterized
		    python-wheel
		    python-pyparsing
		    python-pip))
    (home-page "https://github.com/googleapis/google-api-python-client/")
    (synopsis "Google API Client Library for Python")
    (description "Google API Client Library for Python.")
    (license license:asl2.0)))

python-lieer
