# Team-30
 Team 30's group project GitHub repository for MGT 6203 (Canvas) Spring of 2024 semester.

 Data Source: 
 all Data is sourced from open data Toronto portal https://open.toronto.ca/dataset which is contained in a R Library:  library(opendatatoronto)
 To download the Traffic Data
 https://open.toronto.ca/dataset/traffic-volumes-at-intersections-for-all-modes/ 
 and for business information is at https://open.toronto.ca/dataset/municipal-licensing-and-standards-business-licences-and-permits/
 
 Before Running the Code: 
 i) The file sizes exceeds the built in library capacity where it's limited to 32000 rows. Thus, please ensure the csv data is downloaded in the data folder ../Data/Toronto/ 
 
 ii) the geocode conversion of business (section c of business section of the code) might take longer time due to the number of business to be converted. You can skip to run this section and use the pre-loaded output from business section at ../Data/Toronto/business/biz_geo_loc1.csv.  This biz_geo_loc1 shall be loaded as dataframe 'biz_geo_loc1' which is used as input of the other section of the code. 

 Running Code:
 EV Charging.ipynb contains the code and analysis of this project. 
 You will need to run it on Jupyter notebook compatible environment. 

####################Readme on Business section CODE###########################
Business Section INPUT: ‘biz_data’ dataframe  which read from("../Data/Toronto/business/business licences data.csv") and was downloaded from https://open.toronto.ca/dataset/municipal-licensing-and-standards-business-licences-and-permits/. The explanation of data is provided at same location as business-licence-readme.xls
Business Section OUTPUT: ‘biz_geo_loc1’ dataframe which is pre-uploaded ("../Data/Toronto/business/biz_geo_loc1.csv") due to time consuming on tidygeocoder function.   The data consists of 12 variables i.e.
# Category : business type as defined from Opendatatoronto
# Operating.Name: business name as registered in Opendatatoronto
# city: City where the business is located (extracted from business address)
# Zip: postal code where business is located (extracted from business address)
# Street street name where business is located (extracted from business address)
# Address :physical address
# lat, long : Lattitude , Longitude converting from address into geocoder
# lamda : customer arrival rate used to simulate the number of customer during busy hours(assumption)
# mu : expected time spent (in hr) during busy hours of a customer (exponential distribution) 
# qCustomer: number of customer at busy hours (simulated from lamda)
# tCustomer: time spent at the business per customer (simulated) **
Business Section CODE: Codes are separated into 4 sections:
#section a) load data from Opendatatoronto to biz_data dataframe
#section b) data cleansing in preparation for geocoder conversion
#section c) physical address conversion to geocoder using tidygeocoder from tidyverse package 
#section d) adding simulated number of customer (qCustomer) and time spent (tCustomer) during busy hours to biz_geo_loc1.  ‘Category’ is used as an input for simulating the customer number and time spent using random number generation based on its customer arrival rate λ (Lamda) and average service time in hour µ (mu) assumption on each business type which is defined in as in “biz_category_customer.csv”.   We assume Poisson process with the arrival rate 
#############################################################################
 
