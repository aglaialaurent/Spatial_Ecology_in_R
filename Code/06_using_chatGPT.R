#This code is related to the possibility to use AI to speed up coding practices

#Ex with a for loop, lets take the code from the overlap example

#First: teach the process to chatGPT
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

tigertime <- tiger$circtime
densityPlot(timetiger)

#Exercise: repeat for macaque
macaque <- kerinci[kerinci$Sps == "macaque",]
macaquetime <- macaque$circ
densityPlot(macaque$circtime)


#Now ask chatgpt to speed up the process
#State something like:
#I would like to build a for loop to make the density plot of all the species 
