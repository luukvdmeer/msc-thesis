require(ggplot2)
require(grid)
require(dplyr)
require(tidyr)
require(sf)
require(dockless)

# Load data
modeldata = readRDS('RDS Files/distancedata_modelpoints.rds')
models = readRDS('RDS Files/models.rds')

## ------------------------ TIME PLOTS ------------------------------

# Add model information to each data frame of distance data
f = function(x, y) {
  x$model = y
  return(x)
}

model_vector = as.factor(c(1,2,3,4))
data = mapply(f, modeldata, model_vector, SIMPLIFY = FALSE)

# Bind all data frames together
newdata = do.call(rbind, data)

# Function to find start and end times of weekends
weekend = function(x) {
  saturdaystart = x %>%
    mutate(saturday = lubridate::wday(.$time, week_start = 1) == 6) %>%
    filter(saturday) %>%
    filter(lubridate::hour(.$time) == 0 & lubridate::minute(.$time) == 0) %>%
    select(-saturday)
  
  sundayend = x %>%
    mutate(sunday = lubridate::wday(.$time, week_start = 1) == 7) %>%
    filter(sunday) %>%
    filter(lubridate::hour(.$time) == 23 & lubridate::minute(.$time) == 45) %>%
    select(-sunday)
  
  if(nrow(sundayend) == (nrow(saturdaystart)-1)) {
    sundayend = rbind(sundayend, x[nrow(x),])
  } else if (nrow(saturdaystart) == (nrow(sundayend)-1)) {
    saturdaystart = rbind(x[1,], saturdaystart)
  }
  
  weekend = bind_cols(saturdaystart, sundayend) %>%
    select(time, time1)
}

# Plot
timeplot = ggplot() +
  geom_rect(
    data = weekend(newdata),
    mapping = aes(
      xmin = time, 
      xmax = time1, 
      ymin = -Inf, 
      ymax = Inf
    ),
    fill = 'darkgrey',
    alpha = 0.1
  ) +
  geom_line(
    data = newdata,
    mapping = aes(x = time, y = distance)
  ) +
  labs(
    x = 'Time',
    y = 'Distance to the nearest bike (m)'
  ) +
  scale_x_datetime(
    date_breaks = '1 weeks',
    date_labels = c('Oct 15', 'Sep 17', 'Sep 24', 'Oct 1', 'Oct 8')
  ) +
  theme(
    text = element_text(family = 'sans')
  ) +
  facet_grid(
    model ~ .,
    scale = 'free_y',
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
timegrid = ggplot_gtable(ggplot_build(timeplot))
stripr = which(grepl('strip-r', timegrid$layout$name))
colors = dockless_colors(categorical = TRUE)
k = 1
for (i in stripr) {
  j = which(grepl('rect', timegrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  timegrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/timeplots.png',
  plot = timegrid,
  scale = 1.5,
  dpi = 600
)

rm(model_vector, data, f, stripr, colors, k, i, j, timeplot, timegrid, weekend)

## ------------------ RESIDUAL TIME PLOTS ---------------------------

# Get the residuals from each model as a vector
residuals = lapply(models, function(x) as.vector(x$residuals))

# Combine those vectors
residuals_combined = do.call('c', residuals)

# Add as column to newdata
newdata$residuals = residuals_combined

# Plot
residual_timeplot = ggplot(
  data = newdata,
  mapping = aes(x = time, y = residuals)
) +
  geom_line() +
  labs(
    x = 'Time',
    y = 'Residuals'
  ) +
  scale_x_datetime(
    date_breaks = '1 weeks',
    date_labels = c('Oct 15', 'Sep 17', 'Sep 24', 'Oct 1', 'Oct 8')
  ) +
  theme(
    text = element_text(family = 'sans')
  ) +
  facet_grid(
    model ~ .,
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
residual_timegrid = ggplot_gtable(ggplot_build(residual_timeplot))
stripr = which(grepl('strip-r', residual_timegrid$layout$name))
colors = dockless_colors(categorical = TRUE)
k = 1
for (i in stripr) {
  j = which(grepl('rect', residual_timegrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  residual_timegrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/residual_timeplots.png',
  plot = residual_timegrid,
  scale = 1.5,
  dpi = 600
)

rm(residuals, residuals_combined, f, stripr, colors, k, i, j, 
   residual_timeplot, residual_timegrid)

## ------------------ RESIDUAL AUTOCORRELATION ----------------------

# Get the residuals from each model as a vector
acfdata = newdata %>%
  tsibble::as_tsibble(key = id(model)) %>%
  tsibblestats::ACF(value = residuals, lag.max = 672, na.action = na.pass)

# Plot
residual_acfplot = ggplot(
  data = acfdata,
  mapping = aes(x = lag, y = acf)
) +
  geom_hline(
    mapping = aes(yintercept = 1.96 / sqrt(nrow(newdata %>% filter(model == 1)))),
    linetype = 'dashed',
    col = 'orange',
    lwd = 1
  ) +
  geom_hline(
    mapping = aes(yintercept = -1.96 / sqrt(nrow(newdata %>% filter(model == 1)))),
    linetype = 'dashed',
    col = 'orange',
    lwd = 1
  ) +
  geom_hline(
    mapping = aes(yintercept = mean(acfdata$acf, na.rm = TRUE))
  ) +
  geom_segment(
    mapping = aes(xend = lag, yend = mean(acfdata$acf, na.rm = TRUE))
  ) +
  labs(
    x = 'Time lag',
    y = 'Autocorrelation'
  ) +
  scale_x_continuous(
    breaks = seq(0, nrow(acfdata), 96)
  ) +
  theme(
    text = element_text(family = 'sans')
  ) +
  facet_grid(
    model ~ .,
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
residual_acfgrid = ggplot_gtable(ggplot_build(residual_acfplot))
stripr = which(grepl('strip-r', residual_acfgrid$layout$name))
colors = dockless_colors(categorical = TRUE)
k = 1
for (i in stripr) {
  j = which(grepl('rect', residual_acfgrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  residual_acfgrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/residual_acfplots.png',
  plot = residual_acfgrid,
  scale = 1.5,
  dpi = 600
)

rm(acfdata, stripr, colors, k, i, j, residual_acfplot, residual_acfgrid)

## -------------------- RESIDUAL HISTOGRAMS -------------------------

# Plot
residual_histogram = ggplot(
  data = newdata,
  mapping = aes(x = residuals)
) +
  geom_histogram(
    fill = 'black',
    binwidth = 0.1
  ) +
  geom_rug(
    sides = 'b',
    col = 'darkgrey'
  ) +
  labs(
    x = 'Residuals',
    y = 'Count'
  ) +
  theme(
    text = element_text(family = 'sans')
  ) +
  facet_grid(
    . ~ model,
    scale = 'free',
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
residual_histogrid = ggplot_gtable(ggplot_build(residual_histogram))
stripr = which(grepl('strip-', residual_histogrid$layout$name))
colors = dockless_colors(categorical = TRUE)
k = 1
for (i in stripr) {
  j = which(grepl('rect', residual_histogrid$grobs[[i]]$grobs[[1]]$childrenOrder))
  residual_histogrid$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill = colors[k]
  k = k + 1
}

ggsave(
  'Document/Figures/residual_histograms.png',
  plot = residual_histogrid,
  scale = 1.5,
  dpi = 600
)

rm(stripr, colors, k, i, j, residual_histogram, residual_histogrid)

## ------------------------ STL PLOTS -------------------------------

## MODEL 2
stl = models[[2]]$stl %>%
  as_tibble() %>%
  gather() %>%
  mutate(key = factor(.$key, levels = c('Data', 'Trend', 'Seasonal96', 'Remainder'))) %>%
  mutate(time = rep(modeldata[[2]]$time, length(unique(.$key))))

stlplot_2 = ggplot() +
  geom_line(
    data = stl,
    mapping = aes(x = time, y = value)
  ) +
  labs(
    x = 'Time',
    y = 'Log transformed distance to the nearest bike'
  ) +
  scale_x_datetime(
    date_breaks = '1 weeks',
    date_labels = c('Oct 15', 'Sep 17', 'Sep 24', 'Oct 1', 'Oct 8')
  ) +
  theme(
    text = element_text(family = 'sans'),
    strip.background = element_rect(fill = dockless_colors(categorical = TRUE)[2])
  ) +
  facet_grid(
    key ~ .,
    scale = 'free_y'
  )

ggsave(
  'Document/Figures/stlplot_model2.png',
  plot = stlplot_2,
  scale = 1.5,
  dpi = 600
)

## MODEL 3
stl = models[[3]]$stl %>%
  as_tibble() %>%
  gather() %>%
  mutate(key = factor(.$key, levels = c('Data', 'Trend', 'Seasonal96', 'Remainder'))) %>%
  mutate(time = rep(modeldata[[3]]$time, length(unique(.$key))))

stlplot_3 = ggplot() +
  geom_line(
    data = stl,
    mapping = aes(x = time, y = value)
  ) +
  labs(
    x = 'Time',
    y = 'Log transformed distance to the nearest bike'
  ) +
  scale_x_datetime(
    date_breaks = '1 weeks',
    date_labels = c('Oct 15', 'Sep 17', 'Sep 24', 'Oct 1', 'Oct 8')
  ) +
  theme(
    text = element_text(family = 'sans'),
    strip.background = element_rect(fill = dockless_colors(categorical = TRUE)[3])
  ) +
  facet_grid(
    key ~ .,
    scale = 'free_y'
  )

ggsave(
  'Document/Figures/stlplot_model3.png',
  plot = stlplot_3,
  scale = 1.5,
  dpi = 600
)

rm(modeldata, models, newdata)