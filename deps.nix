{ pkgs } :

with pkgs; rec {

  serokell-corePackage = haskellPackagesExtended.mkDerivation {
    pname = "serokell-core";
    version = "0.1.0.0";
    src = pkgs.fetchgit {
      url = "https://github.com/serokell/serokell-core.git";
      rev = "9f9715763134e41c9ba92a1359be92f97f93eea8";
      sha256 = "0cjc61sx78rb901665yxahyyh8gh7zjki1gvz7j4hl32hz8dfqp3";
    };

    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    libraryHaskellDepends = with haskellPackagesExtended; [
       acid-state base64-bytestring either lens optparse-applicative time-units
       either aeson clock formatting
       base16-bytestring binary-orphans cereal-vector msgpack 
    ];
    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  rscoin-corePackage = haskellPackagesExtended.mkDerivation {
    pname = "rscoin-core";
    version = "0.1.0.0";
    src = pkgs.fetchgit {
        url = "https://github.com/input-output-hk/rscoin-core.git";
        rev = "5b2a65d58cbd0fe38e8effc3e2b05646c3b2a0ed";
	sha256 = "00a0sj23gfjfhvkshbin7njsjlq5rd16r3h68pxbh9ms4w90kv1i";
      };
    isLibrary = true;
    doCheck = false;
    doHaddock = false;
    libraryPkgconfigDepends = with pkgs; [zlib zlib.out];
    libraryHaskellDepends = with haskellPackagesExtended; [
      aeson ansi-terminal base base64-bytestring binary binary-orphans
      blake2 bytestring cereal conduit-extra configurator containers
      data-default directory ed25519 either exceptions extra file-embed
      filepath formatting hashable hslogger lens lifted-base
      monad-control monad-loops MonadRandom msgpack msgpack-rpc mtl
      pqueue QuickCheck quickcheck-instances random safe safecopy
      scientific serokell-core split stm template-haskell text text-format time
      time-units transformers transformers-base tuple
      unordered-containers vector warp websockets yaml
      time-warp
    ];
    testHaskellDepends = with haskellPackagesExtended; [
      aeson async base binary bytestring containers data-default either
      exceptions extra formatting hashable hspec lens MonadRandom msgpack
      msgpack-rpc mtl QuickCheck random safe safecopy serokell-core stm
      text text-format time-units transformers unordered-containers
      vector time-warp
    ];
    license = stdenv.lib.licenses.gpl3;
  };

  msgpackGIT = pkgs.fetchgit {
    url = "https://github.com/serokell/msgpack-haskell.git";
    rev = "c84c868a37446ee0671b3c641a6155af142e6d78";
    sha256 = "17ikw3fp1mnq9lbw439sgc3msq5dpxhyan70g9iywy5vs11pdrm0";
  };

  msgpackPackage = haskellPackagesExtended.mkDerivation {
    pname = "msgpack";
    version = "1.0.0";
    src = msgpackGIT;
    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    # HACK best workaround ever
    patchPhase = ''
      mv msgpack .msgpack
      rm -Rf *
      mv .msgpack/* .
    '';

    libraryHaskellDepends = with haskellPackagesExtended; [
      base mtl bytestring text containers unordered-containers hashable vector 
      blaze-builder deepseq binary data-binary-ieee754
    ];
    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  msgpack-rpcPackage = haskellPackagesExtended.mkDerivation {
    pname = "msgpack-rpc";
    version = "1.0.0";
    src = msgpackGIT;
    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    # HACK best workaround ever
    patchPhase = ''
      mv msgpack-rpc .msgpack-rpc
      rm -Rf *
      mv .msgpack-rpc/* .
    '';

    libraryHaskellDepends = with haskellPackagesExtended; [
       msgpackPackage base bytestring text network random mtl monad-control conduit conduit-extra binary-conduit exceptions binary
    ];

    license = pkgs.stdenv.lib.licenses.gpl3;
  };

  #msgpack-aesonPackage = haskellPackagesExtended.mkDerivation {
  #  pname = "msgpack-aeson";
  #  version = "0.1.0.0";
  #  src = msgpackGIT;
  #  isLibrary = true;
  #  isExecutable = true;
  #  doCheck = false;

  #  # HACK best workaround ever
  #  patchPhase = ''
  #    mv msgpack-aeson .msgpack-aeson
  #    rm -Rf *
  #    mv .msgpack-aeson/* .
  #  '';

  #  libraryHaskellDepends = with haskellPackagesExtended; [
  #     msgpackPackage base aeson bytestring scientific text unordered-containers vector deepseq
  #  ];
  #  license = pkgs.stdenv.lib.licenses.gpl3;
  #};

  acid-statePackage = haskellPackagesExtended.mkDerivation {
    pname = "acid-state";
    version = "0.14.1";
    src = pkgs.fetchgit {
      url = "https://github.com/serokell/acid-state.git";
      rev = "ad77e909bcd46c3e44eeca558eb8a6f1ff3600eb";
      sha256 = "1jl1j0v9wplqz2ayq2af6hnvisp9ysvnf2f77a5ykn9zik8qbhrg";
    };

    isLibrary = true;
    doCheck = false;

    libraryHaskellDepends = with haskellPackagesExtended; [
       array base bytestring cereal containers directory extensible-exceptions 
       filepath mtl network safecopy stm template-haskell unix
    ];
    license = pkgs.stdenv.lib.licenses.publicDomain;
  };

  time-warpPackage = haskellPackagesExtended.mkDerivation {
    pname = "time-warp";
    version = "0.1.0.0";
    src = pkgs.fetchgit {
      url = "https://github.com/serokell/time-warp";
      rev = "557632cdc0e4b90615a7d28359329f05e1919ee5";
      sha256 = "0hi3xxnxsmpmhvxl8cznp7m3di3n54wwhlqqxxcmc8hhn8354ckf";
    };
    libraryHaskellDepends = with haskellPackagesExtended; [
      ansi-terminal base base64-bytestring binary binary-orphans
      bytestring cereal conduit-extra containers data-default directory
      either exceptions extra file-embed filepath formatting hashable
      hslogger lens lifted-base monad-control monad-loops MonadRandom
      msgpack msgpack-rpc mtl pkgconfig pqueue QuickCheck quickcheck-instances
      random safe safecopy serokell-core stm template-haskell text
      text-format time time-units transformers transformers-base tuple
      unordered-containers vector warp websockets yaml zlib zlib.out
    ];
    testHaskellDepends = with haskellPackagesExtended; [
      aeson async base binary bytestring containers data-default either
      exceptions extra formatting hashable hspec lens MonadRandom msgpack
      msgpack-rpc mtl pkgconfig QuickCheck random safe safecopy serokell-core stm
      text text-format time-units transformers unordered-containers
      vector zlib zlib.out 
    ];
    libraryPkgconfigDepends = with pkgs; [zlib zlib.out];
    isLibrary = true;
    doCheck = false;
    homepage = "http://gitlab.serokell.io/serokell-team/time-warp";
    description = "TODO";
    license = stdenv.lib.licenses.gpl3;
  };

  purescript-bridgePackage = haskellPackagesExtended.mkDerivation {
    pname = "purescript-bridge";
    version = "0.8.0.0";
     src = pkgs.fetchgit {
      url = "https://github.com/eskimor/purescript-bridge.git";
      rev = "8b6e3960dd86a517f5fd37ec648957b220818396";
      sha256 = "188mb6hnc5brhs71q445xd6sqsjd47lnw5xs83g9wk6f0nxswav7";
    };
    libraryHaskellDepends = with haskellPackagesExtended; [
      base containers directory filepath generic-deriving lens mtl text
      transformers
    ];
    testHaskellDepends = with haskellPackagesExtended; [
      base containers hspec hspec-expectations-pretty-diff text
    ];
    description = "Generate PureScript data types from Haskell data types";
    license = stdenv.lib.licenses.bsd3;
  };

  semigroupsOverride = haskellPackagesExtended.mkDerivation {
    pname = "semigroups";
    version = "0.18.1";
    sha256 = "ae7607fb2b497a53192c378dc84c00b45610fdc5de0ac8c1ac3234ec7acee807";
    revision = "1";
    editedCabalFile = "7dd2b3dcc9517705391c1c6a0b51eba1da605b554f9817255c4a1a1df4d4ae3d";
    libraryHaskellDepends = with haskellPackagesExtended; [ unordered-containers base hashable tagged text ];
    homepage = "http://github.com/ekmett/semigroups/";
    description = "Anything that associates";
    license = stdenv.lib.licenses.bsd3;
    hydraPlatforms = stdenv.lib.platforms.none;
   };

  haskellPackagesExtended = pkgs.haskell.packages.lts-6_7.override {
    overrides = self: super: {
      serokell-core = serokell-corePackage;
      rscoin-core = rscoin-corePackage;
      msgpack = msgpackPackage;
      msgpack-rpc = msgpack-rpcPackage;
      #msgpack-aeson = msgpack-aesonPackage;
      acid-state = acid-statePackage;
      purescript-bridge = purescript-bridgePackage;
      time-warp = time-warpPackage;
      # some package had a problem with semigroups 0.18.2 and therefore we override 0.18.1 to be default
      semigroups = semigroupsOverride;
    };
  };

  RSlibraryHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson ansi-terminal base base64-bytestring binary blake2
    bytestring cereal conduit-extra configurator containers
    data-default directory ed25519 either exceptions extra file-embed
    filepath formatting hashable hslogger lens lifted-base
    monad-control monad-loops MonadRandom msgpack msgpack-rpc mtl
    optional-args pqueue QuickCheck random rscoin-core safe safecopy
    serokell-core servant-server stm template-haskell text text-format
    time time-units time-warp transformers transformers-base tuple
    turtle unordered-containers vector wai wai-extra wai-websockets
    warp websockets yaml
  ];
  RSexecutableHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson base base64-bytestring binary bytestring clock
    containers exceptions extra filepath formatting lens mtl
    optional-args optparse-applicative optparse-generic
    purescript-bridge rscoin-core safecopy serokell-core stm
    string-conversions temporary text text-format time-units time-warp
    transformers turtle unordered-containers wai wai-extra warp yaml
  ];
  RStestHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson async base binary bytestring containers
    data-default derive either exceptions extra formatting hashable
    hspec lens MonadRandom msgpack msgpack-rpc mtl optional-args
    QuickCheck random rscoin-core safe safecopy serokell-core stm text
    text-format time-units time-warp transformers unordered-containers
    vector
  ];
}
