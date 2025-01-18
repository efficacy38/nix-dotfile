# How to bootstrap

## Setup credential of nix-secret(another private repo to store encrypt secret)

1. add git config in `.ssh/config`
```
Host github.com
  # IdentityFile ~/.ssh/gh.id_ed25519
  User git
  Hostname github.com
```

2. clone this repo
```
git clone git@github.com:efficacy38/nix-dotfile.git
```

3. switch to environment with nix helper
```
nix shell nixpkgs#nh
nh os switch --hostname=phoenixton
```

## build minimal iso image
```
nix build .#nixosConfigurations.minimal-latest-iso.config.system.build.isoImage
```
