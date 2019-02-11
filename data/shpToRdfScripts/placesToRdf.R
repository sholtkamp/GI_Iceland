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
#initialise the rdf object
rdf = rdf()
#defining the linked vocabularies
base = "http://example.com/places#"
geo = "http://www.opengis.net/ont/geosparql#"
volcano = "http://course.geoinfo2018.org/g1#"
v = "volcano:"
dc = "http://purl.org/dc/elements/1.1/#"
dbpedia = "http://dbpedia.org/ontology/#"
rdf2 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

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
            object = paste0(dbpedia,firstup(shapeDF$type[shapeDF$osm_id==i])))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$osm_id[shapeDF$osm_id==i]),
            predicate = paste0(geo, "hasGeometry"),
            object = paste0(volcano, paste0("point_", shapeDF$osm_id[shapeDF$osm_id==i])))
  rdf %>%
    rdf_add(subject = paste0(volcano, paste0("point_", shapeDF$osm_id[shapeDF$osm_id==i])),
            predicate = paste0(geo, "asWKT"),
            object = paste0("Point(", paste0(shapeDF$coords.x1[shapeDF$osm_id==i], paste0(" ", paste0(shapeDF$coords.x2[shapeDF$osm_id==i], ")")))))
}

#serialize the rdf object to the turtle format with the required namespaces
rdf_serialize(rdf, "path to result .ttl", format = "turtle", namespace = c(geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", dc = "http://purl.org/dc/elements/1.1/#", dbpedia = "http://dbpedia.org/ontology/#", rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#", volcano =  "http://course.geoinfo2018.org/g1#"))
