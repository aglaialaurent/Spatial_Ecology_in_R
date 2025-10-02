2+3
#this is a comment, R will not read this but humans will

kat<-2+3

deanna<-5+7

#instead of 2+3+5+7
kat+deanna

#instead of (2+3)*(5+7)
kat*deanna

ade<-c(10,20,50,80,95) #these are the samples of Adelaide containing insect species richness
lara<-c(3,5,15,27,30) #these are species numbers of different taxa found by different scientists

#Is the bumber of insect species related to the number of speces of different taxa?
plot(lara,ade) 

#lets put different arguments
plot(lara, ade, xlab="All taxa species richness", ylab="Insects species richness")

plot(lara, ade, xlab="All taxa species richness", ylab="Insects species richness", col="blue") #add color

plot(lara, ade, xlab="All taxa species richness", ylab="Insects species richness", col="blue", pch=19) #change symbol

plot(lara, ade, xlab="All taxa species richness", ylab="Insects species richness", col="blue", pch=19, cex=2) #increase character size

plot(lara, ade, xlab="All taxa species richness", ylab="Insects species richness", col="blue", pch=19, cex=0.5) #decrease character size
