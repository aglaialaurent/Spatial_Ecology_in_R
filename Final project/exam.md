# Spatial Distribution and Elevational Patterns of *Parnassius apollo* in Italy

## Introduction

Understanding the spatial distribution of species is a fundamental topic in ecology, as it provides insights into habitat preferences, environmental constraints, and potential responses to climate change. Mountain species are particularly relevant in this context, since elevation strongly influences temperature, vegetation structure, and ecological conditions.

Spatial analyses based on occurrence records allow researchers to map where species are found and relate their distribution to environmental variables. When combined with topographic data, such analyses can reveal whether a species is associated with specific elevation ranges and whether this relationship changes over time.

The objective of this project is to analyze the spatial distribution and elevational patterns of *Parnassius apollo*, a montane butterfly species occurring in Italy, using occurrence data obtained from the Global Biodiversity Information System (GBIF). The analysis focuses on:

- Visualizing occurrence points across Italy  
- Relating occurrences to elevation  
- Exploring potential changes in elevation over time  

---

## Data and Methods

### Data Source

Occurrence data were obtained from the GBIF database using the scientific name *Parnassius apollo*. Only records meeting the following criteria were included:

- Country: Italy  
- Valid geographic coordinates  
- Records from 1980 onwards  
- Coordinate uncertainty < 1000 meters  

Elevation data were obtained from the WorldClim 2.1 global elevation raster (30 arc-second resolution).

---

### R Packages

```r
library(rgbif)        # Access GBIF data
library(dplyr)        # Data cleaning
library(terra)        # Raster data handling
library(ggplot2)      # Data visualization
library(viridis)      # Colorblind-friendly color scales
library(sf)           # Spatial vector data
library(rnaturalearth)
library(rnaturalearthdata)
```

---

### Data Collection and Preprocessing

Occurrence records were downloaded using `occ_search()` from the `rgbif` package. The dataset was filtered to remove missing coordinates and records with high spatial uncertainty. Records prior to 1980 were excluded to focus on recent decades, where sampling effort and georeferencing accuracy are generally higher.

A geographic bounding box was applied to ensure that only records within Italy were retained.

```r
occ_gbif <- occ_search(
  scientificName = "Parnassius apollo",
  country = "IT",
  hasCoordinate = TRUE,
  limit = 120000
)

data_gbif <- occ_gbif$data

data_clean <- data_gbif %>%
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  filter(is.na(coordinateUncertaintyInMeters) | coordinateUncertaintyInMeters < 1000) %>%
  filter(!is.na(year) & year >= 1980)

butterfly <- data.frame(
  lon = data_clean$decimalLongitude,
  lat = data_clean$decimalLatitude,
  year = data_clean$year
)

butterfly <- butterfly[
  butterfly$lon > 6 & butterfly$lon < 19 &
  butterfly$lat > 36 & butterfly$lat < 48, ]
```

---

### Elevation Data Processing

The WorldClim elevation raster was loaded and cropped to the political boundaries of Italy using `rnaturalearth`. This ensured that elevation values corresponded only to the study area.

```r
elev_file <- "~/Documents/UNIVERSITY/wc2.1_30s_elev.tif"
elev <- rast(elev_file)

italy <- ne_countries(country = "Italy", scale = "medium", returnclass = "sf")
italy_vect <- vect(italy)

elev_italy <- crop(elev, italy_vect)

elev_df <- as.data.frame(elev_italy, xy = TRUE)
colnames(elev_df) <- c("x", "y", "elevation")
```

---

### Elevation Extraction

Occurrence coordinates were converted into spatial points and overlaid with the elevation raster. Elevation values were extracted for each butterfly record.

```r
butterfly_vect <- vect(butterfly, geom = c("lon", "lat"), crs = "EPSG:4326")

butterfly$elevation <- extract(elev_italy, butterfly_vect)[,2]
```

---

## Results

### Occurrence Map and Elevation Gradient

The following map visualizes the elevation gradient across Italy together with the occurrence records of *Parnassius apollo*.

```r
ggplot() +
  geom_raster(data = elev_df, aes(x = x, y = y, fill = elevation)) +
  geom_sf(data = italy, fill = NA, color = "black") +
  geom_point(data = butterfly,
             aes(x = lon, y = lat),
             color = "green", size = 0.6, alpha = 0.6) +
  scale_fill_viridis(option = "rocket", direction = -1) +
  labs(title = "Parnassius apollo occurrences in Italy",
       fill = "Elevation (m)") +
  coord_sf(expand = FALSE) +
  theme_void()
```

The map indicates that occurrence records are concentrated in mountainous regions, particularly in the Alps and along the Apennine range. Lowland areas show very few or no records, reflecting the species’ association with high-elevation habitats.

---

### Elevation Over Time

To explore potential elevational shifts, elevation values were plotted against year of observation. A smoothing curve was added to visualize temporal trends.

```r
ggplot(butterfly, aes(x = year, y = elevation)) +
  geom_point(alpha = 0.3) +
  geom_smooth(color = "black") +
  theme_minimal() +
  labs(title = "Elevation of Parnassius apollo over time",
       y = "Elevation (m)")
```

If an upward trend is observed in the smoothing line, this may indicate a shift toward higher elevations over recent decades, potentially consistent with climate warming.

---

### Period Comparison (Before and After 2000)

Records were divided into two temporal periods to facilitate comparison:

- Before 2000  
- After 2000  

```r
butterfly$period <- ifelse(butterfly$year < 2000,
                           "Before 2000",
                           "After 2000")

ggplot(butterfly, aes(x = period, y = elevation)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Elevation shift of Parnassius apollo",
       y = "Elevation (m)")
```

Differences in median elevation between periods may suggest changes in elevational distribution through time.

---

## Discussion

The spatial distribution confirms that *Parnassius apollo* is strongly associated with mountainous regions in Italy. The concentration of records in the Alps and Apennines reflects the species’ ecological preference for cooler environments and alpine habitats.

The temporal analysis provides preliminary insights into potential elevational changes. If higher median elevations are observed in recent years, this pattern may suggest climate-driven upward shifts. However, interpretation must consider possible sampling bias, uneven survey effort, and habitat availability constraints.

Further analyses incorporating statistical testing or climatic variables would strengthen these conclusions.

---

## Conclusion

This project demonstrates how GBIF occurrence data can be integrated with environmental raster data to analyze spatial and elevational patterns of a mountain species. By combining geographic visualization with temporal analysis, it is possible to explore potential climate-related shifts using reproducible methods in R.

Such approaches are valuable tools for biodiversity monitoring, ecological research, and conservation planning.
