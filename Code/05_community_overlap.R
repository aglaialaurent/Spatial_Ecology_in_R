# Code to estimate the amount of temporal overlap between species (animals which are moving)

# install.packages("overlap")
library(overlap)

data(kerinci)

#changing linear dimension of time to smth called radiance, view of time as a circular variable. we multiply time by 2 greek pi
circtime <- kerinci$Time* 2 * pi 
circtime

#add a new colum directly to table
kerinci$circtime <- kerinci$Time* 2 * pi 

#subset kerinci dataset choosing only the data of the tiger
tiger <- kerinci[kerinci$Sps == "tiger",]

densityPlot(tiger$circtime)
