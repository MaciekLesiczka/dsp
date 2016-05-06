from twitter_common import *
from pandas import DataFrame
user_dets = DataFrame.from_csv("..\..\..\data\\twitter\\devs_with_links2.csv", encoding="UTF-8")

#user_dets_with_friends = user_dets[user_dets['friends'].notnull()]

# participants only links

links =  DataFrame([ {'source': uid, 'target': fid}
  for uid in user_dets.index
  for fid in [long(x) for x in user_dets.ix[uid,'friends'].split(',')]
  if fid in user_dets.index
])

links.to_csv("..\..\..\data\\twitter\\links.csv", encoding="UTF-8",index_col=False)


#expand all links and get

all_links =  DataFrame([{'source': uid, 'target': fid}
  for uid in user_dets.index
  for fid in [long(x) for x in user_dets.ix[uid,'friends'].split(',')]])



all_links_no_parts = all_links[all_links.target.isin(list(user_dets.index.values))==False]
groups = all_links_no_parts.groupby('target').size()
groups.sort(ascending=False)


top_count = 15
popular_details = get_user_details(groups.head(top_count).index)
popular_details = popular_details.set_index('id')

popular_details['friends'] = None

def download_followers_friends(frame, dump_file):
    for id in frame.index.values:
        print 'getting connections for ' + str(id) + '...'
        friends = twitter_api.friends.ids(_id =id, count=5000)
        frame.ix[id,'friends'] = ','.join([str(fid) for fid in friends['ids']])
        frame.to_csv(dump_file, encoding="UTF-8", index_col=True)
        print 'connections saved ' + str(id)

    print 'complete!'


download_followers_friends(popular_details,"..\..\..\data\\twitter\\popular_with_links.csv")

popular_details = DataFrame.from_csv("..\..\..\data\\twitter\\popular_with_links.csv", encoding="UTF-8")

popular_details.index

# friends formatted for the graph

def get_display_name(x, prefix, df):
    user_name = df.ix[x, 'user']
    return prefix + '.' + user_name



all_people_to_display =  [
    {'name':get_display_name(uid,'part',user_dets),
     'imports':[
             get_display_name(long(x),'part',user_dets) for x in user_dets.ix[uid,'friends'].split(',')  if long(x) in user_dets.index.values]+[
             get_display_name(long(x),'popular',popular_details) for x in user_dets.ix[uid,'friends'].split(',')  if long(x) in popular_details.index.values]
     }
  for uid in user_dets.index
]+[
    {'name':get_display_name(uid,'popular',popular_details),
     'imports':[
             get_display_name(long(x),'part',user_dets) for x in popular_details.ix[uid,'friends'].split(',')  if long(x) in user_dets.index.values]+[
             get_display_name(long(x),'popular',popular_details) for x in popular_details.ix[uid,'friends'].split(',')  if long(x) in popular_details.index.values]
     }
  for uid in popular_details.index
]



with io.open('..\..\..\data\\twitter\\all_people_to_display.json', 'w', encoding='utf-8') as f:
  f.write(unicode(json.dumps(all_people_to_display, ensure_ascii=False)))



