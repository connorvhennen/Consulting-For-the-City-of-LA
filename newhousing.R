# Vincent Yang
# STATS 141SL
# newhousing.R
# Purpose: To clean data for new housing

# Cut off into new bldgs first, residential
#####------------------------------------------------------------------------------------------------ Variables of Interest
# Assessor.Book, Assessor.Page, Assessor.Parcel # -> Transform these to one AssessorID variable (for merging censusID data)
# PCIS.Permit.. # This is unique ID
# Status
# Status.Date
# Permit.Type
# Permit.Sub.Type
# Project.Number
# Event.Code
# Issue.Date

##### Transform this to one address variable
# Address.Start
# Address.Fraction.Start
# Address.End
# Address.Fraction.End
# Street.Direction
# Street.Name
# Street.Suffix
# Suffix.Direction
# Unit.Range.Start
# Unit.Range.End

# Zip.Code
# Work.Description
# X..of.Residential.Dwelling.Units
# Applicant.Business.Name
# Council.District
# Latitude.Longitude # Transform this as Latitude/Longitude Numeric

raw_data <- read.csv('Building_and_Safety_Permit_Information.csv')

# Extract New Building Permits, for 1 or 2 family dwellings, or Apartments
data <- raw_data[as.character(raw_data$Permit.Type)=='Bldg-New',]
data <- data[as.character(data$Permit.Sub.Type)!='Commercial',]
# Extract variables of Interest (above)
data <- data[,c(1:3,8:12,14,15,17:29,32,46,54,55)]

View(data)
summary(data$Project.Number)
summary(data$Event.Code) 
data <- data[,-10] # Event.Code will not be useful

# Double check the order of this
data$AssessorID = paste(data[,1],data[,2],data[,3],sep="-")
data <- data[,c(27,4:26)] 

# Create one address variable
attach(data)
summary(Address.Start)
summary(Address.End)
data$Address <- paste(Address.Start,Address.Fraction.Start,'-',Address.End,Address.Fraction.End,Street.Name,Street.Suffix,Suffix.Direction)
# Come back to add Unit ranges to addresses
summary(Unit.Range.Start)
data <- data[,-(9:18)]

# Create latitude and longitude columns (numeric) for lat and lon values that are given
latlong_ID <- as.character(data$Latitude.Longitude)!=''
latlong = as.character(data$Latitude.Longitude[latlong_ID])
matches = regmatches(latlong,gregexpr('-?\\d+\\.?\\d+',latlong)) # list of alternating lat/longitude pairs
data$latitude[latlong_ID] <- as.numeric(unlist(matches)[seq(1,length(matches)*2,2)]) # Note which starts first: lat or long
data$longitude[latlong_ID] <- as.numeric(unlist(matches)[seq(2,length(matches)*2,2)])
summary(data$latitude)
summary(data$longitude)                           #still 2702 missing values, merge with Assessor Parcels Data


#============================ Merge with Assessor Parcels Data for Latitude/Longitudes: ======================================================
# Use Assessors Data from data.lacity.gov to retrieve missing latitude and longitude values
assessor_db <- read.csv('Assessor_Parcels_Data_-_2017.csv',header=TRUE) # Huge file
#assessor_db <- assessor_db[,c(6,49,50)]
#colnames(assessor_db)[2:3] = c("latitude","longitude")
#write.csv(assessor_db,'Assessor_Parcels_Data_-_2017_small.csv') # Formatted already, comment these out
data <- merge(data,assessor_db,by="AssessorID",all.x=TRUE)

# Set NA's to the ones given by assessor_db
data$latitude.x[which(is.na(data$latitude.x))] = data$latitude.y[which(is.na(data$latitude.x))]
data$longitude.x[which(is.na(data$longitude.x))] = data$longitude.y[which(is.na(data$longitude.x))]
data$latitude.y <- NULL
data$longitude.y <- NULL
colnames(data)[16:17] = c("latitude","longitude")
summary(data$latitude) # 33.71 to 34.33
summary(data$longitude) # -118.7 to -118.2        #still 932 missing values, use census geocoding


#============================ Using Census geocoding to retrieve Latitude/Longitudes: ========================================================
# Find rows with missing lat and lon
missing_latlong_ID <- which(is.na(data$latitude)) # row indices of missing lat/longs, there are 932
# Use https://geocoding.geo.census.gov/
write.csv(cbind(data$Address[missing_latlong_ID],data$Zip.Code[missing_latlong_ID]),"geocode_new.csv")
geocode_results <- read.csv("GeocodeResults_new.csv",blank.lines.skip=FALSE,header=FALSE)
latlong_ID = as.character(geocode_results$V6)!=''
latlong = as.character(geocode_results$V6[latlong_ID])
matches = regmatches(latlong,gregexpr('-?\\d+\\.?\\d+',latlong)) # list of alternating lat/longitude pairs
data$latitude[missing_latlong_ID[latlong_ID]] <- as.numeric(unlist(matches)[seq(2,length(matches)*2,2)]) # Note which starts first: lat or long
data$longitude[missing_latlong_ID[latlong_ID]] <- as.numeric(unlist(matches)[seq(1,length(matches)*2,2)])
summary(data$latitude) # 33.71 to 34.33
summary(data$longitude) # -118.7 to -118.2          #still 615 missing values, use google maps api


#=========================== Using Google Maps API to retrieve Latitude/Longitudes: ==========================================================
# Use geocode on missing addresses to find latitude/longitudes
# Google map searches the address and retrieves the latitude/longitudes
# https://stackoverflow.com/questions/32504880/street-address-to-geolocation-lat-long
geocodeAdddress <- function(address) {
  require(RJSONIO)
  url <- "http://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url, address, "&sensor=false", sep = ""))
  x <- fromJSON(url, simplify = FALSE)
  if (x$status == "OK") {
    out <- c(x$results[[1]]$geometry$location$lng,
             x$results[[1]]$geometry$location$lat)
  } else {
    out <- NA
  }
  Sys.sleep(0.2)  # API only allows 5 requests per second
  out
}
# Find rows with missing lat and lon
missing_latlong_ID <- which(is.na(data$latitude)) # row indices of missing lat/longs, there are 615
# This takes a while to run (maybe 10 minutes)
for(i in 1:length(missing_latlong_ID)){
  latlon = geocodeAdddress(paste(data$Address[missing_latlong_ID[2]], 'LOS ANGELES')) # Might need to format this so we can be more specific with address
  if(!is.na(latlon) && (latlon[2] > 33 && latlon[2] < 35) && (latlon[1] > -119 && latlon[1] < -118)){
    data$latitude[missing_latlong_ID[i]] <- latlon[2]
    data$longitude[missing_latlong_ID[i]] <- latlon[1]
    print(i) #just to track progress
  }
  else {
    print(paste(i, 'FAILED'))
  }
}

summary(data$latitude) # 33.71 to 34.33
summary(data$longitude) # -118.7 to -118.2          # missing 120 values only now

newhousing <- data # store a copy, gonna use data for rehab now
write.csv(data,"newhousing.csv") 


# Still has missing values, rerun geocode sometime without Los Angeles and see if it helps... for now, no time.

