#This code can be used to classify satellite data
library(terra)
library(imageRy)
im.list()
m1992 <-im.import("matogrosso_l5_1992219_lrg.jpg")
#from outside the imageRy package: rast() function from terra
#layers: 1=NIR, 2=red, 3=green
plot(m1992) #rgb123

m2006 <-im.import("matogrosso_ast_2006209_lrg.jpg")
plot(m2006)             

#testing classification
#solar orbiter is a satellite monitoring the gases from the sun
sun <- im.import("Solar_Orbiter_s_first_views_of_the_Sun_pillars.jpg")

sunc <- im.classify(sun,num_clusters=3) #unsupervised classification

par(mfrow=c(2,1))
plot(sun)
plot(sunc) #purple highest energy, yellow is mid, blue is lowest

#apply the classification process to the Mato Grosso
m1992c <- im.classify(m1992, num_clusters=2)
#class 1: human+water
#class2: rainforest

#Ex: classify the 2006 image
m2006c <- im.classify(m2006, num_clusters=2)
#class 1: rainforest
#class 2: human +water(look at river to recognize)

#calculating frequencies
f1992 <-freq(m1992c)

#Proportions
#f/tot
tot1992c <- ncell(m1992c)
#tot1992cis 1 800 000 pixels
#we can make the proportions by looking at count attribute of frequencies

prop1992 = f1992$count / tot1992c
# prop1992
#[1] 0.1691317 0.8308683
#now we can calculate the percentage 

perc1992 = prop1992*100
#perc1992
#16.91317 83.08683
#1992: the human areas = 17%, and the forest = 83%. 

#You can calculate everything in a single line
perc1992=freq(m1992c) * 100 / ncell(m1992c)

#Calculate percentages of 2006
f2006 <-freq(m2006c)
tot2006c <- ncell(m2006c)
prop2006 = f2006$count / tot2006c
perc2006 = prop2006*100
#perc2006
#45.30561 54.69439
#In 2006, class 1 forest = 45%, class2 human = 55%

class <- c("forest","human")
perc1992 <-c(83,17)
perc2006 <- c(45,55)

#Make dataframe
tabout <- data.frame(class,perc1992,perc2006)
tabout #the data frame is ready to go

#Using ggplot2 package for the final graph
ggplot(tabout, aes(x=class, y=perc1992, color=class))+
geom_bar(stat="identity",fill="white")


#same plot for 2006
ggplot(tabout, aes(x=class, y=perc2006, color=class))+
geom_bar(stat="identity",fill="white")


install.packages("patchwork")
library(patchwork)
p1+p2
p1/p2
#problem: the scale is notthe same for the 2 graphs
#use function ylim to scale
p1 <-ggplot(tabout, aes(x=class, y=perc1992, color=class))+ geom_bar(stat="identity",fill="white")+ ylim(c(0,100))
p2 <-ggplot(tabout, aes(x=class, y=perc2006, color=class))+ geom_bar(stat="identity",fill="white")+ylim(c(0,100))


