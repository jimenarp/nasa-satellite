
# Using satellite maps of NASA for economic analysis

## Getting Started

A NASA Earthdata account, and R, with the package raster installed. The download of images will be done in the shell, through the NASA GES DISC. 

### Earthdata Account 

At https://urs.earthdata.nasa.gov/. In order to download images in bulk, in Applications, authorize the App "GES DISC". 

### Download links list

Search the satellite images through https://disc.gsfc.nasa.gov/. For example, monthly rainfall (via the TRMM). Click on Subset/Get Data, refine options (date, geography). Download links list as txt document (in the example, it is 'TRMM_links.txt'). The prefered format I will be using is HDF (Hierarchical Data Format) raster files. 

### Downloading via wget

In order to download the links, I will be using wget on MAC OS (complete instructions for MAC or Windows here: https://disc.gsfc.nasa.gov/data-access#mac_linux_wget). It requires the following steps

Installing wget: wget can be installed using Homebrew in ther terminal (other ways can be found here https://www.fossmint.com/install-and-use-wget-on-mac/). Homebrew is easy to install (https://brew.sh/)

```
brew install wget

```
 
Creating a .netrc file: 

```
touch .netrc
echo "machine urs.earthdata.nasa.gov login <uid> password <password>" >> .netrc 
chmod 0600 .netrc 
```
where <uid> is your user name and <password> is your Earthdata Login password without the brackets. 

Create a cookie file.

```
touch .urs_cookies.
```

Finally on the terminal, call on the text file with the following line (replace <url.txt> with the name of the file saved with the links to be donwoladed, in this case 'TRMM_links.txt'. You should be working on the folder that contains this file):

```
wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition -i <url.txt>

```

This will download all the files in the folder you are working. 
 
 
## Reading HDF files

HDF files support different levels of information, or layers. In the README Document for the files downloaded (is included in the list of downloads), there is a description of the algorithm used to estimate rainfall, sources (such as satellites and sensors), and layers of information provided (which usually includes the inputs used).

I will be focusing on the product 3B43, monthly rainfall estimate product, gridded with a resolution of 0.25° by 0.25°. 


### Opening HDF in R




