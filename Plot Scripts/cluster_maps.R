require(rosm)
require(ggspatial)
require(ggplot2)
require(dockless)

## ------------------------ SYSTEM AREA -----------------------------
systemarea = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/systemarea.rds'),
    col = 'orange',
    lwd = 1,
    alpha = 0.7
  ) +
  labs(
    title = 'System area of JUMP Bikes in San Francisco'
  ) +
  theme(
    text = element_text(family = 'serif'),
    plot.title = element_text(hjust = 0.5)
  )

ggsave(
  'Document/Figures/systemarea.png',
  plot = systemarea,
  width = 7,
  height = 7,
  units = 'in',
  dpi = 600
)

rm(systemarea)

## --------------------------- GRID ---------------------------------
grid = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/systemarea.rds'),
    col = 'black',
    lwd = 1,
    fill = NA
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/gridcells.rds'),
    col = 'orange',
    lwd = 1,
    alpha = 0.7
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/gridcentroids.rds'),
    col = 'black',
    size = 0.5
  ) +
  labs(
    title = 'Overlaying grid with centroids'
  ) +
  theme(
    text = element_text(family = 'serif'),
    plot.title = element_text(hjust = 0.5)
  )

ggsave(
  'Document/Figures/grid.png',
  plot = grid,
  width = 7,
  height = 7,
  units = 'in',
  dpi = 600
)

rm(grid)

## ------------------------- PICK-UPS -------------------------------
pickups = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/systemarea.rds'),
    col = 'black',
    lwd = 1,
    fill = NA
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/gridcells.rds'),
    mapping = aes(fill = npickup),
    lwd = NA,
    alpha = 0.7
  ) +
  scale_fill_gradientn(
    name = 'pick-ups',
    colours = dockless_colors(20)
  ) +
  labs(
    title = 'Number of pick-ups per grid cell'
  ) +
  theme(
    text = element_text(family = 'serif'),
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.1, 0.15),
    legend.background = element_blank()
  )

ggsave(
  'Document/Figures/pickups.png',
  plot = pickups,
  width = 7,
  height = 7,
  units = 'in',
  dpi = 600
)

rm(pickups)

## --------------------------- CLUSTERS -----------------------------
clusters = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = (readRDS('RDS Files/clusters.rds')),
    mapping = aes(fill = cluster),
    col = 'black',
    lwd = 1,
    alpha = 0.7
  ) +
  scale_fill_manual(
    name = 'Cluster',
    values = dockless_colors(categorical = TRUE),
    labels = c('Bayview', 'Central', 'Residential', 'Presidio')
  ) +
  labs(
    title = 'Clusters'
  ) +
  theme(
    text = element_text(family = 'serif'),
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.1, 0.15),
    legend.background = element_blank()
  )

ggsave(
  'Document/Figures/clusters.png',
  plot = clusters,
  width = 7,
  height = 7,
  units = 'in',
  dpi = 600
)

rm(clusters)

## ------------------------- MODEL POINTS ---------------------------
modelpoints = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/clusters.rds'),
    col = 'black',
    lwd = 1,
    fill = NA
  ) +
  ggspatial::layer_spatial(
    data = (readRDS('RDS Files/modelpoints.rds')),
    mapping = aes(col = cluster),
    size = 4
  ) +
  scale_color_manual(
    name = 'Model point',
    values = dockless_colors(categorical = TRUE),
    labels = c('Bayiew', 'Central', 'Residential', 'Presidio')
  ) +
  labs(
    title = 'Model points'
  ) +
  theme(
    text = element_text(family = 'serif'),
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.1, 0.15),
    legend.background = element_blank()
  )

ggsave(
  'Document/Figures/modelpoints.png',
  plot = modelpoints,
  width = 7,
  height = 7,
  units = 'in',
  dpi = 600
)

rm(modelpoints)