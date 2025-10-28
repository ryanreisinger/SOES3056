# Script for working through the examples in Lovelace et al. Chapter 2
# https://r.geocompx.org/spatial-class 


# If necessary, install libraries
# install.packages("sf")
# install.packages("terra")
# install.packages("spData")
# install.packages("spDataLarge", repos = "https://geocompr.r-universe.dev")

# Attach libraries
library(sf)
library(terra)
library(spData)
library(spDataLarge)

#-------------------
# Vector
#-------------------

# Section 2.2.1 - Introduction to simple features
class(world)
names(world)

# Look at the 'geom' slot in 'world'
# it contains sf's 'spatial powers'!
# A regular data frame with spatial powers - the 'geom' or 'geometry' column
world$geom

# It has a special class - 'sfc'
class(world$geom)

# Let's plot the world object
plot(world) # Notice that there is a map for each variable in the dataset (e.g., 'iso_a2', 'name_long', etc.)


summary(world["lifeExp"]) # Notice the 'sticky' behaviour - R reports the geometry ('geom') too

# Subsetting this object
world_mini <- world[1:2, 1:3]
world_mini
names(world_mini) # three variables plus the geom (spatial powers!)
plot(world_mini) # first two rows, so only two countries - Fiji and Tanzania

# Section 2.2.2
# Reading in a shape file
# We'll use one of the files included with the 'spData' package

# We can read it in as a sf data frame with the 'st_read' function
world_dfr = st_read(system.file("shapes/world.gpkg", package = "spData"))
class(world_dfr) # See the class? 'sf' and 'data.frame'

# Or as a 'tibble' which is a special kind of dataframe used in the 'tidyverse'
world_tbl = read_sf(system.file("shapes/world.gpkg", package = "spData"))
class(world_tbl) # See the class? 'sf' and 'tbl_df' and 'tbl' ('tibbles')

# The 'sf' package is becoming the new standard for working with vector data, but
# we can still use the old 'sp' package functions if we need to
library(sp)
world_sp <- as(world, "Spatial") # coerce world_sp from an sf object to an sp object
class(world_sp)

world_sf <- st_as_sf(world_sp) # coerce from sp to sf
class(world_sf)

# Section 2.2.3 - basic maps
plot(world[3:6]) # Plot three variables
plot(world["area_km2"]) # Plot only one variable, selecting it by name

# We can add plots to one another by setting add = TRUE

# First, we select only the countries in Asia
world_asia = world[world$continent == "Asia", ]
asia = st_union(world_asia) # This st_union function performs a union - it joins all the countries together
plot(asia) # see, just the outline of Asia now, instead of countries
plot(world_asia) # before the union -- see the countries are still separate 

# We can now plot Asia over the world map
plot(world["pop"], reset = FALSE) # We use reset = FALSE to keep this layer's legend on
plot(asia, add = TRUE, col = "red") # Then we add Asia on top, and fill it in red (col = "red")

# For very advanced plotting, we probably want to use a package like tmap or ggplot, but
# let's see some more advanced plots in sf:

plot(world["continent"], reset = FALSE) # plot the 'continent' variable in world
cex <- sqrt(world$pop) / 10000 # we create a 'cex' variable that is the square root of population size of each country / 10000
world_cents = st_centroid(world, of_largest = TRUE) # use this function to make a new layer,
#of type 'centroids' instead of polygons. This function finds the center (centroid) of each polygon (country) and we scale
# the size of the symbol by population size (the 'cex' variable we created above).
plot(st_geometry(world_cents), add = TRUE, cex = cex)

# sf's plotting method also has some special options for geographic data,
# like expanding the plot area (the 'bounding box' or BB) to allow us to plot data in context
india <- world[world$name_long == "India", ] # select only 'India' from the world dataframe
plot(st_geometry(india), expandBB = c(0, 0.2, 0.1, 1), col = "gray", lwd = 3) # we create some space around India. you might have to reset your plotting window
plot(st_geometry(world_asia), add = TRUE) # Now we add Asia

# Add country names (this is not in the Geocompr book, but useful to know)
text(st_coordinates(st_centroid(world_asia)), labels = world_asia$name_long, cex = 0.7)

# Section 2.2.6 Simple feature geometries (sfg) - low importance

# We have different types of 'geometries' in sf:
# points, linestrings and polygons (and their 'multi' equivalents, like 'multipoint'
# all these geometries have the class 'sfg' (stands for sf geometry)

# You *could* create any of these from scratch using the appropriate functions (e.g., 'st_point'), but
# we rarely do that in practice

# we can create sfg objects from three types of R objects:
# A numeric vector: a single point
# A matrix: a set of points, where each row represents a point, a multipoint or linestring
# A list: a collection of objects such as matrices, multilinestrings or geometry collections

# 'sf_point' creates single points from numeric vectors
st_point(c(5, 2))                 # XY point - e.g., lat and lon

st_point(c(5, 2, 3))              # XYZ point - lat, lon and height or depth (i.e., 3D)

st_point(c(5, 2, 1), dim = "XYM") # XYM point - lot, lon and another variable, usually measurement accuracy - M

st_point(c(5, 2, 3, 1))           # XYZM point - 3d and with measurement accuracy

# We can make multipoints and linestrings from matrices
# the rbind function simplifies the creation of matrices

## MULTIPOINT
multipoint_matrix = rbind(c(5, 2), c(1, 3), c(3, 4), c(3, 2))
st_multipoint(multipoint_matrix)

## LINESTRING
linestring_matrix = rbind(c(1, 5), c(4, 4), c(4, 1), c(2, 2), c(3, 2))
st_linestring(linestring_matrix)

# And we can use lists to create multilinestrings, (multi-)polygons and geometry collections

## POLYGON
polygon_list = list(rbind(c(1, 5), c(2, 2), c(4, 1), c(4, 4), c(1, 5)))
st_polygon(polygon_list)

## POLYGON with a hole
polygon_border = rbind(c(1, 5), c(2, 2), c(4, 1), c(4, 4), c(1, 5))
polygon_hole = rbind(c(2, 4), c(3, 4), c(3, 3), c(2, 3), c(2, 4))
polygon_with_hole_list = list(polygon_border, polygon_hole)
st_polygon(polygon_with_hole_list)

## MULTILINESTRING
multilinestring_list = list(rbind(c(1, 5), c(4, 4), c(4, 1), c(2, 2), c(3, 2)), 
                            rbind(c(1, 2), c(2, 4)))
st_multilinestring((multilinestring_list))

## MULTIPOLYGON
multipolygon_list = list(list(rbind(c(1, 5), c(2, 2), c(4, 1), c(4, 4), c(1, 5))),
                         list(rbind(c(0, 2), c(1, 2), c(1, 3), c(0, 3), c(0, 2))))
st_multipolygon(multipolygon_list)

## GEOMETRYCOLLECTION
geometrycollection_list = list(st_multipoint(multipoint_matrix),
                               st_linestring(linestring_matrix))
st_geometrycollection(geometrycollection_list)

# Section 2.2.7 - Low importance

# Section 2.2.8 - Don't need to do

# Section 2.2.9 - Don't need to do

#-------------------
# Raster
#-------------------

# Section 2.3.2 - Intro to 'terra'

# We load a raster - a Digital Elevation Model (DEM) - of Zion National Park,
# The data is included with the 'spDataLarge' package
raster_filepath <- system.file("raster/srtm.tif", package = "spDataLarge")
my_rast <- rast(raster_filepath)
class(my_rast) # it is a 'SpatRaster' class object

# We can look at atributes of the raster just by typing the name and running the line
my_rast

# Look at the functions which give more details:
dim(my_rast)
ncell(my_rast)
res(my_rast) # resolution
ext(my_rast) # spatial extent
crs(my_rast) # its coordinate reference system (CRS) -- see section 7.8 in the book for more details

# Section 2.3.3 - a basic map
plot(my_rast)
# If you get an error here, expand or reset your plotting window with the broom icon, or do:
dev.off() # to reset the plotting 'device' (window)
plot(my_rast)

# There are several more powerful plotting packages which you can use to make more advanced maps
# plotRGB() from the terra package
# the tmap package
# levelplot() from the rasteVis package (https://oscarperpinan.github.io/rastervis/)

# Section 2.3.4 - there are different classes of raster
# the raster class in terra is called 'SpatRaster'
# the easiest way to create a raster object in R is to read one in from a file
single_raster_file <- system.file("raster/srtm.tif", package = "spDataLarge")
single_rast <- rast(raster_filepath)

# You could also make a raster from scratch
new_raster <- rast(nrows = 6, ncols = 6, resolution = 0.5, 
                  xmin = -1.5, xmax = 1.5, ymin = -1.5, ymax = 1.5,
                  vals = 1:36)

# rasters can have multiple layers, representing 'multispectral' satellite images (like RGB images)
# or a time series

multi_raster_file <- system.file("raster/landsat.tif", package = "spDataLarge")
multi_rast <- rast(multi_raster_file)
multi_rast

plot(multi_rast) # see, each layer is plotted

# you can see how many layers a raster has using the nlyr() function
nlyr(multi_rast)

# We can subset layers using their layer number or name
multi_rast3 <- subset(multi_rast, 3) # layer number
multi_rast4 <- subset(multi_rast, "landsat_4") # layer name
plot(multi_rast4)

# We can also combine multiple rasters using the c() function
multi_rast34 <- c(multi_rast3, multi_rast4)
plot(multi_rast34)

# End
