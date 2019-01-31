library(rgdal)
library(rdflib)
library(dplyr)
library(tidyr)
library(tibble)
library(jsonld)

shape = readOGR("path to shapefile")
shapeDF = as.data.frame(shape)
shapeDF$name = as.character(shapeDF$name)
shapeDF$name[is.na(shapeDF$name)] <- 'unknown'
shapeDF$coords = ""
rdf = rdf()
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

x = shape@polygons
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

firstup <- function(x) {
  y = toString(x)
  substr(y, 1, 1) <- toupper(substr(y, 1, 1))
  y
}

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

rdf_serialize(rdf, "path to result .ttl", format = "turtle", namespace = c(geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", volcano =  "http://course.geoinfo2018.org/g1#", dc = "http://purl.org/dc/elements/1.1/#"))
