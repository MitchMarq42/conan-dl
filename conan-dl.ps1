#!/bin/pwsh

# Conan-dl: a script to download anime from `gogoanime' or wherever.
# This is the powershell rewrite. I apologize for the nothing that's
# worth...

param(
    [string]$search ,
    [string]$quality ,
    [string]$outdir ,
    [int]$firstep ,
    [int]$lastep ,
    [string]$menu ,
    [string]$player
)

$startingdir = get-location

[uri]$streamsite = "https://gogoanime.sk"

<# rough procedure:

- search gogoanime
- $menu with names -> selects an ID
- go to stream page - simple url
- navigate to download page
- click button of $resolution
- save mp4 or play with $player
#>

# search gogoanime
$searchurl = $streamsite.tostring() + `
  "/search.html?keyword=" + `
  [uri]::escapedatastring($search)
invoke-webrequest $searchurl

# $menu with names -> selects an ID
$table = @{
    "Detective Conan" = "detective-conan"
    "A good show" = "cowboy-bebop"
}
$prettyname = $table.keys | fzf
$anime_id = $table.$prettyname

# go to stream page - simple url
$streamurl = $streamsite.tostring() + `
  $anime_id + `
  "-episode-" + `
  $current_ep
$streampage = invoke-webrequest $streamurl

# navigate to download page
$dllink = $streampage.links | where-object {$_ -match 'download'}
$dlpage = invoke-webrequest $dllink.href

# click button of $resolution
$dlpage.links
