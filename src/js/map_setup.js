//initiate map
let map = L.map('map_div', {zoomControl: false});
map.setView([64.759782, -18.423403], 6.4);

//add tile layer to map

var mapLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
});

map.addLayer(mapLayer);

// add zoom control in right top corner
L.control.zoom({
    position: 'topright'
}).addTo(map);

//add location finder
var lc = L.control.locate({
  position: 'topleft',
  strings: {
    setView: "once"
  }
}).addTo(map);

// add search in top left corner
map.addControl(new L.Control.Search({
    url: 'http://nominatim.openstreetmap.org/search?format=json&q={s}',
    jsonpParam: 'json_callback',
    propertyName: 'display_name',
    propertyLoc: ['lat', 'lon'],
    marker: L.marker([0, 0]),
    autoCollapse: true,
    autoType: false,
    minLength: 2
}));


//add location finder
let lc = L.control.locate({
    position: 'topleft',
    strings: {
        setView: "once"
    }
}).addTo(map);

createVolcanoFeatures();

async function createVolcanoFeatures() {
    let volcanoQuery = "SELECT DISTINCT * WHERE {\n" +
        "?s volcano:vei ?o." +
        "?s geo:hasGeometry ?point." +
        "?point geo:asWKT ?geometry." +
        "?s dc:name ?name" +
        "}";
    let volcanoIcon = new L.Icon({
        iconSize: [20, 20],
        iconAnchor: [6, 6],
        popupAnchor: [1, -24],
        iconUrl: '../img/volcanoIcon.png'
    });
    let volcanoLayer = L.geoJSON('', {
        id: 'volcanoLayer',
        pointToLayer: function (feature, latlng) {
            return L.marker(latlng, {icon: volcanoIcon});
        }
    }).addTo(map);
    queryTripleStore(volcanoQuery).then((volcanos) => {
        volcanos.results.bindings.forEach(volcano => {
            volcanoLayer.addData(_createGeojsonFeaturen(volcano));
        });
    });
    volcanoLayer.bindPopup((layer) => {
        return L.Util.template('<p><b>Name : </b>{name}<br>', layer.feature.properties);
    });
};

createPlacesFeatures(); //https://stackoverflow.com/questions/30501124/or-in-a-sparql-query
async function createPlacesFeatures() {
    let placesQuery = "SELECT DISTINCT * WHERE {\n" +
        "?s a ?towntype ." +
        "FILTER (?towntype IN (dbpedia:Suburb , dbpedia:Village , dbpedia:Hamlet, dbpedia:Town, dbpedia:City ) )"+
        "?s geo:hasGeometry ?point." +
        "?point geo:asWKT ?geometry." +
        "?s dc:name ?name" +
        "}";
    let placeIcon = new L.Icon({
        iconSize: [5, 5],
        iconAnchor: [0, 0],
        popupAnchor: [-6, -24],
        iconUrl: '../img/townIcon.png'
    });
    let placeLayer = L.geoJSON('', {
        id: 'placeLayer',
        pointToLayer: function (feature, latlng) {
            return L.marker(latlng, {icon: placeIcon});
        }
    }).addTo(map);
    queryTripleStore(placesQuery).then((places) => {
        places.results.bindings.forEach(place => {
            placeLayer.addData(_createGeojsonFeaturen(place));
        });
    });
    placeLayer.bindPopup((layer) => {
        return L.Util.template('<p><b>Name : </b>{name}<br>', layer.feature.properties);
    });
};


createWaterFeatures();
async function createWaterFeatures() {
    let waterQuery = "SELECT DISTINCT * WHERE {\n" +
        "?s a ?watertype ." +
        "FILTER (?watertype IN (dbpedia:River , dbpedia:Stream , dbpedia:Drain , dbpedia:Dam , dbpedia:Dock  ) )"+
        "?s geo:hasGeometry ?line." +
        "?line geo:asWKT ?geometry." +
        "?s dc:name ?name" +
        "}";

    let waterStyle = {
        "color": "blue",
        "weight": 2,
        "opacity": 0.75
    };

    let waterLayer = L.geoJSON('', {
        id: 'waterLayer',
        style: waterStyle
    }).addTo(map);
    queryTripleStore(waterQuery).then((waters) => {
        waters.results.bindings.forEach(water => {
            waterLayer.addData(_createPolylineFeaturen(water));
        });
    });
    waterLayer.bindPopup((layer) => {
        return L.Util.template('<p><b>Name : </b>{name}<br>', layer.feature.properties);
    });
};

createRoadFeatures();
async function createRoadFeatures() {
    let roadQuery = "SELECT DISTINCT * WHERE {\n" +
        "?s a ?roadtype ." +
        "FILTER (?roadtype IN (volcano:Residential ,volcano:Primary_link , volcano:Tertiary , volcano:Unclassified , volcano:Service , volcano:Track , volcano:Path , volcano:Bridleway , volcano:Byway ,  volcano:Crossing , volcano:Footway , volcano:Construction , volcano:Cycleway , volcano:Ford , volcano:Living_street , volcano:Minor , volcano:Park , volcano:Pedestrian , volcano:Primary ,  volcano:Road,  volcano:Secondary ,volcano:Secondary_link , volcano:Steps ,  volcano:Services , volcano:Trunk , volcano:Trunk_link , volcano:Unsurfaced ) )"+
        "?s geo:hasGeometry ?line." +
        "?line geo:asWKT ?geometry." +
        "?s dc:name ?name" +
        "}";

    let roadStyle = {
        "color": "grey",
        "weight": 1,
        "opacity": 0.85
    };

    let roadLayer = L.geoJSON('', {
        id: 'roadLayer',
        style: roadStyle


    }).addTo(map);
    queryTripleStore(roadQuery).then((roads) => {
        roads.results.bindings.forEach(road => {
            roadLayer.addData(_createPolylineFeaturen(road));
        });
    });
    roadLayer.bindPopup((layer) => {
        return L.Util.template('<p><b>Name : </b>{name}<br>', layer.feature.properties);
    });
};


async function queryTripleStore(qry) {
    const baseUrl = 'http://giv-oct.uni-muenster.de:8890/sparql?default-graph-uri=http%3A%2F%2Fcourse.geoinfo2018.org%2FG1&format=application/json&timeout=0&debug=on&query='
    const q = `
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            PREFIX geo: <http://www.opengis.net/ont/geosparql#>
            PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
            PREFIX dc: <http://purl.org/dc/elements/1.1/#>
            PREFIX dbpedia: <http://dbpedia.org/ontology/#>
            PREFIX volcano: <http://course.geoinfo2018.org/g1#>
        ${qry}
    `;

    const response = await fetch(baseUrl + encodeURIComponent(q));
    const json = await response.json();
    return json;
}

// function to create feature from json
let _createGeojsonFeaturen = (entry) => {
    let geojsonFeature = {
        "type": "Feature",
        "properties": {
            "name": entry.name.value,
            "id": entry.s.value,
            "entry": entry
        },

        "geometry": {
            "type": "Point",
            "coordinates": [parseFloat(entry.geometry.value.split('(')[1].split(' ')[0]), parseFloat(entry.geometry.value.split('(')[1].split(' ')[1])]
        }
    };
    return geojsonFeature;
};

let _createPolylineFeaturen = (entry) => {
    let temp = entry.geometry.value.split('(');
    let coordinatePairs = temp[1].split(',');
    let coordinates = [];
    coordinatePairs.forEach(pair =>{
       let coordinatePair = [parseFloat(pair.split(' ')[0]), parseFloat(pair.split(' ')[1])];
       coordinates.push(coordinatePair);
    } );
    let geojsonFeature = {
        "type": "Feature",
        "properties": {
            "name": entry.name.value,
            "id": entry.s.value,
            "entry": entry
        },

        "geometry": {
            "type": "LineString",
            "coordinates": coordinates
        }
    };
    console.log(geojsonFeature);
    return geojsonFeature;
};


var overlayMaps = {
  "Cities" : placeLayer,
  "Volcanos" : volcanoLayer,
  "Waterbodies" : waterLayer,
  "Natural Features" : natureLayer,
}

L.control.layers(mapLayer).addTo(map);

