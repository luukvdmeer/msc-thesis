require(dockless)
require(dplyr)
require(ggplot2)
require(grid)
require(gridExtra)
require(lubridate)
require(tibble)

# Load data
testpoints = readRDS('RDS Files/testpoints.rds')
forecasts_dbafs = readRDS('RDS Files/forecasts_user_dbafs.rds')
forecasts_nfs = readRDS('RDS Files/forecasts_user_nfs.rds')

## ------------------- TESTPOINTS TIMESTAMPS ------------------------
# Round timestamps to the nearest hour
testpoints_rounded = testpoints %>%
  mutate(time = lubridate::round_date(time, 'hour'))

# Plot
testpoints_time = ggplot(
  data = testpoints_rounded,
  mapping = aes(x = time)
) +
  geom_bar(
    fill = '#fc8c01'
  ) +
  scale_x_datetime(
    date_breaks = '1 days',
    date_labels = c('Nov 5', 'Oct 29', 'Oct 30', 'Oct 31', 'Nov 1', 'Nov 2', 'Nov 3', 'Nov 4')
  ) +
  theme(
    text = element_text(family = 'sans'),
    axis.title.x = element_blank()
  )

ggsave(
  'Document/Figures/testpoints_time.png',
  plot = testpoints_time,
  width = 5,
  height = 4.9,
  units = 'in',
  dpi = 600
)

rm(testpoints_rounded, testpoints_time)

## ------------------------ SPACE TIME PLOT -------------------------
# Calculate DBAFS forecasts RMSE's for each testpoint
rmse_dbafs = dockless::error(
  forecasts_dbafs,
  type = 'RMSE',
  return = 'all'
)

# Add to test points data
testpoints_dbafs = testpoints %>%
  mutate(rmse = rmse_dbafs, method = 'DBAFS')

# Calculate Naive forecasts RMSE's for each testpoint
rmse_nfs = dockless::error(
  forecasts_nfs,
  type = 'RMSE',
  return = 'all'
)

# Add to test points data
testpoints_nfs = testpoints %>%
  mutate(rmse = rmse_nfs, method = 'NFS')

# Combine
testpoints_combined = rbind(testpoints_dbafs, testpoints_nfs)

# Plot
spacetimeplot = ggplot() +
    geom_point(
    data = testpoints_combined,
    mapping = aes(x = time, y = rmse),
    size = 1
  ) +
  scale_x_datetime(
    date_breaks = '1 days',
    date_labels = c('Nov 5', 'Oct 29', 'Oct 30', 'Oct 31', 'Nov 1', 'Nov 2', 'Nov 3', 'Nov 4')
  ) +
  labs(
    x = 'Time',
    y = 'RMSE'
  ) +
  theme(
    text = element_text(family = 'sans'),
    legend.position = 'none'
  ) +
  facet_grid(
    cluster ~ method,
    labeller = as_labeller(
      c(
        'DBAFS' = 'DBAFS',
        'NFS' = 'NFS',
        '1' = 'Bayview', 
        '2' = 'Downtown', 
        '3' = 'Residential', 
        '4' = 'Presidio'
      )
    )
  )

# Color the facet backgrounds (code from https://github.com/tidyverse/ggplot2/issues/2096)
spacetimegrid = ggplot_gtable(ggplot_build(spacetimeplot))
stripr = which(grepl('strip-', spacetimegrid$layout$name))
colors = c('#fc8c01', 'tan', dockless_colors(categorical = TRUE))
k = 1
for (i in stripr) {
  j = which(grepl('rect', spacetimegrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  spacetimegrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/spacetime.png',
  plot = spacetimegrid,
  scale = 1.5,
  dpi = 600
)

rm(rmse_dbafs, rmse_nfs, testpoints_dbafs, testpoints_nfs,
   testpoints_combined, spacetimeplot, spacetimegrid)

## ------------------- RMSE PER HOUR AND LAG ---------------------

# Calculate DBAFS forecasts RMSE's per hour of the day
rmse_dbafs = dockless::error_hourofday(
  forecasts_dbafs,
  type = 'RMSE'
)
rmse_dbafs[25] = rmse_dbafs[1]

# Calculate Naive forecasts RMSE's per hour of the day
rmse_nfs = dockless::error_hourofday(
  forecasts_nfs,
  type = 'RMSE'
)
rmse_nfs[25] = rmse_nfs[1]

# Combine
rmse_hourofday = data.frame(
  rmse = c(rmse_dbafs, rmse_nfs),
  hour = c(rep(seq(0, 24, 1), 2)),
  method = c(rep('DBAFS', 25), rep('NFS', 25))
)

# Plot
hourofday = ggplot(
  data = rmse_hourofday,
  mapping = aes(x = hour, y = rmse)
) +
  geom_line(
    mapping = aes(col = method),
    lwd = 2
  ) +
  scale_color_manual(
    values = c('#fc8c01', 'tan')
  ) +
  scale_x_continuous(
    breaks = c(0, 4, 8, 12, 16, 20, 24),
    labels = c("0:00", "4:00", "8:00", "12:00", "16:00", "20:00", "0:00")
  ) +
  labs(
    x = 'Hour of the day',
    y = 'Average RMSE'
  ) +
  theme(
    text = element_text(family = 'sans'),
    legend.position = 'none'
  )

# Calculate DBAFS forecasts RMSE's per hour of the day
rmse_dbafs = dockless::error_lag(
  forecasts_dbafs,
  type = 'RMSE'
)

# Calculate Naive forecasts RMSE's per hour of the day
rmse_nfs = dockless::error_lag(
  forecasts_nfs,
  type = 'RMSE'
)

# Combine
rmse_lag = data.frame(
  rmse = c(rmse_dbafs, rmse_nfs),
  lag = c(rep(seq(1, 96, 1), 2)),
  method = c(rep('DBAFS', 96), rep('NFS', 96))
)

# Plot
lag = ggplot(
  data = rmse_lag,
  mapping = aes(x = lag, y = rmse)
) +
  geom_line(
    mapping = aes(col = method),
    lwd = 2
  ) +
  scale_color_manual(
    values = c('#fc8c01', 'tan')
  ) +
  scale_x_continuous(
    breaks = c(0, 16, 32, 48, 64, 80, 96),
    labels = c('0 hours', '4 hours', '8 hours', '12 hours', '16 hours', '20 hours', '24 hours')
  ) +
  labs(
    x = 'Forecast lag',
    y = 'Average RMSE'
  ) +
  theme(
    text = element_text(family = 'sans'),
    legend.position = c(0.9, 0.9),
    legend.background = element_blank()
  )

# Combine and save
g = grid.arrange(hourofday, lag, ncol = 2)

ggsave(
  'Document/Figures/hourlag.png',
  plot = g,
  height = 5,
  width = 10,
  dpi = 600
)

rm(rmse_dbafs, rmse_nfs, rmse_hourofday, rmse_lag, hourofday, lag, g,
   testpoints, forecasts_dbafs, forecasts_nfs)

## ------------------ INDIVIDUAL FORECASTS --------------------------

forecasts_dbafs = readRDS('RDS Files/forecasts_modelpoints_dbafs.rds')
forecasts_nfs   = readRDS('RDS Files/forecasts_modelpoints_nfs.rds')

# Add cluster information to each data frame of the forecasts
f = function(x, y) {
  x$cluster = y
  return(x)
}

cluster_vector = as.factor(c(1,2,3,4))
dbafs_data = mapply(f, forecasts_dbafs, cluster_vector, SIMPLIFY = FALSE)
nfs_data   = mapply(f, forecasts_nfs, cluster_vector, SIMPLIFY = FALSE)

# Bind all data frames together
dbafs_newdata = do.call(rbind, dbafs_data)
nfs_newdata   = do.call(rbind, nfs_data)

# Data frame for observations
obs_newdata   = dbafs_newdata

# Add color columns
dbafs_newdata$color = '#fc8c01'
nfs_newdata$color   = 'tan'
obs_newdata$color   = 'darkgrey'

# Plot
forecastplot = ggplot() +
  geom_line(
    data = obs_newdata,
    mapping = aes(x = time, y = observation, col = color)
  ) +
  geom_line(
    data = dbafs_newdata,
    mapping = aes(x = time, y = forecast, col = color),
    size = 1
  ) +
  scale_x_datetime(
    date_breaks = '1 days',
    date_labels = c('Nov 5', 'Oct 29', 'Oct 30', 'Oct 31', 'Nov 1', 'Nov 2', 'Nov 3', 'Nov 4')
  ) +
  scale_color_manual(
    name = " ",
    values = c('#fc8c01', 'darkgrey'),
    labels = c('forecast', 'observation')
  ) +
  labs(
    x = 'Time',
    y = 'Distance to the nearest available bike (m)'
  ) +
  theme(
    text = element_text(family = 'sans'),
    axis.title.x = element_blank(),
    legend.position = 'bottom'
  ) +
  facet_wrap(
    ~ cluster,
    ncol = 1,
    scales = 'free',
    strip.position = 'right',
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
forecastgrid = ggplot_gtable(ggplot_build(forecastplot))
stripr = which(grepl('strip-', forecastgrid$layout$name))
colors = dockless_colors(categorical = TRUE)
k = 1
for (i in stripr) {
  j = which(grepl('rect', forecastgrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  forecastgrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/forecastplot.png',
  plot = forecastgrid,
  scale = 1.5,
  dpi = 600
)

rm(cluster_vector, forecastplot, forecastgrid, i,
   j, k, stripr, colors, forecasts_dbafs, forecasts_nfs,
   dbafs_data, nfs_data, dbafs_newdata, nfs_newdata, obs_newdata)

