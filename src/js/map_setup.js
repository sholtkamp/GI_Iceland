//initiate map
var map = L.map('map_div', { zoomControl: false });
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

// define layers here
// var cities = L.tileLayer(, {id: '', attribution: }),

var overlayMaps = {
  "Cities" : placeLayer,
  "Volcanos" : volcanoLayer,
  "Waterbodies" : waterLayer,
  "Natural Features" : natureLayer,
}

L.control.layers(mapLayer).addTo(map);