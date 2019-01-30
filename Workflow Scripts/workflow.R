require(dockless)
require(sf)
require(dplyr)

## ------------------------ CLUSTER LOOP ----------------------------

# Load system area file
systemarea = readRDS('RDS Files/systemarea.rds')

# Create grid
gridcells = dockless::create_grid(
  area = systemarea,
  cellsize = c(500, 500)
)

# Calculate grid cell centroids
gridcentroids = gridcells %>%
  dockless::project_sf() %>%
  sf::st_centroid() %>%
  sf::st_transform(crs = 4326)

# Load distance data for grid cell centroids during training period
distancedata_centroids_train = readRDS('RDS Files/distancedata_centroids_train.rds')

# Cluster
clusters = dockless::spatial_cluster(
  data = distancedata_centroids_train,
  grid = gridcells,
  K = 4,
  omega = seq(0, 1, 0.1)
)

# Add cluster information to grid cells and grid cell centroids
gridcells$cluster     = clusters$indices
gridcentroids$cluster = clusters$indices

# Load usage data during training period
usagedata_train = readRDS('RDS Files/usagedata_train.rds')

# Pre-process
outlier_times = as.data.frame(table(usagedata_train$time)) %>%
  filter(Freq > 50) %>%
  pull(Var1)

usagedata_train = 
  usagedata_train[!as.factor(usagedata_train$time) %in% outlier_times, ]

# Usage intensity per grid cell
gridcells$intensity = dockless::usage_intensity(
  usage = usagedata_train,
  grid = gridcells
)

# Add intensity information to grid cell centroids
gridcentroids$intensity = gridcells$intensity

# Create model points
modelpoints = dockless::create_modelpoints(
  centroids = gridcentroids
)

## ------------------------ MODEL LOOP ---------------------------

# Load distance data for the modelpoints
distancedata_modelpoints = readRDS('RDS Files/distancedata_modelpoints.rds')

# Build models
models = dockless::build_models(
  data = distancedata_modelpoints,
  auto_seasonality = TRUE,
  seasons = list(NULL, 96, 672, c(96, 672))
)

## ------------------------ FORECAST LOOP ---------------------------

# Load usage data during test period
usagedata_test = readRDS('RDS Files/usagedata_test.rds')

# Create test points
testpoints = dockless::create_testpoints(
  data = usagedata_test,
  area = systemarea,
  clusters = clusters$outlines,
  n = 1743
)