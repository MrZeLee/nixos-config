{
  haskell,
  fetchgit,
}:

let
  inherit (haskell.lib.compose)
    dontCheck
    doJailbreak
    appendPatch
    overrideCabal
    enableCabalFlag
    addBuildDepends
    ;

  version = "7.0.2";

  src = fetchgit {
    url = "https://github.com/simplex-chat/simplex-chat.git";
    rev = "v${version}";
    hash = "sha256-M9iHAbmxxspcPQ5n+omD7ZRiI1Trd1UkTIjYiCBhH3o=";
  };

  # source-repository-package pins from cabal.project; hashes from scripts/nix/sha256map.nix
  git =
    name: rev: sha256:
    fetchgit {
      url = "https://github.com/${name}.git";
      inherit rev sha256;
    };

  hp = haskell.packages.ghc96.override {
    overrides =
      self: _:
      let
        fork = name: src: dontCheck (self.callCabal2nix name src { });
        forkSub = name: src: dontCheck (self.callCabal2nixWithOptions name src "--subpath ${name}" { });
        # upstream still targets the pre-2.0 tls / pre-5.0 http2 stack
        pin = name: ver: dontCheck (doJailbreak (self.callHackage name ver { }));
      in
      {
        # ansi-terminal 1.x adds an Underlining ConsoleLayer; -Werror=incomplete-patterns trips on it
        simplex-chat = overrideCabal (drv: {
          postPatch = (drv.postPatch or "") + ''
            sed -i 's/^\( *\)Background -> background$/&\n\1Underlining -> foreground/' \
              src/Simplex/Chat/Terminal/Output.hs
          '';
        }) (doJailbreak (dontCheck (self.callCabal2nix "simplex-chat" src { })));

        # jailbreak-cabal skips conditional blocks, where these bounds live
        simplexmq =
          overrideCabal
            (drv: {
              postPatch = (drv.postPatch or "") + ''
                sed -i -E 's/\b(hashable|ini) *[=<>][^,]*/\1/g' simplexmq.cabal
              '';
            })
            (
              doJailbreak (
                dontCheck (
                  self.callCabal2nix "simplexmq" (git "simplex-chat/simplexmq"
                    "efaad8e73436d60f5052f07dda6b71151ad5039b"
                    "1jczm6baqz34sn13jgp5srqjk3gnx90brsfrsqw29al769ssrvkv"
                  ) { }
                )
              )
            );
        socks = fork "socks" (
          git "simplex-chat/hs-socks" "a30cc7a79a08d8108316094f8f2f82a0c5e1ac51"
            "0yasvnr7g91k76mjkamvzab2kvlb1g5pspjyjn2fr6v83swjhj38"
        );
        direct-sqlcipher = appendPatch "${src}/scripts/nix/direct-sqlcipher-2.3.27.patch" (
          fork "direct-sqlcipher" (
            git "simplex-chat/direct-sqlcipher" "f814ee68b16a9447fbb467ccc8f29bdd3546bfd9"
              "1ql13f4kfwkbaq7nygkxgw84213i0zm7c1a8hwvramayxl38dq5d"
          )
        );
        sqlcipher-simple = fork "sqlcipher-simple" (
          git "simplex-chat/sqlcipher-simple" "a46bd361a19376c5211f1058908fc0ae6bf42446"
            "1z0r78d8f0812kxbgsm735qf6xx8lvaz27k1a0b4a2m0sshpd5gl"
        );
        aeson = doJailbreak (
          fork "aeson" (
            git "simplex-chat/aeson" "aab7b5a14d6c5ea64c64dcaee418de1bb00dcc2b"
              "0jz7kda8gai893vyvj96fy962ncv8dcsx71fbddyy8zrvc88jfrr"
          )
        );
        terminal = fork "terminal" (
          git "simplex-chat/haskell-terminal" "f708b00009b54890172068f168bf98508ffcd495"
            "0zmq7lmfsk8m340g47g5963yba7i88n4afa6z93sg9px5jv1mijj"
        );
        zip = fork "zip" (
          git "simplex-chat/zip" "2eff156c3aac389e35d38bf10a52733d7061640a"
            "052vahd5d4lxnazjrb6l60i261aycn2js7jhzafyb72n15ns4r6p"
        );
        warp-tls = forkSub "warp-tls" (
          git "yesodweb/wai" "ec5e017d896a78e787a5acea62b37a4e677dec2e"
            "1ckcpmpjfy9jiqrb52q20lj7ln4hmq9v2jk6kpkf3m68c1m9c2bx"
        );
        warp = forkSub "warp" (
          git "simplex-chat/wai" "2f6e5aa5f05ba9140ac99e195ee647b4f7d926b0"
            "199g4rjdf1zp1fcw8nqdsyr1h36hmg424qqx03071jk7j00z7ay4"
        );

        tls = pin "tls" "1.9.0";
        http2 = pin "http2" "4.2.2";
        crypton = pin "crypton" "0.34";
        crypton-connection = pin "crypton-connection" "0.3.1";
        # the flag doesn't reach callHackage's generated deps, so add them by hand
        cryptostore = addBuildDepends [
          self.crypton
          self.crypton-x509
          self.crypton-x509-validation
        ] (enableCabalFlag "use_crypton" (pin "cryptostore" "0.3.0.1"));
        # simplexmq relies on data-default 0.7's `Default (IO a)` instance
        data-default = pin "data-default" "0.7.1.1";
        data-default-class = pin "data-default-class" "0.1.2.0";
        data-default-instances-containers = pin "data-default-instances-containers" "0.0.1";
        data-default-instances-dlist = pin "data-default-instances-dlist" "0.0.1";
        data-default-instances-old-locale = pin "data-default-instances-old-locale" "0.0.1";
        network = pin "network" "3.1.4.0";
        time-manager = pin "time-manager" "0.0.1";
        auto-update = pin "auto-update" "0.1.6";
        fast-logger = pin "fast-logger" "3.2.2";
        wai-logger = pin "wai-logger" "2.4.0";
        tls-session-manager = pin "tls-session-manager" "0.0.4";
        websockets = pin "websockets" "0.12.7.3";
        # 0.16 imports ansi-wl-pprint 0.6 internals
        optparse-applicative = dontCheck (
          doJailbreak (
            self.callHackage "optparse-applicative" "0.16.1.0" {
              ansi-wl-pprint = pin "ansi-wl-pprint" "0.6.9";
            }
          )
        );
      };
  };
in
haskell.lib.compose.justStaticExecutables hp.simplex-chat
