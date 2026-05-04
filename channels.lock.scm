(list (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (branch "master")
       (commit "4939bcf4bbae4d486fd7b88c7acf3f74bb571a86")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "5f2630e69fbbe9e79c350a67545f0fef7e93e223")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'rosenthal)
       (url "https://codeberg.org/hako/rosenthal.git")
       (branch "trunk")
       (commit "9e60a11917cbdca57e10c51e174dfa56379e74cc")
       (introduction
        (make-channel-introduction
         "7677db76330121a901604dfbad19077893865f35"
         (openpgp-fingerprint
          "13E7 6CD6 E649 C28C 3385  4DF5 5E5A A665 6149 17F7"))))
      (channel
       (name 'heyk)
       (url "https://github.com/ph/heyk")
       (branch "trunk")
       (commit "386fb204bc457d7a28b81bf159e07ea7fdf1ea45")
       (introduction
        (make-channel-introduction
         "fa96f4b8e25dba3b5ea47f1365cbe9cf9ef0358c"
         (openpgp-fingerprint
          "AB8D 7699 282F 5F12 4949  547E C6CD 2C3D B524 1054"))))
      (channel
       (name 'bluebox)
       (url "https://codeberg.org/lapislazuli/bluebox")
       (branch "main")
       (commit "f7f3b1565d626099dd68aae20abb36371ab8a9af")
       (introduction
        (make-channel-introduction
         "63350484aaacc362aea28fb14236019fced4050f"
         (openpgp-fingerprint
          "5132 3571 CEED 988F 52FC  467C 6F98 DBF3 EA7F 4B37")))))

;; warning: GUIX_PACKAGE_PATH="/home/ph/src/automate/modules:"
