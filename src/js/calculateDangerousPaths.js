let volcanoPolygons;

let latlngs = [];

createVolcanoPoints();

let vei1 = new L.Icon({
    iconSize: [5, 5],
    iconAnchor: [0, 0],
    popupAnchor: [-6, -24],
    iconUrl: '../img/volcanoBuffer.png'
});

let vei2 = new L.Icon({
    iconSize: [10, 10],
    iconAnchor: [0, 0],
    popupAnchor: [-6, -24],
    iconUrl: '../img/volcanoBuffer.png'
});

let vei3 = new L.Icon({
    iconSize: [20, 20],
    iconAnchor: [0, 0],
    popupAnchor: [-6, -24],
    iconUrl: '../img/volcanoBuffer.png'
});

let vei4 = new L.Icon({
    iconSize: [40, 40],
    iconAnchor: [0, 0],
    popupAnchor: [-6, -24],
    iconUrl: '../img/volcanoBuffer.png'
});

let vei5 = new L.Icon({
    iconSize: [50, 50],
    iconAnchor: [0, 0],
    popupAnchor: [-6, -24],
    iconUrl: '../img/volcanoBuffer.png'
});

let vei6 = new L.Icon({
    iconSize: [60, 60],
    iconAnchor: [0, 0],
    popupAnchor: [-6, -24],
    iconUrl: '../img/volcanoBuffer.png'
});

async function createVolcanoPoints() {
    let volcanoQuery = "SELECT DISTINCT * WHERE {\n" +
        "?s volcano:vei ?o." +
        "?s geo:hasGeometry ?point." +
        "?point geo:asWKT ?geometry." +
        "?s dc:name ?name" +
        "}";

    queryTripleStore(volcanoQuery).then((volcanos) => {
        volcanos.results.bindings.forEach(volcano => {
            if (volcano.o.value === "2") {
                L.marker((_createPoints(volcano)), {icon: vei1}).addTo(map)
            } else if (volcano.o.value === "3") {
                L.marker((_createPoints(volcano)), {icon: vei2}).addTo(map)
            } else if (volcano.o.value === "4") {
                L.marker((_createPoints(volcano)), {icon: vei3}).addTo(map)
            } else if (volcano.o.value === "5") {
                L.marker((_createPoints(volcano)), {icon: vei4}).addTo(map)
            } else if (volcano.o.value === "6") {
                L.marker((_createPoints(volcano)), {icon: vei5}).addTo(map)
            } else if (volcano.o.value === "7") {
                L.marker((_createPoints(volcano)), {icon: vei6}).addTo(map)
            }
        });
    });
};

let _createPoints = (entry) => {
    let cordinates = [parseFloat(entry.geometry.value.split('(')[1].split(' ')[0]), parseFloat(entry.geometry.value.split('(')[1].split(' ')[1])]
    return cordinates;
};


let streetPolylines;

let getLayerInformation = () => {


};

let checkIfIntersects = () => {
    volcanoPolygons.forEach(polygon => {
        streetPolylines(polyline => {
            let polylinePoints = intersects();
            let intersectionPolyline = new L.Polyline(
                polylinePoints, {
                    color: 'red'
                }
            ).addTo(map);
        })
    })
};

let changeColor = (polyline) => {
    polyline.setStyle({
        color: 'red'
    })
};

let intersects = (polygon, polyline) => {
    let polylinePointsInsidePolygon = [];
    let temp;
    polyline.points.forEach((point, index) => {
        if (isPointInsidePolygon(point, polygon)) {
            if (temp === index - 1) {
                temp = index;
                polylinePointsInsidePolygon.push(point);
            }
        }
    });

    return polylinePointsInsidePolygon
};


function isPointInsidePolygon(marker, poly) {
    let polyPoints = poly.getLatLngs();
    let x = marker.getLatLng().lat,
        y = marker.getLatLng().lng;

    let inside = false;
    for (let i = 0, j = polyPoints.length - 1; i < polyPoints.length; j = i++) {
        let xi = polyPoints[i].lat, yi = polyPoints[i].lng;
        let xj = polyPoints[j].lat, yj = polyPoints[j].lng;

        let intersect = ((yi > y) != (yj > y))
            && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }

    return inside;
};