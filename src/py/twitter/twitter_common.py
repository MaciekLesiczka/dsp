import httplib
import twitter
from pandas import DataFrame
from dsp_twitter_auth import *
auth = twitter.oauth.OAuth(OAUTH_TOKEN, OAUTH_TOKEN_SECRET, CONSUMER_KEY, CONSUMER_SECRET) #provide those values from your own imported script (dsp_twitter_auth.py)
twitter_api = twitter.Twitter(auth=auth)

def get_user_details(user_ids):
    result = twitter_api.users.lookup(user_id = ','.join([str(uid) for uid in user_ids]))
    return DataFrame([
    {
        'user': ud['screen_name'],
        'followers_count': ud['followers_count'],
        'friends_count': ud['friends_count'],
        'id': ud['id_str']
    } for ud in result
])
