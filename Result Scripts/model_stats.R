require(tsfeatures)
require(forecast)
require(dplyr)

# Load data
distancedata_models = readRDS('RDS Files/distancedata_models.rds')

# Calculate seasonal strength of each seasonal modelpoint dataset
seas_strength_1 = (distancedata_models[[1]] %>%
                     pull(distance) %>%
                     msts(seasonal.periods = 96) %>%
                     stl_features())[9]

seas_strength_2 = (distancedata_models[[2]] %>%
                     pull(distance) %>%
                     msts(seasonal.periods = c(96, 672)) %>%
                     stl_features())[10:11]

seas_strength_3 = (distancedata_models[[3]] %>%
                     pull(distance) %>%
                     msts(seasonal.periods = 96) %>%
                     stl_features())[9]

