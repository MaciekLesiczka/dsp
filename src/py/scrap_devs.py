import urllib2
from bs4 import BeautifulSoup
from pandas import DataFrame

page = urllib2.urlopen('http://www.maciejaniserowicz.com/daj-sie-poznac/uczestnicy/').read()
soup = BeautifulSoup(page)
content_div = soup.find_all("div", "post-content")[0]
hrs = content_div.find_all("hr")


def get_dev_info(hr_element):
    header = hr_element.find_next_sibling()
    details = header.find_next_sibling()
    links = details.find_all('a')
    header_html = unicode(header)
    dev = {'name': header.text[0:(header.text.find("-") - 1)],
           'project_title': header_html[header_html.find('"<i>') + 4:(header_html.find('</i>"'))],
           "tech_stack": header_html[header_html.find('</i>" (') + 7:header_html.find(")</h4>")],
           "project_desc": details.find("span").text,
           "blog_url": links[0]['href'],
           "repo_url": links[1]['href']}
    return dev

devs = [get_dev_info(hr) for hr in hrs]

df = DataFrame(devs)

df.to_csv("..\..\data\devs.csv", encoding="utf-8", index=False)
