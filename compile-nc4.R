rm(list=ls())
homedir<-'/Users/jimenaromero/Dropbox/GitHub/nasa-satellite'
# installing packages
packages_vector <- c('ggplot2','tidyverse', 'dplyr')
geopackages<-c('raster','ncdf4', 'sf')
lapply(packages_vector, require, character.only = TRUE) # the "lapply" function means "apply this function to the elements of this list or more restricted data 
lapply(geopackages, require, character.only = TRUE) 


# I will create a panel data of districts, month by month. First, I will get the structure of the data from the shapefile. 

setwd(homedir)
shapefile<-st_read('./peru_shp/PER_adm2.shp')

output<- shapefile[c("NAME_1","NAME_2")] # dataframe with region and district in rows. 

# getting list of files to be opened

setwd('./nc4_data')
list_files<-list.files(pattern=".nc4")

# each column will be named after the date (month-year) of the array
extract <- raster::extract

for (i in 1:length(list_files)){
  temp_file<-list_files[i]
  temp_file <- nc_open(temp_file)
  lon<-ncvar_get(temp_file, "nlon")
  lat<-ncvar_get(temp_file, "nlat")
  tmp.array<-ncvar_get(temp_file,"precipitation")
  fillvalue<-ncatt_get(temp_file, "precipitation", "_FillValue")
  tmp.array[tmp.array == fillvalue$value] <- NA
  name_temp<-str_sub(temp_file$filename,6,11)
  file_raster <- raster(t(tmp.array), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
  file_raster <- flip(file_raster, direction='y')
  x<-extract(file_raster, shapefile, fun = mean,na.rm=T, df=F, small=T, sp=T,  weights=TRUE, normalizedweights=TRUE)
  to_merge<-x@data[c('NAME_1','NAME_2','layer')]
  names(to_merge)[names(to_merge) == "layer"] <- name_temp
  output<-merge(output, to_merge, by=c('NAME_1','NAME_2'))
  print(i)
}


setwd('../compiled_data')
save (output, file='peru_rainfall.RData')

# Plotting examples

temp_file<-list_files[1]
temp_file <- nc_open(temp_file)
lon<-ncvar_get(temp_file, "nlon")
lat<-ncvar_get(temp_file, "nlat")
tmp.array<-ncvar_get(temp_file,"precipitation")
fillvalue<-ncatt_get(temp_file, "precipitation", "_FillValue")
tmp.array[tmp.array == fillvalue$value] <- NA
name_temp<-str_sub(temp_file$filename,6,11)
file_raster <- raster(t(tmp.array), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
file_raster <- flip(file_raster, direction='y')
x<-extract(file_raster, shapefile, fun = mean,na.rm=T, df=F, small=T, sp=T,  weights=TRUE, normalizedweights=TRUE)


#crop raster
rb <- crop(file_raster, shapefile)

#plot raster
plot(rb)

library(tmap)
tm_shape(x)+tm_fill('layer', palette = "Blues", title = "Rainfall")


