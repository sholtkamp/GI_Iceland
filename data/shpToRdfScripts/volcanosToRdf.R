library(rgdal)
library(rdflib)
library(dplyr)
library(tidyr)
library(tibble)
library(jsonld)

shape = readOGR("path to shapefile")
shapeDF = as.data.frame(shape)
shapeDF$Country = as.character(shapeDF$Country)
shapeDF = shapeDF[shapeDF$Country == "Iceland",]
shapeDF$TOTAL_DEAT = as.numeric(shapeDF$TOTAL_DEAT)
shapeDF$TOTAL_DEAT[is.na(shapeDF$TOTAL_DEAT)] <- 0
shapeDF$id = ""
counter = 1
for(j in shapeDF$coords.x1){
  shapeDF[counter,39] = floor(runif(1,min=100000,max=999999))
  counter = counter + 1
}

shapeDF = shapeDF[!duplicated(shapeDF$Name),]

rdf = rdf()
geo = "http://www.opengis.net/ont/geosparql#"
volcano = "http://course.geoinfo2018.org/g1#"
v = "volcano:"
dc = "http://purl.org/dc/elements/1.1/#"
dbpedia = "http://dbpedia.org/ontology/#"
rdf2 = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

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

rdf_serialize(rdf, "path to result .ttl", format = "turtle", namespace = c(geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", dc = "http://purl.org/dc/elements/1.1/#", dbpedia = "http://dbpedia.org/ontology/#", rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#", volcano =  "http://course.geoinfo2018.org/g1#"))
