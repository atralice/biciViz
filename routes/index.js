var express = require('express');
var router = express.Router();
var fs = require('fs');

/* GET home page. */
router.get('/', function(req, res, next) {

  var ciclovias = JSON.parse(fs.readFileSync('data/ciclovias.geojson', 'utf8'));
  var estaciones = JSON.parse(fs.readFileSync('data/estaciones.geojson', 'utf8')); 
  var tramos = JSON.parse(fs.readFileSync('data/tramos.geojson', 'utf8')); 

  res.render('index', { title: 'Buenos Aires', ciclovias: ciclovias, estaciones: estaciones, tramos:tramos });
});

module.exports = router;
