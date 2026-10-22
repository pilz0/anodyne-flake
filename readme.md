# anodyne-flake
This is a flake for the deployment of https://anodyne.wiki.

## Services
### chrp
This is a service for scraping sources and setting up the static content (icons, ...)

#### options

### api
The API has a sqlite with the generated data from chrp and serves that
#### options

### frontend
#### options

### caddy
#### options

## pkgs
* anodyne-api
* anodyne-chrp
* anodyne-molpic

## Example setup
Add this to your flake.nix
```nix
inputs.anodyne-flake.url = "github:pilz0/anodyne-flake";
```
* Add this to your host config
this also set up automatic https
```nix
anodyne-wiki = {
    enable = true;
    api.enable = true;
    chrp.enable = true;
    pkgs.enable = true;
    caddy = {
        enable = true;
        domain = "anodyne-nix.as214958.net";
        contactEmail = "acme@pilz.foo";
    };
};
```
* run these services in tmux 
once for setup (sets up icons etc)
```bash
systemctl start anodyne-chrp-init
```
after adding new substances to anodyne-frontend (and once to pull all substance data)
```bash
systemctl start anodyne-chrp
```
