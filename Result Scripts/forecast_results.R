require(dockless)

# Load data
forecasts = readRDS('RDS Files/forecasts.rds')
forecasts_naive = readRDS('RDS Files/forecasts_naive.rds')
testpoints = readRDS('RDS Files/testpoints.rds')

# Number of test points per area
n_testpoints = c(
  nrow(testpoints),
  as.vector(table(testpoints$cluster))
)

# RMSE for DBAFS
rmse_dbafs = dockless::evaluate(
  x = forecasts,
  clusters = testpoints$cluster,
  type = 'RMSE'
)

# MAE for DBAFS
mae_dbafs = dockless::evaluate(
  x = forecasts,
  clusters = testpoints$cluster,
  type = 'MAE'
)

# RMSE for Naïve
rmse_naive = dockless::evaluate(
  x = forecasts_naive,
  clusters = testpoints$cluster,
  type = 'RMSE'
)

# MAE for Naïve
mae_naive = dockless::evaluate(
  x = forecasts_naive,
  clusters = testpoints$cluster,
  type = 'MAE'
)

# Combine
results = do.call(
  'cbind', 
  list(n_testpoints, rmse_dbafs, mae_dbafs, rmse_naive, mae_naive)
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
  rep(c('mean', 'min', 'max'), 4)
)

# Save as data.frame
saveRDS(as.data.frame(results), 'Document/Results/forecast_results.rds')

