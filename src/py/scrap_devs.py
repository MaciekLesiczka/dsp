import urllib2
from bs4 import BeautifulSoup
from pandas import DataFrame

page = urllib2.urlopen('http://www.maciejaniserowicz.com/daj-sie-poznac/uczestnicy/').read()
soup = BeautifulSoup(page)
content_div = soup.find_all("div", "post-content")[0]
hrs = content_div.find_all("hr")


def get_dev_info(hr_element):
    contestant_div = hr_element.find_next_sibling()

    def get_cell(class_name):
        return contestant_div.select(class_name)[0].text

    dev = {'first_name': get_cell('.dsp_first_name'),
           'last_name': get_cell('.dsp_last_name'),
           'project_title': get_cell('.dsp_prj_name'),
           "tech_stack": get_cell('.dsp_tech'),
           "project_desc": get_cell('.dsp_prj_desc'),
           "blog_url": contestant_div.select('.dsp_blog_url')[0]['href'],
           "repo_url": contestant_div.select('.dsp_src_url')[0]['href']}
    return dev

devs = [get_dev_info(hr) for hr in hrs]

df = DataFrame(devs)

df.to_csv("..\..\data\devs.csv", encoding="utf-8", index=False)
