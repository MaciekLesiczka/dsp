#Extracts all post entries from all known RSS feeds

from feedparser import parse
from pandas import DataFrame
import time
from datetime import datetime

posts_rss = DataFrame.from_csv('..\\..\\data\\post_rss.csv', encoding="utf-8", index_col=False)


def get_feed(feed_url):
    print feed_url
    try:
        rss_feed = parse(feed_url)
        if rss_feed['status'] == 403:
            rss_feed = parse(feed_url.replace('http://', 'https://'))
        if len(rss_feed.entries) == 0:
            yield feed_url, None, None
        for entry in rss_feed.entries:
            published = None
            if 'published_parsed' in entry:
                published = entry.published_parsed
            elif 'updated_parsed' in entry:
                published = entry.updated_parsed
            yield feed_url, published, entry.link
    except Exception as err:
        print 'Error ' + str(err) + ' \nfor ' + feed_url


all_items = [

    item
    for feed in posts_rss.feed_url.values
    for item in get_feed(str(feed))
]


def get_date_string(parsed):
    if parsed is None:
        return ''
    else:
        return datetime(parsed.tm_year, parsed.tm_mon,parsed.tm_mday).strftime("%Y-%m-%d")


all_posts = [( i[0],i[2],  get_date_string( i[1]) ) for i in all_items]
all_posts_df = DataFrame(all_posts)
all_posts_df.columns = ['feed_url', 'post_url', 'date']

all_posts_df.to_csv('..\\..\\data\\posts_link_archive\\'+time.strftime("%Y%m%d")+'.csv', encoding="utf-8", index=False)



