#!/bin/pwsh

# Conan-dl: a script to download anime from `gogoanime' or wherever.
# This is the powershell rewrite. I apologize for the nothing that's
# worth...

param(
    [string[]]$search ,
    [string]$quality ,
    [string]$outdir ,
    [int]$firstep ,
    [int]$lastep #,
)

$startingdir = get-location
$streamsite = "gogoanime.gg"

function get-anime(){
    param(
	[string[]]$search
    )
    $resultpage = invoke-webrequest "https://$streamsite//search.html?keyword=$search"
    $allanime = (
	$resultpage.links.href |
	  where-object {$_ -match "/category"}
    ) -replace '/category/',''
    $allanime
}

function get-embedurl(){
    param(
	[string]$anime ,
	[int]$ep
    )
    $streamurl = invoke-webrequest `
      -uri ("https://" + $streamsite + "/" + $anime + "-episode-" + $ep)
    $embedurl = "https:" + (
	$streamurl.links |
	  where-object {$_.outerhtml -match "data-video"} |
	  where-object {$_.rel -eq 100}
    )."data-video"
    $embedurl
}

function get-streamurl(){
    param(
	[string]$embedurl ,
	[int]$resolution
    )
    $tmp_url = (
	invoke-webrequest $embedurl 
    )
}


# ((iwr "gogoanime.gg//search.html?keyword=detective conan").links |
#   where-object {$_.href -match '/category'}).href
