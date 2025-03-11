;;; SPDX-FileCopyrightText: 2025 Pier-Hugues Pellerin <ph@heykimo.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

(define-module (packages gnu packages rust-crates)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (guix build-system cargo))

(define (crate-name->package-name name)
  (downstream-package-name "rust-" name))

(define* (crate-source name version hash #:key (patches '()) (snippet #f))
  (origin
    (method url-fetch)
    (uri (crate-uri name version))
    (file-name (string-append (crate-name->package-name name) "-" version ".tar.gz"))
    (sha256 (base32 hash))
    (modules '((guix build utils)))
    (patches patches)
    (snippet snippet)))

;;;
;;; crates
;;;

(define qqqq-separator 'begin-of-crates)


(define rust-addr2line-0.22.0
  (crate-source "addr2line" "0.22.0"
                "0y66f1sa27i9kvmlh76ynk60rxfrmkba9ja8x527h32wdb206ibf"))

(define rust-adler-1.0.2
  (crate-source "adler" "1.0.2"
                "1zim79cvzd5yrkzl3nyfx0avijwgk9fqv3yrscdy1cc79ih02qpj"))

(define rust-adler2-2.0.0
  (crate-source "adler2" "2.0.0"
                "09r6drylvgy8vv8k20lnbvwq8gp09h7smfn6h1rxsy15pgh629si"))

(define rust-ahash-0.8.11
  (crate-source "ahash" "0.8.11"
                "04chdfkls5xmhp1d48gnjsmglbqibizs3bpbj6rsj604m10si7g8"))

(define rust-aho-corasick-1.1.3
  (crate-source "aho-corasick" "1.1.3"
                "05mrpkvdgp5d20y2p989f187ry9diliijgwrs254fs9s1m1x6q4f"))

(define rust-allocator-api2-0.2.18
  (crate-source "allocator-api2" "0.2.18"
                "0kr6lfnxvnj164j1x38g97qjlhb7akppqzvgfs0697140ixbav2w"))

(define rust-android-system-properties-0.1.5
  (crate-source "android_system_properties" "0.1.5"
                "04b3wrz12837j7mdczqd95b732gw5q7q66cv4yn4646lvccp57l1"))

(define rust-android-tzdata-0.1.1
  (crate-source "android-tzdata" "0.1.1"
                "1w7ynjxrfs97xg3qlcdns4kgfpwcdv824g611fq32cag4cdr96g9"))

(define rust-anes-0.1.6
  (crate-source "anes" "0.1.6"
                "16bj1ww1xkwzbckk32j2pnbn5vk6wgsl3q4p3j9551xbcarwnijb"))

(define rust-anstream-0.6.15
  (crate-source "anstream" "0.6.15"
                "09nm4qj34kiwgzczdvj14x7hgsb235g4sqsay3xsz7zqn4d5rqb4"))

(define rust-anstyle-1.0.8
  (crate-source "anstyle" "1.0.8"
                "1cfmkza63xpn1kkz844mgjwm9miaiz4jkyczmwxzivcsypk1vv0v"))

(define rust-anstyle-parse-0.2.5
  (crate-source "anstyle-parse" "0.2.5"
                "1jy12rvgbldflnb2x7mcww9dcffw1mx22nyv6p3n7d62h0gdwizb"))

(define rust-anstyle-query-1.1.1
  (crate-source "anstyle-query" "1.1.1"
                "0aj22iy4pzk6mz745sfrm1ym14r0y892jhcrbs8nkj7nqx9gqdkd"))

(define rust-anstyle-wincon-3.0.4
  (crate-source "anstyle-wincon" "3.0.4"
                "1y2pkvsrdxbcwircahb4wimans2pzmwwxad7ikdhj5lpdqdlxxsv"))

(define rust-anyhow-1.0.97
  (crate-source "anyhow" "1.0.97"
                "0kvspbiwncmmkdgrwjrimsmbmhzxc641p5ql99l2rjq6smmdbznw"))

(define rust-arc-swap-1.7.1
  (crate-source "arc-swap" "1.7.1"
                "0mrl9a9r9p9bln74q6aszvf22q1ijiw089jkrmabfqkbj31zixv9"))

(define rust-arrayvec-0.7.6
  (crate-source "arrayvec" "0.7.6"
                "0l1fz4ccgv6pm609rif37sl5nv5k6lbzi7kkppgzqzh1vwix20kw"))

(define rust-assert-cmd-2.0.16
  (crate-source "assert_cmd" "2.0.16"
                "0gdj0710k3lnvyjmpv8a4dgwrk9ib85l2wfw4n2xwy3qyavka66w"))

(define rust-assert-matches-1.5.0
  (crate-source "assert_matches" "1.5.0"
                "1a9b3p9vy0msylyr2022sk5flid37ini1dxji5l3vwxsvw4xcd4v"))

(define rust-async-trait-0.1.87
  (crate-source "async-trait" "0.1.87"
                "15swwmyl4nx7w03rq6ibb4x2c8rzbx9fpiag1kn4fhapb49yqmnm"))

(define rust-atomic-0.6.0
  (crate-source "atomic" "0.6.0"
                "15193mfhmrq3p6vi1a10hw3n6kvzf5h32zikhby3mdj0ww1q10cd"))

(define rust-autocfg-1.3.0
  (crate-source "autocfg" "1.3.0"
                "1c3njkfzpil03k92q0mij5y1pkhhfr4j3bf0h53bgl2vs85lsjqc"))

(define rust-backtrace-0.3.73
  (crate-source "backtrace" "0.3.73"
                "02iffg2pkg5nc36pgml8il7f77s138hhjw9f9l56v5zqlilk5hjw"))

(define rust-base64-0.21.7
  (crate-source "base64" "0.21.7"
                "0rw52yvsk75kar9wgqfwgb414kvil1gn7mqkrhn9zf1537mpsacx"))

(define rust-bit-set-0.5.3
  (crate-source "bit-set" "0.5.3"
                "1wcm9vxi00ma4rcxkl3pzzjli6ihrpn9cfdi0c5b4cvga2mxs007"))

(define rust-bit-vec-0.6.3
  (crate-source "bit-vec" "0.6.3"
                "1ywqjnv60cdh1slhz67psnp422md6jdliji6alq0gmly2xm9p7rl"))

(define rust-bitflags-1.3.2
  (crate-source "bitflags" "1.3.2"
                "12ki6w8gn1ldq7yz9y680llwk5gmrhrzszaa17g1sbrw2r2qvwxy"))

(define rust-bitflags-2.6.0
  (crate-source "bitflags" "2.6.0"
                "1pkidwzn3hnxlsl8zizh0bncgbjnw7c41cx7bby26ncbzmiznj5h"))

(define rust-blake2-0.10.6
  (crate-source "blake2" "0.10.6"
                "1zlf7w7gql12v61d9jcbbswa3dw8qxsjglylsiljp9f9b3a2ll26"))

(define rust-block-buffer-0.10.4
  (crate-source "block-buffer" "0.10.4"
                "0w9sa2ypmrsqqvc20nhwr75wbb5cjr4kkyhpjm1z1lv2kdicfy1h"))

(define rust-bstr-1.11.3
  (crate-source "bstr" "1.11.3"
                "1q3g2wmrvclgx7lk2p6mpzhqxzx41hyg962gkmlyxql1liar26jk"))

(define rust-bumpalo-3.16.0
  (crate-source "bumpalo" "3.16.0"
                "0b015qb4knwanbdlp1x48pkb4pm57b8gidbhhhxr900q2wb6fabr"))

(define rust-bytemuck-1.21.0
  (crate-source "bytemuck" "1.21.0"
                "18wj81x9xhqcd6985r8qxmbik6szjfjfj62q3xklw8h2p3x7srgg"))

(define rust-byteorder-1.5.0
  (crate-source "byteorder" "1.5.0"
                "0jzncxyf404mwqdbspihyzpkndfgda450l0893pz5xj685cg5l0z"))

(define rust-bytes-1.7.1
  (crate-source "bytes" "1.7.1"
                "0l5sf69avjxcw41cznyzxsnymwmkpmk08q0sm7fgicvvn0ysa643"))

(define rust-cassowary-0.3.0
  (crate-source "cassowary" "0.3.0"
                "0lvanj0gsk6pc1chqrh4k5k0vi1rfbgzmsk46dwy3nmrqyw711nz"))

(define rust-cast-0.3.0
  (crate-source "cast" "0.3.0"
                "1dbyngbyz2qkk0jn2sxil8vrz3rnpcj142y184p9l4nbl9radcip"))

(define rust-castaway-0.2.3
  (crate-source "castaway" "0.2.3"
                "1mf0wypwnkpa1hi0058vp8g7bjh2qraip2qv7dmak7mg1azfkfha"))

(define rust-cc-1.1.16
  (crate-source "cc" "1.1.16"
                "02qy8a9c7vabnk7lcaahdkngjg4r6ywafldihq73q29pnzn17l79"))

(define rust-cfg-aliases-0.1.1
  (crate-source "cfg_aliases" "0.1.1"
                "17p821nc6jm830vzl2lmwz60g3a30hcm33nk6l257i1rjdqw85px"))

(define rust-cfg-if-1.0.0
  (crate-source "cfg-if" "1.0.0"
                "1za0vb97n4brpzpv8lsbnzmq5r8f2b0cpqqr0sy8h5bn751xxwds"))

(define rust-chrono-0.4.40
  (crate-source "chrono" "0.4.40"
                "0z334kqnvq5zx6xsq1k6zk8g9z14fgk2w3vkn4n13pvi3mhn8y8s"))

(define rust-chrono-english-0.1.7
  (crate-source "chrono-english" "0.1.7"
                "0vqdl2bfyv224xv2xnqa9rsnbn89pjhzbhvrqs47sjpblyfr0ggp"))

(define rust-ciborium-0.2.2
  (crate-source "ciborium" "0.2.2"
                "03hgfw4674im1pdqblcp77m7rc8x2v828si5570ga5q9dzyrzrj2"))

(define rust-ciborium-io-0.2.2
  (crate-source "ciborium-io" "0.2.2"
                "0my7s5g24hvp1rs1zd1cxapz94inrvqpdf1rslrvxj8618gfmbq5"))

(define rust-ciborium-ll-0.2.2
  (crate-source "ciborium-ll" "0.2.2"
                "1n8g4j5rwkfs3rzfi6g1p7ngmz6m5yxsksryzf5k72ll7mjknrjp"))

(define rust-clap-4.5.31
  (crate-source "clap" "4.5.31"
                "0ryp6xjbdc9cbjjkafjl35j91pvv0ykislwqhr537bi9hkcv0yq2"))

(define rust-clap-builder-4.5.31
  (crate-source "clap_builder" "4.5.31"
                "0qyqd6kfcs41x29a95n15744jyv2v07srvwi6z9g7q3jl35y12am"))

(define rust-clap-complete-4.5.46
  (crate-source "clap_complete" "4.5.46"
                "166f2f6xr1jc8vhgjgpchwbfb12s1q3s1xakgvvnclrwla751igm"))

(define rust-clap-complete-nushell-4.5.5
  (crate-source "clap_complete_nushell" "4.5.5"
                "12miqxh9g7q37w11bgv55b32s0hdf6avf0lhagzc5psp6icv3a66"))

(define rust-clap-derive-4.5.28
  (crate-source "clap_derive" "4.5.28"
                "1vgigkhljp3r8r5lwdrn1ij93nafmjwh8cx77nppb9plqsaysk5z"))

(define rust-clap-lex-0.7.4
  (crate-source "clap_lex" "0.7.4"
                "19nwfls5db269js5n822vkc8dw0wjq2h1wf0hgr06ld2g52d2spl"))

(define rust-clap-mangen-0.2.25
  (crate-source "clap_mangen" "0.2.25"
                "1x09zzzkqpqz5g10nc951imz3b2wqgiiifmyd04qshx28anfdgxc"))

(define rust-clap-markdown-0.1.4
  (crate-source "clap-markdown" "0.1.4"
                "1zrcyih2mfgv11cnyzf1smxar8jgf82g5hj12nrzh53f4vk6gg4f"))

(define rust-clru-0.6.2
  (crate-source "clru" "0.6.2"
                "0ngyycxpxif84wpjjn0ixywylk95h5iv8fqycg2zsr3f0rpggl6b"))

(define rust-cmake-0.1.52
  (crate-source "cmake" "0.1.52"
                "03k2haq0zqqpwrz8p9kq2qdkyk44a69lp9k3gxmmn3kycwiw50n6"))

(define rust-colorchoice-1.0.2
  (crate-source "colorchoice" "1.0.2"
                "1h18ph538y8yjmbpaf8li98l0ifms2xmh3rax9666c5qfjfi3zfk"))

(define rust-compact-str-0.8.1
  (crate-source "compact_str" "0.8.1"
                "0cmgp61hw4fwaakhilwznfgncw2p4wkbvz6dw3i7ibbckh3c8y9v"))

(define rust-console-0.15.8
  (crate-source "console" "0.15.8"
                "1sz4nl9nz8pkmapqni6py7jxzi7nzqjxzb3ya4kxvmkb0zy867qf"))

(define rust-core-foundation-sys-0.8.7
  ;; TODO: Check bundled sources.
  (crate-source "core-foundation-sys" "0.8.7"
                "12w8j73lazxmr1z0h98hf3z623kl8ms7g07jch7n4p8f9nwlhdkp"))

(define rust-cpufeatures-0.2.14
  (crate-source "cpufeatures" "0.2.14"
                "1q3qd9qkw94vs7n5i0y3zz2cqgzcxvdgyb54ryngwmjhfbgrg1k0"))

(define rust-crc32fast-1.4.2
  (crate-source "crc32fast" "1.4.2"
                "1czp7vif73b8xslr3c9yxysmh9ws2r8824qda7j47ffs9pcnjxx9"))

(define rust-criterion-0.5.1
  (crate-source "criterion" "0.5.1"
                "0bv9ipygam3z8kk6k771gh9zi0j0lb9ir0xi1pc075ljg80jvcgj"))

(define rust-criterion-plot-0.5.0
  (crate-source "criterion-plot" "0.5.0"
                "1c866xkjqqhzg4cjvg01f8w6xc1j3j7s58rdksl52skq89iq4l3b"))

(define rust-crossbeam-channel-0.5.13
  (crate-source "crossbeam-channel" "0.5.13"
                "1wkx45r34v7g3wyi3lg2wz536lrrrab4h4hh741shfhr8rlhsj1k"))

(define rust-crossbeam-deque-0.8.5
  (crate-source "crossbeam-deque" "0.8.5"
                "03bp38ljx4wj6vvy4fbhx41q8f585zyqix6pncz1mkz93z08qgv1"))

(define rust-crossbeam-epoch-0.9.18
  (crate-source "crossbeam-epoch" "0.9.18"
                "03j2np8llwf376m3fxqx859mgp9f83hj1w34153c7a9c7i5ar0jv"))

(define rust-crossbeam-utils-0.8.20
  (crate-source "crossbeam-utils" "0.8.20"
                "100fksq5mm1n7zj242cclkw6yf7a4a8ix3lvpfkhxvdhbda9kv12"))

(define rust-crossterm-0.28.1
  (crate-source "crossterm" "0.28.1"
                "1im9vs6fvkql0sr378dfr4wdm1rrkrvr22v4i8byz05k1dd9b7c2"))

(define rust-crossterm-winapi-0.9.1
  (crate-source "crossterm_winapi" "0.9.1"
                "0axbfb2ykbwbpf1hmxwpawwfs8wvmkcka5m561l7yp36ldi7rpdc"))

(define rust-crunchy-0.2.2
  (crate-source "crunchy" "0.2.2"
                "1dx9mypwd5mpfbbajm78xcrg5lirqk7934ik980mmaffg3hdm0bs"))

(define rust-crypto-common-0.1.6
  (crate-source "crypto-common" "0.1.6"
                "1cvby95a6xg7kxdz5ln3rl9xh66nz66w46mm3g56ri1z5x815yqv"))

(define rust-csscolorparser-0.6.2
  (crate-source "csscolorparser" "0.6.2"
                "1gxh11hajx96mf5sd0az6mfsxdryfqvcfcphny3yfbfscqq7sapb"))

(define rust-darling-0.20.10
  (crate-source "darling" "0.20.10"
                "1299h2z88qn71mizhh05j26yr3ik0wnqmw11ijds89l8i9nbhqvg"))

(define rust-darling-core-0.20.10
  (crate-source "darling_core" "0.20.10"
                "1rgr9nci61ahnim93yh3xy6fkfayh7sk4447hahawah3m1hkh4wm"))

(define rust-darling-macro-0.20.10
  (crate-source "darling_macro" "0.20.10"
                "01kq3ibbn47czijj39h3vxyw0c2ksd0jvc097smcrk7n2jjs4dnk"))

(define rust-dashmap-6.1.0
  (crate-source "dashmap" "6.1.0"
                "1kvnw859xvrqyd1lk89na6797yvl5bri4wi9j0viz2a4j54wqhah"))

(define rust-deltae-0.3.2
  (crate-source "deltae" "0.3.2"
                "1d3hw9hpvicl9x0x34jr2ybjk5g5ym1lhbyz6zj31110gq8zaaap"))

(define rust-diff-0.1.13
  (crate-source "diff" "0.1.13"
                "1j0nzjxci2zqx63hdcihkp0a4dkdmzxd7my4m7zk6cjyfy34j9an"))

(define rust-difflib-0.4.0
  (crate-source "difflib" "0.4.0"
                "1s7byq4d7jgf2hcp2lcqxi2piqwl8xqlharfbi8kf90n8csy7131"))

(define rust-digest-0.10.7
  (crate-source "digest" "0.10.7"
                "14p2n6ih29x81akj097lvz7wi9b6b9hvls0lwrv7b6xwyy0s5ncy"))

(define rust-dirs-6.0.0
  (crate-source "dirs" "6.0.0"
                "0knfikii29761g22pwfrb8d0nqpbgw77sni9h2224haisyaams63"))

(define rust-dirs-sys-0.5.0
  ;; TODO: Check bundled sources.
  (crate-source "dirs-sys" "0.5.0"
                "1aqzpgq6ampza6v012gm2dppx9k35cdycbj54808ksbys9k366p0"))

(define rust-displaydoc-0.2.5
  (crate-source "displaydoc" "0.2.5"
                "1q0alair462j21iiqwrr21iabkfnb13d6x5w95lkdg21q2xrqdlp"))

(define rust-doc-comment-0.3.3
  (crate-source "doc-comment" "0.3.3"
                "043sprsf3wl926zmck1bm7gw0jq50mb76lkpk49vasfr6ax1p97y"))

(define rust-dunce-1.0.5
  (crate-source "dunce" "1.0.5"
                "04y8wwv3vvcqaqmqzssi6k0ii9gs6fpz96j5w9nky2ccsl23axwj"))

(define rust-either-1.15.0
  (crate-source "either" "1.15.0"
                "069p1fknsmzn9llaizh77kip0pqmcwpdsykv2x30xpjyija5gis8"))

(define rust-encode-unicode-0.3.6
  (crate-source "encode_unicode" "0.3.6"
                "07w3vzrhxh9lpjgsg2y5bwzfar2aq35mdznvcp3zjl0ssj7d4mx3"))

(define rust-encoding-rs-0.8.34
  (crate-source "encoding_rs" "0.8.34"
                "0nagpi1rjqdpvakymwmnlxzq908ncg868lml5b70n08bm82fjpdl"))

(define rust-enum-dispatch-0.3.13
  (crate-source "enum_dispatch" "0.3.13"
                "1kby2jz173ggg7wk41vjsskmkdyx7749ll8lhqhv6mb5qqmww65a"))

(define rust-equivalent-1.0.1
  (crate-source "equivalent" "1.0.1"
                "1malmx5f4lkfvqasz319lq6gb3ddg19yzf9s8cykfsgzdmyq0hsl"))

(define rust-errno-0.3.10
  (crate-source "errno" "0.3.10"
                "0pgblicz1kjz9wa9m0sghkhh2zw1fhq1mxzj7ndjm746kg5m5n1k"))

(define rust-euclid-0.22.11
  (crate-source "euclid" "0.22.11"
                "0j4yb01x9dn5hbbbigd3mwdplv4m29k5drmhmc95lj3yfi5xp75d"))

(define rust-fancy-regex-0.11.0
  (crate-source "fancy-regex" "0.11.0"
                "18j0mmzfycibhxhhhfja00dxd1vf8x5c28lbry224574h037qpxr"))

(define rust-faster-hex-0.9.0
  (crate-source "faster-hex" "0.9.0"
                "10wi4vqbdpkamw4qvra1ijp4as2j7j1zc66g4rdr6h0xv8gb38m2"))

(define rust-fastrand-2.1.1
  (crate-source "fastrand" "2.1.1"
                "19nyzdq3ha4g173364y2wijmd6jlyms8qx40daqkxsnl458jmh78"))

(define rust-filedescriptor-0.8.2
  (crate-source "filedescriptor" "0.8.2"
                "0vplyh0cw35kzq7smmp2ablq0zsknk5rkvvrywqsqfrchmjxk6bi"))

(define rust-filetime-0.2.25
  (crate-source "filetime" "0.2.25"
                "11l5zr86n5sr6g6k6sqldswk0jzklm0q95rzikxcns0yk0p55h1m"))

(define rust-finl-unicode-1.3.0
  (crate-source "finl_unicode" "1.3.0"
                "0qy1rwjxkqbl6g8ngm2p33y83r4mbfk3l22075yv6vlh4nsp1jcl"))

(define rust-fixedbitset-0.4.2
  (crate-source "fixedbitset" "0.4.2"
                "101v41amgv5n9h4hcghvrbfk5vrncx1jwm35rn5szv4rk55i7rqc"))

(define rust-flate2-1.0.33
  (crate-source "flate2" "1.0.33"
                "0lzj9cmr1pcwrgr4nnxjihnksqhxmygcqqdqcjnhbvslh3k1njij"))

(define rust-fnv-1.0.7
  (crate-source "fnv" "1.0.7"
                "1hc2mcqha06aibcaza94vbi81j6pr9a1bbxrxjfhc91zin8yr7iz"))

(define rust-form-urlencoded-1.2.1
  (crate-source "form_urlencoded" "1.2.1"
                "0milh8x7nl4f450s3ddhg57a3flcv6yq8hlkyk6fyr3mcb128dp1"))

(define rust-futures-0.1.31
  (crate-source "futures" "0.1.31"
                "0y46qbmhi37dqkch8dlfq5aninqpzqgrr98awkb3rn4fxww1lirs"))

(define rust-futures-0.3.31
  (crate-source "futures" "0.3.31"
                "0xh8ddbkm9jy8kc5gbvjp9a4b6rqqxvc8471yb2qaz5wm2qhgg35"))

(define rust-futures-channel-0.3.31
  (crate-source "futures-channel" "0.3.31"
                "040vpqpqlbk099razq8lyn74m0f161zd0rp36hciqrwcg2zibzrd"))

(define rust-futures-core-0.3.31
  (crate-source "futures-core" "0.3.31"
                "0gk6yrxgi5ihfanm2y431jadrll00n5ifhnpx090c2f2q1cr1wh5"))

(define rust-futures-executor-0.3.31
  (crate-source "futures-executor" "0.3.31"
                "17vcci6mdfzx4gbk0wx64chr2f13wwwpvyf3xd5fb1gmjzcx2a0y"))

(define rust-futures-io-0.3.31
  (crate-source "futures-io" "0.3.31"
                "1ikmw1yfbgvsychmsihdkwa8a1knank2d9a8dk01mbjar9w1np4y"))

(define rust-futures-macro-0.3.31
  (crate-source "futures-macro" "0.3.31"
                "0l1n7kqzwwmgiznn0ywdc5i24z72zvh9q1dwps54mimppi7f6bhn"))

(define rust-futures-sink-0.3.31
  (crate-source "futures-sink" "0.3.31"
                "1xyly6naq6aqm52d5rh236snm08kw8zadydwqz8bip70s6vzlxg5"))

(define rust-futures-task-0.3.31
  (crate-source "futures-task" "0.3.31"
                "124rv4n90f5xwfsm9qw6y99755y021cmi5dhzh253s920z77s3zr"))

(define rust-futures-util-0.3.31
  (crate-source "futures-util" "0.3.31"
                "10aa1ar8bgkgbr4wzxlidkqkcxf77gffyj8j7768h831pcaq784z"))

(define rust-generic-array-0.14.7
  (crate-source "generic-array" "0.14.7"
                "16lyyrzrljfq424c3n8kfwkqihlimmsg5nhshbbp48np3yjrqr45"))

(define rust-getrandom-0.2.15
  (crate-source "getrandom" "0.2.15"
                "1mzlnrb3dgyd1fb84gvw10pyr8wdqdl4ry4sr64i1s8an66pqmn4"))

(define rust-getrandom-0.3.1
  (crate-source "getrandom" "0.3.1"
                "1y154yzby383p63ndw6zpfm0fz3vf6c0zdwc7df6vkl150wrr923"))

(define rust-gimli-0.29.0
  (crate-source "gimli" "0.29.0"
                "1zgzprnjaawmg6zyic4f2q2hc39kdhn116qnkqpgvsasgc3x9v20"))

(define rust-git2-0.19.0
  (crate-source "git2" "0.19.0"
                "091pv7866z1qjq800ys0wjv8n73wrv7fqdrddxcnq36w8lzbf0xr"))

(define rust-gix-0.70.0
  (crate-source "gix" "0.70.0"
                "0s3b5407lqx9nf81xfrmka6l269551kkwm9blmpabwq5cxii8vvk"))

(define rust-gix-actor-0.33.2
  (crate-source "gix-actor" "0.33.2"
                "1cp47vxcd7f7nf225spdhncqqsrcjcf5qc68zkqnbq1jccd8l090"))

(define rust-gix-attributes-0.24.0
  (crate-source "gix-attributes" "0.24.0"
                "0f6vdp77d5z98bv3w6i71zlaqcgf8bch4qfa3rj5zvv2yq5h0lgi"))

(define rust-gix-bitmap-0.2.14
  (crate-source "gix-bitmap" "0.2.14"
                "0h3msc00gi2vr2k4q41ddb68qprbvkih824glq6na0lmqrjrgnxi"))

(define rust-gix-chunk-0.4.11
  (crate-source "gix-chunk" "0.4.11"
                "0vxxq4q5pn5cz2xhghcjpp8z83r8xxy74gsffvf9k1lmcj3is7qb"))

(define rust-gix-command-0.4.1
  (crate-source "gix-command" "0.4.1"
                "1wcdm6f8v28y2rv5lmz7kh4lnkdzplc92nh2c9gb8papss20nhfb"))

(define rust-gix-commitgraph-0.26.0
  (crate-source "gix-commitgraph" "0.26.0"
                "0xs85svhri8b40paa3zjjxfqzl6g3ganxnxg1nhjcq51v318wfp2"))

(define rust-gix-config-0.43.0
  (crate-source "gix-config" "0.43.0"
                "1sfry54k4f35ar6y0d7n52ccwyq9r192kkdkw1lx9m8l43yiwz1p"))

(define rust-gix-config-value-0.14.11
  (crate-source "gix-config-value" "0.14.11"
                "1vjckx1is9csf5h9bnrvfir5wjzy9jlvl7a70cs2y24kxx252dhi"))

(define rust-gix-date-0.9.3
  (crate-source "gix-date" "0.9.3"
                "0gqij6pgbajq3a07a0y528pqfa6m5nspc4dvffqliqjycixlfz65"))

(define rust-gix-diff-0.50.0
  (crate-source "gix-diff" "0.50.0"
                "0kbwn5js7qwnqxxva52hrhxrkwhvxfr6a86rvblz9k8arbsbgbv2"))

(define rust-gix-dir-0.12.0
  (crate-source "gix-dir" "0.12.0"
                "0yymdfbdhsl5fwfbsf2py8zb1amcxy27n148nz8zf4ksjarqvmy1"))

(define rust-gix-discover-0.38.0
  (crate-source "gix-discover" "0.38.0"
                "1n35pfcr4didkxswigy4lvwkqrhyvbgjk82sb87lw1h4vx5l3hnh"))

(define rust-gix-features-0.40.0
  (crate-source "gix-features" "0.40.0"
                "0m6mf6f341shzs5b1iy79klkw00x84kba34z5i4bshldia1x9zcb"))

(define rust-gix-filter-0.17.0
  (crate-source "gix-filter" "0.17.0"
                "1frbjkmwrafbp7psbnh9rp9szlakcn44b1jmqc7fsqxwgp6kdk5x"))

(define rust-gix-fs-0.13.0
  (crate-source "gix-fs" "0.13.0"
                "0g86cb2i18c7jnj8i9691a3h07nz7hvinig7ryvzyi6zpykpybhq"))

(define rust-gix-glob-0.18.0
  (crate-source "gix-glob" "0.18.0"
                "0kii7bpz1vcdykb0x1k9zmhn22hynwyk4n5acfrzjy0az94p572f"))

(define rust-gix-hash-0.16.0
  (crate-source "gix-hash" "0.16.0"
                "1y79zcwja9b1bqlr27awndla5wcmzd7a8rnh7qdq5ca9hv25w778"))

(define rust-gix-hashtable-0.7.0
  (crate-source "gix-hashtable" "0.7.0"
                "1l8jq85fkfw4inmpd6w2pk1dq67krsqmmp100lpd1k1a6yy3148q"))

(define rust-gix-ignore-0.13.0
  (crate-source "gix-ignore" "0.13.0"
                "0vyz5jfqd72b4pygwqrssr96jvfzi32hm7y4lz05b65zh35rsljg"))

(define rust-gix-index-0.38.0
  (crate-source "gix-index" "0.38.0"
                "1n45vkbmkpc4m570rdanyqz62a68mihsrqpz1wqnk4w74qv2xldc"))

(define rust-gix-lock-16.0.0
  (crate-source "gix-lock" "16.0.0"
                "0hn696w506zwqfl9pjhijaqkshzr5lb4v0j1hjb40sgzf1982fcp"))

(define rust-gix-object-0.47.0
  (crate-source "gix-object" "0.47.0"
                "0s7xwm1nmx2zp10qnrlxh8vmw5nakjkvfzrl4bzg0i220jhb7i6x"))

(define rust-gix-odb-0.67.0
  (crate-source "gix-odb" "0.67.0"
                "06ww8mc10iydvqxdin0miny89g9z8i7zmsccc1rrbl4wyrylb4ry"))

(define rust-gix-pack-0.57.0
  (crate-source "gix-pack" "0.57.0"
                "05d57xpzk35i2cclnb9iclvm1gvrc20mzcvz04bmcwyvndss84zw"))

(define rust-gix-packetline-0.18.3
  (crate-source "gix-packetline" "0.18.3"
                "1k9rqirrqsggwz9hz72l13dkvjhkg19zamaayimhl5mcqdmsxrf7"))

(define rust-gix-packetline-blocking-0.18.2
  (crate-source "gix-packetline-blocking" "0.18.2"
                "0z71s469s76g96a222221ww051ydbcmp11pmg5kmmgbagivgijy1"))

(define rust-gix-path-0.10.14
  (crate-source "gix-path" "0.10.14"
                "17x9hfl6624q29q8fd5ljix6n8xywccff3xrrzh9nad8cnxi43y4"))

(define rust-gix-pathspec-0.9.0
  (crate-source "gix-pathspec" "0.9.0"
                "0v7q0b55fn0raaj52cg75bi5yc8pijkzl1lq05crv3n0hskd6c34"))

(define rust-gix-protocol-0.48.0
  (crate-source "gix-protocol" "0.48.0"
                "145sln6g810vab9jhwiz3r1bwr61jh1i1qj168hpvdn6mxhvsqbc"))

(define rust-gix-quote-0.4.15
  (crate-source "gix-quote" "0.4.15"
                "1ik6l3s0hjb2p4dlgdarb59v7n9jvgvak4ij786mrj5hrpy5g4z4"))

(define rust-gix-ref-0.50.0
  (crate-source "gix-ref" "0.50.0"
                "03723r9s3m3grmjzcasxp7jcz0z5xs90spg9aj2ryhikz72z9ba7"))

(define rust-gix-refspec-0.28.0
  (crate-source "gix-refspec" "0.28.0"
                "140aif2nciz9j9a0h9lqsg8cb1pkzhbza9bsgy7gc4pnv0l04rar"))

(define rust-gix-revision-0.32.0
  (crate-source "gix-revision" "0.32.0"
                "0lvb7rrjjdr9h21ign5g0za2jg00nimzqvkcdvbacpd5rjy8pqiz"))

(define rust-gix-revwalk-0.18.0
  (crate-source "gix-revwalk" "0.18.0"
                "0iv2c479w9lkjwbngdwyial6km8dllgah8wvp7r9w7jv4c6biv6l"))

(define rust-gix-sec-0.10.11
  (crate-source "gix-sec" "0.10.11"
                "0xcqckdfbbwcqhqzsbryqg3nijalgvr6n5hasvw16hqz4w9swkfq"))

(define rust-gix-shallow-0.2.0
  (crate-source "gix-shallow" "0.2.0"
                "0rjhwcjjixfy4fbzciyz5mikkvq38rwfyny86ckya0z324q58wmb"))

(define rust-gix-status-0.17.0
  (crate-source "gix-status" "0.17.0"
                "10s87zd97hvckhrq4jn7a794q5vypxwn8jmbqcrcmmvra3cc2k21"))

(define rust-gix-submodule-0.17.0
  (crate-source "gix-submodule" "0.17.0"
                "1b532y2c7qg8axqc2nkw2mdiq8mg9hxq87mfj2aa1j3askl2z5vl"))

(define rust-gix-tempfile-16.0.0
  (crate-source "gix-tempfile" "16.0.0"
                "00c5czgzzi3c8yxv24vh1rmkgf06vgb1ypf5521lmwjyjhiz8n15"))

(define rust-gix-trace-0.1.12
  (crate-source "gix-trace" "0.1.12"
                "1xv54v5y91vxjx351wl3yk66fwk7ybkna2knbxlnj34j6qh6lfbw"))

(define rust-gix-transport-0.45.0
  (crate-source "gix-transport" "0.45.0"
                "1nb4p7jwy80g51afzc64ya1faxxcpgnimbk2p2sv2xwl90c7860i"))

(define rust-gix-traverse-0.44.0
  (crate-source "gix-traverse" "0.44.0"
                "1d311l7wlgpv41hvp1ni3r9hhwxn4x27xyiy5brnwn4n73jp1v1b"))

(define rust-gix-url-0.29.0
  (crate-source "gix-url" "0.29.0"
                "04qb2p68886axrbx5gdjlhqwg55j0pn7zn25c08qzpakidv8q899"))

(define rust-gix-utils-0.1.14
  (crate-source "gix-utils" "0.1.14"
                "0pykxyp0cm2x8lj4ryj1pflksf9k7iyrshf8g321d2dc0d7g427z"))

(define rust-gix-validate-0.9.3
  (crate-source "gix-validate" "0.9.3"
                "145xmpf2n047zvkarbjc3yksx8i276194bm4q0bmd23x6g1h3aly"))

(define rust-gix-worktree-0.39.0
  (crate-source "gix-worktree" "0.39.0"
                "0n49fywzh1f4gmv7gwd4d5jnq7ahiabsdv6wda3scmxagqpm2wv6"))

(define rust-gix-worktree-state-0.17.0
  (crate-source "gix-worktree-state" "0.17.0"
                "1w2vaz776v13hrnzhnsihmcbhb6883b33gc3cq475yasmncy3xc6"))

(define rust-glob-0.3.2
  (crate-source "glob" "0.3.2"
                "1cm2w34b5w45fxr522h5b0fv1bxchfswcj560m3pnjbia7asvld8"))

(define rust-globset-0.4.15
  (crate-source "globset" "0.4.15"
                "06gv8a5mg5q724lhdq4hp6zmv923whzm7mgpkghz3rs6crlcxw8m"))

(define rust-half-2.4.1
  (crate-source "half" "2.4.1"
                "123q4zzw1x4309961i69igzd1wb7pj04aaii3kwasrz3599qrl3d"))

(define rust-hashbrown-0.14.5
  (crate-source "hashbrown" "0.14.5"
                "1wa1vy1xs3mp11bn3z9dv0jricgr6a2j0zkf1g19yz3vw4il89z5"))

(define rust-hashbrown-0.15.2
  (crate-source "hashbrown" "0.15.2"
                "12dj0yfn59p3kh3679ac0w1fagvzf4z2zp87a13gbbqbzw0185dz"))

(define rust-heck-0.5.0
  (crate-source "heck" "0.5.0"
                "1sjmpsdl8czyh9ywl3qcsfsq9a307dg4ni2vnlwgnzzqhc4y0113"))

(define rust-hermit-abi-0.3.9
  (crate-source "hermit-abi" "0.3.9"
                "092hxjbjnq5fmz66grd9plxd0sh6ssg5fhgwwwqbrzgzkjwdycfj"))

(define rust-hermit-abi-0.4.0
  (crate-source "hermit-abi" "0.4.0"
                "1k1zwllx6nfq417hy38x4akw1ivlv68ymvnzyxs76ffgsqcskxpv"))

(define rust-hex-0.4.3
  (crate-source "hex" "0.4.3"
                "0w1a4davm1lgzpamwnba907aysmlrnygbqmfis2mqjx5m552a93z"))

(define rust-home-0.5.9
  (crate-source "home" "0.5.9"
                "19grxyg35rqfd802pcc9ys1q3lafzlcjcv2pl2s5q8xpyr5kblg3"))

(define rust-iana-time-zone-0.1.60
  (crate-source "iana-time-zone" "0.1.60"
                "0hdid5xz3jznm04lysjm3vi93h3c523w0hcc3xba47jl3ddbpzz7"))

(define rust-iana-time-zone-haiku-0.1.2
  (crate-source "iana-time-zone-haiku" "0.1.2"
                "17r6jmj31chn7xs9698r122mapq85mfnv98bb4pg6spm0si2f67k"))

(define rust-icu-collections-1.5.0
  (crate-source "icu_collections" "1.5.0"
                "09j5kskirl59mvqc8kabhy7005yyy7dp88jw9f6f3gkf419a8byv"))

(define rust-icu-locid-1.5.0
  (crate-source "icu_locid" "1.5.0"
                "0dznvd1c5b02iilqm044q4hvar0sqibq1z46prqwjzwif61vpb0k"))

(define rust-icu-locid-transform-1.5.0
  (crate-source "icu_locid_transform" "1.5.0"
                "0kmmi1kmj9yph6mdgkc7v3wz6995v7ly3n80vbg0zr78bp1iml81"))

(define rust-icu-locid-transform-data-1.5.0
  (crate-source "icu_locid_transform_data" "1.5.0"
                "0vkgjixm0wzp2n3v5mw4j89ly05bg3lx96jpdggbwlpqi0rzzj7x"))

(define rust-icu-normalizer-1.5.0
  (crate-source "icu_normalizer" "1.5.0"
                "0kx8qryp8ma8fw1vijbgbnf7zz9f2j4d14rw36fmjs7cl86kxkhr"))

(define rust-icu-normalizer-data-1.5.0
  (crate-source "icu_normalizer_data" "1.5.0"
                "05lmk0zf0q7nzjnj5kbmsigj3qgr0rwicnn5pqi9n7krmbvzpjpq"))

(define rust-icu-properties-1.5.1
  (crate-source "icu_properties" "1.5.1"
                "1xgf584rx10xc1p7zjr78k0n4zn3g23rrg6v2ln31ingcq3h5mlk"))

(define rust-icu-properties-data-1.5.0
  (crate-source "icu_properties_data" "1.5.0"
                "0scms7pd5a7yxx9hfl167f5qdf44as6r3bd8myhlngnxqgxyza37"))

(define rust-icu-provider-1.5.0
  (crate-source "icu_provider" "1.5.0"
                "1nb8vvgw8dv2inqklvk05fs0qxzkw8xrg2n9vgid6y7gm3423m3f"))

(define rust-icu-provider-macros-1.5.0
  (crate-source "icu_provider_macros" "1.5.0"
                "1mjs0w7fcm2lcqmbakhninzrjwqs485lkps4hz0cv3k36y9rxj0y"))

(define rust-ident-case-1.0.1
  (crate-source "ident_case" "1.0.1"
                "0fac21q6pwns8gh1hz3nbq15j8fi441ncl6w4vlnd1cmc55kiq5r"))

(define rust-idna-1.0.3
  (crate-source "idna" "1.0.3"
                "0zlajvm2k3wy0ay8plr07w22hxkkmrxkffa6ah57ac6nci984vv8"))

(define rust-idna-adapter-1.2.0
  (crate-source "idna_adapter" "1.2.0"
                "0wggnkiivaj5lw0g0384ql2d7zk4ppkn3b1ry4n0ncjpr7qivjns"))

(define rust-ignore-0.4.23
  (crate-source "ignore" "0.4.23"
                "0jysggjfmlxbg60vhhiz4pb8jfb7cnq5swdsvxknbs7x18wgv2bd"))

(define rust-imara-diff-0.1.7
  (crate-source "imara-diff" "0.1.7"
                "008abq9x276wsak6xl27r309pz1f6li3f82p2qscsi5xaaia37gw"))

(define rust-indexmap-2.7.1
  (crate-source "indexmap" "2.7.1"
                "0lmnm1zbr5gq3wic3d8a76gpvampridzwckfl97ckd5m08mrk74c"))

(define rust-indoc-2.0.6
  (crate-source "indoc" "2.0.6"
                "1gbn2pkx5sgbd9lp05d2bkqpbfgazi0z3nvharh5ajah11d29izl"))

(define rust-insta-1.42.2
  (crate-source "insta" "1.42.2"
                "111hrdc3bxwp146kz2ffwdq0qypdjk8a2yzwr8mivlb7maxrl9ah"))

(define rust-instability-0.3.6
  (crate-source "instability" "0.3.6"
                "0gsvkqy6ximw97f1glz13nic81yif4bh86r21s60r34h8jj16j49"))

(define rust-io-close-0.3.7
  (crate-source "io-close" "0.3.7"
                "1g4hldfn436rkrx3jlm4az1y5gdmkcixdlhkwy64yx06gx2czbcw"))

(define rust-is-executable-1.0.4
  (crate-source "is_executable" "1.0.4"
                "1qlafm7f0zq0kzvbd4fhcfci4g9gxp6g3yqxjqsjj1zrssxbb8fl"))

(define rust-is-terminal-0.4.13
  (crate-source "is-terminal" "0.4.13"
                "0jwgjjz33kkmnwai3nsdk1pz9vb6gkqvw1d1vq7bs3q48kinh7r6"))

(define rust-is-terminal-polyfill-1.70.1
  (crate-source "is_terminal_polyfill" "1.70.1"
                "1kwfgglh91z33kl0w5i338mfpa3zs0hidq5j4ny4rmjwrikchhvr"))

(define rust-itertools-0.10.5
  (crate-source "itertools" "0.10.5"
                "0ww45h7nxx5kj6z2y6chlskxd1igvs4j507anr6dzg99x1h25zdh"))

(define rust-itertools-0.12.1
  (crate-source "itertools" "0.12.1"
                "0s95jbb3ndj1lvfxyq5wanc0fm0r6hg6q4ngb92qlfdxvci10ads"))

(define rust-itertools-0.13.0
  (crate-source "itertools" "0.13.0"
                "11hiy3qzl643zcigknclh446qb9zlg4dpdzfkjaa9q9fqpgyfgj1"))

(define rust-itoa-1.0.11
  (crate-source "itoa" "1.0.11"
                "0nv9cqjwzr3q58qz84dcz63ggc54yhf1yqar1m858m1kfd4g3wa9"))

(define rust-jiff-0.1.12
  (crate-source "jiff" "0.1.12"
                "16rsbjj433av3gqck20d9v5115f6ylasnm82sza00yd4dl952xj3"))

(define rust-jiff-tzdb-0.1.0
  (crate-source "jiff-tzdb" "0.1.0"
                "1rmbi5l6ssz6wfbdf5v06sgm8kkfw2vnray2lcc0y76znclc7yh5"))

(define rust-jiff-tzdb-platform-0.1.0
  (crate-source "jiff-tzdb-platform" "0.1.0"
                "0h396fsksidvhiwsc9aihrywbybd9lcjq4ic9jambwzabxykinpq"))

(define rust-jobserver-0.1.32
  (crate-source "jobserver" "0.1.32"
                "1l2k50qmj84x9mn39ivjz76alqmx72jhm12rw33zx9xnpv5xpla8"))

(define rust-js-sys-0.3.70
  ;; TODO: Check bundled sources.
  (crate-source "js-sys" "0.3.70"
                "0yp3rz7vrn9mmqdpkds426r1p9vs6i8mkxx8ryqdfadr0s2q0s0q"))

(define rust-kstring-2.0.2
  (crate-source "kstring" "2.0.2"
                "1lfvqlqkg2x23nglznb7ah6fk3vv3y5i759h5l2151ami98gk2sm"))

(define rust-lab-0.11.0
  (crate-source "lab" "0.11.0"
                "13ymsn5cwl5i9pmp5mfmbap7q688dcp9a17q82crkvb784yifdmz"))

(define rust-lazy-static-1.5.0
  (crate-source "lazy_static" "1.5.0"
                "1zk6dqqni0193xg6iijh7i3i44sryglwgvx20spdvwk3r6sbrlmv"))

(define rust-libc-0.2.170
  (crate-source "libc" "0.2.170"
                "0a38q3avb6r6azxb7yfbjly5sbr8926z6c4sryyp33rgrf03cnw7"))

(define rust-libgit2-sys-0.17.0+1.8.1
  ;; TODO: Check bundled sources.
  (crate-source "libgit2-sys" "0.17.0+1.8.1"
                "093jxfl2i9vxdlgf7vk9d040sjwy0nq4fid640y7qix6m0k26iqh"))

(define rust-libredox-0.1.3
  (crate-source "libredox" "0.1.3"
                "139602gzgs0k91zb7dvgj1qh4ynb8g1lbxsswdim18hcb6ykgzy0"))

(define rust-libssh2-sys-0.3.0
  ;; TODO: Check bundled sources.
  (crate-source "libssh2-sys" "0.3.0"
                "1vkidqw5ll71ynqc93hgcq62iqkklzb5268zffd13ql7nwqa1j1d"))

(define rust-libz-ng-sys-1.1.16
  ;; TODO: Check bundled sources.
  (crate-source "libz-ng-sys" "1.1.16"
                "0f54ffm7bzqdvmcxkv2as6ir9bgzhkaq0g1jgwkz2mns04d7adj4"))

(define rust-libz-sys-1.1.20
  ;; TODO: Check bundled sources.
  (crate-source "libz-sys" "1.1.20"
                "0wp4i6zl385ilmcqafv61jwsk1mpk6yb8gpws9nwza00x19n9lfj"))

(define rust-linked-hash-map-0.5.6
  (crate-source "linked-hash-map" "0.5.6"
                "03vpgw7x507g524nx5i1jf5dl8k3kv0fzg8v3ip6qqwbpkqww5q7"))

(define rust-linux-raw-sys-0.4.14
  ;; TODO: Check bundled sources.
  (crate-source "linux-raw-sys" "0.4.14"
                "12gsjgbhhjwywpqcrizv80vrp7p7grsz5laqq773i33wphjsxcvq"))

(define rust-linux-raw-sys-0.9.2
  ;; TODO: Check bundled sources.
  (crate-source "linux-raw-sys" "0.9.2"
                "1s89d3ykla46h6i3z42972gnlm9xbdlyj1kmgdbxr1zhva1wdfbd"))

(define rust-litemap-0.7.4
  (crate-source "litemap" "0.7.4"
                "012ili3vppd4952sh6y3qwcd0jkd0bq2qpr9h7cppc8sj11k7saf"))

(define rust-lock-api-0.4.12
  (crate-source "lock_api" "0.4.12"
                "05qvxa6g27yyva25a5ghsg85apdxkvr77yhkyhapj6r8vnf8pbq7"))

(define rust-log-0.4.22
  (crate-source "log" "0.4.22"
                "093vs0wkm1rgyykk7fjbqp2lwizbixac1w52gv109p5r4jh0p9x7"))

(define rust-lru-0.12.4
  (crate-source "lru" "0.12.4"
                "017rzh4kyl3j79sj0qc35wallblsqbnkzxpn6i3xkrv02y4kkvip"))

(define rust-mac-address-1.1.7
  (crate-source "mac_address" "1.1.7"
                "13m0jdaaq77r8azml00dm5ca1ym253l7kpgw9s5jrgnls3lzldl8"))

(define rust-maplit-1.0.2
  (crate-source "maplit" "1.0.2"
                "07b5kjnhrrmfhgqm9wprjw8adx6i225lqp49gasgqg74lahnabiy"))

(define rust-matchers-0.1.0
  (crate-source "matchers" "0.1.0"
                "0n2mbk7lg2vf962c8xwzdq96yrc9i0p8dbmm4wa1nnkcp1dhfqw2"))

(define rust-maybe-async-0.2.10
  (crate-source "maybe-async" "0.2.10"
                "04fvg2ywb2p9dzf7i35xqfibxc05k1pirv36jswxcqg3qw82ryaw"))

(define rust-memchr-2.7.4
  (crate-source "memchr" "2.7.4"
                "18z32bhxrax0fnjikv475z7ii718hq457qwmaryixfxsl2qrmjkq"))

(define rust-memmap2-0.5.10
  (crate-source "memmap2" "0.5.10"
                "09xk415fxyl4a9pgby4im1v2gqlb5lixpm99dczkk30718na9yl3"))

(define rust-memmap2-0.9.4
  (crate-source "memmap2" "0.9.4"
                "08hkmvri44j6h14lyq4yw5ipsp91a9jacgiww4bs9jm8whi18xgy"))

(define rust-memmem-0.1.1
  (crate-source "memmem" "0.1.1"
                "05ccifqgxdfxk6yls41ljabcccsz3jz6549l1h3cwi17kr494jm6"))

(define rust-memoffset-0.9.1
  (crate-source "memoffset" "0.9.1"
                "12i17wh9a9plx869g7j4whf62xw68k5zd4k0k5nh6ys5mszid028"))

(define rust-minimal-lexical-0.2.1
  (crate-source "minimal-lexical" "0.2.1"
                "16ppc5g84aijpri4jzv14rvcnslvlpphbszc7zzp6vfkddf4qdb8"))

(define rust-miniz-oxide-0.7.4
  (crate-source "miniz_oxide" "0.7.4"
                "024wv14aa75cvik7005s5y2nfc8zfidddbd7g55g7sjgnzfl18mq"))

(define rust-miniz-oxide-0.8.0
  (crate-source "miniz_oxide" "0.8.0"
                "1wadxkg6a6z4lr7kskapj5d8pxlx7cp1ifw4daqnkzqjxych5n72"))

(define rust-mio-1.0.2
  (crate-source "mio" "1.0.2"
                "1v1cnnn44awxbcfm4zlavwgkvbyg7gp5zzjm8mqf1apkrwflvq40"))

(define rust-multimap-0.10.0
  (crate-source "multimap" "0.10.0"
                "00vs2frqdhrr8iqx4y3fbq73ax5l12837fvbjrpi729d85alrz6y"))

(define rust-nix-0.28.0
  (crate-source "nix" "0.28.0"
                "1r0rylax4ycx3iqakwjvaa178jrrwiiwghcw95ndzy72zk25c8db"))

(define rust-nom-7.1.3
  (crate-source "nom" "7.1.3"
                "0jha9901wxam390jcf5pfa0qqfrgh8li787jx2ip0yk5b8y9hwyj"))

(define rust-nu-ansi-term-0.46.0
  (crate-source "nu-ansi-term" "0.46.0"
                "115sywxh53p190lyw97alm14nc004qj5jm5lvdj608z84rbida3p"))

(define rust-num-cpus-1.16.0
  (crate-source "num_cpus" "1.16.0"
                "0hra6ihpnh06dvfvz9ipscys0xfqa9ca9hzp384d5m02ssvgqqa1"))

(define rust-num-derive-0.4.2
  (crate-source "num-derive" "0.4.2"
                "00p2am9ma8jgd2v6xpsz621wc7wbn1yqi71g15gc3h67m7qmafgd"))

(define rust-num-traits-0.2.19
  (crate-source "num-traits" "0.2.19"
                "0h984rhdkkqd4ny9cif7y2azl3xdfb7768hb9irhpsch4q3gq787"))

(define rust-object-0.36.4
  (crate-source "object" "0.36.4"
                "02h7k38dwi8rndc3y81n6yjxijbss99p2jm9c0b6ak5c45c1lkq8"))

(define rust-once-cell-1.20.3
  (crate-source "once_cell" "1.20.3"
                "0bp6rgrsri1vfdcahsimk08zdiilv14ppgcnpbiw8hqyp2j64m4l"))

(define rust-oorandom-11.1.4
  (crate-source "oorandom" "11.1.4"
                "1sg4j19r5302a6jpn0kgfkbjnslrqr3ynxv8x2h2ddaaw7kvn45l"))

(define rust-openssl-probe-0.1.5
  (crate-source "openssl-probe" "0.1.5"
                "1kq18qm48rvkwgcggfkqq6pm948190czqc94d6bm2sir5hq1l0gz"))

(define rust-openssl-src-300.3.2+3.3.2
  ;; TODO: Check bundled sources.
  (crate-source "openssl-src" "300.3.2+3.3.2"
                "0yv44gm6ds9h1lz21si2p6m4dvj8qps5h03fri4fdxsyjj6s24d2"))

(define rust-openssl-sys-0.9.103
  ;; TODO: Check bundled sources.
  (crate-source "openssl-sys" "0.9.103"
                "1mi9r5vbgqqwfa2nqlh2m0r1v5abhzjigfbi7ja0mx0xx7p8v7kz"))

(define rust-option-ext-0.2.0
  (crate-source "option-ext" "0.2.0"
                "0zbf7cx8ib99frnlanpyikm1bx8qn8x602sw1n7bg6p9x94lyx04"))

(define rust-ordered-float-4.6.0
  (crate-source "ordered-float" "4.6.0"
                "0ldrcgilsiijd141vw51fbkziqmh5fpllil3ydhirjm67wdixdvv"))

(define rust-os-pipe-1.2.1
  (crate-source "os_pipe" "1.2.1"
                "10nrh0i507560rsiy4c79fajdmqgbr6dha2pbl9mncrlaq52pzaz"))

(define rust-overload-0.1.1
  (crate-source "overload" "0.1.1"
                "0fdgbaqwknillagy1xq7xfgv60qdbk010diwl7s1p0qx7hb16n5i"))

(define rust-parking-lot-0.12.3
  (crate-source "parking_lot" "0.12.3"
                "09ws9g6245iiq8z975h8ycf818a66q3c6zv4b5h8skpm7hc1igzi"))

(define rust-parking-lot-core-0.9.10
  (crate-source "parking_lot_core" "0.9.10"
                "1y3cf9ld9ijf7i4igwzffcn0xl16dxyn4c5bwgjck1dkgabiyh0y"))

(define rust-paste-1.0.15
  (crate-source "paste" "1.0.15"
                "02pxffpdqkapy292harq6asfjvadgp1s005fip9ljfsn9fvxgh2p"))

(define rust-percent-encoding-2.3.1
  (crate-source "percent-encoding" "2.3.1"
                "0gi8wgx0dcy8rnv1kywdv98lwcx67hz0a0zwpib5v2i08r88y573"))

(define rust-pest-2.7.15
  (crate-source "pest" "2.7.15"
                "1p4rq45xprw9cx0pb8mmbfa0ih49l0baablv3cpfdy3c1pkayz4b"))

(define rust-pest-derive-2.7.15
  (crate-source "pest_derive" "2.7.15"
                "0zpmcd1jv1c53agad5b3jb66ylxlzyv43x1bssh8fs7w3i11hrc1"))

(define rust-pest-generator-2.7.15
  (crate-source "pest_generator" "2.7.15"
                "0yrpk5ymc56pffv7gqr5rkv92p3dc6s73lb8hy1wf3w77byrc4vx"))

(define rust-pest-meta-2.7.15
  (crate-source "pest_meta" "2.7.15"
                "1skx7gm932bp77if63f7d72jrk5gygj39d8zsfzigmr5xa4q1rg1"))

(define rust-petgraph-0.6.5
  (crate-source "petgraph" "0.6.5"
                "1ns7mbxidnn2pqahbbjccxkrqkrll2i5rbxx43ns6rh6fn3cridl"))

(define rust-phf-0.11.3
  (crate-source "phf" "0.11.3"
                "0y6hxp1d48rx2434wgi5g8j1pr8s5jja29ha2b65435fh057imhz"))

(define rust-phf-codegen-0.11.3
  (crate-source "phf_codegen" "0.11.3"
                "0si1n6zr93kzjs3wah04ikw8z6npsr39jw4dam8yi9czg2609y5f"))

(define rust-phf-generator-0.11.3
  (crate-source "phf_generator" "0.11.3"
                "0gc4np7s91ynrgw73s2i7iakhb4lzdv1gcyx7yhlc0n214a2701w"))

(define rust-phf-macros-0.11.3
  (crate-source "phf_macros" "0.11.3"
                "05kjfbyb439344rhmlzzw0f9bwk9fp95mmw56zs7yfn1552c0jpq"))

(define rust-phf-shared-0.11.3
  (crate-source "phf_shared" "0.11.3"
                "1rallyvh28jqd9i916gk5gk2igdmzlgvv5q0l3xbf3m6y8pbrsk7"))

(define rust-pin-project-1.1.8
  (crate-source "pin-project" "1.1.8"
                "05jr3xfy1spgmz3q19l4mmvv46vgvkvsgphamifx7x45swxcabhy"))

(define rust-pin-project-internal-1.1.8
  (crate-source "pin-project-internal" "1.1.8"
                "1yzfhf6l27nhzv7r5hfrwj2g0x7xmfhgil19fj9am4srqp06csnm"))

(define rust-pin-project-lite-0.2.14
  (crate-source "pin-project-lite" "0.2.14"
                "00nx3f04agwjlsmd3mc5rx5haibj2v8q9b52b0kwn63wcv4nz9mx"))

(define rust-pin-utils-0.1.0
  (crate-source "pin-utils" "0.1.0"
                "117ir7vslsl2z1a7qzhws4pd01cg2d3338c47swjyvqv2n60v1wb"))

(define rust-pkg-config-0.3.30
  (crate-source "pkg-config" "0.3.30"
                "1v07557dj1sa0aly9c90wsygc0i8xv5vnmyv0g94lpkvj8qb4cfj"))

(define rust-plotters-0.3.6
  (crate-source "plotters" "0.3.6"
                "1wqwn2fdavsk6lvhcykr4nk973nflijzwi1yb8ch4h28p366wnx1"))

(define rust-plotters-backend-0.3.6
  (crate-source "plotters-backend" "0.3.6"
                "1dxdxdy31fkaqwp8bq7crbkn7kw7zs6i4mhwx80fjjk3qrifqk21"))

(define rust-plotters-svg-0.3.6
  (crate-source "plotters-svg" "0.3.6"
                "01g74kchmz4lyyv5wbzmfj2i7wi9db9bv122p08f1hyrly30dcw1"))

(define rust-pollster-0.3.0
  (crate-source "pollster" "0.3.0"
                "1wn73ljx1pcb4p69jyiz206idj7nkfqknfvdhp64yaphhm3nys12"))

(define rust-portable-atomic-1.10.0
  (crate-source "portable-atomic" "1.10.0"
                "1rjfim62djiakf5rcq3r526hac0d1dd9hwa1jmiin7q7ad2c4398"))

(define rust-ppv-lite86-0.2.20
  (crate-source "ppv-lite86" "0.2.20"
                "017ax9ssdnpww7nrl1hvqh2lzncpv04nnsibmnw9nxjnaqlpp5bp"))

(define rust-predicates-3.1.2
  (crate-source "predicates" "3.1.2"
                "15rcyjax4ykflw5425wsyzcfkgl08c9zsa8sdlsrmhj0fv68d43y"))

(define rust-predicates-core-1.0.8
  (crate-source "predicates-core" "1.0.8"
                "0c8rl6d7qkcl773fw539h61fhlgdg7v9yswwb536hpg7x2z7g0df"))

(define rust-predicates-tree-1.0.11
  (crate-source "predicates-tree" "1.0.11"
                "04zv0i9pjfrldnvyxf4y07n243nvk3n4g03w2k6nccgdjp8l1ds1"))

(define rust-pretty-assertions-1.4.1
  (crate-source "pretty_assertions" "1.4.1"
                "0v8iq35ca4rw3rza5is3wjxwsf88303ivys07anc5yviybi31q9s"))

(define rust-prettyplease-0.2.22
  (crate-source "prettyplease" "0.2.22"
                "1fpsyn4x1scbp8ik8xw4pfh4jxfm5bv7clax5k1jcd5vzd0gk727"))

(define rust-proc-macro2-1.0.94
  (crate-source "proc-macro2" "1.0.94"
                "114wxb56gdj9vy44q0ll3l2x9niqzcbyqikydmlb5f3h5rsp26d3"))

(define rust-prodash-29.0.0
  (crate-source "prodash" "29.0.0"
                "09g3zx6bhp96inzvgny7hlcqwn1ph1hmwk3hpqvs8q8c0bbdhrm2"))

(define rust-prost-0.12.6
  (crate-source "prost" "0.12.6"
                "0a8z87ir8yqjgl1kxbdj30a7pzsjs9ka85szll6i6xlb31f47cfy"))

(define rust-prost-build-0.12.6
  (crate-source "prost-build" "0.12.6"
                "1936q2grirm4rh5l26p88gbw8dijjcf4sfcn55y3p3nsjif5ll12"))

(define rust-prost-derive-0.12.6
  (crate-source "prost-derive" "0.12.6"
                "1waaq9d2f114bvvpw957s7vsx268licnfawr20b51ydb43dxrgc1"))

(define rust-prost-types-0.12.6
  (crate-source "prost-types" "0.12.6"
                "1c6mvfhz91q8a8fwada9smaxgg9w4y8l1ypj9yc8wq1j185wk4ch"))

(define rust-quote-1.0.39
  (crate-source "quote" "1.0.39"
                "00a8q2w3aacil4aqnndyv73k0x4lj55kp487k66nbq89x5693wf1"))

(define rust-rand-0.8.5
  (crate-source "rand" "0.8.5"
                "013l6931nn7gkc23jz5mm3qdhf93jjf0fg64nz2lp4i51qd8vbrl"))

(define rust-rand-chacha-0.3.1
  (crate-source "rand_chacha" "0.3.1"
                "123x2adin558xbhvqb8w4f6syjsdkmqff8cxwhmjacpsl1ihmhg6"))

(define rust-rand-core-0.6.4
  (crate-source "rand_core" "0.6.4"
                "0b4j2v4cb5krak1pv6kakv4sz6xcwbrmy2zckc32hsigbrwy82zc"))

(define rust-ratatui-0.29.0
  (crate-source "ratatui" "0.29.0"
                "0yqiccg1wmqqxpb2sz3q2v3nifmhsrfdsjgwhc2w40bqyg199gga"))

(define rust-rayon-1.10.0
  (crate-source "rayon" "1.10.0"
                "1ylgnzwgllajalr4v00y4kj22klq2jbwllm70aha232iah0sc65l"))

(define rust-rayon-core-1.12.1
  (crate-source "rayon-core" "1.12.1"
                "1qpwim68ai5h0j7axa8ai8z0payaawv3id0lrgkqmapx7lx8fr8l"))

(define rust-redox-syscall-0.5.3
  (crate-source "redox_syscall" "0.5.3"
                "1916m7abg9649gkif055pn5nsvqjhp70isy0v7gx1zgi01p8m41a"))

(define rust-redox-users-0.5.0
  (crate-source "redox_users" "0.5.0"
                "0awxx66izdw6kz97r3zxrl5ms5f6dqi5l0f58mlsvlmx8wyrsvyx"))

(define rust-ref-cast-1.0.24
  (crate-source "ref-cast" "1.0.24"
                "1kx57g118vs9sqi6d2dcxy6vp8jbx8n5hilmv1sacip9vc8y82ja"))

(define rust-ref-cast-impl-1.0.24
  (crate-source "ref-cast-impl" "1.0.24"
                "1ir7dm7hpqqdgg60hlspsc1ck6wli7wa3xcqrsxz7wdz45f24r8i"))

(define rust-regex-1.11.1
  (crate-source "regex" "1.11.1"
                "148i41mzbx8bmq32hsj1q4karkzzx5m60qza6gdw4pdc9qdyyi5m"))

(define rust-regex-automata-0.1.10
  (crate-source "regex-automata" "0.1.10"
                "0ci1hvbzhrfby5fdpf4ganhf7kla58acad9i1ff1p34dzdrhs8vc"))

(define rust-regex-automata-0.4.8
  (crate-source "regex-automata" "0.4.8"
                "18wd530ndrmygi6xnz3sp345qi0hy2kdbsa89182nwbl6br5i1rn"))

(define rust-regex-syntax-0.6.29
  (crate-source "regex-syntax" "0.6.29"
                "1qgj49vm6y3zn1hi09x91jvgkl2b1fiaq402skj83280ggfwcqpi"))

(define rust-regex-syntax-0.8.5
  (crate-source "regex-syntax" "0.8.5"
                "0p41p3hj9ww7blnbwbj9h7rwxzxg0c1hvrdycgys8rxyhqqw859b"))

(define rust-roff-0.2.2
  (crate-source "roff" "0.2.2"
                "1wyqz6m0pm4p6wzhwhahvcidfm7nwb38zl4q7ha940pn3w66dy48"))

(define rust-rpassword-7.3.1
  (crate-source "rpassword" "7.3.1"
                "0gvy3lcpph9vv1rl0cjfn72ylvmgbw2vklmj6w0iv4cpr3ijniw0"))

(define rust-rtoolbox-0.0.2
  (crate-source "rtoolbox" "0.0.2"
                "03n9z8x353kylxhr9im8zawcisnmid3jiqrs8rbdn313cd7d4iy2"))

(define rust-rustc-demangle-0.1.24
  (crate-source "rustc-demangle" "0.1.24"
                "07zysaafgrkzy2rjgwqdj2a8qdpsm6zv6f5pgpk9x0lm40z9b6vi"))

(define rust-rustix-0.38.44
  (crate-source "rustix" "0.38.44"
                "0m61v0h15lf5rrnbjhcb9306bgqrhskrqv7i1n0939dsw8dbrdgx"))

(define rust-rustix-1.0.1
  (crate-source "rustix" "1.0.1"
                "0mznc6mzxgrm5b9aw0alji956mb2q7cgrrav8w8lff2wvw94ipns"))

(define rust-rustversion-1.0.17
  (crate-source "rustversion" "1.0.17"
                "1mm3fckyvb0l2209in1n2k05sws5d9mpkszbnwhq3pkq8apjhpcm"))

(define rust-ryu-1.0.18
  (crate-source "ryu" "1.0.18"
                "17xx2s8j1lln7iackzd9p0sv546vjq71i779gphjq923vjh5pjzk"))

(define rust-same-file-1.0.6
  (crate-source "same-file" "1.0.6"
                "00h5j1w87dmhnvbv9l8bic3y7xxsnjmssvifw2ayvgx9mb1ivz4k"))

(define rust-sapling-renderdag-0.1.0
  (crate-source "sapling-renderdag" "0.1.0"
                "0qbv8k698kiz8rpr63hn0m7g789pbmpmg7blql0hkgc7mffbizzd"))

(define rust-sapling-streampager-0.11.0
  (crate-source "sapling-streampager" "0.11.0"
                "14ns7a8lmsvnn3kpcs3vdfj7f9ya9pfzbwzgh902sghzhkh5l8k7"))

(define rust-scanlex-0.1.4
  (crate-source "scanlex" "0.1.4"
                "1nrkq1kjwf3v084pndiq18yx6vqsivlqr6jllyg94911axqmv308"))

(define rust-scm-record-0.5.0
  (crate-source "scm-record" "0.5.0"
                "0mn2w81s3890a3lqv4pl7gx1yibdh80iaa0wgpnqa8pv2ldmq5n2"))

(define rust-scopeguard-1.2.0
  (crate-source "scopeguard" "1.2.0"
                "0jcz9sd47zlsgcnm1hdw0664krxwb5gczlif4qngj2aif8vky54l"))

(define rust-serde-1.0.218
  (crate-source "serde" "1.0.218"
                "0q6z4bnrwagnms0bds4886711l6mc68s979i49zd3xnvkg8wkpz8"))

(define rust-serde-bser-0.4.0
  (crate-source "serde_bser" "0.4.0"
                "05w7iyrm8xrinnqh6b7ydxnd707g5dc7avvcw5d5nbp42p64nsx5"))

(define rust-serde-bytes-0.11.15
  (crate-source "serde_bytes" "0.11.15"
                "0sjwczchd9p4ak4m644jpkv4r181zr8yj14fdjll1fq6rc2caz1q"))

(define rust-serde-derive-1.0.218
  (crate-source "serde_derive" "1.0.218"
                "0azqd74xbpb1v5vf6w1fdbgmwp39ljjfj25cib5rgrzlj7hh75gh"))

(define rust-serde-json-1.0.140
  (crate-source "serde_json" "1.0.140"
                "0wwkp4vc20r87081ihj3vpyz5qf7wqkqipq17v99nv6wjrp8n1i0"))

(define rust-serde-spanned-0.6.8
  (crate-source "serde_spanned" "0.6.8"
                "1q89g70azwi4ybilz5jb8prfpa575165lmrffd49vmcf76qpqq47"))

(define rust-sha1-0.10.6
  (crate-source "sha1" "0.10.6"
                "1fnnxlfg08xhkmwf2ahv634as30l1i3xhlhkvxflmasi5nd85gz3"))

(define rust-sha1-asm-0.5.3
  (crate-source "sha1-asm" "0.5.3"
                "0asqxlxf5li7ac9mi49qj890rzsfb5px5ynzmqq12z5nz2xcwsi8"))

(define rust-sha1-smol-1.0.1
  (crate-source "sha1_smol" "1.0.1"
                "0pbh2xjfnzgblws3hims0ib5bphv7r5rfdpizyh51vnzvnribymv"))

(define rust-sha2-0.10.8
  (crate-source "sha2" "0.10.8"
                "1j1x78zk9il95w9iv46dh9wm73r6xrgj32y6lzzw7bxws9dbfgbr"))

(define rust-sharded-slab-0.1.7
  (crate-source "sharded-slab" "0.1.7"
                "1xipjr4nqsgw34k7a2cgj9zaasl2ds6jwn89886kww93d32a637l"))

(define rust-shell-words-1.1.0
  (crate-source "shell-words" "1.1.0"
                "1plgwx8r0h5ismbbp6cp03740wmzgzhip85k5hxqrrkaddkql614"))

(define rust-shlex-1.3.0
  (crate-source "shlex" "1.3.0"
                "0r1y6bv26c1scpxvhg2cabimrmwgbp4p3wy6syj9n0c4s3q2znhg"))

(define rust-signal-hook-0.3.17
  (crate-source "signal-hook" "0.3.17"
                "0098nsah04spqf3n8niirmfym4wsdgjl57c78kmzijlq8xymh8c6"))

(define rust-signal-hook-mio-0.2.4
  (crate-source "signal-hook-mio" "0.2.4"
                "1k8pl9aafiadr4czsg8zal9b4jdk6kq5985p90i19jc5sh31mnrl"))

(define rust-signal-hook-registry-1.4.2
  (crate-source "signal-hook-registry" "1.4.2"
                "1cb5akgq8ajnd5spyn587srvs4n26ryq0p78nswffwhv46sf1sd9"))

(define rust-similar-2.6.0
  (crate-source "similar" "2.6.0"
                "0vk89dx2mmjp81pmszsa1s3mpzvbiy4krvfbq3s3mc3k27wd9q8x"))

(define rust-siphasher-0.3.11
  (crate-source "siphasher" "0.3.11"
                "03axamhmwsrmh0psdw3gf7c0zc4fyl5yjxfifz9qfka6yhkqid9q"))

(define rust-siphasher-1.0.1
  (crate-source "siphasher" "1.0.1"
                "17f35782ma3fn6sh21c027kjmd227xyrx06ffi8gw4xzv9yry6an"))

(define rust-slab-0.4.9
  (crate-source "slab" "0.4.9"
                "0rxvsgir0qw5lkycrqgb1cxsvxzjv9bmx73bk5y42svnzfba94lg"))

(define rust-smallvec-1.14.0
  (crate-source "smallvec" "1.14.0"
                "1z8wpr53x6jisklqhkkvkgyi8s5cn69h2d2alhqfxahzxwiq7kvz"))

(define rust-smawk-0.3.2
  (crate-source "smawk" "0.3.2"
                "0344z1la39incggwn6nl45k8cbw2x10mr5j0qz85cdz9np0qihxp"))

(define rust-socket2-0.5.7
  (crate-source "socket2" "0.5.7"
                "070r941wbq76xpy039an4pyiy3rfj7mp7pvibf1rcri9njq5wc6f"))

(define rust-stable-deref-trait-1.2.0
  (crate-source "stable_deref_trait" "1.2.0"
                "1lxjr8q2n534b2lhkxd6l6wcddzjvnksi58zv11f9y0jjmr15wd8"))

(define rust-static-assertions-1.1.0
  (crate-source "static_assertions" "1.1.0"
                "0gsl6xmw10gvn3zs1rv99laj5ig7ylffnh71f9l34js4nr4r7sx2"))

(define rust-strsim-0.11.1
  (crate-source "strsim" "0.11.1"
                "0kzvqlw8hxqb7y598w1s0hxlnmi84sg5vsipp3yg5na5d1rvba3x"))

(define rust-strum-0.26.3
  (crate-source "strum" "0.26.3"
                "01lgl6jvrf4j28v5kmx9bp480ygf1nhvac8b4p7rcj9hxw50zv4g"))

(define rust-strum-macros-0.26.4
  (crate-source "strum_macros" "0.26.4"
                "1gl1wmq24b8md527cpyd5bw9rkbqldd7k1h38kf5ajd2ln2ywssc"))

(define rust-subtle-2.6.1
  (crate-source "subtle" "2.6.1"
                "14ijxaymghbl1p0wql9cib5zlwiina7kall6w7g89csprkgbvhhk"))

(define rust-syn-1.0.109
  (crate-source "syn" "1.0.109"
                "0ds2if4600bd59wsv7jjgfkayfzy3hnazs394kz6zdkmna8l3dkj"))

(define rust-syn-2.0.99
  (crate-source "syn" "2.0.99"
                "1hizbzkwa6wgi77x9ck45p3fshrwfmj448qfcjfzv3z1h5994bp0"))

(define rust-synstructure-0.13.1
  (crate-source "synstructure" "0.13.1"
                "0wc9f002ia2zqcbj0q2id5x6n7g1zjqba7qkg2mr0qvvmdk7dby8"))

(define rust-tempfile-3.18.0
  (crate-source "tempfile" "3.18.0"
                "0rz5y2qjz3mwpca8j5kg9fr65jmdinf27bdbil6i5rkfa857wc9c"))

(define rust-terminal-size-0.4.0
  (crate-source "terminal_size" "0.4.0"
                "1vx6a5klj7sjkx59v78gh93j445s09y2fasiykwgsb04rbbrnnag"))

(define rust-terminfo-0.9.0
  (crate-source "terminfo" "0.9.0"
                "0qp6rrzkxcg08vjzsim2bw7mid3vi29mizrg70dzbycj0q7q3snl"))

(define rust-termios-0.3.3
  (crate-source "termios" "0.3.3"
                "0sxcs0g00538jqh5xbdqakkzijadr8nj7zmip0c7jz3k83vmn721"))

(define rust-termtree-0.4.1
  (crate-source "termtree" "0.4.1"
                "0xkal5l2r3r9p9j90x35qy4npbdwxz4gskvbijs6msymaangas9k"))

(define rust-termwiz-0.23.0
  (crate-source "termwiz" "0.23.0"
                "0925nsy4j35qx0sppr7fixf8wh1pyyp3xc20hv5kf6g859wsycpd"))

(define rust-test-case-3.3.1
  (crate-source "test-case" "3.3.1"
                "1a380yzm6787737cw7s09jqmkn9035hghahradl2ikdg2gfm09gb"))

(define rust-test-case-core-3.3.1
  (crate-source "test-case-core" "3.3.1"
                "0krqi0gbi1yyycigyjlak63r8h1n0vms7mg3kckqwlfd87c7zjxd"))

(define rust-test-case-macros-3.3.1
  (crate-source "test-case-macros" "3.3.1"
                "1yvgky3qax73bic6m368q04xc955p4a91mddd6b5fk7d04mfg2aw"))

(define rust-textwrap-0.16.2
  (crate-source "textwrap" "0.16.2"
                "0mrhd8q0dnh5hwbwhiv89c6i41yzmhw4clwa592rrp24b9hlfdf1"))

(define rust-thiserror-1.0.69
  (crate-source "thiserror" "1.0.69"
                "0lizjay08agcr5hs9yfzzj6axs53a2rgx070a1dsi3jpkcrzbamn"))

(define rust-thiserror-2.0.12
  (crate-source "thiserror" "2.0.12"
                "024791nsc0np63g2pq30cjf9acj38z3jwx9apvvi8qsqmqnqlysn"))

(define rust-thiserror-impl-1.0.69
  (crate-source "thiserror-impl" "1.0.69"
                "1h84fmn2nai41cxbhk6pqf46bxqq1b344v8yz089w1chzi76rvjg"))

(define rust-thiserror-impl-2.0.12
  (crate-source "thiserror-impl" "2.0.12"
                "07bsn7shydaidvyyrm7jz29vp78vrxr9cr9044rfmn078lmz8z3z"))

(define rust-thread-local-1.1.8
  (crate-source "thread_local" "1.1.8"
                "173i5lyjh011gsimk21np9jn8al18rxsrkjli20a7b8ks2xgk7lb"))

(define rust-timeago-0.4.2
  (crate-source "timeago" "0.4.2"
                "1rnh92sh1l4jbjvz4g7xvcvmfh7nk5k7mm2w56pnm9z0kmc0wwd1"))

(define rust-tinystr-0.7.6
  (crate-source "tinystr" "0.7.6"
                "0bxqaw7z8r2kzngxlzlgvld1r6jbnwyylyvyjbv1q71rvgaga5wi"))

(define rust-tinytemplate-1.2.1
  (crate-source "tinytemplate" "1.2.1"
                "1g5n77cqkdh9hy75zdb01adxn45mkh9y40wdr7l68xpz35gnnkdy"))

(define rust-tinyvec-1.8.0
  (crate-source "tinyvec" "1.8.0"
                "0f5rf6a2wzyv6w4jmfga9iw7rp9fp5gf4d604xgjsf3d9wgqhpj4"))

(define rust-tinyvec-macros-0.1.1
  (crate-source "tinyvec_macros" "0.1.1"
                "081gag86208sc3y6sdkshgw3vysm5d34p431dzw0bshz66ncng0z"))

(define rust-tokio-1.44.0
  (crate-source "tokio" "1.44.0"
                "0fpv4c8dyp5jh55kf69arhvq8ic2h4iqr21dpxr3kamm907ylxcr"))

(define rust-tokio-macros-2.5.0
  (crate-source "tokio-macros" "2.5.0"
                "1f6az2xbvqp7am417b78d1za8axbvjvxnmkakz9vr8s52czx81kf"))

(define rust-tokio-util-0.6.10
  (crate-source "tokio-util" "0.6.10"
                "01v5zkcxjdd5zaniqxxfl6isvd7y5qfmljpqsdyrfrvd3bh3x51n"))

(define rust-toml-0.8.19
  (crate-source "toml" "0.8.19"
                "0knjd3mkxyb87qcs2dark3qkpadidap3frqfj5nqvhpxwfc1zvd1"))

(define rust-toml-datetime-0.6.8
  (crate-source "toml_datetime" "0.6.8"
                "0hgv7v9g35d7y9r2afic58jvlwnf73vgd1mz2k8gihlgrf73bmqd"))

(define rust-toml-edit-0.22.24
  (crate-source "toml_edit" "0.22.24"
                "0x0lgp70x5cl9nla03xqs5vwwwlrwmd0djkdrp3h3lpdymgpkd0p"))

(define rust-tracing-0.1.41
  (crate-source "tracing" "0.1.41"
                "1l5xrzyjfyayrwhvhldfnwdyligi1mpqm8mzbi2m1d6y6p2hlkkq"))

(define rust-tracing-attributes-0.1.28
  (crate-source "tracing-attributes" "0.1.28"
                "0v92l9cxs42rdm4m5hsa8z7ln1xsiw1zc2iil8c6k7lzq0jf2nir"))

(define rust-tracing-chrome-0.7.2
  (crate-source "tracing-chrome" "0.7.2"
                "0977zy46gpawva2laffigxr2pph8v0xa51kfp6ghlifnsn7762mz"))

(define rust-tracing-core-0.1.33
  (crate-source "tracing-core" "0.1.33"
                "170gc7cxyjx824r9kr17zc9gvzx89ypqfdzq259pr56gg5bwjwp6"))

(define rust-tracing-log-0.2.0
  (crate-source "tracing-log" "0.2.0"
                "1hs77z026k730ij1a9dhahzrl0s073gfa2hm5p0fbl0b80gmz1gf"))

(define rust-tracing-subscriber-0.3.19
  (crate-source "tracing-subscriber" "0.3.19"
                "0220rignck8072i89jjsh140vmh14ydwpdwnifyaf3xcnpn9s678"))

(define rust-typenum-1.17.0
  (crate-source "typenum" "1.17.0"
                "09dqxv69m9lj9zvv6xw5vxaqx15ps0vxyy5myg33i0kbqvq0pzs2"))

(define rust-ucd-trie-0.1.6
  (crate-source "ucd-trie" "0.1.6"
                "1ff4yfksirqs37ybin9aw71aa5gva00hw7jdxbw8w668zy964r7d"))

(define rust-uluru-3.1.0
  (crate-source "uluru" "3.1.0"
                "1njp6vvy1mm8idnsp6ljyxx5znfsk3xkmk9cr2am0vkfwmlj92kw"))

(define rust-unicode-bom-2.0.3
  (crate-source "unicode-bom" "2.0.3"
                "05s2sqyjanqrbds3fxam35f92npp5ci2wz9zg7v690r0448mvv3y"))

(define rust-unicode-ident-1.0.12
  (crate-source "unicode-ident" "1.0.12"
                "0jzf1znfpb2gx8nr8mvmyqs1crnv79l57nxnbiszc7xf7ynbjm1k"))

(define rust-unicode-linebreak-0.1.5
  (crate-source "unicode-linebreak" "0.1.5"
                "07spj2hh3daajg335m4wdav6nfkl0f6c0q72lc37blr97hych29v"))

(define rust-unicode-normalization-0.1.23
  (crate-source "unicode-normalization" "0.1.23"
                "1x81a50h2zxigj74b9bqjsirxxbyhmis54kg600xj213vf31cvd5"))

(define rust-unicode-segmentation-1.12.0
  (crate-source "unicode-segmentation" "1.12.0"
                "14qla2jfx74yyb9ds3d2mpwpa4l4lzb9z57c6d2ba511458z5k7n"))

(define rust-unicode-truncate-1.1.0
  (crate-source "unicode-truncate" "1.1.0"
                "1gr7arjjhrhy8dww7hj8qqlws97xf9d276svr4hs6pxgllklcr5k"))

(define rust-unicode-width-0.1.12
  (crate-source "unicode-width" "0.1.12"
                "1mk6mybsmi5py8hf8zy9vbgs4rw4gkdqdq3gzywd9kwf2prybxb8"))

(define rust-unicode-width-0.2.0
  (crate-source "unicode-width" "0.2.0"
                "1zd0r5vs52ifxn25rs06gxrgz8cmh4xpra922k0xlmrchib1kj0z"))

(define rust-url-2.5.4
  (crate-source "url" "2.5.4"
                "0q6sgznyy2n4l5lm16zahkisvc9nip9aa5q1pps7656xra3bdy1j"))

(define rust-utf16-iter-1.0.5
  (crate-source "utf16_iter" "1.0.5"
                "0ik2krdr73hfgsdzw0218fn35fa09dg2hvbi1xp3bmdfrp9js8y8"))

(define rust-utf8-iter-1.0.4
  (crate-source "utf8_iter" "1.0.4"
                "1gmna9flnj8dbyd8ba17zigrp9c4c3zclngf5lnb5yvz1ri41hdn"))

(define rust-utf8parse-0.2.2
  (crate-source "utf8parse" "0.2.2"
                "088807qwjq46azicqwbhlmzwrbkz7l4hpw43sdkdyyk524vdxaq6"))

(define rust-uuid-1.11.1
  (crate-source "uuid" "1.11.1"
                "1i2nlxkzfxsi0bz33z28ny4szk0r8fv65k33klk2w544zsss64xr"))

(define rust-valuable-0.1.0
  (crate-source "valuable" "0.1.0"
                "0v9gp3nkjbl30z0fd56d8mx7w1csk86wwjhfjhr400wh9mfpw2w3"))

(define rust-vcpkg-0.2.15
  (crate-source "vcpkg" "0.2.15"
                "09i4nf5y8lig6xgj3f7fyrvzd3nlaw4znrihw8psidvv5yk4xkdc"))

(define rust-vec-map-0.8.2
  (crate-source "vec_map" "0.8.2"
                "1481w9g1dw9rxp3l6snkdqihzyrd2f8vispzqmwjwsdyhw8xzggi"))

(define rust-version-check-0.9.5
  (crate-source "version_check" "0.9.5"
                "0nhhi4i5x89gm911azqbn7avs9mdacw2i3vcz3cnmz3mv4rqz4hb"))

(define rust-vtparse-0.6.2
  (crate-source "vtparse" "0.6.2"
                "1l5yz9650zhkaffxn28cvfys7plcw2wd6drajyf41pshn37jm6vd"))

(define rust-wait-timeout-0.2.0
  (crate-source "wait-timeout" "0.2.0"
                "1xpkk0j5l9pfmjfh1pi0i89invlavfrd9av5xp0zhxgb29dhy84z"))

(define rust-walkdir-2.5.0
  (crate-source "walkdir" "2.5.0"
                "0jsy7a710qv8gld5957ybrnc07gavppp963gs32xk4ag8130jy99"))

(define rust-wasi-0.11.0+wasi-snapshot-preview1
  (crate-source "wasi" "0.11.0+wasi-snapshot-preview1"
                "08z4hxwkpdpalxjps1ai9y7ihin26y9f476i53dv98v45gkqg3cw"))

(define rust-wasi-0.13.3+wasi-0.2.2
  (crate-source "wasi" "0.13.3+wasi-0.2.2"
                "1lnapbvdcvi3kc749wzqvwrpd483win2kicn1faa4dja38p6v096"))

(define rust-wasite-0.1.0
  (crate-source "wasite" "0.1.0"
                "0nw5h9nmcl4fyf4j5d4mfdjfgvwi1cakpi349wc4zrr59wxxinmq"))

(define rust-wasm-bindgen-0.2.93
  (crate-source "wasm-bindgen" "0.2.93"
                "1dfr7pka5kwvky2fx82m9d060p842hc5fyyw8igryikcdb0xybm8"))

(define rust-wasm-bindgen-backend-0.2.93
  (crate-source "wasm-bindgen-backend" "0.2.93"
                "0yypblaf94rdgqs5xw97499xfwgs1096yx026d6h88v563d9dqwx"))

(define rust-wasm-bindgen-macro-0.2.93
  (crate-source "wasm-bindgen-macro" "0.2.93"
                "1kycd1xfx4d9xzqknvzbiqhwb5fzvjqrrn88x692q1vblj8lqp2q"))

(define rust-wasm-bindgen-macro-support-0.2.93
  (crate-source "wasm-bindgen-macro-support" "0.2.93"
                "0dp8w6jmw44srym6l752nkr3hkplyw38a2fxz5f3j1ch9p3l1hxg"))

(define rust-wasm-bindgen-shared-0.2.93
  (crate-source "wasm-bindgen-shared" "0.2.93"
                "1104bny0hv40jfap3hp8jhs0q4ya244qcrvql39i38xlghq0lan6"))

(define rust-watchman-client-0.9.0
  (crate-source "watchman_client" "0.9.0"
                "0lpvdkvf500cr6454c722m9q15y3zxxq19sg1phsm9s3njdlrg48"))

(define rust-web-sys-0.3.70
  ;; TODO: Check bundled sources.
  (crate-source "web-sys" "0.3.70"
                "1h1jspkqnrx1iybwhwhc3qq8c8fn4hy5jcf0wxjry4mxv6pymz96"))

(define rust-wezterm-bidi-0.2.3
  (crate-source "wezterm-bidi" "0.2.3"
                "1v7kwmnxfplv9kgdmamn6csbn2ag5xjr0y6gs797slk0alsnw2hc"))

(define rust-wezterm-blob-leases-0.1.0
  (crate-source "wezterm-blob-leases" "0.1.0"
                "02z6m7p9vf4wvr9g2qv1kxp6zaxxli4ziphhcjbnivbyvw55wnlf"))

(define rust-wezterm-color-types-0.3.0
  (crate-source "wezterm-color-types" "0.3.0"
                "15j29f60p1dc0msx50x940niyv9d5zpynavpcc6jf44hbkrixs3x"))

(define rust-wezterm-dynamic-0.2.1
  (crate-source "wezterm-dynamic" "0.2.1"
                "1b6mrk09xxiz66dj3912kmiq8rl7dqig6rwminkfmmhg287bcajz"))

(define rust-wezterm-dynamic-derive-0.1.1
  (crate-source "wezterm-dynamic-derive" "0.1.1"
                "0nspip7gwzmfn66fbnbpa2yik2sb97nckzmgir25nr4wacnwzh26"))

(define rust-wezterm-input-types-0.1.0
  (crate-source "wezterm-input-types" "0.1.0"
                "0zp557014d458a69yqn9dxfy270b6kyfdiynr5p4algrb7aas4kh"))

(define rust-whoami-1.5.2
  (crate-source "whoami" "1.5.2"
                "0vdvm6sga4v9515l6glqqfnmzp246nq66dd09cw5ri4fyn3mnb9p"))

(define rust-winapi-0.3.9
  (crate-source "winapi" "0.3.9"
                "06gl025x418lchw1wxj64ycr7gha83m44cjr5sarhynd9xkrm0sw"))

(define rust-winapi-i686-pc-windows-gnu-0.4.0
  (crate-source "winapi-i686-pc-windows-gnu" "0.4.0"
                "1dmpa6mvcvzz16zg6d5vrfy4bxgg541wxrcip7cnshi06v38ffxc"))

(define rust-winapi-util-0.1.9
  (crate-source "winapi-util" "0.1.9"
                "1fqhkcl9scd230cnfj8apfficpf5c9vhwnk4yy9xfc1sw69iq8ng"))

(define rust-winapi-x86-64-pc-windows-gnu-0.4.0
  (crate-source "winapi-x86_64-pc-windows-gnu" "0.4.0"
                "0gqq64czqb64kskjryj8isp62m2sgvx25yyj3kpc2myh85w24bki"))

(define rust-windows-aarch64-gnullvm-0.48.5
  (crate-source "windows_aarch64_gnullvm" "0.48.5"
                "1n05v7qblg1ci3i567inc7xrkmywczxrs1z3lj3rkkxw18py6f1b"))

(define rust-windows-aarch64-gnullvm-0.52.6
  (crate-source "windows_aarch64_gnullvm" "0.52.6"
                "1lrcq38cr2arvmz19v32qaggvj8bh1640mdm9c2fr877h0hn591j"))

(define rust-windows-aarch64-msvc-0.48.5
  (crate-source "windows_aarch64_msvc" "0.48.5"
                "1g5l4ry968p73g6bg6jgyvy9lb8fyhcs54067yzxpcpkf44k2dfw"))

(define rust-windows-aarch64-msvc-0.52.6
  (crate-source "windows_aarch64_msvc" "0.52.6"
                "0sfl0nysnz32yyfh773hpi49b1q700ah6y7sacmjbqjjn5xjmv09"))

(define rust-windows-core-0.52.0
  (crate-source "windows-core" "0.52.0"
                "1nc3qv7sy24x0nlnb32f7alzpd6f72l4p24vl65vydbyil669ark"))

(define rust-windows-i686-gnu-0.48.5
  (crate-source "windows_i686_gnu" "0.48.5"
                "0gklnglwd9ilqx7ac3cn8hbhkraqisd0n83jxzf9837nvvkiand7"))

(define rust-windows-i686-gnu-0.52.6
  (crate-source "windows_i686_gnu" "0.52.6"
                "02zspglbykh1jh9pi7gn8g1f97jh1rrccni9ivmrfbl0mgamm6wf"))

(define rust-windows-i686-gnullvm-0.52.6
  (crate-source "windows_i686_gnullvm" "0.52.6"
                "0rpdx1537mw6slcpqa0rm3qixmsb79nbhqy5fsm3q2q9ik9m5vhf"))

(define rust-windows-i686-msvc-0.48.5
  (crate-source "windows_i686_msvc" "0.48.5"
                "01m4rik437dl9rdf0ndnm2syh10hizvq0dajdkv2fjqcywrw4mcg"))

(define rust-windows-i686-msvc-0.52.6
  (crate-source "windows_i686_msvc" "0.52.6"
                "0rkcqmp4zzmfvrrrx01260q3xkpzi6fzi2x2pgdcdry50ny4h294"))

(define rust-windows-link-0.1.0
  (crate-source "windows-link" "0.1.0"
                "1qr0srnkw148wbrws3726pm640h2vxgcdlxn0cxpbcg27irzvk3d"))

(define rust-windows-sys-0.48.0
  ;; TODO: Check bundled sources.
  (crate-source "windows-sys" "0.48.0"
                "1aan23v5gs7gya1lc46hqn9mdh8yph3fhxmhxlw36pn6pqc28zb7"))

(define rust-windows-sys-0.52.0
  ;; TODO: Check bundled sources.
  (crate-source "windows-sys" "0.52.0"
                "0gd3v4ji88490zgb6b5mq5zgbvwv7zx1ibn8v3x83rwcdbryaar8"))

(define rust-windows-sys-0.59.0
  ;; TODO: Check bundled sources.
  (crate-source "windows-sys" "0.59.0"
                "0fw5672ziw8b3zpmnbp9pdv1famk74f1l9fcbc3zsrzdg56vqf0y"))

(define rust-windows-targets-0.48.5
  (crate-source "windows-targets" "0.48.5"
                "034ljxqshifs1lan89xwpcy1hp0lhdh4b5n0d2z4fwjx2piacbws"))

(define rust-windows-targets-0.52.6
  (crate-source "windows-targets" "0.52.6"
                "0wwrx625nwlfp7k93r2rra568gad1mwd888h1jwnl0vfg5r4ywlv"))

(define rust-windows-x86-64-gnu-0.48.5
  (crate-source "windows_x86_64_gnu" "0.48.5"
                "13kiqqcvz2vnyxzydjh73hwgigsdr2z1xpzx313kxll34nyhmm2k"))

(define rust-windows-x86-64-gnu-0.52.6
  (crate-source "windows_x86_64_gnu" "0.52.6"
                "0y0sifqcb56a56mvn7xjgs8g43p33mfqkd8wj1yhrgxzma05qyhl"))

(define rust-windows-x86-64-gnullvm-0.48.5
  (crate-source "windows_x86_64_gnullvm" "0.48.5"
                "1k24810wfbgz8k48c2yknqjmiigmql6kk3knmddkv8k8g1v54yqb"))

(define rust-windows-x86-64-gnullvm-0.52.6
  (crate-source "windows_x86_64_gnullvm" "0.52.6"
                "03gda7zjx1qh8k9nnlgb7m3w3s1xkysg55hkd1wjch8pqhyv5m94"))

(define rust-windows-x86-64-msvc-0.48.5
  (crate-source "windows_x86_64_msvc" "0.48.5"
                "0f4mdp895kkjh9zv8dxvn4pc10xr7839lf5pa9l0193i2pkgr57d"))

(define rust-windows-x86-64-msvc-0.52.6
  (crate-source "windows_x86_64_msvc" "0.52.6"
                "1v7rb5cibyzx8vak29pdrk8nx9hycsjs4w0jgms08qk49jl6v7sq"))

(define rust-winnow-0.6.18
  (crate-source "winnow" "0.6.18"
                "0vrsrnf2nm9jsk1161x1vacmi3ns4h3h10fib91rs28zd6jbvab8"))

(define rust-winnow-0.7.0
  (crate-source "winnow" "0.7.0"
                "06948rqffp1iww8rr2wm12gkakzvxhvr04wlkfrnkb9zbp9x4jby"))

(define rust-winreg-0.52.0
  (crate-source "winreg" "0.52.0"
                "19gh9vp7mp1ab84kc3ag48nm9y7xgjhh3xa4vxss1gylk1rsaxx2"))

(define rust-wit-bindgen-rt-0.33.0
  (crate-source "wit-bindgen-rt" "0.33.0"
                "0g4lwfp9x6a2i1hgjn8k14nr4fsnpd5izxhc75zpi2s5cvcg6s1j"))

(define rust-write16-1.0.0
  (crate-source "write16" "1.0.0"
                "0dnryvrrbrnl7vvf5vb1zkmwldhjkf2n5znliviam7bm4900z2fi"))

(define rust-writeable-0.5.5
  (crate-source "writeable" "0.5.5"
                "0lawr6y0bwqfyayf3z8zmqlhpnzhdx0ahs54isacbhyjwa7g778y"))

(define rust-yansi-1.0.1
  (crate-source "yansi" "1.0.1"
                "0jdh55jyv0dpd38ij4qh60zglbw9aa8wafqai6m0wa7xaxk3mrfg"))

(define rust-yoke-0.7.5
  (crate-source "yoke" "0.7.5"
                "0h3znzrdmll0a7sglzf9ji0p5iqml11wrj1dypaf6ad6kbpnl3hj"))

(define rust-yoke-derive-0.7.5
  (crate-source "yoke-derive" "0.7.5"
                "0m4i4a7gy826bfvnqa9wy6sp90qf0as3wps3wb0smjaamn68g013"))

(define rust-zerocopy-0.7.35
  (crate-source "zerocopy" "0.7.35"
                "1w36q7b9il2flg0qskapgi9ymgg7p985vniqd09vi0mwib8lz6qv"))

(define rust-zerocopy-derive-0.7.35
  (crate-source "zerocopy-derive" "0.7.35"
                "0gnf2ap2y92nwdalzz3x7142f2b83sni66l39vxp2ijd6j080kzs"))

(define rust-zerofrom-0.1.5
  (crate-source "zerofrom" "0.1.5"
                "0bnd8vjcllzrvr3wvn8x14k2hkrpyy1fm3crkn2y3plmr44fxwyg"))

(define rust-zerofrom-derive-0.1.5
  (crate-source "zerofrom-derive" "0.1.5"
                "022q55phhb44qbrcfbc48k0b741fl8gnazw3hpmmndbx5ycfspjr"))

(define rust-zerovec-0.10.4
  (crate-source "zerovec" "0.10.4"
                "0yghix7n3fjfdppwghknzvx9v8cf826h2qal5nqvy8yzg4yqjaxa"))

(define rust-zerovec-derive-0.10.3
  (crate-source "zerovec-derive" "0.10.3"
                "1ik322dys6wnap5d3gcsn09azmssq466xryn5czfm13mn7gsdbvf"))

(define-public jujutsu-cargo-inputs
  (list rust-addr2line-0.22.0
        rust-adler-1.0.2
        rust-adler2-2.0.0
        rust-ahash-0.8.11
        rust-aho-corasick-1.1.3
        rust-allocator-api2-0.2.18
        rust-android-tzdata-0.1.1
        rust-android-system-properties-0.1.5
        rust-anes-0.1.6
        rust-anstream-0.6.15
        rust-anstyle-1.0.8
        rust-anstyle-parse-0.2.5
        rust-anstyle-query-1.1.1
        rust-anstyle-wincon-3.0.4
        rust-anyhow-1.0.97
        rust-arc-swap-1.7.1
        rust-arrayvec-0.7.6
        rust-assert-cmd-2.0.16
        rust-assert-matches-1.5.0
        rust-async-trait-0.1.87
        rust-atomic-0.6.0
        rust-autocfg-1.3.0
        rust-backtrace-0.3.73
        rust-base64-0.21.7
        rust-bit-set-0.5.3
        rust-bit-vec-0.6.3
        rust-bitflags-1.3.2
        rust-bitflags-2.6.0
        rust-blake2-0.10.6
        rust-block-buffer-0.10.4
        rust-bstr-1.11.3
        rust-bumpalo-3.16.0
        rust-bytemuck-1.21.0
        rust-byteorder-1.5.0
        rust-bytes-1.7.1
        rust-cassowary-0.3.0
        rust-cast-0.3.0
        rust-castaway-0.2.3
        rust-cc-1.1.16
        rust-cfg-if-1.0.0
        rust-cfg-aliases-0.1.1
        rust-chrono-0.4.40
        rust-chrono-english-0.1.7
        rust-ciborium-0.2.2
        rust-ciborium-io-0.2.2
        rust-ciborium-ll-0.2.2
        rust-clap-4.5.31
        rust-clap-markdown-0.1.4
        rust-clap-builder-4.5.31
        rust-clap-complete-4.5.46
        rust-clap-complete-nushell-4.5.5
        rust-clap-derive-4.5.28
        rust-clap-lex-0.7.4
        rust-clap-mangen-0.2.25
        rust-clru-0.6.2
        rust-cmake-0.1.52
        rust-colorchoice-1.0.2
        rust-compact-str-0.8.1
        rust-console-0.15.8
        rust-core-foundation-sys-0.8.7
        rust-cpufeatures-0.2.14
        rust-crc32fast-1.4.2
        rust-criterion-0.5.1
        rust-criterion-plot-0.5.0
        rust-crossbeam-channel-0.5.13
        rust-crossbeam-deque-0.8.5
        rust-crossbeam-epoch-0.9.18
        rust-crossbeam-utils-0.8.20
        rust-crossterm-0.28.1
        rust-crossterm-winapi-0.9.1
        rust-crunchy-0.2.2
        rust-crypto-common-0.1.6
        rust-csscolorparser-0.6.2
        rust-darling-0.20.10
        rust-darling-core-0.20.10
        rust-darling-macro-0.20.10
        rust-dashmap-6.1.0
        rust-deltae-0.3.2
        rust-diff-0.1.13
        rust-difflib-0.4.0
        rust-digest-0.10.7
        rust-dirs-6.0.0
        rust-dirs-sys-0.5.0
        rust-displaydoc-0.2.5
        rust-doc-comment-0.3.3
        rust-dunce-1.0.5
        rust-either-1.15.0
        rust-encode-unicode-0.3.6
        rust-encoding-rs-0.8.34
        rust-enum-dispatch-0.3.13
        rust-equivalent-1.0.1
        rust-errno-0.3.10
        rust-euclid-0.22.11
        rust-fancy-regex-0.11.0
        rust-faster-hex-0.9.0
        rust-fastrand-2.1.1
        rust-filedescriptor-0.8.2
        rust-filetime-0.2.25
        rust-finl-unicode-1.3.0
        rust-fixedbitset-0.4.2
        rust-flate2-1.0.33
        rust-fnv-1.0.7
        rust-form-urlencoded-1.2.1
        rust-futures-0.1.31
        rust-futures-0.3.31
        rust-futures-channel-0.3.31
        rust-futures-core-0.3.31
        rust-futures-executor-0.3.31
        rust-futures-io-0.3.31
        rust-futures-macro-0.3.31
        rust-futures-sink-0.3.31
        rust-futures-task-0.3.31
        rust-futures-util-0.3.31
        rust-generic-array-0.14.7
        rust-getrandom-0.2.15
        rust-getrandom-0.3.1
        rust-gimli-0.29.0
        rust-git2-0.19.0
        rust-gix-0.70.0
        rust-gix-actor-0.33.2
        rust-gix-attributes-0.24.0
        rust-gix-bitmap-0.2.14
        rust-gix-chunk-0.4.11
        rust-gix-command-0.4.1
        rust-gix-commitgraph-0.26.0
        rust-gix-config-0.43.0
        rust-gix-config-value-0.14.11
        rust-gix-date-0.9.3
        rust-gix-diff-0.50.0
        rust-gix-dir-0.12.0
        rust-gix-discover-0.38.0
        rust-gix-features-0.40.0
        rust-gix-filter-0.17.0
        rust-gix-fs-0.13.0
        rust-gix-glob-0.18.0
        rust-gix-hash-0.16.0
        rust-gix-hashtable-0.7.0
        rust-gix-ignore-0.13.0
        rust-gix-index-0.38.0
        rust-gix-lock-16.0.0
        rust-gix-object-0.47.0
        rust-gix-odb-0.67.0
        rust-gix-pack-0.57.0
        rust-gix-packetline-0.18.3
        rust-gix-packetline-blocking-0.18.2
        rust-gix-path-0.10.14
        rust-gix-pathspec-0.9.0
        rust-gix-protocol-0.48.0
        rust-gix-quote-0.4.15
        rust-gix-ref-0.50.0
        rust-gix-refspec-0.28.0
        rust-gix-revision-0.32.0
        rust-gix-revwalk-0.18.0
        rust-gix-sec-0.10.11
        rust-gix-shallow-0.2.0
        rust-gix-status-0.17.0
        rust-gix-submodule-0.17.0
        rust-gix-tempfile-16.0.0
        rust-gix-trace-0.1.12
        rust-gix-transport-0.45.0
        rust-gix-traverse-0.44.0
        rust-gix-url-0.29.0
        rust-gix-utils-0.1.14
        rust-gix-validate-0.9.3
        rust-gix-worktree-0.39.0
        rust-gix-worktree-state-0.17.0
        rust-glob-0.3.2
        rust-globset-0.4.15
        rust-half-2.4.1
        rust-hashbrown-0.14.5
        rust-hashbrown-0.15.2
        rust-heck-0.5.0
        rust-hermit-abi-0.3.9
        rust-hermit-abi-0.4.0
        rust-hex-0.4.3
        rust-home-0.5.9
        rust-iana-time-zone-0.1.60
        rust-iana-time-zone-haiku-0.1.2
        rust-icu-collections-1.5.0
        rust-icu-locid-1.5.0
        rust-icu-locid-transform-1.5.0
        rust-icu-locid-transform-data-1.5.0
        rust-icu-normalizer-1.5.0
        rust-icu-normalizer-data-1.5.0
        rust-icu-properties-1.5.1
        rust-icu-properties-data-1.5.0
        rust-icu-provider-1.5.0
        rust-icu-provider-macros-1.5.0
        rust-ident-case-1.0.1
        rust-idna-1.0.3
        rust-idna-adapter-1.2.0
        rust-ignore-0.4.23
        rust-imara-diff-0.1.7
        rust-indexmap-2.7.1
        rust-indoc-2.0.6
        rust-insta-1.42.2
        rust-instability-0.3.6
        rust-io-close-0.3.7
        rust-is-terminal-0.4.13
        rust-is-executable-1.0.4
        rust-is-terminal-polyfill-1.70.1
        rust-itertools-0.10.5
        rust-itertools-0.12.1
        rust-itertools-0.13.0
        rust-itoa-1.0.11
        rust-jiff-0.1.12
        rust-jiff-tzdb-0.1.0
        rust-jiff-tzdb-platform-0.1.0
        rust-jobserver-0.1.32
        rust-js-sys-0.3.70
        rust-kstring-2.0.2
        rust-lab-0.11.0
        rust-lazy-static-1.5.0
        rust-libc-0.2.170
        rust-libgit2-sys-0.17.0+1.8.1
        rust-libredox-0.1.3
        rust-libssh2-sys-0.3.0
        rust-libz-ng-sys-1.1.16
        rust-libz-sys-1.1.20
        rust-linked-hash-map-0.5.6
        rust-linux-raw-sys-0.4.14
        rust-linux-raw-sys-0.9.2
        rust-litemap-0.7.4
        rust-lock-api-0.4.12
        rust-log-0.4.22
        rust-lru-0.12.4
        rust-mac-address-1.1.7
        rust-maplit-1.0.2
        rust-matchers-0.1.0
        rust-maybe-async-0.2.10
        rust-memchr-2.7.4
        rust-memmap2-0.5.10
        rust-memmap2-0.9.4
        rust-memmem-0.1.1
        rust-memoffset-0.9.1
        rust-minimal-lexical-0.2.1
        rust-miniz-oxide-0.7.4
        rust-miniz-oxide-0.8.0
        rust-mio-1.0.2
        rust-multimap-0.10.0
        rust-nix-0.28.0
        rust-nom-7.1.3
        rust-nu-ansi-term-0.46.0
        rust-num-derive-0.4.2
        rust-num-traits-0.2.19
        rust-num-cpus-1.16.0
        rust-object-0.36.4
        rust-once-cell-1.20.3
        rust-oorandom-11.1.4
        rust-openssl-probe-0.1.5
        rust-openssl-src-300.3.2+3.3.2
        rust-openssl-sys-0.9.103
        rust-option-ext-0.2.0
        rust-ordered-float-4.6.0
        rust-os-pipe-1.2.1
        rust-overload-0.1.1
        rust-parking-lot-0.12.3
        rust-parking-lot-core-0.9.10
        rust-paste-1.0.15
        rust-percent-encoding-2.3.1
        rust-pest-2.7.15
        rust-pest-derive-2.7.15
        rust-pest-generator-2.7.15
        rust-pest-meta-2.7.15
        rust-petgraph-0.6.5
        rust-phf-0.11.3
        rust-phf-codegen-0.11.3
        rust-phf-generator-0.11.3
        rust-phf-macros-0.11.3
        rust-phf-shared-0.11.3
        rust-pin-project-1.1.8
        rust-pin-project-internal-1.1.8
        rust-pin-project-lite-0.2.14
        rust-pin-utils-0.1.0
        rust-pkg-config-0.3.30
        rust-plotters-0.3.6
        rust-plotters-backend-0.3.6
        rust-plotters-svg-0.3.6
        rust-pollster-0.3.0
        rust-portable-atomic-1.10.0
        rust-ppv-lite86-0.2.20
        rust-predicates-3.1.2
        rust-predicates-core-1.0.8
        rust-predicates-tree-1.0.11
        rust-pretty-assertions-1.4.1
        rust-prettyplease-0.2.22
        rust-proc-macro2-1.0.94
        rust-prodash-29.0.0
        rust-prost-0.12.6
        rust-prost-build-0.12.6
        rust-prost-derive-0.12.6
        rust-prost-types-0.12.6
        rust-quote-1.0.39
        rust-rand-0.8.5
        rust-rand-chacha-0.3.1
        rust-rand-core-0.6.4
        rust-ratatui-0.29.0
        rust-rayon-1.10.0
        rust-rayon-core-1.12.1
        rust-redox-syscall-0.5.3
        rust-redox-users-0.5.0
        rust-ref-cast-1.0.24
        rust-ref-cast-impl-1.0.24
        rust-regex-1.11.1
        rust-regex-automata-0.1.10
        rust-regex-automata-0.4.8
        rust-regex-syntax-0.6.29
        rust-regex-syntax-0.8.5
        rust-roff-0.2.2
        rust-rpassword-7.3.1
        rust-rtoolbox-0.0.2
        rust-rustc-demangle-0.1.24
        rust-rustix-0.38.44
        rust-rustix-1.0.1
        rust-rustversion-1.0.17
        rust-ryu-1.0.18
        rust-same-file-1.0.6
        rust-sapling-renderdag-0.1.0
        rust-sapling-streampager-0.11.0
        rust-scanlex-0.1.4
        rust-scm-record-0.5.0
        rust-scopeguard-1.2.0
        rust-serde-1.0.218
        rust-serde-bser-0.4.0
        rust-serde-bytes-0.11.15
        rust-serde-derive-1.0.218
        rust-serde-json-1.0.140
        rust-serde-spanned-0.6.8
        rust-sha1-0.10.6
        rust-sha1-asm-0.5.3
        rust-sha1-smol-1.0.1
        rust-sha2-0.10.8
        rust-sharded-slab-0.1.7
        rust-shell-words-1.1.0
        rust-shlex-1.3.0
        rust-signal-hook-0.3.17
        rust-signal-hook-mio-0.2.4
        rust-signal-hook-registry-1.4.2
        rust-similar-2.6.0
        rust-siphasher-0.3.11
        rust-siphasher-1.0.1
        rust-slab-0.4.9
        rust-smallvec-1.14.0
        rust-smawk-0.3.2
        rust-socket2-0.5.7
        rust-stable-deref-trait-1.2.0
        rust-static-assertions-1.1.0
        rust-strsim-0.11.1
        rust-strum-0.26.3
        rust-strum-macros-0.26.4
        rust-subtle-2.6.1
        rust-syn-1.0.109
        rust-syn-2.0.99
        rust-synstructure-0.13.1
        rust-tempfile-3.18.0
        rust-terminal-size-0.4.0
        rust-terminfo-0.9.0
        rust-termios-0.3.3
        rust-termtree-0.4.1
        rust-termwiz-0.23.0
        rust-test-case-3.3.1
        rust-test-case-core-3.3.1
        rust-test-case-macros-3.3.1
        rust-textwrap-0.16.2
        rust-thiserror-1.0.69
        rust-thiserror-2.0.12
        rust-thiserror-impl-1.0.69
        rust-thiserror-impl-2.0.12
        rust-thread-local-1.1.8
        rust-timeago-0.4.2
        rust-tinystr-0.7.6
        rust-tinytemplate-1.2.1
        rust-tinyvec-1.8.0
        rust-tinyvec-macros-0.1.1
        rust-tokio-1.44.0
        rust-tokio-macros-2.5.0
        rust-tokio-util-0.6.10
        rust-toml-0.8.19
        rust-toml-datetime-0.6.8
        rust-toml-edit-0.22.24
        rust-tracing-0.1.41
        rust-tracing-attributes-0.1.28
        rust-tracing-chrome-0.7.2
        rust-tracing-core-0.1.33
        rust-tracing-log-0.2.0
        rust-tracing-subscriber-0.3.19
        rust-typenum-1.17.0
        rust-ucd-trie-0.1.6
        rust-uluru-3.1.0
        rust-unicode-bom-2.0.3
        rust-unicode-ident-1.0.12
        rust-unicode-linebreak-0.1.5
        rust-unicode-normalization-0.1.23
        rust-unicode-segmentation-1.12.0
        rust-unicode-truncate-1.1.0
        rust-unicode-width-0.1.12
        rust-unicode-width-0.2.0
        rust-url-2.5.4
        rust-utf16-iter-1.0.5
        rust-utf8-iter-1.0.4
        rust-utf8parse-0.2.2
        rust-uuid-1.11.1
        rust-valuable-0.1.0
        rust-vcpkg-0.2.15
        rust-vec-map-0.8.2
        rust-version-check-0.9.5
        rust-vtparse-0.6.2
        rust-wait-timeout-0.2.0
        rust-walkdir-2.5.0
        rust-wasi-0.11.0+wasi-snapshot-preview1
        rust-wasi-0.13.3+wasi-0.2.2
        rust-wasite-0.1.0
        rust-wasm-bindgen-0.2.93
        rust-wasm-bindgen-backend-0.2.93
        rust-wasm-bindgen-macro-0.2.93
        rust-wasm-bindgen-macro-support-0.2.93
        rust-wasm-bindgen-shared-0.2.93
        rust-watchman-client-0.9.0
        rust-web-sys-0.3.70
        rust-wezterm-bidi-0.2.3
        rust-wezterm-blob-leases-0.1.0
        rust-wezterm-color-types-0.3.0
        rust-wezterm-dynamic-0.2.1
        rust-wezterm-dynamic-derive-0.1.1
        rust-wezterm-input-types-0.1.0
        rust-whoami-1.5.2
        rust-winapi-0.3.9
        rust-winapi-i686-pc-windows-gnu-0.4.0
        rust-winapi-util-0.1.9
        rust-winapi-x86-64-pc-windows-gnu-0.4.0
        rust-windows-core-0.52.0
        rust-windows-link-0.1.0
        rust-windows-sys-0.48.0
        rust-windows-sys-0.52.0
        rust-windows-sys-0.59.0
        rust-windows-targets-0.48.5
        rust-windows-targets-0.52.6
        rust-windows-aarch64-gnullvm-0.48.5
        rust-windows-aarch64-gnullvm-0.52.6
        rust-windows-aarch64-msvc-0.48.5
        rust-windows-aarch64-msvc-0.52.6
        rust-windows-i686-gnu-0.48.5
        rust-windows-i686-gnu-0.52.6
        rust-windows-i686-gnullvm-0.52.6
        rust-windows-i686-msvc-0.48.5
        rust-windows-i686-msvc-0.52.6
        rust-windows-x86-64-gnu-0.48.5
        rust-windows-x86-64-gnu-0.52.6
        rust-windows-x86-64-gnullvm-0.48.5
        rust-windows-x86-64-gnullvm-0.52.6
        rust-windows-x86-64-msvc-0.48.5
        rust-windows-x86-64-msvc-0.52.6
        rust-winnow-0.6.18
        rust-winnow-0.7.0
        rust-winreg-0.52.0
        rust-wit-bindgen-rt-0.33.0
        rust-write16-1.0.0
        rust-writeable-0.5.5
        rust-yansi-1.0.1
        rust-yoke-0.7.5
        rust-yoke-derive-0.7.5
        rust-zerocopy-0.7.35
        rust-zerocopy-derive-0.7.35
        rust-zerofrom-0.1.5
        rust-zerofrom-derive-0.1.5
        rust-zerovec-0.10.4
        rust-zerovec-derive-0.10.3))

