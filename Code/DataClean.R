#download data from open data toronto
install.packages("opendatatoronto")
library(opendatatoronto)
library(dplyr)
library(stringr)

# get package
package <- show_package("traffic-volumes-at-intersections-for-all-modes")
package

# get all resources for this package
resources <- list_package_resources("traffic-volumes-at-intersections-for-all-modes")

# identify datastore resources; by default, Toronto Open Data sets datastore resource format to CSV for non-geospatial and GeoJSON for geospatial resources
datastore_resources <- filter(resources, tolower(format) %in% c('csv', 'geojson'))

# load the first datastore resource as a sample
location <- filter(datastore_resources, row_number()==1) %>% get_resource()


datastore_resources$name
traffic1 <-filter(datastore_resources, row_number()==3) %>% get_resource()
traffic2 <-filter(datastore_resources, row_number()==4) %>% get_resource()
traffic3 <-filter(datastore_resources, row_number()==5) %>% get_resource()
traffic4 <-filter(datastore_resources, row_number()==6) %>% get_resource()
traffic5 <-filter(datastore_resources, row_number()==7) %>% get_resource()
meta <- filter(datastore_resources, row_number()==2) %>% get_resource()


# Post Code M5C, https://postal-codes.cybo.com/canada/M5C_toronto/

# boundary can be user defined. 

# 4 Intersections Starting at North West Corner going clockwise
#1: Dupont Ossington
#2: Dupont Spadina
#3: Spadina College
#4: College Ossington

# assume the boundary is a rectangle 
# coordinates manually looked up from location dataset
#1406	5370	DUPONT ST AT OSSINGTON AVE (PX 842)	-79.429019	43.670031996501194
# 251	4180	DUPONT ST AT SPADINA RD (PX 840)	-79.407122	43.67485699954096
#1885	5864	COLLEGE ST AT OSSINGTON AVE (PX 829)	-79.422705	43.65439999619167
#241	4170	COLLEGE ST AT SPADINA AVE (PX 279)	-79.400048	43.65794800150128

# traffic volume boundary bigger than region of interest ROI. 

boundary <- location %>%
  select(location_id,location,lng,lat) %>%
  filter(location_id %in% list(5370,4180,5864,4170)) # boundary intersection ID

lng_min <- min(boundary$lng) # west most value since it's negative
lng_max <- max(boundary$lng) # east most value
lat_min <- min(boundary$lat) # south most value
lat_max <- max(boundary$lat) # north most value


# remove unnecessary data:
# columns:  ID, Count ID, centre line ID? m px, truck, bus, peds
col_rem_t1 <-select(traffic1, one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                                       "time_start","time_end","sb_cars_r","sb_cars_t","sb_cars_l",
                                       "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                                       "eb_cars_r","eb_cars_t","eb_cars_l")))

# rows: 
# centre line type 1
# 

row_rem_t1 <-filter(col_rem_t1,centreline_type ==2)


# filter by boundary <- last step


row_bound_t1 <-row_rem_t1 %>% 
  filter(lng > lng_min & lng < lng_max) %>%
  filter(lat > lat_min & lat < lat_max)


unique(row_bound_t1$count_date)
unique(row_bound_t1$location_id)

row_rem_t_common <- trafficsince2010_common %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                            "time_start","time_end","sb_cars_r","sb_cars_t","sb_cars_l",
                            "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                            "eb_cars_r","eb_cars_t","eb_cars_l"))) %>%
  filter(centreline_type ==2) 

row_bound_t_common <-row_rem_t_common %>% 
  filter(lng > lng_min & lng < lng_max) %>%
  filter(lat > lat_min & lat < lat_max)
# transform: 

# Separate Time Start Time End between Date, Hour, 
# then group by date and hour, data is taken in 15 min increments
# sum total vol by at each intersection - new column
# sum total nb/sb/eb/wb outflow traffic vol - new column
# new columns of two streets of the intersection
# remove individual vol count per type

tranform_t1 <- row_rem_t1 %>%
  mutate(counthour = str_extract(time_start,"(?<=T)(\\d+)(?=\\:)")) %>%
  mutate(total_int_traffic = sb_cars_r+sb_cars_t+sb_cars_l+
           nb_cars_r+nb_cars_t+nb_cars_l+wb_cars_r + wb_cars_t+
           wb_cars_l+eb_cars_r+eb_cars_t+eb_cars_l) %>%
  mutate(nb_exit_traffic = nb_cars_t+eb_cars_l+wb_cars_r) %>%
  mutate(sb_exit_traffic = sb_cars_t+eb_cars_r+wb_cars_l) %>%
  mutate(wb_exit_traffic = wb_cars_t+nb_cars_l+sb_cars_r) %>%
  mutate(eb_exit_traffic = eb_cars_t+nb_cars_r+sb_cars_l) %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "counthour",
                  "total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                  "eb_exit_traffic")))

plot(unique(traffic4$lng),unique(traffic4$lat))
  
hourlySum_t1 <- tranform_t1 %>%
  group_by(across(all_of(c("count_date","location_id","location","lng","lat", "counthour")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum))
# peak hours to consider
peakhours <- 4

peak_t1 <- hourlySum_t1 %>%
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  slice_max(order_by = total_int_traffic, n = peakhours)  # get peakhours worth of volume based on total traffic data
  
  
clean_t1 <- peak_t1 %>%
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum))

clean_T1 <- traffic1 %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                                      "time_start","sb_cars_r","sb_cars_t","sb_cars_l",
                                      "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                                      "eb_cars_r","eb_cars_t","eb_cars_l"))) %>% #select needed attributes
  filter(centreline_type ==2) %>% #only need intersection data
  mutate(counthour = str_extract(time_start,"(?<=T)(\\d+)(?=\\:)")) %>% # extract hour
  mutate(total_int_traffic = sb_cars_r+sb_cars_t+sb_cars_l+
           nb_cars_r+nb_cars_t+nb_cars_l+wb_cars_r + wb_cars_t+
           wb_cars_l+eb_cars_r+eb_cars_t+eb_cars_l) %>% # get total sum
  mutate(nb_exit_traffic = nb_cars_t+eb_cars_l+wb_cars_r) %>% # get north bound exit volume
  mutate(sb_exit_traffic = sb_cars_t+eb_cars_r+wb_cars_l) %>% # get south bound exit volume
  mutate(wb_exit_traffic = wb_cars_t+nb_cars_l+sb_cars_r) %>% # get west bound exit volume
  mutate(eb_exit_traffic = eb_cars_t+nb_cars_r+sb_cars_l) %>% # get east bound exit volume
  select(one_of(c("count_date","location_id","location","lng","lat", "counthour",
                  "total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                  "eb_exit_traffic"))) %>% # remove raw attributes, retain aggregate only
  group_by(across(all_of(c("count_date","location_id","location","lng","lat", "counthour")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) %>% # agregate hourly volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  slice_max(order_by = total_int_traffic, n = peakhours) %>% # filter top peak hour volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) # aggregate daily peak hour volume

clean_T2 <- traffic2 %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                  "time_start","sb_cars_r","sb_cars_t","sb_cars_l",
                  "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                  "eb_cars_r","eb_cars_t","eb_cars_l"))) %>% #select needed attributes
  filter(centreline_type ==2) %>% #only need intersection data
  mutate(counthour = str_extract(time_start,"(?<=T)(\\d+)(?=\\:)")) %>% # extract hour
  mutate(total_int_traffic = sb_cars_r+sb_cars_t+sb_cars_l+
           nb_cars_r+nb_cars_t+nb_cars_l+wb_cars_r + wb_cars_t+
           wb_cars_l+eb_cars_r+eb_cars_t+eb_cars_l) %>% # get total sum
  mutate(nb_exit_traffic = nb_cars_t+eb_cars_l+wb_cars_r) %>% # get north bound exit volume
  mutate(sb_exit_traffic = sb_cars_t+eb_cars_r+wb_cars_l) %>% # get south bound exit volume
  mutate(wb_exit_traffic = wb_cars_t+nb_cars_l+sb_cars_r) %>% # get west bound exit volume
  mutate(eb_exit_traffic = eb_cars_t+nb_cars_r+sb_cars_l) %>% # get east bound exit volume
  select(one_of(c("count_date","location_id","location","lng","lat", "counthour",
                  "total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                  "eb_exit_traffic"))) %>% # remove raw attributes, retain aggregate only
  group_by(across(all_of(c("count_date","location_id","location","lng","lat", "counthour")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) %>% # agregate hourly volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  slice_max(order_by = total_int_traffic, n = peakhours) %>% # filter top peak hour volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) # aggregate daily peak hour volume

clean_T3 <- traffic3 %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                  "time_start","sb_cars_r","sb_cars_t","sb_cars_l",
                  "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                  "eb_cars_r","eb_cars_t","eb_cars_l"))) %>% #select needed attributes
  filter(centreline_type ==2) %>% #only need intersection data
  mutate(counthour = str_extract(time_start,"(?<=T)(\\d+)(?=\\:)")) %>% # extract hour
  mutate(total_int_traffic = sb_cars_r+sb_cars_t+sb_cars_l+
           nb_cars_r+nb_cars_t+nb_cars_l+wb_cars_r + wb_cars_t+
           wb_cars_l+eb_cars_r+eb_cars_t+eb_cars_l) %>% # get total sum
  mutate(nb_exit_traffic = nb_cars_t+eb_cars_l+wb_cars_r) %>% # get north bound exit volume
  mutate(sb_exit_traffic = sb_cars_t+eb_cars_r+wb_cars_l) %>% # get south bound exit volume
  mutate(wb_exit_traffic = wb_cars_t+nb_cars_l+sb_cars_r) %>% # get west bound exit volume
  mutate(eb_exit_traffic = eb_cars_t+nb_cars_r+sb_cars_l) %>% # get east bound exit volume
  select(one_of(c("count_date","location_id","location","lng","lat", "counthour",
                  "total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                  "eb_exit_traffic"))) %>% # remove raw attributes, retain aggregate only
  group_by(across(all_of(c("count_date","location_id","location","lng","lat", "counthour")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) %>% # agregate hourly volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  slice_max(order_by = total_int_traffic, n = peakhours) %>% # filter top peak hour volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) # aggregate daily peak hour volume

clean_T4 <- traffic4 %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                  "time_start","sb_cars_r","sb_cars_t","sb_cars_l",
                  "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                  "eb_cars_r","eb_cars_t","eb_cars_l"))) %>% #select needed attributes
  filter(centreline_type ==2) %>% #only need intersection data
  mutate(counthour = str_extract(time_start,"(?<=T)(\\d+)(?=\\:)")) %>% # extract hour
  mutate(total_int_traffic = sb_cars_r+sb_cars_t+sb_cars_l+
           nb_cars_r+nb_cars_t+nb_cars_l+wb_cars_r + wb_cars_t+
           wb_cars_l+eb_cars_r+eb_cars_t+eb_cars_l) %>% # get total sum
  mutate(nb_exit_traffic = nb_cars_t+eb_cars_l+wb_cars_r) %>% # get north bound exit volume
  mutate(sb_exit_traffic = sb_cars_t+eb_cars_r+wb_cars_l) %>% # get south bound exit volume
  mutate(wb_exit_traffic = wb_cars_t+nb_cars_l+sb_cars_r) %>% # get west bound exit volume
  mutate(eb_exit_traffic = eb_cars_t+nb_cars_r+sb_cars_l) %>% # get east bound exit volume
  select(one_of(c("count_date","location_id","location","lng","lat", "counthour",
                  "total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                  "eb_exit_traffic"))) %>% # remove raw attributes, retain aggregate only
  group_by(across(all_of(c("count_date","location_id","location","lng","lat", "counthour")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) %>% # agregate hourly volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  slice_max(order_by = total_int_traffic, n = peakhours) %>% # filter top peak hour volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) # aggregate daily peak hour volume

clean_T5 <- traffic5 %>%
  select(one_of(c("count_date","location_id","location","lng","lat", "centreline_type",
                  "time_start","sb_cars_r","sb_cars_t","sb_cars_l",
                  "nb_cars_r","nb_cars_t","nb_cars_l","wb_cars_r","wb_cars_t","wb_cars_l",
                  "eb_cars_r","eb_cars_t","eb_cars_l"))) %>% #select needed attributes
  filter(centreline_type ==2) %>% #only need intersection data
  mutate(counthour = str_extract(time_start,"(?<=T)(\\d+)(?=\\:)")) %>% # extract hour
  mutate(total_int_traffic = sb_cars_r+sb_cars_t+sb_cars_l+
           nb_cars_r+nb_cars_t+nb_cars_l+wb_cars_r + wb_cars_t+
           wb_cars_l+eb_cars_r+eb_cars_t+eb_cars_l) %>% # get total sum
  mutate(nb_exit_traffic = nb_cars_t+eb_cars_l+wb_cars_r) %>% # get north bound exit volume
  mutate(sb_exit_traffic = sb_cars_t+eb_cars_r+wb_cars_l) %>% # get south bound exit volume
  mutate(wb_exit_traffic = wb_cars_t+nb_cars_l+sb_cars_r) %>% # get west bound exit volume
  mutate(eb_exit_traffic = eb_cars_t+nb_cars_r+sb_cars_l) %>% # get east bound exit volume
  select(one_of(c("count_date","location_id","location","lng","lat", "counthour",
                  "total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                  "eb_exit_traffic"))) %>% # remove raw attributes, retain aggregate only
  group_by(across(all_of(c("count_date","location_id","location","lng","lat", "counthour")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) %>% # agregate hourly volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  slice_max(order_by = total_int_traffic, n = peakhours) %>% # filter top peak hour volume
  group_by(across(all_of(c("count_date","location_id","location","lng","lat")))) %>%
  summarise(across(any_of(c("total_int_traffic", "nb_exit_traffic","sb_exit_traffic","wb_exit_traffic",
                            "eb_exit_traffic")), sum)) # aggregate daily peak hour volume

CleanTraffic <-bind_rows(clean_T1,clean_T2,clean_T3,clean_T4,clean_T5)


# change data type 
tranform_t1$counthour <- as.integer(tranform_t1$counthour)
tranform_t1$count_date <- as.Date(tranform_t1$count_date)

# repeat for all 5 datasets
# combine transformed data, simpe append. # further processing depends on boundary and proximity
# def. for a simplistic view, can use traffic volume per intersection average, which still requires 
# boundary def. 

inter <-intersect(locID4,locID5)
trafficsince2010_common <-filter(traffic5,traffic5$location_id %in% inter)

totalTraffic <- inner_join(traffic1, traffic5, join_by("location_id")) 
traffic12 <- inner_join(traffic1, traffic2, join_by("location_id")) 
traffic34<- inner_join(traffic3, traffic4, join_by("location_id")) 
traffic1234<- inner_join(traffic12, traffic34, join_by("location_id")) 
totaltrafic<- inner_join(traffic1234, traffic5, join_by("location_id")) 

length(unique(totaltrafic$location_id))
