require(dplyr)
require(lubridate)
require(ggplot2)

# Load data
usagedata_train = readRDS('data/usagedata_train.rds')

## ------------------------- DAY OF WEEK ----------------------------
usagedata_train$day = lubridate::wday(
  usagedata_train$time,
  label = TRUE,
  abbr = TRUE,
  week_start = 1,
  locale = Sys.setlocale('LC_TIME', 'English')
)

usagedata_dayofweek = as.data.frame(table(usagedata_train$day)/4)

# Plot
usage_dayofweek = ggplot(
  data = usagedata_dayofweek,
  mapping = aes(x = Var1, y = Freq)
) +
  geom_bar(
    fill = '#fc8c01',
    stat = 'identity'
  ) +
  labs(
    x = 'Day of the week',
    y = 'Average number of pick-ups'
  ) +
  theme(
    text = element_text(family = 'sans')
  )

# Save
ggsave(
  'figures/usageday.png',
  plot = usage_dayofweek,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)

## ------------------------- HOUR OF DAY ----------------------------
usagedata_train$hour = lubridate::hour(usagedata_train$time)
usagedata_hourofday = as.data.frame(table(usagedata_train$hour)/28)

# Plot
usage_hourofday = ggplot(
  data = usagedata_hourofday,
  mapping = aes(x = Var1, y = Freq)
) +
  geom_bar(
    fill = '#fc8c01',
    stat = 'identity'
  ) +
  labs(
    x = 'Hour of the day',
    y = 'Average number of pick-ups'
  ) +
  theme(
    text = element_text(family = 'sans')
  )

# Save
ggsave(
  'figures/usagehour.png',
  plot = usage_hourofday,
  width = 5,
  height = 5,
  units = 'in',
  dpi = 600
)