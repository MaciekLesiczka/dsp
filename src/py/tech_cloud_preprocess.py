from pandas import DataFrame

from collections import defaultdict


devs = DataFrame.from_csv("..\..\data\\tech_categories.csv", encoding="utf-8", index_col=False)


def group_tags():
    result = defaultdict(list)
    for idx in devs.index:
        for tag in devs.loc[idx].tech_stack.split(','):
            tag = tag.lower().strip()
            result[tag].append(devs.loc[idx].blog_url)
    return result

grouped = group_tags()


exceptions = ['gimp','grpc','scratch','powershell','clojure','lazarus','godot engine','accord.net']

df = DataFrame([(key,len(grouped[key]),','.join(grouped[key]) ) for key in  grouped.keys() if len(grouped[key]) > 1 or key in exceptions])


df.columns = ['tag', 'count', 'devs']

df.to_csv('../../data/tech_tags.csv',index=False)

len(grouped.keys())


