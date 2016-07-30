### Compiling localy
`nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix { }' -I nixpkgs=../nixpkgs`
after that all binarys can be

### Deploying changes
`nixops deploy -d rscoin -I nixpkgs=../nixpkgs`
note this will not remove machines if they no longer exist.

### removing machines
if you want to remove a machine simply remove them in the bottom part of the `nixops.nix` file.
Then run `nixops deploy` with `-k`:
`nixops deploy -k -d rscoin -I nixpkgs=../nixpkgs`

### connect to a machine
`nixops ssh -d rscoin rs-bank`
replace `rs-bank` with the machine you want to connect to.

### list all deployments
nixpops list

### infos about all machines (including public IPs)
`nixops info -d rscoin`

### fuck up the deployment
this command will undeploy all machines:
`nixops destroy -d rscoin`
