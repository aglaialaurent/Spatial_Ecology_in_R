#Code for graph theory in ecology
install.packages("igraph")
library(igraph)

species <- c("Algae", "Zooplankton", "Small Fish", "Large Fish", "Bird")

#build 1 column
predator <- c("Zooplankton", "Small Fish", "Large Fish", "Bird", "Bird")
#another colum
prey<- c("Algae", "Zooplankton", "Small Fish", "Small fish", "Large Fish")

#Build a data frame
interactions <- data.frame(predator,prey)
