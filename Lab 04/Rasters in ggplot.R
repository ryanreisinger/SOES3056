
# EXTENSION: PLOTTING RASTERS WITH GGPLOT

library(ggplot2)
library(marmap)

# load in some bathymetry data
lonmin <- -180
lonmax<- 180
latmin <- -90
latmax <- 90
papoue <- getNOAA.bathy(lon1=lonmin,lon2=lonmax,lat1=latmin,lat2=latmax,
                        resolution=30)
papoue_raster <- marmap::as.raster(papoue)

# first we need to prepare coordinates for each cell in the raster.
raster_lon <- seq(lonmin,lonmax,length=dim(papoue)[1]) # longitude values
raster_lat <- rev(seq(latmin,latmax,length=dim(papoue)[2])) # latitude values
# The rev() function in the line above flips the map North-South.

# We use the expand.grid() function to make a table with all combiantions of 
# latitude and longitude
coords <- expand.grid(raster_lat,raster_lon)
# convert this into a data frame called my_df
my_df <- data.frame(coords$Var1,coords$Var2)
dim(my_df)

# Now we add the bathymetry raster to the data frame containing the coordinates. 
# We need to convert the raster object into a vector first though
dim(papoue_raster)
bathy_vector <- c(as.matrix(papoue_raster))
length(bathy_vector)
my_df$bathy <- bathy_vector

# rename the variables
names(my_df) <- c("lat","lon","bathy")

# Now we are ready to plot a map using ggplot
# tell ggplot which data frame to use
# tell ggplot which variables to use for x,y,colour,size,...
ggplot()+ 
  geom_raster(data=my_df,aes(x=lon,y=lat,fill=bathy)) 

# Now we can make this look better by only setting the land values to NA.
my_df$bathy[my_df$bathy >= 0] <- NA 

# and plot again
ggplot(my_df)+
  geom_raster(aes(lon,lat,fill=bathy))

# we can change the way our plot looks very easily in ggplot by 
# adding extra 'elements' to the 'gg object'
ggplot(my_df)+
  geom_raster(aes(lon,lat,fill=bathy))+
  coord_fixed()+ # makes x and y axes equal scale
  labs(x="Longitude",y="Latitude",fill="Bathymetry (m)",title = "Global Ocean")


# Suppose we also have some study sites and we want to add them to the map
study_lon <- c(-100,0,60,-135,-20) # longitude
study_lat <- c(-50,-20,-40,45,42) # latitude
study_pop <- c(20,23,28,32,21) # some data (e.g. population)
study_df <- data.frame(study_lon,study_lat,study_pop) # combine in data frame

# adding study location only
ggplot()+
  geom_raster(data=my_df,aes(lon,lat,fill=bathy))+
  geom_point(data=study_df,aes(x=study_lon,y=study_lat),
             shape=4,colour="yellow",size=3)+
  coord_fixed()+ 
  labs(x="Longitude",y="Latitude",fill="Bathymetry (m)",title = "Global Ocean")
# note how we need to specify the different data frames for each data layer

# adding study data as well
ggplot()+
  geom_raster(data=my_df,aes(lon,lat,fill=bathy))+
  geom_point(data=study_df,aes(x=study_lon,y=study_lat,size=study_pop),
             shape=16,colour="yellow")+
  coord_fixed()+ 
  labs(x="Longitude",y="Latitude",fill="Bathymetry (m)",title = "Global Ocean")




