# Code to visualize remote sensing data
install.packages("imageRy")
library(terra)
library(imageRy)
library(viridis)

# Listing data inside imageRy
im.list()

# importing the data
b2 <- im.import("sentinel.dolomites.b2.tif")
plot(b2) #everything blue is absorbed, all that is yellow is being reflected
plot(b2,col=magma(100))

#exercise: import and plot band 3 with the legend mako from viridis
b3 <- im.import("sentinel.dolomites.b3.tif")
plot(b3,col=mako(100))

cl <- colorRampPalette(c("black", "grey", "light grey")) (100)

#avoid to write multiframe everytime
multiframe <- function(x,y){par(mfrow=c(x,y))}

multiframe(1,2)
plot(b2,col=cl)
plot(b3,col=cl)

dev.off()
plot(b2,b3) #see they are very related, the bands 2 and 3 are correlated

#Exercise: usign the function that you developed, plot band 2, band 3 and their relationship, one beside the other
multiframe(1,3)
plot(b2,col=cl)
plot(b3,col=cl)
plot(b2,b3)

#importing the red band 4
b4 <- im.import("sentinel.dolomites.b4.tif")

# Importing the NIR band
b8 <- im.import("sentinel.dolomites.b8.tif")
