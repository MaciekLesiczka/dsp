from pandas import DataFrame
import re

devs = DataFrame.from_csv("..\..\data\devs.csv", encoding="utf-8", index_col=False)


def n_grams(txt, n):
    txt = txt.split(' ')
    output = {}
    for i in range(len(txt)-n+1):
        g = ' '.join(txt[i:i+n])
        output.setdefault(g, 0)
        output[g] += 1
    return output


def pre_process(txt):
    return re.sub(' +', ' ', txt
                  .lower()
                  .replace('/', ' ')
                  .replace(',', ' ')
                  .replace('(', ' ')
                  .replace(')', ' ')
                  .replace('!', ' ')
                  .replace('?', ' ')
                  .replace('.net', 'dotnet')
                  .replace('.', ' ')
                  ).replace('dotnet', '.net')


text_to_examine = ','.join(devs.tech_stack.values)
processed = pre_process(text_to_examine)
unigrams = n_grams(processed, 1)
bigrams = n_grams(processed, 2)
trigrams = n_grams(processed, 3)

tech_ngrams = DataFrame(
    [(key, value, 1) for key, value in unigrams.items() if value > 1] +
    [(key, value, 2) for key, value in bigrams.items() if value > 1] +
    [(key, value, 3) for key, value in trigrams.items() if value > 1]
)

tech_ngrams.columns = ['ngram', 'count', 'n']

tech_ngrams.to_csv('..\..\data\\tech_ngrams.csv', encoding="utf-8", index=False)

