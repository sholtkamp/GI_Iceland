let volcanoPolygons;
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