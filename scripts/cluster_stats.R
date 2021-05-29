require(tsfeatures)
require(dplyr)

# Load data
distancedata_centroids = readRDS('data/distancedata_centroids.rds')
gridcentroids = readRDS('data/gridcentroids.rds')

## -------------------------- LENGTH --------------------------------
# Calculate length of each time series
length_total = length(distancedata_centroids)

# Calculate average mean per cluster
length_cluster = gridcentroids %>%
  group_by(cluster) %>%
  summarise(length = n()) %>%
  pull(length)

# Store all results
length_results = c(length_total, length_cluster)

## -------------------------- MEAN ----------------------------------
# Calculate mean of each time series
mean_vec = sapply(
  distancedata_centroids,
  function(x) mean(x$distance, na.rm = TRUE)
)

# Calculate average mean of all time series
mean_avg_total = mean(mean_vec, na.rm = TRUE)

# Add cluster information
mean_df = data.frame(
  mean = mean_vec,
  cluster = gridcentroids$cluster
)

# Calculate average mean per cluster
mean_avg_cluster = mean_df %>%
  group_by(cluster) %>%
  summarise(mean = mean(mean, na.rm = TRUE)) %>%
  pull(mean)

# Store all results
mean_results = c(mean_avg_total, mean_avg_cluster)

## -------------------------- RANGE ----------------------------------
# Calculate range of each time series
range_vec = sapply(
  distancedata_centroids,
  function(x) max(x$distance, na.rm = TRUE) - min(x$distance, na.rm = TRUE)
)

# Calculate average range of all time series
range_avg_total = mean(range_vec, na.rm = TRUE)

# Add cluster information
range_df = data.frame(
  range = range_vec,
  cluster = gridcentroids$cluster
)

# Calculate average range per cluster
range_avg_cluster = range_df %>%
  group_by(cluster) %>%
  summarise(range = mean(range, na.rm = TRUE)) %>%
  pull(range)

# Store all results
range_results = c(range_avg_total, range_avg_cluster)

## -------------------- STANDARD DEVIATION --------------------------
# Calculate sd of each time series
var_vec = sapply(
  distancedata_centroids,
  function(x) var(x$distance, na.rm = TRUE)
)

# Calculate average sd of all time series
sd_avg_total = sqrt(mean(var_vec, na.rm = TRUE))

# Add cluster information
var_df = data.frame(
  var = var_vec,
  cluster = gridcentroids$cluster
)

# Calculate average sd per cluster
sd_avg_cluster = var_df %>%
  group_by(cluster) %>%
  summarise(sd = sqrt(mean(var, na.rm = TRUE))) %>%
  pull(sd)

# Store all results
sd_results = c(sd_avg_total, sd_avg_cluster)

## ----------------- FIRST ORDER AUTOCORRELATION --------------------
# Calculate first-order autocorrelation of each time series
acf_vec = sapply(
  distancedata_centroids,
  function(x) tsfeatures::acf_features(x$distance)[[1]]
)

# Calculate average first-order autocorrelation of all time series
acf_avg_total = mean(acf_vec)

# Add cluster information
acf_df = data.frame(
  acf = acf_vec,
  cluster = gridcentroids$cluster
)

# Calculate average first-order autocorrelations per cluster
acf_avg_cluster = acf_df %>%
  group_by(cluster) %>%
  summarise(acf = mean(acf)) %>%
  pull(acf)

# Store all results
acf_results = c(acf_avg_total, acf_avg_cluster)

## ------------------------ SPECTRAL ENTROPY ------------------------
# Calculate entropy of each time series
entropy_vec = sapply(
  distancedata_centroids,
  function(x) tsfeatures::entropy(x$distance)
)

# Calculate average entropy of all time series
entropy_avg_total = mean(entropy_vec)

# Add cluster information
entropy_df = data.frame(
  entropy = entropy_vec,
  cluster = gridcentroids$cluster
)

# Calculate average entropy per cluster
entropy_avg_cluster = entropy_df %>%
  group_by(cluster) %>%
  summarise(entropy = mean(entropy)) %>%
  pull(entropy)

# Store all results
entropy_results = c(entropy_avg_total, entropy_avg_cluster)

## -------------------------- COMBINE -------------------------------

cluster_stats = data.frame(
  length = length_results,
  mean = mean_results,
  range = range_results,
  sd = sd_results,
  acf = acf_results,
  entropy = entropy_results
)

rownames(cluster_stats) = c(
  'Total',
  'Bayview',
  'Downtown',
  'Residential',
  'Presido'
)

saveRDS(cluster_stats, 'data/cluster_stats.rds')
