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
#creating a matrix with only the polygons with coordinates
m = matrix(0,nrow = length(shape@polygons[[1]]@Polygons),ncol=2)
m = data.frame(m)
#editing the column names of the new data frame
colnames(m)[1] = "id"
colnames(m)[2] = "coords"
#intitialise the rdf object
rdf = rdf()
#defining the linked vocabularies
base = "http://gadm.geovocab.org/ontology#"
geo = "http://www.opengis.net/ont/geosparql#"
volcano =  "http://course.geoinfo2018.org/g1#"
v = "volcano:"
polygon = NULL
counter = 1
dataframeCounter = 1
l = 0

#select a subset of the data frame with only polygons
x = shape@polygons[[1]]@Polygons
#for loop to edit the data frame in a way the coordinates are added in a geosparql accepted way
for(j in x){
  y = apply(j@coords,1,paste)
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
  m[dataframeCounter,2] = polygon
  m[dataframeCounter,1] = dataframeCounter
  counter = 1
  polygon = NULL
  l=0
  dataframeCounter = dataframeCounter + 1
}

#for loop to add triples to the rdf object
for(i in shapeDF$ID_0)
{
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$ID_0[shapeDF$ID_0==i]),
            predicate = paste0(base, "name"),
            object = shapeDF$NAME_ENGLI[shapeDF$ID_0==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$ID_0[shapeDF$ID_0==i]),
            predicate = paste0(base, "iso"),
            object = shapeDF$ISO[shapeDF$ID_0==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$ID_0[shapeDF$ID_0==i]),
            predicate = paste0(base, "pop2000"),
            object = shapeDF$POP2000[shapeDF$ID_0==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$ID_0[shapeDF$ID_0==i]),
            predicate = paste0(base, "sqkm"),
            object = shapeDF$SQKM[shapeDF$ID_0==i])
  rdf %>%
    rdf_add(subject = paste0(volcano, shapeDF$ID_0[shapeDF$ID_0==i]),
            predicate = paste0(base, "popsqkm"),
            object = shapeDF$POPSQKM[shapeDF$ID_0==i])
  for(k in m$id){
    rdf %>%
      rdf_add(subject = paste0(volcano, shapeDF$ID_0[shapeDF$ID_0==i]),
              predicate = paste0(geo, "hasGeometry"),
              object = paste0(volcano, paste0("polygon_", paste0(shapeDF$ID_0[shapeDF$ID_0==i],paste0("_",m$id[m$id == k])))))
    rdf %>%
      rdf_add(subject = paste0(volcano, paste0("polygon_", paste0(shapeDF$ID_0[shapeDF$ID_0==i],paste0("_",m$id[m$id == k])))),
              predicate = paste0(geo, "asWKT"),
              object = paste0("Polygon(",paste0(m$coords[m$id==k],")")))
  }
}

#serialize the rdf object to the turtle format with the required namespaces
rdf_serialize(rdf, "path to result .ttl", format = "turtle", namespace = c(gadm = "http://gadm.geovocab.org/ontology#",geo = "http://www.opengis.net/ont/geosparql#", xsd = "http://www.w3.org/2001/XMLSchema#", volcano =  "http://course.geoinfo2018.org/g1#"))
