#!/usr/bin/env python3
import re
import requests

search = 'detective conan'
ua = {'user-agent': 'curl'}
url = 'https://www2.gogoanime.cm//search.html'
payload={'keyword': search}
r = requests.get(url, params=payload, headers=ua)
url = r.url
print(url)
exitcode = r.status_code
print(exitcode)
page = r.text

    # Broken bits of ed/sed/vi regex that don't quite work here
    # r's_[[:space:]]*<a\shref="/category/([^"]*)"\stitle="([^"]*)".*_\1_p'
    # r'^[[:space:]]*\<a\shref=\"/category/([^\"]*)"\stitle=\"([^\"]*)\".*$'
    # r'\1',

regex = re.compile(r' *<a href="/category/([^"]*)" title="([^"]*)".*')
# for m in re.findall(regex, page):
#     allanime.add(m)
m = re.findall(regex, page)
allanime = set(m)
# allanime.add(m)

# allanime = list(allanime)
print(allanime)
