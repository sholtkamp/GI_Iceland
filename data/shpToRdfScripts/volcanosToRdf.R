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
#delete all the volcanos beside the ones in Iceland
shapeDF$Country = as.character(shapeDF$Country)
shapeDF = shapeDF[shapeDF$Country == "Iceland",]
#chnage the empty numeric entries to 0
shapeDF$TOTAL_DEAT = as.numeric(shapeDF$TOTAL_DEAT)
shapeDF$TOTAL_DEAT[is.na(shapeDF$TOTAL_DEAT)] <- 0
shapeDF$id = ""
counter = 1
#for loop to give every data frame entry a unique id
for(j in shapeDF$coords.x1){
  shapeDF[counter,39] = floor(runif(1,min=100000,max=999999))
  counter = counter + 1
}

#delete the duplicates from the data frame
shapeDF = shapeDF[!duplicated(shapeDF$Name),]

#initialise the rdf object
rdf = rdf()
#defining the linked vocabularies
geo = "http://www.opengis.net/ont/geosparql#"
volcano = "http://course.geoinfo2018.org/g1#"
v = "volcano:"
dc = "http://purl.org/dc/elements/1.1/#"
dbpedia = "http://dbpedia.org/ontology/#"
rdf2 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

#for loop to add triples to the rdf object
for(i in shapeDF$id)
{
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$id[shapeDF$id==i]),
            predicate = paste0(dc, "name"),
            object = shapeDF$Name[shapeDF$id==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$id[shapeDF$id==i]),
            predicate = paste0(rdf2, "type"),
            object = paste0(volcano,shapeDF$Type[shapeDF$id==i]))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$id[shapeDF$id==i]),
            predicate = paste0(volcano, "vei"),
            object = as.numeric(shapeDF$VEI[shapeDF$id==i]))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$id[shapeDF$id==i]),
            predicate = paste0(dbpedia, "elevation"),
            object = as.numeric(shapeDF$Elevation[shapeDF$id==i]))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$id[shapeDF$id==i]),
            predicate = paste0(volcano, "deaths"),
            object = as.numeric(shapeDF$TOTAL_DEAT[shapeDF$id==i]))
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$id[shapeDF$id==i]),
            predicate = paste0(geo, "hasGeometry"),
            object = paste0(volcano, paste0("point_", shapeDF$id[shapeDF$id==i])))
  rdf %>%
    rdf_add(subject = paste0(volcano, paste0("point_", shapeDF$id[shapeDF$id==i])),
            predicate = paste0(geo, "asWKT"),
            object = paste0("Point(", paste0(shapeDF$coords.x1[shapeDF$id==i], paste0(" ", paste0(shapeDF$coords.x2[shapeDF$id==i], ")")))))
}

#serialize the rdf object to the turtle format with the required namespaces
rdf_serialize(rdf, "path to result .ttl", format = "turtle", namespace = c(geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", dc = "http://purl.org/dc/elements/1.1/#", dbpedia = "http://dbpedia.org/ontology/#", rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#", volcano =  "http://course.geoinfo2018.org/g1#"))
