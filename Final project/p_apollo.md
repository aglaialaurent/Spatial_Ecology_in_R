# Spatial Distribution and Elevational Shift of Parnassius apollo in Italy 🦋⛰️
## 1. Aim and ecological background
Mountain organisms are expected to respond to warming temperatures by shifting their distributions upslope, because temperature decreases with elevation and higher elevations can function as thermal refuges. Butterflies are especially informative indicators due to their sensitivity to temperature and widely available occurrence records.

*Parnassius apollo* is a montane butterfly that mainly inhabits open, rocky habitats at mid- to high elevations. It is adapted to cooler conditions and depends on specific mountain environments, which makes it potentially sensitive to climate change.

<p align="center">
<img width="600" height="300" alt="image" src="https://github.com/user-attachments/assets/b74175d3-cd5b-403e-a53e-9da452b6d1e8" />

**Aim:** GBIF occurrence records from 2010–2025 will be used to test whether *Parnassius apollo* occurrences in Italy show an upward shift in elevation over time, and whether this pattern differs between two broad mountain regions (Alps vs. Apennines).

### Predictions
- If species are responding to **climate warming**, their occurrence elevation should **increase** through time.
- The average elevation may be different between regions because the **Alps are generally higher than the Apennines**.
- Because **GBIF data are opportunistic**, trends must be interpreted alongside **sampling effort**.


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
```

### 2.2 GBIF occurrence data 

Occurrences for *P. apollo* in Italy with coordinates were downloaded and filtered to:
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
elev_file <- "~/Documents/UNIVERSITY/wc2.1_30s_elev.tif"
elev <- rast(elev_file)

italy <- ne_countries(country = "Italy", scale = "medium", returnclass = "sf")
italy_vect <- vect(italy)

elev_italy <- crop(elev, italy_vect)

# For map plotting
elev_df <- as.data.frame(elev_italy, xy = TRUE)
colnames(elev_df) <- c("x", "y", "elevation")

# Spatial vector for extraction
butterfly_vect <- vect(butterfly, geom = c("lon", "lat"), crs = "EPSG:4326")
butterfly$elevation <- extract(elev_italy, butterfly_vect)[,2] 
```


## 3. Results
### 3.1 Spatial Distribution in Italy

```r
ggplot() +
  geom_raster(data = elev_df, aes(x = x, y = y, fill = elevation)) +
  geom_sf(data = italy, fill = NA, color = "black") +
  geom_point(
    data = butterfly,
    aes(x = lon, y = lat, shape = region, color = region),
    size = 2, alpha = 0.5
  ) +
  scale_shape_manual(values = c("Alps" = 20, "Apennines" = 18)) +
  scale_color_manual(values = c("Alps" = "chocolate1", "Apennines" = "deeppink3")) +
  scale_fill_viridis(option = "mako", direction = -1) +
  labs(
    title = "*Parnassius apollo* occurrences in Italy (2010–2025)",
    subtitle = "GBIF records overlaid on WorldClim elevation",
    fill = "Elevation (m)",
    color = "Region",
    shape = "Region"
  ) +
  coord_sf(expand = FALSE) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )
```
<img width="2879" height="1799" alt="image" src="https://github.com/user-attachments/assets/d24a8bf8-1b6f-4223-83f2-c4cd527bb537" />

**Interpretation of Figure 1.** Occurrences concentrate strongly in mountainous terrain, matching the known ecology of *P. apollo* as a montane butterfly associated with cooler climates and open alpine/subalpine habitats. The regional grouping highlights that records are primarily distributed across the Alpine arc and the Apennine chain.
Key caution: This pattern reflects both ecology and detectability — mountain parks, trails, and accessible valleys can accumulate more observations than equally suitable but less visited areas.

### 3.2 Elevation through time

We analyzed the shift in elevation over time to detect potential upward migration.

```r
ggplot(butterfly, aes(x = year, y = elevation, color = region)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Occurrence elevation over time by region",x = "Year",y = "Elevation (m)",color = "Region") +
  scale_color_manual(values = c("Alps" = "chocolate1", "Apennines" = "deeppink3")) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
```
<p align="center">
<img width="591" height="478" alt="image" src="https://github.com/user-attachments/assets/1dcb2209-519b-4b83-8905-1ab2bd359e94" />

**Interpretation of Figure 2.** There is a **wide range** of elevations in the data, which is expected in mountainous areas and when using **presence-only** records. The fitted lines show that there is a general **upward trend over time**. This suggests that records are increasingly found at higher elevations, which may indicate that the species is **tracking cooler conditions** as temperatures rise.
However, this plot alone cannot confirm true ecological change. An apparent upward trend could also result from changes in sampling, such as more observers visiting and recording butterflies at higher elevations in recent years.

### 3.3 Sampling effort over time (context for bias)
```r
obs_by_year_region <- count(butterfly, year, region)

ggplot(obs_by_year_region, aes(x = year, y = n, color = region)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = c("Alps" = "chocolate1",
                                "Apennines" = "deeppink3")) +
  labs(title = "Sampling effort over time",x = "Year",y = "Number of records",color = "Region") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),legend.position = "top")
```
<p align="center">
<img width="800" height="700" alt="image" src="https://github.com/user-attachments/assets/84eb2d06-4cc9-41fb-aef9-5c87fbef8ef1" />

**Interpretation of Figure 3.** The figure shows that **sampling effort is highly uneven** across both time and space. The Alps dominate the dataset, especially in recent years. Therefore:
- Elevational trends likely reflect **patterns primarily driven by Alpine** records.
- Any conclusions about regional differences must explicitly acknowledge sampling imbalance.
- Results should be framed as **trends in recorded occurrences**, not definitive range shifts.

### 3.4 Region specific linear model
This model tests the year effect and the region effect on elevation, and their interaction, so whether the rate of elevational change differs between regions. 
```r
# Model for Elevation Shift
model_region <- lm(elevation ~ year * region, data = butterfly)
summary(model_region)

```
The linear model shows a **significant positive effect of year on elevation** (**β = 13.15 m** per year, **p < 0.001**). This indicates that *Parnassius apollo* occurrences increased in elevation by approximately **13 meters** per year between 2010 and 2025 — equivalent to nearly **200 meters** over 15 years.
There was no significant difference between regions (Alps vs. Apennines) in baseline elevation (**p = 0.927**), and the interaction between year and region was also not significant (**p = 0.923**). This suggests that **the upward trend is similar across both mountain systems.**

The model explains only a small part of the total variation in elevation (**R² ≈ 0.016**). This is expected because elevation varies widely in mountainous landscapes. However, the upward trend is still statistically strong, partly because the dataset is large.

Overall, the results indicate that *Parnassius apollo* is being recorded at higher elevations over time. This pattern is consistent with a response to warming temperatures, although increasing sampling effort may also influence the trend.


## 4. Synthesis
Taken together, the results show a clear pattern.
- **Figure 1** confirms that **P. apollo is strongly associated with mountainous areas in Italy.**
- **Figure 2** shows that **recorded elevations increase through time.**
- **Figure 3** highlights **strong differences in sampling effort**, especially the sharp increase in Alpine records in recent years.
- The linear model confirms a **significant upward trend of ~13 meters per year**, with **no difference between Alps and Apennines.**

Overall, the data indicate that *Parnassius apollo* is being recorded at progressively higher elevations between 2010 and 2025. The similar slopes in both mountain systems suggest a broad-scale driver, consistent with regional climatic change.
However, because sampling effort increased strongly over time — particularly in the Alps — the results should be interpreted as an upslope shift in recorded occurrences, rather than definitive proof of a demographic range shift.

## 5. Conclusion and limitations
This project demonstrates how spatial ecology tools in R can be used to detect potential distributional changes using open-access occurrence data. *Parnassius apollo* records in Italy increased in elevation by approximately 13 meters per year, or nearly 200 meters over 15 years, with similar trends in both the Alps and the Apennines.
This pattern is consistent with an upslope response to warming in a cold-adapted montane butterfly and suggests a broad-scale environmental driver.
However, because the analysis is based on presence-only GBIF data and sampling effort increased strongly over time, the results should be interpreted as an upslope shift in recorded occurrences, rather than confirmed population redistribution.
These findings highlight the importance of monitoring high-elevation habitats, as continued upward shifts in mountain systems may lead to “escalator to extinction” dynamics if suitable habitat becomes limited at higher elevations.
