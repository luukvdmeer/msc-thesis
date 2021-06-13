# Thesis for the Master of Science in Geospatial Technologies

## Overview

This repository contains my my master thesis **Spatio-Temporal Forecasts for Bike Availability in Dockless Bike Sharing Systems**. The thesis is the final part of the master program in [Geospatial Technologies](http://mastergeotech.info/). I used the bookdown-based R package [thesisdown](https://github.com/ismayc/thesisdown) to create the document.

The final document can be found [here](docs/thesis.pdf). An online gitbook version is available [here](https://luukvdmeer.github.io/msc-thesis/spatio-temporal-forecasts-for-bike-availability-in-dockless-bike-sharing-systems.html). However, the thesis document is optimized for LateX knitting, and never intended to be in gitbook format. Therefore, style errors may occur in the gitbook version and references may not work. The PDF version is the official version!

All code used in this thesis is bundled in the R package **dockless**, which GitHub repository can be found [here](https://github.com/luukvdmeer/dockless).

The presentation slides for the thesis defence can be found [here](https://luukvdmeer.github.io/msc-thesis/defence/defence.html). These slides are created using RMarkdown and the [xaringan](https://github.com/yihui/xaringan) package. All related files are in the [defence folder](docs/defence).

## Abstract

Forecasting bike availability is of great importance when turning the shared bike into a reliable, pleasant and uncomplicated mode of transport. Several approaches have been developed to forecast bike availability in station-based bike sharing systems. However, dockless bike sharing systems remain fairly unexplored in that sense, despite their rapid expansion over the world in recent years. To fill this gap, this thesis aims to develop a generally applicable methodology for bike availability forecasting in dockless bike sharing systems, that produces automated, fast and accurate forecasts. \par

To balance speed and accuracy, an approach is taken in which the system area of a dockless bike sharing system is divided into spatially contiguous clusters that represent locations with the same temporal patterns in the historical data. Each cluster gets assigned a model point, for which an ARIMA($p$,$d$,$q$) forecasting model is fitted to the deseasonalized data. Each individual forecast will inherit the structure and parameters of one of those pre-build models, rather than building a new model on its own. \par

The proposed system was tested through a case study in San Francisco, California. The results showed that the proposed system outperforms simple baseline methods. However, they also highlighted the limited forecastability of dockless bike sharing data. \par

## Keywords

`dockless` `bike sharing systems` `bike availability` `forecasting` `time series analysis` `sustainable transport`
