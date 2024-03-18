install.packages("dplyr") 
library(dplyr)
library(stringr)
###############################################################################
# Bring in Centerline Intersection dataset
###############################################################################
centerline_Intersection = read.csv("centerline_intersection.csv")
class(centerline_Intersection)

###############################################################################
# Data Exploration 
###############################################################################
# View data
head(centerline_Intersection)
# Data Summary
summary(centerline_Intersection)
# Column data types
lapply(centerline_Intersection,class)

# All attribute class appear good to continue

# For the purpose of our analysis, we will need the 
# INTERSECTION_DESC, INTERSECTION_ID, and geometry Columns from this data set
cl_df = centerline_Intersection[ -c(1,3:5,7:20)]
head(cl_df)
class(cl_df)

###############################################################################
# Data Structuring
###############################################################################
# Create Columns Lat and Long that contains the extracted Latitude and longitude
# From geometry column

cl_df = cl_df %>% 
  mutate(tcoord = str_extract(geometry, paste("(?<=\\[)[^]]+(?=\\])"))) %>%
  mutate(lat = str_extract(tcoord,paste("^(.+?),")))%>%
  mutate(long = str_extract(tcoord,paste(",^(.+?)")))
head(cl_df)

