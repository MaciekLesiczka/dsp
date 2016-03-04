
library(ggplot2)
library(waffle)
library(extrafont)


df = read.csv('../../data/devs_with_sex.csv',encoding = "UTF-8")

freq = table(df$female)

dimnames(freq) = list(c("coding guys", "coding girls"))

#or use_glyph="female" for female icon. waffle currently doesn't support diffrent
waffle(freq, rows = 10,colors=c("#969696", "palevioletred1"),use_glyph="male",glyph_size=8,xlab="Daj się poznać 2016") +
   ggtitle("20 out of total 230 contestants are women") +
  
   theme(plot.title = element_text(size = rel(1.7)))

