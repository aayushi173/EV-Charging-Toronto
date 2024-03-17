install.packages("tidyjson") 
install.packages("tidygeocoder")
install.packages("sf")
install.packages("mapview")

library(tidyjson) 
library(dplyr) 
library(tidyverse)
library(tidygeocoder)
library(sf)
library(mapview)
library(stringr)

  
#Read the JSON data 
json_data <- jsonlite::fromJSON("green-p-parking-2019.json") 
  
#Convert the R object to a data frame 
df <- as.data.frame(json_data) 
  
#View the data frame 
head(df)


# Extract required columns from main data
data<- data.frame(address=df$carparks.address,
                                     lat=df$carparks.lat,
                                     lng=df$carparks.lng,
                                      carpark_type=df$carparks.carpark_type_str,
                                      rate_half_hr=df$carparks.rate_half_hour,
                                      capacity=df$carparks.capacity
                  )

# Check class of each attribute
sapply(data, class) 

# Convert char to numeric class
data$lat<-as.numeric(data$lat)
data$lng<-as.numeric(data$lng)
data$rate_half_hr<-as.numeric(data$rate_half_hr)
data$capacity<-as.numeric(data$capacity)


sapply(data, class) 

# Check for missing values
any(is.na(data))


# Extract street name from address
data <- data %>%
  mutate(extracted_address = str_replace_all(data$address, "\\(.*?\\)",""))

data$extracted_address<-str_replace_all(data$extracted_address, "-.*", "")
data$extracted_address<-str_replace_all(data$extracted_address, ",.*", "")

# Extract data with carpark_type as 'Surface'
data <- data %>%
  filter(carpark_type == "Surface")


# Convert Lat/Lng to address
geo_rev_data<-data %>%
  tidygeocoder::reverse_geocode(
    lat=lat,
    long=lng,
    method="osm")

# Plot map
map<-data %>%
  st_as_sf(
    coords=c("lng","lat"),
    crs=4326
  )

map %>% mapview()

# Filter data to extract only parking spots with M5C pin code
filtered_df <- geo_rev_data %>%
  filter(grepl("M5C", address...8))

# Print the filtered data frame
print(filtered_df)

# Convert Lat/Lng to address and plot map
filtered_df_map<-filtered_df %>%
  st_as_sf(
    coords=c("lng","lat"),
    crs=4326
  )

filtered_df_map %>% mapview()
