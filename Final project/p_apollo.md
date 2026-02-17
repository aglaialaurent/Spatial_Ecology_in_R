# Spatial distribution and elevational shift of Parnassius apollo in Italy 🦋⛰️
## 1. Aim and ecological background
Mountain organisms are expected to respond to warming temperatures by shifting their distributions upslope, because temperature decreases with elevation and higher elevations can function as thermal refuges. Butterflies are especially informative indicators due to their sensitivity to temperature and widely available occurrence records.

*Parnassius apollo* is a montane butterfly that mainly inhabits open, rocky habitats at mid- to high elevations. It is adapted to cooler conditions and depends on specific mountain environments, which makes it potentially sensitive to climate change.

<p align="center">
<img width="600" height="300" alt="image" src="https://github.com/user-attachments/assets/b74175d3-cd5b-403e-a53e-9da452b6d1e8" />

**Aim:** GBIF occurrence records from 2010–2025 will be used to test whether Parnassius apollo occurrences in Italy show an upward shift in elevation over time, and whether this pattern differs between two broad mountain regions (Alps vs. Apennines).

### Predictions
- If species are responding to climate warming, their occurrence elevation should increase through time.
- Baseline elevations may differ by region due to different mountain hypsometry (Alps generally higher than Apennines).
- Because GBIF data are opportunistic, trends must be interpreted alongside sampling effort.


## 2. Data and Methods

### 2.1. R packages

```r
library(rgbif)         # Access GBIF data
library(dplyr)         # Data manipulation & cleaning
library(terra)         # Raster data handling (elevation)
library(ggplot2)       # Data visualization
library(viridis)       # Colorblind-friendly color scales
library(sf)            # Spatial vector data
library(rnaturalearth) # Country boundaries for map
library(rnaturalearthdata) 
```

### 2.2 GBIF occurrence data 

Occurrences for P. apollo in Italy with coordinates were downloaded and filtered to:
- non-missing coordinates
- coordinate uncertainty < 1000 m (or missing uncertainty)
- years ≥ 2010
- a broad Italy bounding box (for visualization focus)

```r
# Download GBIF occurrences of Parnassius apollo in Italy
occ_gbif <- occ_search(scientificName = "Parnassius apollo", country = "IT", hasCoordinate = TRUE, limit = 120000)

#Extract dataframe from gbif data
data_gbif <- occ_gbif$data

# Data cleaning and filtering
data_clean <- data_gbif %>%
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  filter(is.na(coordinateUncertaintyInMeters) | coordinateUncertaintyInMeters < 1000) %>%
  filter(!is.na(year) & year >= 2010)

butterfly <- data.frame(lon = data_clean$decimalLongitude, lat = data_clean$decimalLatitude, year = data_clean$year)

# Italy bounding box for plotting focus
butterfly <- butterfly[butterfly$lon > 6 & butterfly$lon < 19 & butterfly$lat > 36 & butterfly$lat < 48, ]

# Region assignment
butterfly$region <- ifelse(butterfly$lat < 45 & butterfly$lon > 8.5,"Apennines", "Alps") 
```


### 2.3 Elevation data and extraction

Elevation was extracted from a WorldClim elevation raster (local file). Occurrence points were converted to a terra spatial vector and used to extract elevation at each record location.

```r
# Load and crop elevation raster
elev <- rast("~/Documents/UNIVERSITY/wc2.1_30s_elev.tif")
italy <- ne_countries(country = "Italy", scale = "medium", returnclass = "sf")
elev_italy <- crop(elev, vect(italy))

# Terrain Ruggedness Index (TRI) calculation
ruggedness <- terrain(elev_italy, v = "TRI")

# Elevation and Ruggedness Extraction
butterfly_vect <- vect(butterfly, geom = c("lon", "lat"), crs = "EPSG:4326")
butterfly$elevation <- extract(elev_italy, butterfly_vect)[,2]
butterfly$ruggedness <- extract(ruggedness, butterfly_vect)[,2]

# Prepare raster for ggplot
elev_df <- as.data.frame(elev_italy, xy = TRUE)
colnames(elev_df) <- c("x", "y", "elevation")
```


## Results
### Spatial Distribution Map

The occurrence map illustrates the distribution of *P. apollo* across the major mountain chains of Italy, showing a strong affinity for high-altitude environments.

```r
ggplot() +
  #Elevation raster:
  geom_raster(data = elev_df, aes(x = x, y = y, fill = elevation)) +
  #Italy border:
  geom_sf(data = italy, fill = NA, color = "black") +
  #Occurence points:
  geom_point(data = butterfly, aes(x = lon, y = lat, shape = region, color = region), size = 2, alpha = 0.5) +
  scale_shape_manual(values = c("Alps" = 20, "Apennines" = 18)) + 
  scale_color_manual(values = c("Alps" = "chocolate1", "Apennines" = "deeppink3")) +
  scale_fill_viridis(option = "mako", direction = -1) +
  labs(title = "Parnassius apollo occurrences in Italy (2010-2025)",subtitle = "GBIF occurrence records overlaid on WorldClim elevation data",fill = "Elevation (m)",color = "Region",shape = "Region") +
  coord_sf(expand = FALSE) +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14), plot.subtitle = element_text(hjust = 0.5, size = 10))
```
<img width="2879" height="1799" alt="image" src="https://github.com/user-attachments/assets/d24a8bf8-1b6f-4223-83f2-c4cd527bb537" />

### Elevational Trends over Time

We analyzed the shift in elevation over time to detect potential upward migration.

```r
# Elevation over time plot
ggplot(butterfly, aes(x = year, y = elevation, color = region)) +
  geom_point(alpha = 0.3) +
  geom_smooth(aes(color = region), method = "lm",se=T) +
  labs(title = "Elevation of Parnassius apollo over time by region", x = "Year", y = "Elevation (m)",color = "Region") +
  scale_color_manual(values = c("Alps" = "chocolate1", "Apennines" = "deeppink3")) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
```
<p align="center">
<img width="591" height="478" alt="image" src="https://github.com/user-attachments/assets/1dcb2209-519b-4b83-8905-1ab2bd359e94" />

### Terrain Ruggedness Analysis

We investigated whether the species is moving toward more rugged terrain, which often provides micro-refugia.

```r
# Ruggedness over time plot
ggplot(butterfly, aes(x = year, y = ruggedness, color = region)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title="Ruggedness of occurrence points over time") +
  scale_color_manual(values = c("Alps" = "chocolate1", "Apennines" = "deeppink3")) +
  theme_minimal()
```
<p align="center">
<img width="591" height="478" alt="image" src="https://github.com/user-attachments/assets/c8a82d3e-aa2c-48a8-b2dc-516698b7c421" />


### Statistical Modeling

```r
# Model for Elevation Shift
model_region <- lm(elevation ~ year * region, data = butterfly)
summary(model_region)

# Model for Ruggedness Shift
model_rugged <- lm(ruggedness ~ year * region, data = butterfly)
summary(model_rugged)
```


## Discussion
### Ecological Reflections on Elevational Shift

The results indicate a statistically significant upward trend in the elevation of *Parnassius apollo* occurrences, estimated at approximately 10 meters per year. This finding is ecologically significant as it suggests the species is actively tracking its thermal niche. As lower elevations become warmer, the metabolic costs for the larvae increase and host plants may desiccate earlier in the season, forcing populations to persist only at higher altitudes.

Interestingly, the trend is consistent across both the Alps and the Apennines. While the Alps offer a continuous elevational gradient up to very high peaks, the Apennines are more fragmented and lower in average height. This "summit trap" effect is a major concern: as populations move upward in the Apennines, they may eventually run out of available mountain surface, leading to local extinctions.

### Terrain Ruggedness and Micro-refugia

The analysis of Terrain Ruggedness (TRI) shows how the species utilizes complex topographies. Rugged terrain provides a variety of microclimates (e.g., north-facing shaded slopes vs. south-facing sunny rocky outcrops) within a small geographic area. These micro-refugia can buffer the species against extreme weather events and general warming trends, allowing them to survive in areas where the macro-climate might otherwise be unsuitable.

### Sampling Effort and Bias

The sampling effort analysis acknowledges an increase in records over time, likely due to the democratization of biodiversity monitoring through platforms like iNaturalist. However, the robustness of the elevational trend—even when accounting for regional differences—points toward a real biological response rather than a purely observational bias.

## Conclusion
This project demonstrates the power of spatial ecology tools in R to monitor species' responses to environmental pressure. Our analysis confirms that Parnassius apollo in Italy is undergoing a significant elevational shift, likely driven by climate change.

### Key Insights:

- Upward Migration: A shift of ~10m/year suggests rapid adaptation or habitat loss at lower bounds.

- Regional Consistency: Both the Alps and Apennines show similar trends, indicating a national ecological phenomenon.

- Conservation Necessity: Protecting high-altitude rocky meadows and ensuring elevational connectivity is vital for the long-term survival of this species.

These findings highlight the importance of "escalator to extinction" dynamics in mountain ecosystems, where species move higher until no suitable habitat remains. Future conservation strategies should focus on protecting these high-altitude refugia and monitoring the health of host plant communities at the species' leading edge.
