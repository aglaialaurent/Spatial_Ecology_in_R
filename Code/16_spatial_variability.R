# Script to measure variability

library(imageRy)
library(terra)
library(ggplot2)
library(patchwork)
library(viridis)

im.list()

sent <- im.import("sentinel.png")
im.plotRGB(sent, r=1, g=2, b=3)

# bands:
# 1 NIR
# 2 red
# 3 green

im.plotRGB(sent, r=2, g=1, b=3)
im.plotRGB(sent, r=2, g=3, b=1)

sentmean <-focal(sent[[1]],w=3, fun="mean")

# measuring standard deviation
nir <- sent[[1]]
sd3 <- focal(sent[[1]],w=3, fun="sd")

#assigning plotsto objects so that we can sum them after
p1 <- im.ggplot(nir)
p2<- im.ggplot(sentmean)
p3<- im.ggplot(sd3)
p1+p2+p3

plot(sd3, col=magma(100)) #points which there are the highest passage of species variability

#copy im.ggplotRGB function from another repo
im.ggplotRGB <- function(input_image, r = 1, g = 2, b = 3, 
                        stretch = "lin", title = "", downsample = 1) {
  
  # Only downsample if needed
  if (downsample == 1) {
    rgb_small <- input_image
  } else {
    rgb_small <- aggregate(input_image, fact = downsample)
  }
  
  # Convert only the downsampled version to data frame
  rgb_df <- as.data.frame(rgb_small, xy = TRUE)
  rgb_df <- na.omit(rgb_df)
  
  band_names <- names(rgb_df)[3:5]
  
  # Create ggplot
  p <- ggplot() +
    geom_raster(data = rgb_df, 
                aes(x = x, y = y, 
                    fill = rgb(
                      get(band_names[r]), 
                      get(band_names[g]), 
                      get(band_names[b]),
                      maxColorValue = max(c(get(band_names[r]), 
                                          get(band_names[g]), 
                                          get(band_names[b])), na.rm = TRUE)
                    ))) +
    scale_fill_identity() +
    coord_equal() +
    labs(title = title) +
    # theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
          axis.text = element_text(size = 8),
          panel.grid = element_blank())
  
  return(p)
}

#####
p0 <- im.ggplotRGB(sent,r=2,g=1,b=3)
p0+p1+p2+p3

#enlarge the window of analysis(bigger amount of pixels, was 3x3,now 5x5)
sd5<- focal(nir,w=5,fun="sd")
p4 <- im.ggplot(sd5)
p3+p4
#effect is that relative sd will increase. higher variability in yellow colors. 

p0+p3+p4


