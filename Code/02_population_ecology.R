#Code for studying population spread over space

install.packages("spatstat")

library(spatstat)

bei #points spread in a space

plot(bei) #see points spread over space

#changing characters
plot(bei, pch=15)

#decrease size of points bcs they are clumped together
 plot(bei, pch=15, cex=0.5)

#inside spatstat package there are variables representing the way the pop is spread
bei.extra #anciallary variables, elevation and gradient #what is it about?# are images composed of pixels

#selecting only the elevation
el <- bei.extra$elev
plot(el)

#other way, when have table called bei.extra and a column where el is the first. 
el <- bei.extra[[1]] #using double square brackets because its not a simple table but an image

#density map
dmap<-density(bei)
plot(dmap) #density mapof spread of my population

#put points on top of the map
points(bei)

points(bei,pch=15,cex=0.5) #changed look of points

plot(el)
points(bei) #at higher elevations thereare less points


