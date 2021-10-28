# conan-dl

## Config file and command-line options (5)

    -s | streamsite     Top-level domain of site to be searched. Should be gogoanime.abc or similar.
    -a | anime          the name of the anime, in quotes. Will be searched.
    -f | firstep        First episode to download. Passing `-f` or`-l` with no options will
                        trigger eplist.list detection
    -l | lastep         Last episode to download
    -r | resolution     Resolution in pixels. 360 and 1080 are usually supported.
    -o | outputdir      Directory to dump downloaded files to. May include variables like $HOME.
    -m | menu           Menu program to use. Defaults to fzf, but dmenu also works.

    -h                  show this or similar help
    --depcheck          dependency check
