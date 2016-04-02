#Gets all RSS feed URLs, based on DSP participant list
#feedfinder is not perfect. Lists of Exceptions and blogs without RSS has been manualy built

from pandas import DataFrame
from feedfinder import *

import re
tag_re = re.compile(r'(<!--.*?-->|<[^>]*>)')

devs = DataFrame.from_csv("..\..\data\devs.csv", encoding="utf-8", index_col=False)

exceptions = {
    'http://matma.github.io': 'http://matma.github.io/feed.xml',
    'http://www.devanarch.com': 'http://www.devanarch.com/feed/',
    'http://knowakowski.azurewebsites.net':'http://knowakowski.azurewebsites.net/feed/',
    'http://skobo.pl':'http://adam.skobo.pl/?feed=rss2',
    'http://bodolsog.pl/blog': 'http://www.bodolsog.pl/devblog/feed/',
    'http://adamszneider.azurewebsites.net': 'http://adamszneider.azurewebsites.net/feed/',
    'http://md-techblog.net.pl' : 'http://www.md-techblog.net.pl/feed/',
    'http://www.mikolajdemkow.pl' : 'http://www.mikolajdemkow.pl/feed',
    'http://blog.creyn.pl':'http://blog.creyn.pl/feed/',
    'http://pawelrzepinski.azurewebsites.net': 'http://pawelrzepinski.azurewebsites.net/feed/',
    'http://www.malachowicz.org': 'http://www.malachowicz.org/?feed=rss2',
    'http://www.kamilhawdziejuk.wordpress.com':'https://kamilhawdziejuk.wordpress.com/feed/',
    'http://rutkowski.in' : 'http://rutkowski.in/feed/',
    'http://bnowakowski.pl/blog' : 'http://bnowakowski.pl/en/feed/',
    'http://sweetprogramming.com' : 'http://sweetprogramming.com/feed/',
    'http://kubasz.esy.es' : 'http://kubasz.esy.es/feed/',
    'http://www.webatelier.io': 'http://www.webatelier.io/blog.xml'
}


def find_all_feeds(site_url):
    print site_url + str()
    try:
        site_feeds = feeds(site_url)
        if len(site_feeds) == 0:
            if site_url in exceptions:
                yield site_url, exceptions[site_url]
            else:
                yield site_url, None,
        for feed_url in site_feeds:
            yield site_url, feed_url
    except TimeoutError:
        print "Timeout for" + site_url
    except Exception as err:
        print 'Error ' + str(err) + ' \nfor ' + site_url

all_feeds = [
    feed
    for site in devs.blog_url.values
    for feed in find_all_feeds(str(site))
]

all_feeds_df = DataFrame(all_feeds)
all_feeds_df.columns = ['blog_url', 'feed_url']


#all_feeds_df.to_csv('..\\..\\data\\all_rss_feeds_cleaned.csv', encoding="utf-8", index=False)




#List of known blogs without rss. Not used in a code, only for verification.

known_notfound = [
'http://wolfman12333-ethicalhacker.simplesite.com' #dead
,'http://github.com/piotrkowalczuk/charon' #no blog
,'http://mkotas.cz' #no content
,'https://gpks.github.io' #no rss, active (so so)
,'http://nikow.pl' # empty page
,'http://koderatornia.pl' #aktywny blog!
,'http://blog.gotowal.ski' #so so..., no rss
,'https://www.facebook.com/Akti-486837264835951/?ref=bookmarks' # not exists, repo empty
,'http://www.sztobar.net' # not accesible site
,'http://www.ankwieci.pl' # not existing webio site
,'http://asznajder.github.io' # dead blog, no rss
,'https://blog.luzid.co/concerto' # dead, no access
,'http://kicholen.github.io' # dead
,'http://alien-mcl.github.io/URSA/posts.html' # well maintained blog, no rss
,'http://www.blog.foodculture.pl' #dead
,'http://pushitapp.azurewebsites.net' #dead
,'http://sirdigital.pl' #dead
,'http://kaolo.azurewebsites.net' # empty blog
,'http://mnets.simplesite.com' # dead
,'http://www.marcinwalas.com', # active but wrong rss
]






