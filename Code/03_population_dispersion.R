install.packages("sdm")
install.packages("terra")
library(sdm)
library(terra)

file <- system.file("external/species.shp",package="sdm")

#convert to something that can be read by R
rana<-vect(file)
plot(rana) #distribution of occurencies of rana in the field, some samples refer to the presences, some refer to absence
rana$Occurence #see if presence or absence, stored in rana$Occurence

