
library(sp)
library(rgdal)
library(rgeos)
library(readr)
library(tidyr)
library(dplyr)

locations <- read_csv("GeocodeResults_All.csv", 
                      col_types = cols(ID = "c", ADDRESS = "c", GEOCODE = "c", .default = "_")) %>%
  filter(!is.na(GEOCODE)) %>%
  separate(GEOCODE, c("lon", "lat"), ",", convert = TRUE) 

locations_spdf <- SpatialPointsDataFrame(
  coords = select(locations, lon, lat), 
  data = locations, 
  proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
)


# exported from https://overpass-turbo.eu/
gardens <- rgdal::readOGR("las_vegas_gardens.geojson", "OGRGeoJSON")

utm_zone_11_proj <- "+proj=utm +zone=11 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

gardens_trans <- gardens %>% 
  gUnaryUnion %>%
  spTransform(CRS(utm_zone_11_proj))

locations_trans <- locations_spdf %>%
  spTransform(CRS(utm_zone_11_proj))

# distance to closest garden in meters
locations_trans$dist_to_garden <- as.numeric(gDistance(locations_trans, gardens_trans, byid = TRUE))

