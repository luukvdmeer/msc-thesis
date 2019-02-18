require(dockless)
require(dplyr)

# Load data
forecasts_dbafs = readRDS('RDS Files/forecasts_dbafs.rds')
forecasts_nfs = readRDS('RDS Files/forecasts_nfs.rds')
testpoints = readRDS('RDS Files/testpoints.rds')

## ----------------------- POINT FORECAST ERRORS --------------------

# Number of test points per area
n_testpoints = c(
  nrow(testpoints),
  as.vector(table(testpoints$cluster))
)

# RMSE for DBAFS
rmse_dbafs = dockless::evaluate(
  x = forecasts_dbafs,
  clusters = testpoints$cluster,
  type = 'RMSE'
)

# # MAE for DBAFS
# mae_dbafs = dockless::evaluate(
#   x = forecasts_dbafs,
#   clusters = testpoints$cluster,
#   type = 'MAE'
# )

# RMSE for Naïve
rmse_nfs = dockless::evaluate(
  x = forecasts_nfs,
  clusters = testpoints$cluster,
  type = 'RMSE'
)

# # MAE for Naïve
# mae_nfs = dockless::evaluate(
#   x = forecasts_nfs,
#   clusters = testpoints$cluster,
#   type = 'MAE'
# )

# Combine
results = do.call(
  'cbind', 
  list(n_testpoints, rmse_dbafs, rmse_nfs)
)
rownames(results) = c(
  'Total', 
  'Bayview', 
  'Downtown', 
  'Residential', 
  'Presidio'
)
colnames(results) = c(
  'n',
  rep(c('mean', 'min', 'max'), 2)
)

# Save as data.frame
saveRDS(as.data.frame(results), 'Document/Results/forecast_results.rds')

## ----------------------- PREDICTION INTERVALS ---------------------

# For each dockless_fc, examine if forecasts fall inside prediction interval
f = function(x) {
  inside_interval = (x$observation <= x$upper95 & x$observation >= x$lower95)
  inside_count = sum(inside_interval, na.rm = TRUE)
  all_count = length(inside_interval) - length(inside_interval[is.na(inside_interval)])
  return(c(inside_count, all_count))
}

inside_interval = sapply(forecasts_dbafs, f)

# Convert to data frame and add cluster information
inside_interval_df = data.frame(
  inside_count = inside_interval[1,],
  all_count = inside_interval[2,],
  cluster = testpoints$cluster
)

# Total percentage within the bounds
percentage_total = inside_interval_df %>%
  summarise(percentage = sum(inside_count) / sum(all_count) * 100) %>%
  pull(percentage)

# Percentage within the bounds per cluster
percentage_cluster = inside_interval_df %>%
  group_by(cluster) %>%
  summarise(percentage = sum(inside_count) / sum(all_count) * 100) %>%
  pull(percentage)

# Combine
prediction_interval_check = matrix(
  c(percentage_total, percentage_cluster),
  nrow = 1
)
rownames(prediction_interval_check) = 
  c('Percentage of observations within 95% prediction interval')
colnames(prediction_interval_check) =
  c('Total', 'Bayview', 'Downtown', 'Residential', 'Presidio')

# Save as data.frame
saveRDS(as.data.frame(prediction_interval_check), 'Document/Results/prediction_interval_check.rds')



