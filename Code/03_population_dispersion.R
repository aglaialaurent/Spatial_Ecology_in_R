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
#Select presences by doing a subset
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

#Ancillary data, abiotic variables which shape life of organisms. One of them is the biomass, which is biotic
elev <- system.file("external/elevation.asc", package="sdm")

elevmap <- rast(elev) #Use rast instead of vect because it is a raster, a map
plot(elevmap)

# Exercise: change the colors of the elevation map by the colorRampPalette function
cl <- colorRampPalette(c("green","hotpink","mediumpurple"))(100)
plot(elevmap, col=cl) 

# Exercise: plot the presnces together with elevation map
points(pres, pch=19) #more presences in low/medium elevation, and less in high elevation

#Ex: import temperature and plot presences vs temperature
temp <- system.file("external/temperature.asc", package="sdm")
tempmap <- rast(temp)
plot(tempmap)
points(pres, pch=19)

#change colors with viridis package
install.packages("viridis")
library(viridis)
plot(tempmap, col=mako(100))

#ex: plot elevation and temperaturewith presences one beside the other
par(mfrow=c(1,2))
plot(elevmap, col=inferno(100))
points(pres, pch=19)
plot(tempmap, col=mako(100))
points(pres, pch=19)

#precipitation
prec <- system.file("external/precipitation.asc", package="sdm")
precmap <- rast(prec)
plot(precmap)
points(pres)

#vegetation
vege <- system.file("external/vegetation.asc", package="sdm")
vegemap <- rast(vege)
plot(vegemap)
points(pres)

#Exercise: plot all ancillary variables in a multiframe
par(mfrow=c(2,2))
plot(elevmap)
plot(tempmap)
plot(precmap)
plot(vegemap)

#use stack
anci<-c(elevmap,tempmap,precmap,vegemap)
plot(anci,col=magma(100))

