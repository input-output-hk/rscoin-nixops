{pkgs}:
with pkgs;
rec{
  serokellCoreSrc = pkgs.fetchgit {
      url = "https://github.com/serokell/serokell-core.git";
      rev = "a88dfced743c335f84a9ef814b3cd948ba051105";
      sha256 = "1kr1h4dwaj70qi4pv6agg2i8jxsb3qxlqhc5qli90sadmw7jp1s3";
    };
#  serokellCoreExtraDeps = with haskellPackagesExtended; [clock formatting];

  serokellPackage = haskellPackagesExtended.mkDerivation {
    pname = "serokell-core";
    version = "0.1.0.0";
    src = serokellCoreSrc;
    isLibrary = true;
    isExecutable = true;
    doCheck = false;

    # FIXME: too many deps for serokell-core! (joschi)
    libraryHaskellDepends = with haskellPackagesExtended; [
       acid-state base64-bytestring either lens optparse-applicative time-units
       either aeson clock formatting];
#      acid-state aeson base base64-bytestring binary bytestring cereal
#      conduit-extra containers cryptohash data-default directory ed25519
#      either exceptions file-embed filepath hashable hslogger lens
#      monad-control monad-loops MonadRandom msgpack msgpack-aeson
#      msgpack-rpc mtl QuickCheck random safe safecopy
#      stm text text-format time time-units transformers
#      transformers-base tuple unordered-containers vector
#    ] ++ serokellCoreExtraDeps;
#    executableHaskellDepends = with haskellPackagesExtended; [
#      acid-state aeson base base64-bytestring binary bytestring cereal
#      conduit-extra containers cryptohash data-default directory ed25519
#      exceptions filepath hashable hslogger hspec lens monad-control
#      monad-loops MonadRandom msgpack msgpack-aeson msgpack-rpc mtl
#      optparse-applicative QuickCheck random safe safecopy
#      stm text text-format time time-units transformers
#      transformers-base tuple unordered-containers vector
#    ] ++ serokellCoreExtraDeps;
#    testHaskellDepends = with haskellPackagesExtended; [
#      acid-state async base bytestring containers data-default
#      exceptions conduit-extra
#      hspec lens MonadRandom msgpack msgpack-rpc mtl QuickCheck random
#      safe safecopy  stm text time-units transformers tuple
#      vector 
#    ] ++ serokellCoreExtraDeps;
#    libraryPkgconfigDepends =
#      [ haskellPackagesExtended.aeson zlib git openssh stack nodejs ] ++
#      [ pkgconfig cairo  haskellPackagesExtended.conduit-extra ];

#    buildDepends = [ makeWrapper ];

    license = pkgs.stdenv.lib.licenses.gpl3;
  };


  haskellPackagesExtended  = pkgs.haskell.packages.lts-6_7.override {
    overrides = self: super: {
      serokell-core = serokellPackage;
    };
  };

  rscoinExtraDeps = with haskellPackagesExtended; [ serokell-core gtk3 
    aeson pqueue blake2 yaml clock derive extra formatting optparse-generic
    purescript-bridge servant-server string-conversions temporary turtle wai
    wai-extra wai-websockets warp websockets configurator 
    configurator-export ];

  rscoinLibraryHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson base base64-bytestring binary bytestring cereal
    conduit-extra containers cryptohash data-default directory ed25519
    either exceptions file-embed filepath hashable hslogger lens
    monad-control monad-loops MonadRandom msgpack msgpack-aeson
    msgpack-rpc mtl QuickCheck random safe safecopy
      stm text text-format time time-units transformers
    transformers-base tuple unordered-containers vector
  ] ++ rscoinExtraDeps;
  rscoinExecutableHaskellDepends = with haskellPackagesExtended; [
    acid-state aeson base base64-bytestring binary bytestring cereal
    conduit-extra containers cryptohash data-default directory ed25519
    exceptions filepath hashable hslogger hspec lens monad-control
    monad-loops MonadRandom msgpack msgpack-aeson msgpack-rpc mtl
    optparse-applicative QuickCheck random safe safecopy
      stm text text-format time time-units transformers
    transformers-base tuple unordered-containers vector
  ] ++ rscoinExtraDeps;
  rscoinTestHaskellDepends = with haskellPackagesExtended; [
    acid-state async base bytestring containers data-default exceptions
    conduit-extra hspec lens MonadRandom msgpack msgpack-rpc mtl QuickCheck random
    safe safecopy stm text time-units transformers tuple vector
  ] ++ rscoinExtraDeps;
  rscoinLibraryPkgconfigDepends =
    [ haskellPackagesExtended.aeson zlib git openssh stack nodejs ] ++
    [ pkgconfig cairo haskellPackagesExtended.conduit-extra ] ++
    [ haskellPackagesExtended.serokell-core
      haskellPackagesExtended.purescript ];
}
