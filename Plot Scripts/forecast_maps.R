require(rosm)
require(ggspatial)
require(ggplot2)
require(sf)
require(dockless)
require(dplyr)

## ------------------------ TEST POINTS -----------------------------
testpoints_locations = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/clusters.rds'),
    col = 'grey',
    lwd = 1,
    alpha = 0.4
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/testpoints.rds'),
    col = 'orange',
    alpha = 0.7
  ) +
  theme(
    text = element_text(family = 'serif'),
    plot.title = element_text(hjust = 0.5)
  )

ggsave(
  'Document/Figures/testpoints_locations.png',
  plot = testpoints_locations,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

rm(testpoints_locations)

## ------------------------ VORONOI -----------------------------

# # Load data
# testpoints = readRDS('RDS Files/testpoints.rds')
# systemarea = readRDS('RDS Files/systemarea.rds')
# forecasts_dbafs = readRDS('RDS Files/forecasts_dbafs.rds')
# forecasts_naive = readRDS('RDS Files/forecasts_naive.rds')
# 
# # Calculate forecasts RMSE's for each testpoint
# rmse_dbafs = dockless::error(
#   forecasts_dbafs,
#   type = 'RMSE',
#   return = 'all'
# )
# 
# rmse_naive = dockless::error(
#   forecasts_naive,
#   type = 'RMSE',
#   return = 'all'
# )
# 
# # Calculate accuracy gain of DBAFS for each test point
# rmse_diff = rmse_naive - rmse_dbafs
# 
# # Add to test points data
# testpoints$rmse = rmse_diff
# 
# # Identify duplicate points
# eq_matrix = st_equals(testpoints, sparse = FALSE)
# diag(eq_matrix) = FALSE
# indices = (which(eq_matrix, arr.ind = TRUE))[1:2,1]
# 
# # Remove duplicate points
# testpoints = testpoints[-indices, ]
# 
# # Create voronoi polygons
# voronoi_poly = testpoints %>%
#   dockless::project_sf() %>%
#   sf::st_union() %>%
#   sf::st_voronoi(sf::st_geometry(dockless::project_sf(systemarea))) %>%
#   sf::st_cast() %>%
#   sf::st_sf() %>%
#   st_intersection(dockless::project_sf(systemarea)) %>%
#   sf::st_transform(crs = 4326) %>%
#   mutate(rmse = testpoints$rmse)
# 
# 
# voronoi = ggplot() +
#   ggspatial::annotation_map_tile(
#     type = 'cartolight',
#     zoom = 13
#   ) +
#   ggspatial::layer_spatial(
#     data = voronoi_poly,
#     aes(fill = rmse),
#     col = NA
#   ) +
#   scale_fill_gradient2(
#     low = 'deepskyblue',
#     mid = 'white',
#     high = 'orange',
#     midpoint = 0
#   ) +
#   theme(
#     text = element_text(family = 'serif'),
#     plot.title = element_text(hjust = 0.5)
#   )