#This code is related to multivariate analysis of RS data

library(imageRy)
library(terra)
library(ggplot2)
library(viridis)
library(patchwork)

sent <- im.import("sentinel.png")

p1<-im.ggplot(sent[[1]])
p2<-im.ggplot(sent[[2]])
p3<-im.ggplot(sent[[3]])

p1+p2+p3

pairs(sent)

#names of the bands
names(sent) <- c("b01_nir", "b02_red", "b03_green")
pairs(sent)

sentpc <- im.pca(sent)

pcsd3 <- focal(sentpc[[1]])

      
