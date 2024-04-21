# Team-30
## Project Title:  

Team 30 – Toronto EV Charging Network Expansion: A Sustainable Urban Mobility Initiative 

## Project Description: 

The project’s objective is to determine the order of car park conversion to EV charging stations considering factors such as projected EV traffic volume, accessibility to local business, the potential community benefits and to maximize the effectiveness of the budget.   

Downloading and Running Project: 

Download Project from GitHub as ZIP (Reference below for downloading project). Extract Zip folder and save on computer. 

## Data Sources:  

Data was sourced from open data Toronto portal https://open.toronto.ca/dataset which is contained in a R Library: library(opendatatoronto) To download the Traffic Data https://open.toronto.ca/dataset/traffic-volumes-at-intersections-for-all-modes/ and for business information is at https://open.toronto.ca/dataset/municipal-licensing-and-standards-business-licences-and-permits/.  

Data used for the project can be found in the Data folder. (.../Data/Toronto/) 



## Code File:  

The code can be run through a Jupiter notebook Compatible environment (.../Code/EV Charging.ipynb ) or through RStudio (.../Code/EV Charging.r). We recommend running the project through RStudio.  

Running through RStudio: 

Step 1. Open RStudio 

Step 2. File -> New Project -> Existing directory -> Browse  

Step 3. Select project folder downloaded earlier from GitHub as working directory 

Step 4. Create Project 

Step 5: File -> Open File... -> Team-30-main -> Code -> EV Charging.r 

Previewing Code and Usage: 

Previewing code through Jupiter notebook provides a glimpse into the process and output followed to develop our solution to our problem statement (Determining the order of car park conversion to EV charging stations). 

Opening .../Code/EV Charging.ipynb will provide access to the code in a Jupiter notebook interface with code and output. The code is broken down by data gathering, preprocessing, and model development.  

The Output from Model –SVM (with KNN):  

 

## More Information about the data: 

Reference Jupiter Notebook code version for comment on code. Below provides additional background for segments of the code.  

Green P Parking: 

Performed data cleaning tasks such as standardizing formats, handling missing values, and removing duplicates. 

Converted character columns to numeric class. 

Extract street name from the address. 

Added a column named Convert set to 1 for already existing EV Charging Stations and 0 for the others. 

Used KNN to find 8 nearest businesses, average distance, average number of customers, and average time spent at business locations. 

Added EV traffic volume data for the year 2022. 

Grouped by address to get mean of all the variables. Normalized predictors 

Made an SVM model with 'convert' as the dependent variable and 'distance' and 'traffic_volume' as independent variables. 

Used coefficients from the SVM model to calculate the weighted score. 

Output: Top 12 parking locations to convert to EV Charging stations. 

 

####################Readme on Business Section #################### 

Business Section INPUT: ‘biz_data’ dataframe which read from ("../Data/Toronto/business/business licences data.csv") and was downloaded from https://open.toronto.ca/dataset/municipal-licensing-and-standards-business-licences-and-permits/. The explanation of data is provided at same location as business-licence-readme.xls  

Business Section OUTPUT: ‘biz_geo_loc1’ dataframe which is pre-uploaded ("../Data/Toronto/business/biz_geo_loc1.csv") due to time consuming on tidygeocoder function in section c).   The output data consists of 12 variables i.e. 

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

Business Section CODE:  

Codes are separated into 4 sections:  

#section a) load data from Opendatatoronto to biz_data dataframe  

#section b) data cleansing in preparation for geocoder conversion  

#section c) physical address conversion to geocoder using tidygeocoder from tidyverse package #section d) adding simulated number of customer (qCustomer) and time spent (tCustomer) during busy hours to biz_geo_loc1. ‘Category’ is used as an input for simulating the customer number and time spent using random number generation based on its customer arrival rate λ (Lamda) and average service time in hour µ (mu) assumption on each business type which is defined in as in “biz_category_customer.csv”. We assume Poisson process with the arrival rate (lamda) customer per hour whereas the time spent for each customer follows exponential distribution with average time spent (mu) hour per customer.  

 
 
