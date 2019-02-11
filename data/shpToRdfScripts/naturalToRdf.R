#loading required packages
library(rgdal)
library(rdflib)
library(dplyr)
library(tidyr)
library(tibble)
library(jsonld)

#reading in the shapefile with gdal (path needed)
shape = readOGR("path to shapefile")
#converting the shapefile to a data frame
shapeDF = as.data.frame(shape)
#change the empty data frame entries to unknown
shapeDF$name = as.character(shapeDF$name)
shapeDF$name[is.na(shapeDF$name)] <- 'unknown'
#add a column for the coordinates to the data frame
shapeDF$coords = ""
#initialise the rdf object
rdf = rdf()
#defining the linked vocabularies
base = "http://example.com/natural#"
geo = "http://www.opengis.net/ont/geosparql#"
volcano =  "http://course.geoinfo2018.org/g1#"
v = "volcano:"
dc = "http://purl.org/dc/elements/1.1/#"
rdf2 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
polygon = NULL
counter = 1
dataframeCounter = 1
l = 0

#select a subset with only the coordinates
x = shape@polygons
#for loop to add the coordinates to the column in a geosparql accepted way
for(j in x){
  z = j@Polygons
  for(k in z){
    q = k@coords
    y = apply(q,1,paste)
    while(l<length(y)/2){
      if(counter!=1){
        polygon = paste0(polygon,paste0(",",paste0(y[1,counter],paste0(" ",y[2,counter]))))
      }
      if(counter == 1){
        polygon = paste0(y[1,counter],paste0(" ",y[2,counter]))
      }
      counter = counter + 1
      l = l + 1
    }
    shapeDF[dataframeCounter,4] = polygon
    counter = 1
    polygon = NULL
    l=0
  }
  dataframeCounter = dataframeCounter + 1
}

#function to capitalize the first letter of a string
firstup <- function(x) {
  y = toString(x)
  substr(y, 1, 1) <- toupper(substr(y, 1, 1))
  y
}

#for loop to add triples to the rdf object
for(i in shapeDF$osm_id)
{
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$osm_id[shapeDF$osm_id==i]),
            predicate = paste0(dc, "name"),
            object = shapeDF$name[shapeDF$osm_id==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$osm_id[shapeDF$osm_id==i]),
            predicate = paste0(rdf2, "type"),
            object = paste0(volcano,firstup(shapeDF$type[shapeDF$osm_id==i])))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$osm_id[shapeDF$osm_id==i]),
            predicate = paste0(geo, "hasGeometry"),
            object = paste0(volcano, paste0("polygon_", shapeDF$osm_id[shapeDF$osm_id==i])))
  rdf %>%
    rdf_add(subject = paste0(volcano, paste0("polygon_", shapeDF$osm_id[shapeDF$osm_id==i])),
            predicate = paste0(geo, "asWKT"),
            object = paste0("Polygon(",paste0(shapeDF$coords[shapeDF$osm_id == i],")")))
}

#serialize the rdf object to the turtle format with the required namespaces
rdf_serialize(rdf, "path to result .ttl", format = "turtle", namespace = c(geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", volcano =  "http://course.geoinfo2018.org/g1#", dc = "http://purl.org/dc/elements/1.1/#"))
