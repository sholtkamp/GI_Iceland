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
#edit the needed and empty data frame entires by giving them new values
shapeDF$oneway[shapeDF$oneway==0] = 'false'
shapeDF$oneway[shapeDF$oneway==1] = 'true'
shapeDF$name = as.character(shapeDF$name)
shapeDF$name[is.na(shapeDF$name)] <- 'unknown'
shapeDF$maxspeed[shapeDF$maxspeed==0] <- 'unknown'
#add an emtpy column for the coordinates
shapeDF$coords = ""
#initialise the rdf object
rdf = rdf()
#defining the linked vocabularies
base = "http://example.com/roads#"
geo = "http://www.opengis.net/ont/geosparql#"
volcano =  "http://course.geoinfo2018.org/g1#"
v = "volcano:"
rdf2 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
dc = "http://purl.org/dc/elements/1.1/#"
dbpedia = "http://dbpedia.org/ontology/#"
lines = NULL
counter = 1
dataframeCounter = 1
l = 0

#function to refactor binary data frame columns
oneway <- function(x){
  if(x == 0){
    y = 'false'
  } else{
    y = 'true'
  }
  y
}

#function to capitalize the first letter of a string
firstup <- function(x) {
  y = toString(x)
  substr(y, 1, 1) <- toupper(substr(y, 1, 1))
  y
}

#select a subset of the data frame with only the coordinates
x = coordinates(shape)
#for loop to add the coordinates to the column in a geosparql accepted way
for(j in x){
  for(k in j){
    y = apply(k,1,paste)
    while(l<length(y)/2){
      if(counter!=1){
        lines = paste0(lines,paste0(",",paste0(y[1,counter],paste0(" ",y[2,counter]))))
      }
      if(counter == 1){
        lines = paste0(y[1,counter],paste0(" ",y[2,counter]))
      }
      counter = counter + 1
      l = l + 1
    }
    shapeDF[dataframeCounter,7] = lines
    counter = 1
    lines = NULL
    l=0
  }
  dataframeCounter = dataframeCounter + 1
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
            predicate = paste0(volcano, "maximum_speed"),
            object = shapeDF$maxspeed[shapeDF$osm_id==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$osm_id[shapeDF$osm_id==i]),
            predicate = paste0(base, "oneway"),
            object = paste0(shapeDF$oneway[shapeDF$osm_id==i],"^^xsd:boolean"))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$osm_id[shapeDF$osm_id==i]),
            predicate = paste0(geo, "hasGeometry"),
            object = paste0(volcano, paste0("line_", shapeDF$osm_id[shapeDF$osm_id==i])))
  rdf %>%
    rdf_add(subject = paste0(volcano, paste0("line_", shapeDF$osm_id[shapeDF$osm_id==i])),
            predicate = paste0(geo, "asWKT"),
            object = paste0("Line(",paste0(shapeDF$coords[shapeDF$osm_id == i],")")))
}

#serialize the rdf object to the turtle format with the required namespaces
rdf_serialize(rdf, "path to result.ttl", format = "turtle", namespace = c(road = "http://example.com/roads#",geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", dc = "http://purl.org/dc/elements/1.1/#", dbpedia = "http://dbpedia.org/ontology/#", volcano =  "http://course.geoinfo2018.org/g1#"))
