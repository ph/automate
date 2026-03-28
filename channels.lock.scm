(list (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (branch "master")
       (commit "7638729a6746df4b37ce025c29139abef1d6e694")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "62ea83535efec8809187c8110b5583b79d053686")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'rosenthal)
       (url "https://github.com/rakino/Rosenthal")
       (branch "trunk")
       (commit "a238fc8c286b3fa0d3264e179c49d0d26b2e6865")
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
       (name 'emacs-master)
       (url "https://github.com/gs-101/emacs-master.git")
       (branch "main")
       (commit "a4c7113329460ab1ef2fc902716e0598195d542f")
       (introduction
        (make-channel-introduction
         "568579841d0ca41a9d222a2cfcad9a7367f9073b"
         (openpgp-fingerprint
          "3049 BF6C 0829 94E4 38ED  4A15 3033 E0E9 F7E2 5FE4")))))

;; warning: GUIX_PACKAGE_PATH="/home/ph/src/automate/modules:"
