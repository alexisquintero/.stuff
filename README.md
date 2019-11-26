# utils

## Contains several useful script

# PS1
## _Simple_ prompt script to show git status made in POSIX sh

### Pics

![ps1](https://gist.githubusercontent.com/alexisquintero/a246066a7fdc3f938f5b72fd6653ebe4/raw/5b09839358433b6a1950c2e70fec84f1e614e476/ps1.png)
Current is up to date (❙) with no changes (same color as u) and master is behind (❰).

### Customization

#### If working on a feature branch
* `MAINCHAR`: Used for the main branch (master or develop or whatever) when it's up to date.
* `MAINBEHINDCHAR`: Used for the main branch when it's behind upstream main.

#### If working on a feature branch `CURRENT` means the feature branch, otherwise it's the symbol used for... current branch
* `CURRENTCHAR`: Used for current branch when it's up to date.
* `CURRENTBEHINDCHAR`: Used for current branch when it's behind upstream current.
* `CURRENTAHEADCHAR`: Used for current branch when it's ahead upstream current.

#### Miscellaneous
* `DETACHEDCHAR`: Used when head is detached, i.e. checkout to a specific hash.
* `PROBLEMCHAR`: Used when local and upstream diverged, e.g. when rebasing and changing commits hashes.
* `REBASECHAR`: Used when there's a rebase in progress.
* `BISECTCHAR`: Used when there's a bisection in progress.

#### Colors are mostly self-explanatory.

#### FAQs
* Why is there no `MAINAHEADCHAR`? I don't know a _clever_ way to do that.

# custom.cfg
## Simple grub default selector based on time and/or day

# SpotifyInfo.sh
## Simple spotify integration with i3status
