# Spatial Distribution and Elevational Shift of *Parnassius apollo* in Italy 🦋⛰️
## 1. Aim and ecological background

Mountain ecosystems are particularly sensitive to environmental change. Because temperature varies strongly with elevation, mountainous landscapes provide natural gradients that can influence where species occur. Understanding how species distributions relate to elevation is therefore central to **spatial ecology**.

Butterflies are often used as **ecological indicators** due to their sensitivity to environmental conditions and the availability of long-term occurrence data. *Parnassius apollo* is a montane butterfly associated with open, rocky habitats at mid- to high elevations in European mountain systems.

<p align="center">
<img width="600" height="300" alt="image" src="https://github.com/user-attachments/assets/b74175d3-cd5b-403e-a53e-9da452b6d1e8" />

In this project, **GBIF occurrence records (2010–2025)** were used to investigate how the elevational distribution of *P. apollo* in Italy has changed over time and whether patterns differ between the **Alps** and the **Apennines**.

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
- valid geographic coordinates
- coordinate uncertainty < 1000 m
- years ≥ 2010
- points within an Italy bounding box (for visualization focus)
- assigned to one of two regions: Alps or Apennines

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

Elevation values were obtained from a WorldClim elevation raster.
The raster was cropped to Italy to reduce its spatial extent. Elevation at each butterfly occurrence point was then extracted and added to the dataset.

```r
#Load WorldClim elevation raster
elev_file <- "~/Documents/UNIVERSITY/wc2.1_30s_elev.tif"
elev <- rast(elev_file)

#Get Italy polygon
italy <- ne_countries(country = "Italy", scale = "medium", returnclass = "sf")
italy_vect <- vect(italy)

elev_italy <- crop(elev, italy_vect) #Crop elev to Italy

# For map plotting
elev_df <- as.data.frame(elev_italy, xy = TRUE)
colnames(elev_df) <- c("x", "y", "elevation")

# Spatial vector for extracting elev value for each occurrence
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

**Interpretation of Figure 1.** Most records are located in **mountainous areas**, which matches the known ecology of *P. apollo* as a species associated with cooler, high-elevation habitats. Records are mainly concentrated in the **Alpine arc** and along the **Apennine chain**.

It is important to note that this pattern reflects both the **species’ distribution and observer activity.** Areas that are more accessible, such as mountain parks and hiking trails, are likely to receive more observations than equally suitable but less visited locations.

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

**Interpretation of Figure 2.** Elevation **values vary widely**, which is expected in mountainous landscapes. The regression lines show a clear **upward trend over time**, meaning that records are occurring at **higher elevations** in recent years.
This pattern **may suggest a response to warming temperatures**. However, the plot alone does not prove ecological change. The trend could also reflect changes in sampling effort, such as **increased observation at higher elevations in recent years**.

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

**Interpretation of Figure 3.** The figure shows that **sampling effort is highly uneven** across both time and space. The Alps contribute most of the records, especially in recent years, while the Apennines have consistently fewer observations.
- Because of this imbalance, the overall trend is likely influenced mainly by Alpine data.
- Regional comparisons should therefore be interpreted with caution.
- The results reflect changes in recorded occurences rather than confirmed changes in population distribution.

### 3.4 Region specific linear model
To formally test whether elevation changes over time — and whether this change differs between the Alps and the Apennines — I fitted a linear model. This allows us to **move beyond visual patterns** and **statistically** evaluate:
- whether **elevation increases with year**
- whether **mean elevation differs between regions**
- whether the **rate of change differs between regions**

```r
# Model for Elevation Shift
model_region <- lm(elevation ~ year * region, data = butterfly)
summary(model_region)

```

#### Results

* **Year effect:** Elevation increases by approximately **13.15 meters (β) per year** (**p < 0.001**).
  → This corresponds to nearly **200 meters over 15 years**.

* **Region effect:** No significant difference in mean elevation between regions (**p = 0.927**).

* **Interaction (year × region):** Not significant (**p = 0.923**).
  → The rate of elevational change is similar in both mountain systems.

* **Model fit:** **R² ≈ 0.016**, meaning year explains a small portion of total variation.
  → This is expected in heterogeneous mountainous landscapes.

#### Interpretation
Overall, the results indicate that *Parnassius apollo* is being recorded at higher elevations over time. This pattern is consistent with a response to warming temperatures. However, because the dataset is based on presence-only records and uneven sampling effort, results should be interpreted as an **upslope shift in recorded occurrences**, not confirmed population redistribution.


## 4. Conclusion and Limitations

Between 2010 and 2025, *Parnassius apollo* records in Italy increased in elevation by approximately **13 meters per year**, corresponding to nearly **200 meters over 15 years**. This upward trend is statistically significant and is largely driven by records from the **Alps**, which dominate the dataset.

The observed pattern is consistent with a possible elevational response in a cold-adapted montane butterfly. However, the analysis has important limitations that must be considered.

### Key Limitations
* The dataset is based on **presence-only GBIF records**, which reflect both species distribution and observer activity.
* **Sampling effort increased strongly over time**, particularly in the Alps, which may influence the apparent trend.
* The **Apennines are underrepresented**, limiting confidence in regional comparisons.

Because of these factors, the results should be interpreted as an **upslope shift in recorded occurrences**, rather than confirmed population redistribution.

### Broader Implications
Despite these limitations, the analysis demonstrates how **spatial ecology tools in R** can be used to detect potential distributional changes using open-access biodiversity data. If the upward trend reflects a true ecological response, continued shifts could reduce available habitat at lower elevations and increase pressure on high-elevation populations.

Overall, this study highlights both the potential and the limitations of citizen-science data for understanding species responses to environmental change.
