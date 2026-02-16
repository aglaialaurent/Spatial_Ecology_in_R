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

Occurrence data were obtained from GBIF using the scientific name *Parnassius apollo*. Only records meeting the following criteria were included:

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

Occurrence records were downloaded using `occ_search()` from `rgbif`. The dataset was filtered to remove missing coordinates and records with high spatial uncertainty. Records prior to 1980 were excluded to focus on recent decades, where sampling effort and georeferencing accuracy are generally higher. A geographic bounding box was applied to ensure that only records within Italy were retained.

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

The WorldClim elevation raster was loaded and cropped to the political boundaries of Italy using `rnaturalearth`. This ensures that elevation values correspond only to the study area.

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

The following map visualizes the elevation gradient across Italy together with occurrence records of *Parnassius apollo*.

```r
ggplot() +
  geom_raster(data = elev_df, aes(x = x, y = y, fill = elevation)) +
  geom_sf(data = italy, fill = NA, color = "black") +
  geom_point(data = butterfly,
             aes(x = lon, y = lat),
             color = "cadetblue2", size = 0.6, alpha = 0.5) +
  scale_fill_viridis(option = "rocket", direction = -1) +
  labs(title = "Parnassius apollo occurrences in Italy (1980-2025)",
       subtitle = "GBIF occurrence records overlaid on WorldClim elevation data",
       fill = "Elevation (m)") +
  coord_sf(expand = FALSE) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  )
```

**Interpretation:**  
Occurrence records are concentrated in mountainous regions, particularly the Alps and Apennines. Lowland areas have few or no records, reflecting the species’ preference for high-elevation habitats.

---

### Elevation Over Time with Sampling Effort

To explore potential elevational shifts, elevation values were plotted against year of observation. Raw points, annual medians, linear trend, and sampling effort were combined for a complete visualization.

```r
library(dplyr)

# Compute annual median and sampling effort
annual <- butterfly %>%
  group_by(year) %>%
  summarise(
    median_elev = median(elevation, na.rm = TRUE),
    n = n()
  )

range_elev <- range(butterfly$elevation, na.rm = TRUE)
annual <- annual %>%
  mutate(
    n_scaled = n / max(n) * diff(range_elev) * 0.2 + min(range_elev)  # 20% height for shading
  )

ggplot() +
  geom_ribbon(data = annual, aes(x = year, ymin = min(range_elev), ymax = n_scaled),
              fill = "grey80", alpha = 0.4) +
  geom_point(data = butterfly, aes(x = year, y = elevation), 
             alpha = 0.3, color = "darkred", size = 0.7) +
  geom_point(data = annual, aes(x = year, y = median_elev), 
             color = "blue", size = 2) +
  geom_smooth(data = annual, aes(x = year, y = median_elev), 
              method = "lm", color = "black", se = TRUE, linewidth = 1) +
  labs(
    title = "Elevation of Parnassius apollo Over Time",
    subtitle = "Red: raw points, Blue: annual median, Grey: sampling effort",
    x = "Year",
    y = "Elevation (m)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  )
```

---

### Linear Model: Raw Points

```r
model <- lm(elevation ~ year, data = butterfly)
summary(model)
```

**Interpretation:**  
The raw-point model indicates a significant positive relationship between elevation and year (β ≈ 20.3 m/year, p < 0.001), although R² = 0.062 shows high variability in individual records. This confirms a preliminary upward elevational trend but highlights substantial natural variability and the influence of sampling patterns.

---

### Linear Model: Annual Medians

```r
model_median <- lm(median_elev ~ year, data = annual)
summary(model_median)
```

**Interpretation:**  
The median-based model shows a slope of ~26 m/year (p < 0.001) with R² = 0.72. This robustly confirms the upward elevational shift and reduces the influence of extreme values and variable sampling effort. Ecologically, the data suggest that *Parnassius apollo* has shifted upward by roughly **1000 meters** over the past four decades, potentially in response to warming temperatures.

---

### Period Comparison (Before and After 2000)

Records were divided into two temporal periods for comparison:

- Before 2000  
- After 2000  

```r
butterfly$period <- ifelse(butterfly$year < 2000, "Before 2000", "After 2000")

ggplot(butterfly, aes(x = period, y = elevation)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Elevation shift of Parnassius apollo",
       y = "Elevation (m)")
```

**Interpretation:**  
Differences in median elevation between periods may reflect upward shifts over time. Combined with median-based linear modeling, this provides consistent evidence of a temporal trend.

---

## Discussion

The spatial distribution confirms that *Parnassius apollo* is strongly associated with mountainous regions in Italy. Concentration in the Alps and Apennines reflects the species’ preference for cooler alpine environments.

Temporal analyses, including median-based modeling and period comparison, indicate a significant upward shift in elevation over recent decades. The grey shading representing sampling effort highlights that early years have fewer records, confirming that median-based methods produce more reliable estimates. 

While the trend may suggest climate-driven shifts, alternative explanations include sampling biases, accessibility of mountain areas, and changes in survey intensity. Nevertheless, the combination of raw points, medians, and sampling effort provides strong evidence for a consistent elevational increase.

---

## Conclusion

This project demonstrates how GBIF occurrence data can be integrated with environmental raster data to analyze spatial and elevational patterns. By combining geographic visualization, temporal trends, and robust median-based modeling, it is possible to detect potential climate-related shifts in montane species.

Such approaches provide reproducible, interpretable methods for biodiversity monitoring, ecological research, and conservation planning.

