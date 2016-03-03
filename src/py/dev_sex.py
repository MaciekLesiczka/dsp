import urllib2
from bs4 import BeautifulSoup
from pandas import DataFrame

page = urllib2.urlopen('http://imiona.nazwiska-polskie.pl/meskie').read()
soup = BeautifulSoup(page)
soup.body.select('div')
all_rows = soup.select('.namesTab')[0].select('tr')
all_names = [tr.select('td')[2].text for tr in all_rows[1:]]

exceptions = ["Dmitro", "Cad", "CZe"]

devs = DataFrame.from_csv("..\..\data\devs.csv", encoding="utf-8", index_col=False)
devs['female'] = devs.first_name.map(lambda x : x in all_names or x in exceptions) == False
coding_girls = devs[devs.female]
coding_girls.to_csv("..\..\data\coding_girls.csv", encoding="utf-8", index=False)
devs.to_csv("..\..\data\devs_with_sex.csv", encoding="utf-8", index=False)



