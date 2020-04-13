rm(list=ls())

# installing packages
packages_vector <- c('ggplot2','tidyverse', 'dplyr')
geopackages<-c('raster','ncdf4', 'maptools','rgdal','sf')
lapply(packages_vector, require, character.only = TRUE) # the "lapply" function means "apply this function to the elements of this list or more restricted data 
lapply(geopackages, require, character.only = TRUE) 

setwd('./nc4_data')

# getting list of files to be opened

list_files<-list.files(pattern=".nc4")

# I will create a panel data of districts, month by month. 
# I will get the structure of the data from the shapefile. 

#shapefile2<-readShapePoly('../peru_shp/PER_adm2.shp')
shapefile<-st_read('../peru_shp/PER_adm2.shp')



file=list_files[1]
file_o <- nc_open(file)

rain.array<-ncvar_get(file_o,"precipitation")

fillvalue<-ncatt_get(file_o, "precipitation", "_FillValue")

rain.array[rain.array==fillvalue]<-NA


rain.array[rain.array == fillvalue$value] <- NA

lon<-ncvar_get(file_o, "nlon")


longitude
