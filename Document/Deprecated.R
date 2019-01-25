## ------------------------------ Ljung Box -------------------------
# Instead, the Ljung-Box test can be used, which tests the null hypothesis that the residuals are independent, against the alternative that they are not. It uses the test statistic as shown in Equation 2.x.
# 
# $$ Q = n(n + 2) \sum_{h=1}^{k} \frac{\hat\rho(h)^{2}}{n - h} $$
#   
# Where $n$ is the length of the sample data, $\hat\rho(h)$ is the autocorrelation of the corresponding residuals at time lag $h$, and $k$ is the number of time lags involved in the test. @hyndman2018fpp suggest to use $k = 10$ for non-seasonal data, and $k = 2m$ for seasonal data, where $m$ is the seasonal period. The detailed mathematics underlying the test can be found in @ljung1978.