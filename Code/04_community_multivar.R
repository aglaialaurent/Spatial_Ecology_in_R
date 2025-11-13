#Code for performing multivariate analysis with community abundance matrices
install.packages("vegan")
library(vegan)

data(dune)
head(dune) 

#to see relationships between different species, need smth more, just table isnt sufficient - need to move to graphical perspective

#detrended correspondence analysis, data is dispersed, need to detrend to comapcg it together and see it in a new space. (shouldnt perform directly a pca)
#multivariate analysis
multivar <- decorana(dune)
multivar #length of diff axes

#sum of all axes and see difference percentage btween them
dcal1 = 3.7004
dcal2 = 3.1166
dcal3 = 1.30055
dcal4 = 1.47888

#calculating percerntage of each axis:
total = dcal1 + dcal2 + dcal3 + dcal4
#or
total <- sum(c(dcal1,dcal2,dcal3,dcal4))

#percentage of dca1
percdca1 = dcal1 * 100 / total
percdca2 = dcal2 * 100 / total

percdca1 + percdca2
#2 dimensions explain 71.03683 percent of the total variation

plot(multivar)



#Principal component analysis
multipca <- pca(dune)
#if plot multipca, we see it is all compacted with some strays, not wel ligible
