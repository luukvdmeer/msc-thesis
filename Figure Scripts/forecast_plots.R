require(dockless)
require(dplyr)
require(ggplot2)
require(grid)
require(gridExtra)
require(lubridate)
require(tibble)

# Load data
testpoints = readRDS('RDS Files/testpoints.rds')
forecasts_dbafs = readRDS('RDS Files/forecasts_dbafs.rds')
forecasts_naive = readRDS('RDS Files/forecasts_naive.rds')

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
    fill = 'orange'
  ) +
  scale_x_datetime(
    date_breaks = '2 days',
    date_labels = c('16 dec', '04 dec', '06 dec', '08 dec', '10 dec', '12 dec', '14 dec')
  ) +
  theme(
    text = element_text(family = 'serif'),
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
rmse_naive = dockless::error(
  forecasts_naive,
  type = 'RMSE',
  return = 'all'
)

# Add to test points data
testpoints_naive = testpoints %>%
  mutate(rmse = rmse_naive, method = 'Naïve')

# Combine
testpoints_combined = rbind(testpoints_dbafs, testpoints_naive)

# Plot
spacetimeplot = ggplot() +
  geom_rect(
    data = data.frame(
      cluster = factor(1:4)
    ),
    mapping = aes(
      xmin = as.POSIXct('2018-12-08 00:00:00', tz = 'America/Los_Angeles', format = '%Y-%m-%d %H:%M:%S'), 
      xmax = as.POSIXct('2018-12-09 23:59:59', tz = 'America/Los_Angeles', format = '%Y-%m-%d %H:%M:%S'), 
      ymin = -Inf, 
      ymax = Inf
    ),
    alpha = 0.3,
    fill = 'darkgrey'
  ) +
  geom_rect(
    data = data.frame(
      cluster = factor(1:4)
    ),
    mapping = aes(
      xmin = as.POSIXct('2018-12-15 00:00:00', tz = 'America/Los_Angeles', format = '%Y-%m-%d %H:%M:%S'), 
      xmax = as.POSIXct('2018-12-16 23:59:59', tz = 'America/Los_Angeles', format = '%Y-%m-%d %H:%M:%S'), 
      ymin = -Inf, 
      ymax = Inf
    ),
    alpha = 0.3,
    fill = 'darkgrey'
  ) +
  geom_point(
    data = testpoints_combined,
    mapping = aes(x = time, y = rmse),
    size = 1
  ) +
  scale_x_datetime(
    date_breaks = "2 days",
    date_labels = c('04 dec', '06 dec', '08 dec', '10 dec', '12 dec', '14 dec', '16 dec')
  ) +
  labs(
    x = 'Time',
    y = 'RMSE'
  ) +
  theme(
    text = element_text(family = 'serif'),
    legend.position = 'none'
  ) +
  facet_grid(
    cluster ~ method,
    labeller = as_labeller(
      c(
        'DBAFS' = 'DBAFS',
        'Naïve' = 'NAÏVE',
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
colors = c('orange', 'tan', dockless_colors(categorical = TRUE))
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

rm(rmse_dbafs, rmse_naive, testpoints_dbafs, testpoints_naive,
   testpoints_combined, spacetimeplot, spacetimegrid)

## ------------------- RMSE PER HOUR AND LAG ---------------------

# Calculate DBAFS forecasts RMSE's per hour of the day
rmse_dbafs = dockless::error_hourofday(
  forecasts_dbafs,
  type = 'RMSE'
)
rmse_dbafs[25] = rmse_dbafs[1]

# Calculate Naive forecasts RMSE's per hour of the day
rmse_naive = dockless::error_hourofday(
  forecasts_naive,
  type = 'RMSE'
)
rmse_naive[25] = rmse_naive[1]

# Combine
rmse_hourofday = data.frame(
  rmse = c(rmse_dbafs, rmse_naive),
  hour = c(rep(seq(0, 24, 1), 2)),
  method = c(rep('DBAFS', 25), rep('NAÏVE', 25))
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
    values = c('orange', 'tan')
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
    text = element_text(family = 'serif'),
    legend.position = 'none'
  )

# Calculate DBAFS forecasts RMSE's per hour of the day
rmse_dbafs = dockless::error_lag(
  forecasts_dbafs,
  type = 'RMSE'
)

# Calculate Naive forecasts RMSE's per hour of the day
rmse_naive = dockless::error_lag(
  forecasts_naive,
  type = 'RMSE'
)

# Combine
rmse_lag = data.frame(
  rmse = c(rmse_dbafs, rmse_naive),
  lag = c(rep(seq(1, 96, 1), 2)),
  method = c(rep('DBAFS', 96), rep('NAÏVE', 96))
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
    values = c('orange', 'tan')
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
    text = element_text(family = 'serif'),
    legend.position = c(0.9, 0.15),
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

rm(rmse_dbafs, rmse_naive, rmse_hourofday, rmse_lag, hourofday, lag, g,
   testpoints, forecasts_dbafs, forecasts_naive)

## ------------------ INDIVIDUAL FORECASTS --------------------------

# Randomly sample two indices per cluster from testpoints
selection = testpoints %>%
  rowid_to_column %>%
  group_by(cluster) %>%
  sample_n(1)
  
indices = selection %>%
  pull(rowid)

# Select the corresponding forecasts, both for naïve and DBAFS
dbafs = forecasts_dbafs[indices]
naive = forecasts_naive[indices]
obser = forecasts_dbafs[indices]

# Add cluster number and number to each dockless_fc
for(i in c(1:length(indices))) {
  
  dbafs[[i]]$cluster = (selection$cluster)[i]
  dbafs[[i]]$color = 'orange'
  naive[[i]]$cluster = (selection$cluster)[i]
  naive[[i]]$color = 'tan'
  obser[[i]]$cluster = (selection$cluster)[i]
  obser[[i]]$color = 'black'
  
}

# Bind all together
dbafs_combined = do.call('rbind', dbafs)
naive_combined = do.call('rbind', naive)
obser_combined = do.call('rbind', obser)

# Plot
forecastplot = ggplot() +
  geom_line(
    data = obser_combined,
    mapping = aes(x = time, y = observation, col = color),
    size = 2
  ) +
  geom_line(
    data = naive_combined,
    mapping = aes(x = time, y = forecast, col = color),
    size = 2
  ) +
  geom_line(
    data = dbafs_combined,
    mapping = aes(x = time, y = forecast, col = color),
    size = 2
  ) +
  scale_color_manual(
    name = " ",
    values = c('black', 'orange', 'tan'),
    labels = c('observation', 'DBAFS forecast', 'naïve forecast')
  ) +
  labs(
    x = 'Time',
    y = 'Distance to the nearest available bike (m)'
  ) +
  theme(
    text = element_text(family = 'serif'),
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

rm(selection, indices, dbafs, naive, obser, forecastplot, forecastgrid, i,
   j, k, stripr, colors, dbafs_combined, naive_combined,
   obser_combined, forecasts_dbafs, forecasts_naive, testpoints)

