### Parnassius apollo Elevational Shift in Italy (2010–2025) ####

#_-1-LOAD PACKAGES_________________________________________________________
library(rgbif)         # Download GBIF occurrence records
library(dplyr)         # Data manipulation (filtering, cleaning) + %>% pipe
library(terra)         # Spatial raster + vector tools (elevation raster, extraction)
library(ggplot2)       # Plotting (maps and scatterplots)
library(viridis)       # Nice color scale for elevation raster
library(sf)            # Simple Features (vector data format often used for borders/maps)
library(rnaturalearth) # Functions to access Natural Earth country polygons
library(geodata) #for getting elev file in a reproducible manner

#_-2-SPECIES DATA COLLECTION AND PREPROCESSING_____________________________

# Download GBIF occurrences of P. apollo in Italy
# We request:
# - scientificName: the species
# - country = "IT": restrict to Italy
# - hasCoordinate = TRUE: only records with lat/lon (needed for mapping & extraction)
# - limit = 120000: try to retrieve all available records
occ_gbif <- occ_search(
  scientificName = "Parnassius apollo",
  country = "IT",
  hasCoordinate = TRUE,
  limit = 120000
)

# Extract the data frame from the GBIF result object
# occ_search returns a list with multiple elements (metadata + data).
# The actual records are stored in occ_gbif$data as a tabular data frame.
data_gbif <- occ_gbif$data

# Data cleaning (tabular stage)
# At this stage, we keep everything as a normal data frame because:
# - filtering and selecting columns is easiest in tabular format
# - we are not doing spatial operations yet
data_clean <- data_gbif %>%
  # Remove missing coordinates
  # Even though hasCoordinate=TRUE, some records can still be incomplete or messy.
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  
  # Remove imprecise coordinates (> 1 km)
  # Very imprecise points can blur elevation estimates or place points in wrong habitat.
  filter(is.na(coordinateUncertaintyInMeters) | coordinateUncertaintyInMeters < 1000) %>%
  
  # Keep only recent data (2010+)
  # Here the goal is to analyze elevational change in a modern period with stronger sampling.
  filter(!is.na(year) & year >= 2010)

# Create simplified dataframe, with only necessary columns
# - GBIF tables have MANY columns (hundreds).
# - Keeping only lon/lat/year makes the analysis clearer and reduces confusion.
butterfly <- data.frame(
  lon = data_clean$decimalLongitude,
  lat = data_clean$decimalLatitude,
  year = data_clean$year
)

# Keep only points within Italy bounding box (visual focus)
# Why do this?
# - Sometimes GBIF has slightly wrong coordinates, or offshore points, etc.
# - Bounding box keeps the plot focused on Italy and removes obvious outliers.
butterfly <- butterfly[
  butterfly$lon > 6 & butterfly$lon < 19 &
    butterfly$lat > 36 & butterfly$lat < 48, ]

# Assign region (Alps or Apennines)
# - We want to compare elevational trends between two broad mountain systems.
# - This is a simple geographic rule (not a true biogeographic classification).
# - It creates a categorical variable used in plots and the linear model.
butterfly$region <- ifelse(
  butterfly$lat < 45 & butterfly$lon > 8.5,
  "Apennines",
  "Alps"
)

#_-3-ELEVATION DATA PROCESSING_____________________________________________

# Load WorldClim elevation raster
# A raster is a grid of cells; each cell stores an elevation value (meters).
# We will extract elevation values at each butterfly occurrence location.
elev <- geodata::worldclim_tile(var = "elev", lon = 12, lat = 42, res = 0.5, path = "data")

# Get Italy polygon (vector boundary)
# ne_countries returns an sf object (a vector polygon dataset).
# sf objects are great for plotting borders and spatial operations.
italy <- ne_countries(country = "Italy", scale = "medium", returnclass = "sf")

# Convert sf to terra vector
# - terra uses its own vector class ("SpatVector") for spatial operations like crop/mask.
# - crop() in terra works best with a terra vector.
italy_vect <- vect(italy)

# Crop elevation raster to Italy area
# Why crop?
# - The global WorldClim raster is huge.
# - Cropping reduces memory and makes plotting faster.
# Note: crop() keeps a rectangular extent around Italy.
elev_italy <- crop(elev, italy_vect)

# Convert raster to a data frame for ggplot
# Why?
# - ggplot2 cannot directly plot terra rasters in a simple way like base plotting.
# - Converting raster to a data frame gives us columns (x, y, elevation),
#   which ggplot can use in geom_raster().
elev_df <- as.data.frame(elev_italy, xy = TRUE)
colnames(elev_df) <- c("x", "y", "elevation")

#_-4-ELEVATION EXTRACTION__________________________________________________

# Convert butterfly occurrence data frame to a spatial vector
# - extract() needs spatial geometry to know where the points are in space.
# - A data frame has numbers but no "spatial meaning" (no CRS, no geometry).
# - A SpatVector stores both coordinates + CRS information.
butterfly_vect <- vect(butterfly, geom = c("lon", "lat"), crs = "EPSG:4326")

# Extract elevation value for each occurrence point
# extract(raster, points) returns a table with:
# - one row per point
# - typically an ID column and the extracted raster value column
# [,2] selects the extracted value column.
butterfly$elevation <- extract(elev_italy, butterfly_vect)[, 2]

#_-5-OCCURRENCE MAP & ELEVATION GRADIENT___________________________________
# This map shows:
# - elevation background (raster)
# - Italy border (sf polygon)
# - occurrence points (colored/shaped by region)
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
    title = "Parnassius apollo occurrences in Italy (2010–2025)",
    subtitle = "GBIF records overlaid on WorldClim elevation data",
    fill = "Elevation (m)",
    color = "Region",
    shape = "Region"
  ) +
  coord_sf(expand = FALSE) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10)
  )

#_-6-ELEVATION OVER TIME___________________________________________________
# Scatterplot of elevation vs year to visualize temporal trend.
# The linear regression line (geom_smooth method="lm") gives the direction of change.
ggplot(butterfly, aes(x = year, y = elevation, color = region)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Elevation of Parnassius apollo over time by region",
    x = "Year",
    y = "Elevation (m)",
    color = "Region"
  ) +
  scale_color_manual(values = c("Alps" = "chocolate1", "Apennines" = "deeppink3")) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

#_-7-SAMPLING EFFORT_______________________________________________________
# GBIF data are opportunistic: number of records depends on observer activity.
# Counting records per year helps interpret whether trends could be influenced by effort.
obs_by_year_region <- count(butterfly, year, region)

ggplot(obs_by_year_region, aes(x = year, y = n, color = region)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = c("Alps" = "chocolate1",
                                "Apennines" = "deeppink3")) +
  labs(
    title = "Sampling effort over time",
    x = "Year",
    y = "Number of records",
    color = "Region"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "top"
  )

#_-8-REGION SPECIFIC LINEAR MODEL FOR DISCUSSION___________________________
# This model tests:
# - whether elevation changes with year (overall trend)
# - whether mean elevation differs between regions
# - whether the trend differs between regions (interaction year:region)
model_region <- lm(elevation ~ year * region, data = butterfly)
summary(model_region)
