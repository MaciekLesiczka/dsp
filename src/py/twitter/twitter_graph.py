import time

from pandas import DataFrame

import twitter_get_devs
from dsp_twitter_auth import *

auth = twitter_get_devs.oauth.OAuth(OAUTH_TOKEN, OAUTH_TOKEN_SECRET, CONSUMER_KEY, CONSUMER_SECRET) #provide those values from your own imported script (dsp_twitter_auth.py)
twitter_api = twitter_get_devs.Twitter(auth=auth)

users = DataFrame.from_csv("..\..\..\data\\twitter\\devs.csv", encoding="UTF-8")
users['followers'] = None
users['friends'] = None
users=users.set_index('id')


def download_followers_friends():
    for id in users.index.values:
        print 'getting connections for ' + str(id) + '...'
        friends = twitter_api.friends.ids(_id =id, count=5000)
        followers = twitter_api.followers.ids(_id=id,count=5000)
        users.ix[id,'friends'] = ','.join([str(fid) for fid in friends['ids']])
        users.ix[id,'followers'] = ','.join([str(fid) for fid in followers['ids']])
        users.to_csv("..\..\..\data\\twitter\\devs_with_links2.csv", encoding="UTF-8", index_col=True)
        print 'connections saved ' + str(id)
        print 'waiting...'
        time.sleep(65)
    print 'complete!'




users[users.followers.isnull()]

users.index.values[43:]

download_followers_friends()