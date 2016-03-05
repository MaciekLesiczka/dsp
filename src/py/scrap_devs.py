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
           "repo_url": contestant_div.select('.dsp_src_url')[0]['href'],
           }
    return dev

devs = [get_dev_info(hr) for hr in hrs]


def get_repo_info(repo_url):
    repo_url = repo_url.lower()
    if repo_url.endswith("/"):
        repo_url = repo_url[:-1]

    if repo_url.endswith(".git"):
        repo_url = repo_url[:-4]
    if repo_url.startswith('https://github.com/'):
        repo_url = repo_url.replace('https://github.com/','')
    elif repo_url.startswith('http://github.com/'):
        repo_url = repo_url.replace('http://github.com/','')
    else:
        repo_url = None
    repo_owner = None
    repo_name = None
    if repo_url is not None:
        repo_parts = repo_url.split('/')

        if len(repo_parts) > 0:
            repo_owner = repo_parts[0]
            if len(repo_parts) == 2:
                repo_name = repo_parts[1]
            elif len(repo_parts) == 1:
                #exceptions
                if repo_owner == "konstruktywnie":
                    repo_name = "metod"
                if repo_owner in ["meteostation", "wikibus"]:
                    repo_name = "/all/"
    return {
                'repo_owner':repo_owner,
                'repo_name':repo_name
    }

df = DataFrame(devs)

parts = df.repo_url.map(lambda x: get_repo_info(x))
df['repo_owner'] = parts.map(lambda x: x["repo_owner"])
df['repo_name'] = parts.map(lambda x: x["repo_name"])

not_found_repos = df[df.repo_name.isnull()][['blog_url', 'repo_url']]

if len(not_found_repos) > 0:
    print 'not found repos for:'
    print not_found_repos

df.to_csv("..\..\data\devs.csv", encoding="utf-8", index=False)
