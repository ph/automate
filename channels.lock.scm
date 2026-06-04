(list (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (branch "master")
       (commit "9d743563e20784f3cd4af664b02bc8bd6eeb29cd")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "3ed7c207c59dde11a97db483cad4c96eae1a10c4")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'rosenthal)
       (url "https://codeberg.org/hako/rosenthal.git")
       (branch "trunk")
       (commit "8d0f3f34c74864449399e489ff24e6ef1cf4fc12")
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
       (commit "71628770c8612c041e06672f34c0c8e6fc67c13c")
       (introduction
        (make-channel-introduction
         "63350484aaacc362aea28fb14236019fced4050f"
         (openpgp-fingerprint
          "5132 3571 CEED 988F 52FC  467C 6F98 DBF3 EA7F 4B37"))))
      (channel
       (name 'microvm)
       (url "https://codeberg.org/pierhugues/microvm.git")
       (branch "trunk")
       (commit "8d57dbade723ed3ea5125911249e44bf74ffee29")
       (introduction
        (make-channel-introduction
         "61226b15bb6e23369810463e2dd77f691d815231"
         (openpgp-fingerprint
          "6068 E700 E178 0ADB 1D43  1E65 F7B8 F761 5A88 1272"))))
      (channel
       (name 'supervoid)
       (url "https://codeberg.org/pierhugues/supervoid.git")
       (branch "trunk")
       (commit "10edb45e6c33564abb06dbb8e40b687e5fca7a42")
       (introduction
        (make-channel-introduction
         "245db3d4ef2a29559b7dccef67afba453c9f6563"
         (openpgp-fingerprint
          "6068 E700 E178 0ADB 1D43  1E65 F7B8 F761 5A88 1272")))))

;; warning: GUIX_PACKAGE_PATH="/home/ph/src/automate/modules:"
