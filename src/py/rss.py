from pandas import DataFrame
from feedfinder import *
from feedparser import parse
from langdetect import detect
import re
tag_re = re.compile(r'(<!--.*?-->|<[^>]*>)')

devs = DataFrame.from_csv("..\..\data\devs.csv", encoding="utf-8", index_col=False)


exceptions = {
    'https://matma.github.io': 'http://matma.github.io/feed.xml'
}

def find_all_feeds(site_url):
    print site_url
    try:
        site_feeds = feeds(site_url)
        if len(site_feeds) == 0:
            if site_url in exceptions:
                site_feeds = [exceptions[site_url]]
            else:
                yield site_url, None, None, None, None
        for feed_url in site_feeds:
            rss_feed = parse(feed_url)
            if rss_feed['status'] == 403:
                rss_feed = parse(feed_url.replace('http://', 'https://'))
            if len(rss_feed.entries) == 0:
                yield site_url, feed_url, None, None, None
            for entry in rss_feed.entries:
                published = None
                if 'published_parsed' in entry:
                    published = entry.published_parsed
                elif 'updated_parsed' in entry:
                    published = entry.updated_parsed
                yield site_url, feed_url, entry.summary, published, entry.link
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
all_feeds_df.columns = ['blog_url', 'feed_url', 'summary', 'date', 'link']

all_feeds_df['date'] = all_feeds_df.date.map(lambda x: None if x is None else '%d-%d-%d %d:%d:%d' % x[0:6] )

all_feeds_df[all_feeds_df.summary.notnull()][all_feeds_df.date.isnull()]


def detect_language(txt):
    result = None
    if txt is not None:
        no_tags = tag_re.sub('', txt)
        try:
            result = detect(no_tags)
        except Exception as err:
            print 'Error ' + str(err) + ' \nfor ' + txt
    return result

all_feeds_df['lang'] = all_feeds_df.summary.map(lambda x: detect_language(x))

print 'undable o detect langage for ' + str(len(all_feeds_df[all_feeds_df.summary.notnull()][all_feeds_df.lang.isnull()])) +\
    ' entries out of ' + str(len(all_feeds_df[all_feeds_df.summary.notnull()])) + ' not empty summaries'

print str(len(all_feeds_df)) + ' items'

all_feeds_df.to_csv('..\\..\\data\\feed.csv', encoding="utf-8", index=False)
