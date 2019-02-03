require(rosm)
require(ggspatial)
require(ggplot2)
require(sf)
require(dockless)

## ------------------------ SYSTEM AREA -----------------------------
systemarea_map = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/systemarea.rds'),
    col = '#fc8c01',
    lwd = 1,
    alpha = 0.7
  ) +
  theme(
    text = element_text(family = 'sans'),
    plot.title = element_text(hjust = 0.5)
  )

ggsave(
  'Document/Figures/systemarea.png',
  plot = systemarea_map,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

rm(systemarea_map)

## --------------------------- GRID ---------------------------------
grid_map = ggplot() +
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
    col = '#fc8c01',
    lwd = 1,
    alpha = 0.7
  ) +
  ggspatial::layer_spatial(
    data = readRDS('RDS Files/gridcentroids.rds'),
    col = 'black',
    size = 0.5
  ) +
  theme(
    text = element_text(family = 'sans'),
    plot.title = element_text(hjust = 0.5)
  )

ggsave(
  'Document/Figures/grid.png',
  plot = grid_map,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

rm(grid_map)

## ------------------------- PICK-UPS -------------------------------
pickups_map = ggplot() +
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
    mapping = aes(fill = intensity),
    lwd = NA,
    alpha = 0.7
  ) +
  scale_fill_gradientn(
    name = 'pick-ups',
    colours = dockless_colors(20)
  ) +
  theme(
    text = element_text(family = 'sans'),
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.1, 0.2),
    legend.background = element_blank()
  )

ggsave(
  'Document/Figures/pickups.png',
  plot = pickups_map,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

rm(pickups_map)

## --------------------------- CLUSTERS -----------------------------
clusters_map = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = (readRDS('RDS Files/clusters.rds'))$outlines,
    mapping = aes(fill = cluster),
    col = 'black',
    lwd = 1,
    alpha = 0.7
  ) +
  scale_fill_manual(
    name = 'Cluster',
    values = dockless_colors(categorical = TRUE),
    labels = c('Bayview', 'Downtown', 'Residential', 'Presidio')
  ) +
  theme(
    text = element_text(family = 'sans'),
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.1, 0.15),
    legend.background = element_blank()
  )

ggsave(
  'Document/Figures/clusters.png',
  plot = clusters_map,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

rm(clusters_map)

## ------------------------- MODEL POINTS ---------------------------
modelpoints_map = ggplot() +
  ggspatial::annotation_map_tile(
    type = 'cartolight',
    zoom = 13
  ) +
  ggspatial::layer_spatial(
    data = (readRDS('RDS Files/clusters.rds'))$outlines,
    col = 'grey',
    lwd = 1,
    alpha = 0.4
  ) +
  ggspatial::layer_spatial(
    data = (readRDS('RDS Files/modelpoints.rds')),
    mapping = aes(fill = cluster),
    color = 'black',
    shape = 21,
    stroke = 2,
    size = 4
  ) +
  scale_fill_manual(
    name = 'Model point',
    values = dockless_colors(categorical = TRUE),
    labels = c('Bayiew', 'Downtown', 'Residential', 'Presidio')
  ) +
  theme(
    text = element_text(family = 'sans'),
    plot.title = element_text(hjust = 0.5),
    legend.position = c(0.1, 0.15),
    legend.background = element_blank()
  ) +
  guides(
    fill = guide_legend(override.aes = list(shape = 21))
  )

ggsave(
  'Document/Figures/modelpoints.png',
  plot = modelpoints_map,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

rm(modelpoints_map)