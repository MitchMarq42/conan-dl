#!/bin/pwsh
# (tell emacs to highlight this as powershell) -*- mode: powershell -*-

# ani-pwsh

#This program is (for now) licensed under the WTFPL:


#        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
#                    Version 2, December 2004 

# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 

# Everyone is permitted to copy and distribute verbatim or modified 
# copies of this license document, and changing it is allowed as long 
# as the name is changed. 

#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

#  0. You just DO WHAT THE FUCK YOU WANT TO.

# (taken from http://www.wtfpl.net/about/)

$version = "0.1"

#######################
# Auxiliary Functions #
#######################

function show-helptext(){
    # display parameters and their descriptions
}

function show-version(){
    write-inf $null "Version: $version"
}

function die-werr(){
    param([string]$allargs)
    write-err $allargs
    exit 1
}

function update-script(){
    # update script. Pulls new release from wherever.
}

function check-deps(){
    # check if dependencies are present
    param([string]$allargs)
    foreach ($dep in ($allargs -split ' ')) {
	if (! (get-command $dep 2> /dev/null)) {
	    write-err "Program $dep not found. Please install it."
	    if ($dep -eq "aria2c") {
		write-err "To install aria2c, Type <your_package_manager> aria2"
	    }
	    die-werr
	}
    }
}

function download-remotefile(){
    param([string]$referer,
	  [string]$vidfile)
    switch -wildcard ($vidfile) {
	("*mp4*") {
	    aria2c `
	      --summary-interval=0 `
	      -x 16 `
	      -s 16 `
	      --referer=$referer `
	      $vidfile `
	      --dir=$download-dir `
	      -o output.mp4 `
	      --download-result=hide
	}
	("*") {
	    ffmpeg `
	      -loglevel error `
	      -stats `
	      -referer $referer `
	      -i $vidfile `
	      -map "0:p:($idx - 1)?" `
	      -c copy "$download-dir/$3-$4.mp4"}
    }
}

function write-err(){
    # error message to stderr in red
    param([string]$allargs)
    write-host $allargs -foreground red >/dev/stderr
}

function write-inf(){
    # first argument in green, second in magenta
    param([string]$arg1,
	  [string]$arg2)
    write-host $arg1 -foreground green -nonewline
    write-host  " " -nonewline
    write-host $arg2 -foreground magenta
}

function prompt-replies(){
    # prompts user with message in $arg1-arg2 ($arg1 in blue, $arg2 in magenta)
    # and saves the input to the variables in $reply1 $reply2
    param([string]$arg1,
	  [string]$arg2)
    write-host $arg1 -foreground blue -nonewline -separator " "
    write-host  " " -nonewline
    write-host $arg2 -foreground magenta -nonewline
    write-host  " " -nonewline
    $reply0 = read-host 
    $script:reply1,$script:reply2 = $reply0 -split ' '
}

#############
# Searching #
#############

function search-anime(){
    param([string]$allargs)
    $search = $allargs -replace ' ','-'
    $results = invoke-webrequest $base_url/search.html?keyword=$search
    $results.Links | where-object {$_.href -match "/videos/"}
}

function search-extended(){
    param([string]$allargs)
    $indexing_url = "gogoanime.cm"
    $search = $allargs -replace ' ','-'
    $results = invoke-webrequest $indexing_url/search.html?keyword=$search
    $results.Links | where-object {$_.href -match "/category/"}
}

function check-episode(){
    param([string]$anime_id,
	  [string]$temp_anime_id)
    $matchregex = "a href.*videos/$temp_anime_id" 
    $data = invoke-webrequest $base_url/videos/$anime_id
    $del = $data.content -split [system.environment]::newline |
      select-string "Latest Episodes"
    if ($del -ne $null) {
	($data.content -split [system.environment]::newline |
	  select-string ".*" |
	  where-object {$_.linenumber -le $del.linenumber}
	) -match $matchregex `
	  -replace "^.*$temp_anime_id",$null `
	  -replace '">',$null
    }
}

function process-histentry(){
    $script:temp_anime_id = $anime_id -replace "[0-9]*.$",$null
    $script:latest_ep = $anime_id -replace $temp_anime_id,$null
    $script:current_ep = (check-episode $anime_id $temp_anime_id)
    if (($current_ep -ne $null) -and ($current_ep -ge $latest_ep)) {
	$anime_id
    }
}

function search-history(){
    # compares history with gogoplay; only shows unfinished anime
    if ((get-content $logfile) -eq $null) { die-werr "History is empty"}
    $search_results = (get-content $logfile) `
      -split [system.environment]::newline |
      foreach {process-histentry}
    if ($search_results -eq $null) { die-werr "no unwatched episodes"}
    $one_hist = ($search_results -split [system.environment]::newline |
      where-object {$_ -match '$'}).linenumber
    if ($one_hist -eq "1") {$select_first = 1}
    menuselect-anime $search_results
    $ep_choice_start = (get-content $logfile) -replace $selection_id,$null
}

##################
# URL processing #
##################

function objectize-uri(){
    # not in the original. Supposed to make the script more idiomatic
    # to powershell. Credit:
    # https://stackoverflow.com/questions/53766303/how-do-i-split-parse-a-url-string-into-an-object
    param([uri]$url)
    $parsedquerystring = [web.httputility]::parsequerystring($url.query)
    $i = 0
    $queryparams = @()
    foreach($querystringobject in $parsedquerystring){
	$queryobject = [psobject]::new()
	$queryobject | add-member `
	  -membertype noteproperty `
	  -name query -value $querystringobject
	$queryobject | add-member `
	  -membertype noteproperty `
	  -name value -value $parsedquerystring[$i]
	$queryparams += $queryobject
	$i++
    }
    $queryparams
}

function update-url(){
    # update main url to latest one
    $prev_url = ($base_url -split '/')[2]
    $new_url = ($dpage_link -split '/')[2]
    if ($prev_url -ne $new_url) {$new_url > $urlfile}
}

function get-dpagelink(){
    param([string]$anime_id,
	  [string]$ep_no)
    $stream_page = invoke-webrequest "${base_url}/videos/${anime_id}${ep_no}"
    "https:" + (($stream_page.content -split [environment]::newline |
      where-object {$_ -match "iframe"}) -split '"')[1]
}

function decrypt-link(){
    $sh_decrypt = @"
ajax_url="$base_url/encrypt-ajax.php"
id=$(printf "%s" "$args" | sed -nE 's/.*id=(.*)&title.*/\1/p')
resp=$(curl -s "$args")
secret_key=$(printf "%s" "$resp" | sed -nE 's/.*class="container-(.*)">/\1/p' | tr -d "\n" | od -A n -t x1 | tr -d " |\n")
iv=$(printf "%s" "$resp" | sed -nE 's/.*class="wrapper container-(.*)">/\1/p' | tr -d "\n" | od -A n -t x1 | tr -d " |\n")
second_key=$(printf "%s" "$resp" | sed -nE 's/.*class=".*videocontent-(.*)">/\1/p' | tr -d "\n" | od -A n -t x1 | tr -d " |\n")
token=$(printf "%s" "$resp" | sed -nE 's/.*data-value="(.*)">.*/\1/p' | base64 -d | openssl enc -d -aes256 -K "$secret_key" -iv "$iv" | sed -nE 's/.*&(token.*)/\1/p')
ajax=$(printf '%s' "$id" | openssl enc -e -aes256 -K "$secret_key" -iv "$iv" | base64)
data=$(curl -s -H "X-Requested-With:XMLHttpRequest" "${ajax_url}?id=${ajax}&alias=${id}&${token}" | sed -e 's/{"data":"//' -e 's/"}/\n/' -e 's/\\//g')
printf '%s' "$data" | base64 -d | openssl enc -d -aes256 -K "$second_key" -iv "$iv" | sed -e 's/\].*/\]/' -e 's/\\//g' |
  grep -Eo 'https:\/\/[-a-zA-Z0-9@:%._\+~#=][a-zA-Z0-9][-a-zA-Z0-9@:%_\+.~#?&\/\/=]*'
"@
    start-process -wait sh -c $sh_decrypt
}

function get-videolink(){
    param([string]$dpage_url)
    $video_links = decrypt-link $dpage_url
    if ($video_links -match 'mp4') {
	$video_url = (get-mp4quality "$video_links")
	$idx = 1
    } else {
	$video_url = $video_links
	get-m3u8quality
    }
}

function get-mp4quality(){
    switch ($quality) {
	("best") {$video_url = ($args[3])}
	("worst") {$video_url = ($args[0])}
	default {$video_url = $args | where-object {$_ -match 'quality'}
		 if ($video_url -eq '') {
		     write-err `
		       "Current video quality is not available `
		       (defaulting to best quality)"
		     $quality = "best"
		     $video_url = $args[3]
		 }
		}
    }
    $video_url
}

function get-m3u8quality(){
    $m3u8_links = (
	invoke-webrequest $video_url -headers @{referer = $dpage_link}).links
}
