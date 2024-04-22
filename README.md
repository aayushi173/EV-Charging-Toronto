# Team-30
## Project Title:  

Team 30 – Toronto EV Charging Network Expansion: A Sustainable Urban Mobility Initiative 

## Project Description: 

The project’s objective is to determine the order of car park conversion to EV charging stations considering factors such as projected EV traffic volume, accessibility to local business, the potential community benefits and to maximize the effectiveness of the budget.   

## Downloading and Running Project: 

Download Project from GitHub as ZIP (Reference below for downloading project). Extract Zip folder and save on computer. 

## Data Sources:  

Data was sourced from open data Toronto portal https://open.toronto.ca/dataset which is contained in a R Library: library(opendatatoronto). Link to download the Traffic Data: https://open.toronto.ca/dataset/traffic-volumes-at-intersections-for-all-modes/ 
Link for business information: https://open.toronto.ca/dataset/municipal-licensing-and-standards-business-licences-and-permits/.  

Data downloaded from source for purpose of analysis. Utilizing the library(opendatatoronto). Library presented limitation for number of records (limited to the max of 32000 records). 


## Code File:  

The code can be run through a Jupiter notebook compatible environment (.../Code/EV Charging.ipynb ) 

## Previewing Code and Usage: 

Previewing code through Jupiter notebook provides a glimpse into the process and output followed to develop our solution to our problem statement (Determining the order of car park conversion to EV charging stations). 

Opening .../Code/EV Charging.ipynb will provide access to the code in a Jupiter notebook interface with code and output. The code is broken down by data gathering, preprocessing, and model development.  

 


## Code overview: 

Reference Jupiter Notebook code version for comment on code. Below is the additional background for segments of the code.  

### Traffic:
The traffic dataset sorced from https://open.toronto.ca/dataset/traffic-volumes-at-intersections-for-all-modes/ provides traffic volume across the city of Toronto collected by City of Toronto's Transportation Services Division.

The data presents the total volumes observed at specific intersections, segmented by direction of approach, turning movement (if applicable), and mode (car, truck, bus, pedestrian, cyclist, other) at the time of observation. 

The data used for this project is from the ‘raw_data_<yyyy-yyyy>’ datafiles which contain the traffic counted result during the period of the year <yyyy-yyyy>. Only ‘car’ mode and Centreline_type 2 (intersection) are used. 

 Data processing is done to group the result by block of year ith instead of directly using the observed year ‘yyyy’ data and only selected peak hour of the car counted on any given counted date. In the case that there are records on the same location on multiple days in the same year, the average number of cars over daily peak hour is used for the given year.

 OUTPUT:
 A dataframe named CleanTraffic ("../Data/DataProcessing/CleanTraffic.csv") consisting of following columns: year, location_id, loaction, lat, lng, AvgTotal

 
### Business Section:

Business Section INPUT: ‘biz_data’ dataframe which is read from https://open.toronto.ca/dataset/municipal-licensing-and-standards-business-licences-and-permits/. The explanation of data is provided at same location as business-licence-readme.xls  

OUTPUT: ‘biz_geo_loc1’ dataframe which is pre-uploaded ("../Data/DataProcessing/biz_geo_loc1.csv") due to time consuming on tidygeocoder function in section c).   

The output data consists of 12 variables i.e. 

Category : business type as defined from Opendatatoronto 

Operating.Name: business name as registered in Opendatatoronto 

city: City where the business is located (extracted from business address) 

Zip: postal code where business is located (extracted from business address) 

Street street name where business is located (extracted from business address) 

Address :physical address 

lat, long : Lattitude , Longitude converting from address into geocoder 

lamda : customer arrival rate used to simulate the number of customer during busy hours(assumption) 

mu : expected time spent (in hr) during busy hours of a customer (exponential distribution) 

qCustomer: number of customer at busy hours simulated from rpois(lamda) 

tCustomer: time spent at the business per customer simulated from rexp(mu) 

CODE:  

Code is separated into 4 sections:  

a) Load data from Opendatatoronto to biz_data dataframe  

b) Data cleansing in preparation for geocoder conversion  

c) Physical address conversion to geocoder using tidygeocoder from tidyverse package #section 

d) Adding simulated number of customer (qCustomer) and time spent (tCustomer) during busy hours to biz_geo_loc1. ‘Category’ is used as an input for simulating the customer number and time spent using random number generation based on its customer arrival rate λ (Lamda) and average service time in hour µ (mu) assumption on each business type which is defined in as in “biz_category_customer.csv”. We assume Poisson process with the arrival rate (lamda) customer per hour whereas the time spent for each customer follows exponential distribution with average time spent (mu) hour per customer.  

### Green P Parking and Model:

Performed data cleaning tasks such as standardizing formats, handling missing values, and removing duplicates on GreenPParking dataset sourced from https://open.toronto.ca/dataset/green-p-parking/ and cleaned file is stored at "../Data/DataProcessing/parking_data.csv". 

 Converted character columns to numeric class. 

 Extracted street name from the address.

 Added a column named Convert set to 1 for already existing EV Charging Stations and 0 for the others. 

 Used KNN to find 8 nearest businesses, average distance, average number of customers, and average time spent at business locations. 

 Added EV traffic volume data for the year 2022. 

 Grouped by address to get mean of all the variables. Normalized predictors 

 Made an SVM model with 'convert' as the dependent variable and 'distance' and 'traffic_volume' as independent variables. 

 Used coefficients from the SVM model to calculate the weighted score. 

 OUTPUT: Top 5 parking locations to convert to EV Charging stations (stored in a csv file at "../Data/DataProcessing/sorted_result.csv").

 
