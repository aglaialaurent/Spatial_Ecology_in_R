#This is an example of code for the exam

##How to import external data in R
In order to import data in R we should set the working directory

```r
library(terra)
setwd("~/Bureau/")
```


To check for the folder you can make use of:
```r
getwd()
```

The import of the data is done by:
```r
rast("image.JPG")
```

If you receive errors 
