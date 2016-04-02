#Extracts all post entries from all known RSS feeds

from feedparser import parse
from pandas import DataFrame


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
all_items

all_posts = [( i[0], i[1].tm_mday,i[1].tm_month, i[1].tm_year) for i in all_items if i[1] is not None and i[1].tm_mon >=3 and i[1].tm_year>=2016]


all_posts = [( i[0], None if i[1] is None else i[1].tm_mday, None if i[1] is None else i[1].tm_mon, None if i[1] is None else i[1].tm_year) for i in all_items]

all_posts_df = DataFrame(all_posts)


all_posts_df.columns = ['url', 'day', 'month', 'year']



len([i for i in all_items if i[1] is not None and i[1].tm_mon >=3 and i[1].tm_year>=2016])

len([i for i in all_items if i[1] is not None and i[1].tm_mon >=3 and i[1].tm_year>=2016])


#all_posts_df.to_csv('..\\..\\data\\all_posts_27032016.csv')



