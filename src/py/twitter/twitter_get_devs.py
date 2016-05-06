#Script loads all users that posted status with #dajsiepoznac hashtag


from twitter_common import *
from BeautifulSoup import BeautifulSoup
import io, json
from urlparse import urlparse
from pandas import DataFrame
import pandas as pd
from datetime import datetime

# Step 1. scrap tweet ids from a page

page=open("C:\Users\Maciek\Desktop\\twitter\\tweets_03052016.html",'r').read() #yupp, you will have to provide saved html from tweeter search page
soup = BeautifulSoup(page)
list_items = soup.findAll("li", 'stream-item')
tweets = [
    {
        'username':li.findAll("span", 'js-action-profile-name')[0].findAll('b')[0].text,
        'id':li.div['data-tweet-id']
    } for li in list_items]


# Step 1. get tweet details from API


ranges = [(n*100,(n+1)*100) for n in range(0, len(tweets)/100)]
ranges.append((ranges[-1][1],len(tweets)))

# Step 2. get all tweets by lookup

def getAllTeets():
    arrays = []
    for (f, t) in ranges:
        q = ','.join([t['id'] for t in tweets[f:t]])
        arrays.append(twitter_api.statuses.lookup(_id=q))
    return [t
            for array in arrays
            for t in array]


tweetsJson = getAllTeets()


with io.open('..\..\..\data\\tweeter\\tweets_03052016.json', 'w', encoding='utf-8') as f:
  f.write(unicode(json.dumps(tweetsJson, ensure_ascii=False)))



# with io.open('..\..\data\\tweets_03052016.json', 'r', encoding='utf-8') as f:
#     json_data = json.load(f)
#     print(json_data)



## Step 3. Cleanup

def date_time_from_string(txt):
    return datetime.strptime(txt, '%a %b %d %H:%M:%S +0000 %Y')
for t in tweetsJson:
    t['created_at'] = date_time_from_string(t['created_at'])


def tuser(t):
    return t['user']['screen_name']


def get_netloc(x):
    result = urlparse(x).netloc.lower()
    if result.startswith('www.'):
        result = result[4:]
    return result


def unshorten_url(url):
    parsed = urlparse(url)
    h = httplib.HTTPConnection(parsed.netloc)
    h.request('HEAD', parsed.path)
    response = h.getresponse()
    if response.status/100 == 3 and response.getheader('Location'):
        return response.getheader('Location')
    else:
        return url


# some domains and account dont belong to participants and intruduce noise
excluded_domains = {'twitter.com','maciejaniserowicz.com','softwarehut.pl','github.com', 'facebook.com',
                    #I'm lucky. wybraniect posted link to my bog without retweeting
                    'macieklesiczka.github.io'}
excluded_accounts = {'dotnetomaniak','maniserowicz','dariusz_lenart','gutek','barozanski','infoWirepl','spotkaniait'}

# there are some slight discrepancies (domain redirects, mistakes in submissions) we have to handle manually
found_manually = {
    'Adamskodev': 'skobo.pl',
    'slavciu': 'rzeczybezinternetu.blogspot.com',
    'pikoscielniak': 'koscielniak.me',
    'piotrstadnik': 'lazybitch.com',
    'borowczykk': 'codestorm.pl',
    'BentkowskiJakub': 'bentkowski.northeurope.cloudapp.azure.com',
    'larciszewski': 'duszekmestre.wordpress.com',
    'MaciekLesiczka': 'macieklesiczka.github.io',
    'KrzysztofSeroka': 'chrisseroka.wordpress.com'
}

announcementDay = datetime(2016,02,01)
dsp16 = [t for t in tweetsJson if t['created_at'] >= announcementDay and t['retweeted']==False]


all_urls = [{'url': url['expanded_url'], 'user': tuser(t), 'domain':get_netloc(url['expanded_url'])}
      for t in dsp16
      for url in t['entities']['urls']]

all_urls = DataFrame(all_urls)
all_urls = all_urls[all_urls.domain.isin(excluded_domains) == False ][all_urls.user.isin(excluded_accounts) == False]


## Step 4. find all accounts by blog URL


devs = DataFrame.from_csv("..\..\..\data\devs.csv", encoding="utf-8",index_col=False)[['blog_url', 'first_name', 'last_name']]
devs['domain'] = devs.blog_url.map(lambda x: get_netloc(x))

accounts_domains = all_urls[['user', 'domain']].drop_duplicates()
accounts_domains = pd.concat([accounts_domains, DataFrame( {'user': found_manually.keys(), 'domain': found_manually.values()} )])

found_by_blog_url = pd.merge(accounts_domains ,devs, on='domain')


## 5. find by shortened urls

exluded_or_found = list(excluded_accounts) +list(found_by_blog_url.user.values)+found_manually.keys()
not_found = all_urls[all_urls.domain.isin(excluded_domains) == False][all_urls.user.isin(exluded_or_found) == False]
not_found['url'] = not_found.url.map(lambda x: unshorten_url(x))
not_found['domain'] = not_found.url.map(lambda x: get_netloc(x))
not_found = not_found[not_found.domain.isin(excluded_domains)==False]


found_by_short_url = pd.merge(not_found[['user', 'domain']].drop_duplicates() ,devs, on='domain')

twitter_accounts = pd.concat([found_by_short_url,found_by_blog_url])[['blog_url', 'user', 'first_name', 'last_name']]

# 5.1 method above doesn't guarantee uniquness, so let's check duplicates and remove them
twitter_accounts = twitter_accounts[(twitter_accounts.user!='mdymel') | (twitter_accounts.last_name!='Sroka')]
twitter_accounts.groupby('user').size()[twitter_accounts.groupby('user').size()!=1]


## 6. add accounts details

user_details = twitter_api.users.lookup(screen_name = ','.join(twitter_accounts.user.values))

user_details_df = DataFrame([
    {
        'user': ud['screen_name'],
        'followers_count': ud['followers_count'],
        'friends_count': ud['friends_count'],
        'id': ud['id_str']
    } for ud in user_details
])


twitter_accounts = pd.merge(user_details_df,twitter_accounts,  on='user')
twitter_accounts.to_csv("..\..\..\data\\twitter\\devs.csv", encoding="UTF-8", index=False)


## 6. get tweets times

dsp16_dates = DataFrame( [{'time' : str(t['created_at']),'user':t['user']['name'] } for t in dsp16])

dsp16_dates.to_csv("..\..\..\data\\twitter\\dates.csv", encoding="UTF-8", index=False)