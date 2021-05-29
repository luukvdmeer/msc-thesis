require(dockless)
require(dplyr)

database_user = ''
database_password = ''

## -------------------- DISTANCE DATA ---------------------

# Distance data for the grid cell centroids, during the training period
distancedata_centroids_train = dockless::query_distances(
  gridcentroids,
  from = as.POSIXct(
    "2018-09-17 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-10-15 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
)

# Distance data for the grid cell centroids, during the test period
distancedata_centroids_test = dockless::query_distances(
  gridcentroids,
  from = as.POSIXct(
    "2018-10-14 23:45:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-11-05 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
)

# Distance data for the model points, during the training period
distancedata_modelpoints_train = dockless::query_distances(
  modelpoints,
  from = as.POSIXct(
    "2018-09-16 23:45:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-10-15 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
)

# Distance data for the model points, during the test period
distancedata_modelpoints_test = dockless::query_distances(
  modelpoints,
  from = as.POSIXct(
    "2018-10-14 23:45:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-11-06 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
)

# Distance data for the test points
distancedata_testpoints = dockless::query_distances(
  testpoints,
  from = as.POSIXct(
    "2018-10-14 23:45:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-11-06 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
)

## ---------------------- USAGE DATA ----------------------

# Usage data for the training period
usagedata_train = dockless::query_bikes(
  from = as.POSIXct(
    "2018-09-17 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-10-15 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
) %>%
  pull(bike_id) %>%
  dockless::query_usage(
    from = as.POSIXct(
      "2018-09-17 00:00:00",
      format = "%Y-%m-%d %H:%M:%S", 
      tz = "America/Los_Angeles"
    ),
    to = as.POSIXct(
      "2018-10-15 00:00:00",
      format = "%Y-%m-%d %H:%M:%S", 
      tz = "America/Los_Angeles"
    ),
    database_user = database_user,
    database_password = database_password
  )

# Usage data for the test period
usagedata_test = dockless::query_bikes(
  from = as.POSIXct(
    "2018-10-29 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  to = as.POSIXct(
    "2018-11-05 00:00:00",
    format = "%Y-%m-%d %H:%M:%S", 
    tz = "America/Los_Angeles"
  ),
  database_user = database_user,
  database_password = database_password
) %>%
  pull(bike_id) %>%
  dockless::query_usage(
    from = as.POSIXct(
      "2018-10-29 00:00:00",
      format = "%Y-%m-%d %H:%M:%S", 
      tz = "America/Los_Angeles"
    ),
    to = as.POSIXct(
      "2018-11-05 00:00:00",
      format = "%Y-%m-%d %H:%M:%S", 
      tz = "America/Los_Angeles"
    ),
    database_user = database_user,
    database_password = database_password
  )