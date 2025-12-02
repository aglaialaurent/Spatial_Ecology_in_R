#Spectral indices from satellite images

library(terra)
library(imageRy)
library(viridis)

#List
im.list()

# Importing data
m1992 <- im.import("matogrosso_l5_1992219_lrg.jpg")
#layer 1 = NIR, layer 2 = red, layer 3 = green

im.plotRGB(m1992, r=1, g=2, b=3) #putting NIR on top of the red, everything that will reflect the NIR will become red, so its the original forest

im.plotRGB(m1992, r=2, g=1, b=3) #putting NIR on top of green, so everything reflecting NIR will be green
#water doesnt look black, means its not pure water but it is mixed with mud or smth

im.plotRGB(m1992, r=2, g=3, b=1) #vegetation blue, water/soil yellow

m2006 <- im.import("matogrosso_ast_2006209_lrg.jpg")
im.plotRGB(m2006, r=1, g=2, b=3)

#DVI = difference vegetation index. imagine image with 3 reflecatances in an image, arriving to 100 in nir, and 0 in red. 
#calculate dvi of 1992.
#dvi = nir - red = 100
#if the plant is suffering, the stressed leaf has decreased capability to reflect infrared, bcs the tissues collapse. for ex its nir decreases from 100 to 60. it will also absorb less red, bcs photosynthesis in chloroplast is decreased, so theres higher relfectance in red. 

#60 nir and 20 red
#dvi = NIR -red = 40


dvi1992 <- m1992[[1]] - m1992[[2]] #first layer minus second layer of the image
dvi2006 <- m2006[[1]] - m2006[[2]]

par(mfrow=c(1,2))
plot(dvi1992,col=inferno(100))
plot(dvi2006,col=inferno(100))
#we see that in 1992, the dvi was high everywhere, and in 2006 it has decreased a lot. 

#with ndvi, we standardize the data, if one image ranges from 0 to100, and another to 200, it will  normalize the data.
ndvi1992 <- im.ndvi(m1992,1,2)
ndvi2006 <- im.ndvi(m2006,1,2)
par(mfrow=c(1,2))
plot(ndvi1992,col=inferno(100))
plot(ndvi2006,col=inferno(100))
