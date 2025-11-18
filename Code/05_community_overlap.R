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

#How much time spent by the tiger is overlapping with that of the macaque. WHat is the adaptation of the macaque to survive to the tiger
overlapPlot(tigertime, macaquetime)
#we see that macaque avoids meeting tiger for survivability
plot(density(species_data$circtime), 
       main = paste("Density Plot of Circumference for", species), 
       xlab = "Circumference")
}
