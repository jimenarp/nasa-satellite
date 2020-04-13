
# Getting satellite maps of NASA for economic analysis

## Getting Started

A NASA Earthdata account, and R, with the package raster installed. The download of images will be done in the shell, through the NASA GES DISC. 

### Earthdata Account 

At https://urs.earthdata.nasa.gov/. In order to download the files in bulk, in Applications, authorize the App "GES DISC". 

### Download list of files' links

Search the satellite images through https://disc.gsfc.nasa.gov/. For example, monthly rainfall (via the TRMM). Click on Subset/Get Data, refine options (date, geography). Download links list as txt document (in the example, it is 'TRMM_links.txt'). The prefered format I will be using is NetCDF (Network Common Data Form) data format. 

### Downloading the files via wget

In order to download the files from the list of links, I will be using "wget"" on MAC OS (complete instructions for MAC or Windows here: https://disc.gsfc.nasa.gov/data-access#mac_linux_wget). It requires the following steps:

- Install wget: wget can be installed using Homebrew in ther terminal (other ways can be found here https://www.fossmint.com/install-and-use-wget-on-mac/). Homebrew is easy to install (https://brew.sh/)

```
brew install wget
```
 
- Create a .netrc file in the terminal: 

```
touch .netrc
echo "machine urs.earthdata.nasa.gov login <uid> password <password>" >> .netrc 
chmod 0600 .netrc 
```

where <uid> is your user name and <password> is your Earthdata Login password without the brackets. 

- Create a cookie file:

```
touch .urs_cookies.
```

Finally on the terminal, call on the text file with the following line (replace <url.txt> with the name of the file saved with the links to be donwoladed, in this case 'TRMM_links.txt'. You should be working on the folder that contains this file):

```
wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition -i <url.txt>
```

This will download all the files in the folder you are working. 
 
 
## Reading NetCDF files

NetCDF files (*.nc4) can support different levels of information, or layers. In the list of files downloaded, there is a README Document with a complete description of the algorithm used to estimate the output rainfall, sources (such as satellites and sensors), and information provided (which could include the inputs used).

I will be focusing on the product "3B43"", monthly rainfall estimate product, gridded with a resolution of 0.25° by 0.25°. 

I am going to compile the gridded data to the district level of Peru. This means that the gridded information will be aggregated to each district (weighted mean by the land area). For this, I need to follow the steps: 

- Open .nc4 file
- Extract raster information and aggregate to the district levels. For this, I need to download the shapefiles of the districts of Peru (found here:https://earthworks.stanford.edu/catalog/stanford-gv908jn2631), which contains geographic information on the coordinates and shapes of the polygons of the administrative limits of regions and districts. They are saved in the folder 'peru_shp'.

In the code, I am doing these steps in a loop, in order to generate a panel of districts, month by month. 

### Opening NetCDF in R and turning into raster

Requires package "ncdf4" (to open file), "raster" (to turn into raster and extract information) and "sf" (to read shapefiles). The complete sample code is in "compile-nc4.R"

```
install.packages("ncdf4", "raster", "sf")
```

To open a .nc4 file: 

```
file<- nc_open(file.nc4)

```
Select the array with the layer of information chosen: 

```
rain.array<-ncvar_get(file,"precipitation")

```

Find the fill value for missing values, and convert it to NA:

```
fillvalue<-ncatt_get(file, "precipitation", "_FillValue")
rain.array[rain.array==fillvalue$value]<-NA
```

To extract information to the shapefile, I have to indicate that the extract function should come from the package 'raster':

```
extract <- raster::extract
```

Specify the latitude, longitude, and coordiantes system. In this data, latitude is saved as "nlat" and longitude as "nlon". 

```
lon<-ncvar_get(file, "nlon")
lat<-ncvar_get(file, "nlat")

```
Turn the array into raster. In this case I will be using as standard projection of the coordinate reference system (CRS) WGS84. 

```
raster_file <- raster(t(rain.array), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
```
And then extract the raster file information to shapefile using the code: 

```
extract(raster_file, shapefile, fun = mean,na.rm=T, df=F, small=T, sp=T,  weights=TRUE, normalizedweights=TRUE)
```
which weights the average by area. 


## Sources and more information: 

https://disc.gsfc.nasa.gov/data-access#mac_linux_wget: steps to downloading the GESDISC files using wget or wcurl

http://geog.uoregon.edu/bartlein/courses/geog607/Rmd/netCDF_01.htm: About netCDF in R

http://chris35wills.github.io/netcdf-R/: About netCDF in R

https://rspatial.org/raster/spatial/6-crs.html: More about Coordinates Reference System

https://eburchfield.github.io/files/7_spatial_data_int_lab.html: Integrating spatial data in R. More about gridded data and polygons



