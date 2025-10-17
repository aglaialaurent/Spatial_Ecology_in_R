install.packages("sdm")
install.packages("terra")

library(terra)
library(sdm)


file <- system.file("external/species.shp",package="sdm")

#convert to something that can be read by R
rana<-vect(file)
plot(rana) #distribution of occurencies of rana in the field, some samples refer to the presences, some refer to absence
rana$Occurence #see if presence or absence, stored in rana$Occurence.Occurrence refers to presence of DATA from field. 


#divide presences and absences by making subset of original dataset
#Select presences 
pres <- rana[rana$Occurrence==1] #doesnt equal is written !=

#Select absences:
abs <- rana[rana$Occurrence==0]
#or 
abs <- rana[rana$Occurrence!=0]

#Plot presences with a color together with the absences with another color
plot(pres, col="darkgreen") #cannot use plot for abs, but rather points()
points(abs, col="darkorchid4")

#Do the same in a multiframe with two sets, pres on top of abs
par(mfrow=c(2,1))
plot(pres, col="darkgreen")
plot(abs, col="darkorchid4")

