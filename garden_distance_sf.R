
library(sf)
library(readr)
library(tidyr)
library(dplyr)

locations <- read_csv(
  "GeocodeResults_All.csv", 
  col_types = cols(ID = "c", ADDRESS = "c", GEOCODE = "c", .default = "_")
) %>%
  filter(!is.na(GEOCODE)) %>%
  separate(GEOCODE, c("lon", "lat"), ",", convert = TRUE) 

utm_zone_11_proj <- "+proj=utm +zone=11 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

gardens <- read_sf("las_vegas_gardens.geojson") %>%
  st_transform(utm_zone_11_proj) %>%
  st_union

# with distance to garden in meters
locations_sf <- locations %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(utm_zone_11_proj) %>%
  mutate(dist_to_garden = as.numeric(st_distance(., gardens)))

