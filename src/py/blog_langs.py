#Identifies text language
#Sample usage
# all_feeds_df['lang'] = all_feeds_df.summary.map(lambda x: detect_language(x))
from langdetect import detect


def detect_language(txt):
    result = None
    if txt is not None:
        no_tags = tag_re.sub('', txt)
        try:
            result = detect(no_tags)
        except Exception as err:
            print 'Error ' + str(err) + ' \nfor ' + txt
    return result





print 'undable o detect langage for ' + str(len(all_feeds_df[all_feeds_df.summary.notnull()][all_feeds_df.lang.isnull()])) +\
    ' entries out of ' + str(len(all_feeds_df[all_feeds_df.summary.notnull()])) + ' not empty summaries'
