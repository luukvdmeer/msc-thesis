require(ggplot2)
require(grid)
require(dplyr)
require(sf)
require(dockless)

# Load data
distancedata_clusters = readRDS('RDS Files/distancedata_centroids_train.rds')
gridcells = readRDS('RDS Files/gridcells.rds')

# Aggregate all data frames by weekhour
data_aggregated = dockless::aggregate_by_weekhour(distancedata_clusters)

# Normalize the distance column of each aggregated data frame
f = function(x) {
  x$distance_scaled = dockless::scale_minmax(x$distance)
  return(x)
}

data_scaled = lapply(data_aggregated, f)

# Get the cluster information
clusters = gridcells$cluster

# Add cluster information to each data frame
f = function(x, y) {
  x$cluster = y
  return(x)
}

data_clustered = mapply(f, data_scaled, clusters, SIMPLIFY = FALSE)

# Bind all data frames together
data_combined = do.call(rbind, data_clustered)

# Aggregate per cluster per weekhour
newdata = data_combined %>%
  group_by(cluster, weekhour) %>%
  summarise(distance = mean(distance, na.rm = TRUE),
            distance_scaled = mean(distance_scaled, na.rm = TRUE))

# Plot
clusterplot = ggplot(
  data = newdata,
  mapping = aes(x = weekhour, y = distance_scaled)
) +
  geom_line(
    lwd = 1
  ) +
  scale_x_continuous(
    breaks = seq(0, 168, 24)
  ) +
  labs(
    x = 'Hour of the week',
    y = 'Average normalized distance to nearest bike'
  ) +
  theme(
    text = element_text(family = 'serif')
  ) +
  facet_grid(
    cluster ~ .,
    labeller = as_labeller(
      c(
      '1' = 'Bayview',
      '2' = 'Downtown', 
      '3' = 'Residential', 
      '4' = 'Presidio'
      )
    )
  )

# Color the facet backgrounds (code from https://github.com/tidyverse/ggplot2/issues/2096)
clustergrid = ggplot_gtable(ggplot_build(clusterplot))
stripr = which(grepl('strip-r', clustergrid$layout$name))
colors = dockless_colors(categorical = TRUE)
k = 1
for (i in stripr) {
  j = which(grepl('rect', clustergrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  clustergrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/clusterplots.png',
  plot = clustergrid,
  scale = 1.5,
  dpi = 600
)
  
rm(distancedata_clusters, gridcells, data_aggregated, data_scaled, 
   clusters, data_clustered, data_combined, newdata, f, stripr, 
   colors, k, i, j, clusterplot, clustergrid)