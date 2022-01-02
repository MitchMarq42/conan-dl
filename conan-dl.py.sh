#!/bin/sh

# A lot of the things in this are done in python... need a sh treesitter...
menu='fzf'
anime=$(
(python<<EOF
import re
import requests

search = 'slime'
ua = 'curl'
headers = {'user-agent': ua}
searchurl = 'https://www2.gogoanime.cm//search.html'
payload={'keyword': search}
resultpage = requests.get(searchurl, params=payload, headers=headers)
url = resultpage.url
exitcode = resultpage.status_code
page = resultpage.text
namematch = re.compile(r' *<a href="/category/([^"]*)" title="[^"]*".*')
for m in re.findall(namematch, page): print(m)
EOF
) |
    $menu
)
echo "$anime"
