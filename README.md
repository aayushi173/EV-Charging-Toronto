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



 
