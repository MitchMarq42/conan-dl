#!/bin/pwsh

# Declare
#{ declarations
$configfile="$HOME/.config/conan-dl/conan-dl.conf"
$startingdir="$PWD"
$tmpdir="/tmp/cdl/"
# refresh="0.5"
# watch="no"
$menu="fzf"
$streamsite="gogoanime.gg"
$eplist="$startingdir/eplist.list"
#}
# Define
## All functions which use variables must declare all of them as arguments.
## All functions which (re)assign must be in form `get_$var` and give that var on stdout.
function menu() {
    $menu
}
function get_anime() { # $search
    $search=$(echo "$@" | sed 's/\s/-/g')
    curl -s "https://$streamsite//search.html" `
        -G --data-binary "keyword=$search" |
    sed -n -E 's_^[[:space:]]*<a href="/category/([^"]*)" title="([^"]*)".*_\1_p' |
    menu
    # This does it all and spits
    # out correctly formatted anime.
}
function get_embedurl() { # $anime $ep
    $anime=$1
    $ep=$2
    curl -s "https://$streamsite/$anime-episode-$ep" |
    sed -n -E '
        /^[[:space:]]*<a href="#" rel="100"/{
        s/.*data-video="([^"]*)".*/https:\1/p
        q
        }'
}
function get_streamurl() { # $embedurl $resolution
    $embedurl="$1"
    $resolution="$2"
    $tmp_url=$(curl -s "$embedurl" |
        sed -n -E '
            /^.*sources:/{
            s/.*(https[^'']*).*/\1/p
            q
            }
        '
    )
    printf '%s' "$tmp_url" |
        sed -n -E '
            s/(.*)\.([0-9]+\.[0-9]+)\.[0-9]+\.m3u8/\1.\2.m3u8/p
        '
    echo "$tmp_url" | sed -n -E "s/(.*)\.m3u8/\1.$resolution.m3u8/p"
}
function get_lastepint() { # $lastep $anime
    $lastep=$1
    $anime=$2
    switch ( "$lastep" -is [int] && echo "yes" ) {
        (yes)        { echo "$lastep" } ;;
        ('')
        {curl -s "https://$streamsite/category/$anime" |
              sed -n -E "
			 /^[[:space:]]*<a href="#" class="active" ep_start/{
			     s/.* "([0-9]*)' ep_end = '([0-9]*)'.*/\2/p
			     q
			 }
			 "
	}
        ;;
    }
}
function get_resolution(){ # $resolution
    echo "$resolution" |
        sed "s/p$//;s/P$//"
}
function get_eps() { # $firstep $lastepint
    $firstep="$1"
    $lastepint="$2"
    switch ( (test-path $eplist) && echo "yes" ) {
        (yes)    { cat "$eplist" };;
        ('')     { seq "$firstep" "$lastepint" };;
    }
}
function faketty() { # <command $args>
    # USAGE: `faketty <command>` where <command> is anything that spews colors.
    # Credit: https://stackoverflow.com/questions/1401002/how-to-trick-an-application-into-thinking-its-stdout-is-a-terminal-not-a-pipe
    script -qfc "$(/bin/printf "%q " "$@")" /dev/null
}
function monitor_ep() { # $ep
    $ep=$1
    $eplogfile="$tmpdir/$anime/$ep.log"
    tput sc
    while ( pgrep yt-dlp ) # inotifywait -qqm --event modify "$eplogfile"
    {
        tput rc
        tail -f "$eplogfile"
        sleep 0.5
    }
}
function download_episode() { # $streamurl $embedurl
    $streamurl=$1
    $embedurl=$2
    yt-dlp `
        "$streamurl" `
        "--add-header=Referer: $embedurl" `
        "--restrict-filenames" `
        "--quiet" `
        "--progress" > "$eplogfile"
}
function do_all() {
    . $configfile
    $anime=$(get_anime "$search")
    $lastepint=$(get_lastepint "$lastep" "$anime")
    $eps=$(get_eps "$firstep" "$lastepint")
    mkdir -p "$outputdir" && cd "$outputdir"
    mkdir -p "$tmpdir/$anime"
    $eps | foreach-object {
	$ep = $_
        $embedurl=$(get_embedurl "$anime" "$ep")
        $resolution=$(get_resolution)
        $streamurl=$(get_streamurl "$embedurl" "$resolution")
        download_episode "$streamurl" "$embedurl" &
        monitor_ep "$ep" &
    }
}

# Process
do_all

# Print

