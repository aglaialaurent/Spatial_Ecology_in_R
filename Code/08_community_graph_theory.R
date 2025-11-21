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

#Create graph, directed means that there is a direction from predator to prey
g <- graph_from_data_frame(interactions, vertices = species, directed = TRUE)
