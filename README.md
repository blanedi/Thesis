
## Impact of women's participation in politics on the development and implementation of progressive care policies in Latin America and the Caribbean

This repository houses the R code and analytical framework for [Cintya Huaire](https://www.linkedin.com/in/cintyahuaire/)'s [master's thesis](https://www.researchgate.net/publication/371555501_Impact_of_women%27s_participation_in_politics_on_the_development_and_implementation_of_progressive_care_policies_in_Latin_America_and_the_Caribbean?channel=doi&linkId=6489bb53712bd82962230b14&showFulltext=true) at the Hertie School of Public Policy. The research delves into the extent to which women's active involvement in politics shapes the formulation and execution of forward-thinking care policies across Latin America and the Caribbean.  

## Table of Contents
- [Libraries Used](#libraries-used)
- [Data Loading and Preprocessing](#data-loading-and-preprocessing)
- [Analysis](#analysis)
- [Visualization](#visualization)
- [Note](#note)

## Libraries Used
The following R libraries are essential for the analysis:

```R
library(tidyverse)
library(haven)
library(descr)
library(corrplot)
library(knitr)
library(kableExtra)
library(readxl)
library(ggplot2)
library(table1)
library(gtsummary)
library(estimatr)
library(dplyr)
library(car)
library(plm)
library(zoo)
```

## Data Loading and Preprocessing
The data for this analysis is sourced from various CSV files corresponding to different countries in Latin America and the Caribbean. The data is then merged, subsetted, and reshaped as required for the analysis.

## Analysis
The core of the research involves:

- **Correlation Analysis**: Calculating correlation matrices and creating correlograms.
- **Descriptive Statistics**: Generating a summary of the data.
- **Multicollinearity Test**: Checking for multicollinearity in the regression models.
- **Modeling**: Running fixed and random effects models and conducting the Hausman test to choose the appropriate model.
- **Regional Analysis**: Comparing models based on different regions: South America (including Mexico) and the Caribbean & Central America.

## Visualization
The results of the analysis are visualized using various plots, including:

- Line plots showcasing the percentage of women in parliament by year and country.
- Model coefficient plots to interpret the results of the regression models.

## Note
For a detailed walkthrough of the code and the steps involved in the analysis, please refer to the provided R script.

