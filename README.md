# biciViz
## Mapeando datos

La idea es aprender a usar datos geolocalizados, y usando librerías de javascript poder dibujar mapas interactivos.

Vamos a hacer un mapa para visualizar los datos del uso del sistema de transporte público de bicicletas de la Ciudad de Buenos Aires, provistos por [Buenos Aires Data](http://data.buenosaires.gob.ar/).

Para hacerlo vamos a utilizar las librerías de javascript [leaflet](http://leafletjs.com/) y un poco de [d3.js](https://d3js.org/).

Como servidor web usaremos [express](http://expressjs.com/).

### Como correr el servidor

Para poder ver la visualización vas a necesitar tener instalado:

* [node](https://nodejs.org/)
* npm

Podés instalarlo siguiendo [ésta](http://blog.teamtreehouse.com/install-node-js-npm-windows) guía o [esta](http://www.vozidea.com/instalar-node-js-windows).
Si tienen mac prueben con [esta](https://coolestguidesontheplanet.com/installing-node-js-on-osx-10-10-yosemite/).

Una vez que tengan node y npm, bajen o clonen este repo. Vayan hasta el root del directorio donde estan los archivos y hagan:

```
npm install
```

Una vez que termine el proceso de instalación de paquetes de npm, pueden correr el servidor escribiendo:

```
npm start
```

Eso iniciará el servidor de forma local, por lo tanto van a poder acceder a `http://localhost:3000` desde su browser y si todo funcionó bien ver el mapa de la Ciudad!

# Los Datos

Vamos a utilizar los siguentes datasets de [Buenos Aires Data](http://data.buenosaires.gob.ar/):

* [Estaciones de Bicis](http://data.buenosaires.gob.ar/dataset/estaciones-bicicletas-publicas)
* [Recorridos 2014](http://data.buenosaires.gob.ar/dataset/bicicletas-publicas)


Para poder trabajar de forma más adecuada con las librerías javascript, los datos fueron transformados a [GeoJson](http://geojson.org/) usando [postGis](http://postgis.net/).

Para eso se hizo un trabajo previo en los datos que vamos a explicar en un post aparte por la complejidad que tiene.

En ese trabajo con los datos también agregamos los datos de recorridos entre todas las estaciones a lo que llamamos 'tramos'. Cada tramo es una línea recta entre dos estaciones, y tiene asociada la cantidad de veces que se registro un viaje en ese tramo, y el tiempo promedio en hacer ese tramo.
Esto lo podemos ver en el archivo `tramos.geojson` dentro de la carpeta `data`.
Las features de tramos son:

* f1: ID estacion origen.
* f2: Nombre estacion origen.
* f3: ID estacion destino.
* f4: Nombre estacion destino.
* f5: Tiempo promedio (en minutos).
* f6: Cantidad de viajes del tramo.

Los datos de las estaciones están en el archivo `estaciones.geojson`, también dentro de `data`.

Sus features son:

* f1: Nombre de la Estación
* f2: ID
* f3: Cantidad de usos (Como origen o destino).


Con estos datos vamos a intentar representar en el mapa:

* La cantidad de usos de cada estacion.
* La cantidad de viajes por cada tramo.


# Haciendo el Mapa

El primer paso va a ser dibujar un mapa de la ciudad de Buenos Aires, sobre este mapa vamos a agregar los datos anteriores.

Vamos a trabajar sobre el archivo `index.ejs` en la carpeta `views`.

Para esto vamos a hacer uso de leaflet, por lo que debemos importar la librería, que cuenta con un archivo js y una hoja de estilos CSS. De paso también agregamos d3.js y jQuery.

```html
<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7/leaflet.css"/>

<script src="http://d3js.org/d3.v3.min.js"></script>
<script src="https://code.jquery.com/jquery-3.0.0.min.js" integrity="sha256-JmvOoLtYsmqlsWxa7mDSLMwa6dZ9rrIdtrrVYRnDRH0=" crossorigin="anonymous"></script>
<script src="http://cdn.leafletjs.com/leaflet-0.7/leaflet.js"></script>
```

Ahora en el HTML agregamos las tags de base donde queremos que leaflet nos dibuje el mapa, en este caso le puse un ancho y alto definido:

```html
<h1>Mapa EcoBici - DataScienceAr.io</h1>
<div id="map" style="width: 800px; height: 600px"></div>
```

Bien, ahora vamos a escribir el javascript para dibujar el mapa de base.
En la variable buenosAires guardamos las coordenadas de un punto central de la ciudad, que es donde va poner el centro el mapa cuando se dibuje.

Creamos el mapa, pasandole como parámetro el id del div donde queremos que se dibuje ('map'). En la función setView pasamos por parámetro las coordenadas donde queremos que se centre el mapa y el nivel de zoom al iniciar, por prueba y error elegí el valor 12.

Leaflet te permite cambiar el mapa de base elegiendo entre varios providers, para este mapa usé el provider Hydda Full, podés ver más providers y ver el código para cambiarlos [acá](https://leaflet-extras.github.io/leaflet-providers/preview/).

```html
<script type="text/javascript">
		var buenosAires = [-34.609851, -58.423326]
        var map = L.map('map').setView(buenosAires, 12);

		var Hydda_Full = L.tileLayer('http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png', {
			attribution: 'Tiles courtesy of <a href="http://openstreetmap.se/" target="_blank">OpenStreetMap Sweden</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
		});

        Hydda_Full.addTo(map);
</script>
```

En este punto, si vamos a ```http://localhost:3000``` deberíamos ver el título de la página y el mapa:

```
//No se olviden de arrancar el servidor:

npm start

```

![Mapa](https://github.com/atralice/biciViz/blob/master/public/images/guia/mapa.png)

Bien, ahora vamos a dibujar las estaciones:

Primero queremos leer los datos de los archivos GeoJson y pasarlos al front-end como objetos, para eso vamos al archivo `./routes/index.js`. Acá está el código que se ejecuta en el servidor cuando entramos a la página.

Básicamente lo único que va a hacer esta parte es leer los archivos geoJson y pasarlos al front-end. Leemos el archivo con la función `readFileSync`, parseamos el archivo para transformarlo en un objeto Javascript con JSON.parse y eso lo guardamos en una variable.
En este paso ya vamos a leer las estaciones y los tramos.

La siguiente linea de código renderiza la página `index.ejs` (donde habiamos escrito el código html del mapa) y le pasa los objetos estaciones y tramos.

```javascript

router.get('/', function(req, res, next) {

  var estaciones = JSON.parse(fs.readFileSync('data/estaciones.geojson', 'utf8')); 
  var tramos = JSON.parse(fs.readFileSync('data/tramos.geojson', 'utf8')); 

  res.render('index', { title: 'Buenos Aires', estaciones: estaciones, tramos:tramos });
});

```

Para recibir los datos en el front-end vamos a agregar lo siguiente a `index.ejs`

```javascript

	estaciones = <%-JSON.stringify(estaciones)%>;
	tramos = <%-JSON.stringify(tramos)%>;

```

Bien, ahora ya tenemos los datos en el front-end.

## Agregando Capas al mapa

Ahora vamos a agregar una capa al mapa que tenga un marcador por cada estacion de bicis.
Para eso, elegimos una imagen que guardamos en `./public/images/marker.png`, que utilizaremos para marcar el punto está cada estación.

Leaflet nos deja crear un objeto Marcador pasandole ciertas opciones, como por ejemplo la imagen que mostrará, el tamaño del icono, etc...
Vamos a crear entonces un objeto marcador (icon) y guardarlo en la variable `emarker`, que usaremos más adelante.

```javascript

	var emarker = L.icon({
	    iconUrl: '/images/marker.png',
	    iconSize:     [20,20], // size of the icon
	    iconAnchor:   [10, 10], // point of the icon which will correspond to marker's location
	    popupAnchor:  [0, 0] // point from which the popup should open relative to the iconAnchor
	});

```

Ahora vamos a agregar cada estación al mapa, con el marcador que creamos recién. La función geoJson recibe un objeto geoJson por parámetro y varias opciones, nosostros le decims que para cada estacion que encuentre la dibuje poniendo un marcado en las coordenadas de la estacion ( `latlng` ) y usando el icono `emarker`.
Finalmente queremos agregar esa layer al mapa que teniamos, y lo hacemos con `.addTo(map)`.

```javascript
	L.geoJson(estaciones,{
		pointToLayer: function (feature, latlng) {
        	return L.marker(latlng, {icon: emarker });
    	}
	}).addTo(map)

```

Si vemos nuestro mapa deberíamos ver las estaciones dibujadas sobre el mapa con el marcador que creamos:

![Mapa](https://github.com/atralice/biciViz/blob/master/public/images/guia/mapaConEstaciones.png)

Ahora lo que vamos a hacer es mapear el tamaño del marcador con la cantidad de veces que fue usada la estacion, ese dato lo teníamos en el feature `f3` de cada estación.
Lo Primero que vamos a tener que hacer es crear una escala linear para mapear cantidad de usos a tamaño en pixels. Si vemos los datos, los usos van desde 9500 usos hasta 82794. Por lo tanto vamos a usar `d3.js` para armar una escala lineal que vaya desde ese dominio a un rango entre 10px y 30px para los menos usados y los más usados respectivamente, para eso usamos la función `scale.liner()` de esta forma:

```javascript

	var size = d3.scale.linear()
    		.domain([9500,82794])
    		.range([10, 30])


```

Ahora vamos a poder usar la función `size` para obtener el tamaño en pixels de cada icono según su uso.

Ahora lo que hacemos es crear un icono nuevo (marcador nuevo) por cada estación, que tenga como `iconSize` el tamaño en pixels que nos devuele la función `size` que creamos recien.
Para acceder a la cantidad de usos de cada estación, vamos a acceder al objeto `feature` que leaftlet nos pasa dentro de la función pointToLayer.
Cada `feature` es una estación, y habiamos dicho que la cantidad de usos estaba en la propiedad `f3` de la misma, por lo tanto el valor que queremos está en `feature.properties.f3`.
Ahora, tenemos que mapear ese valor a pixeles, usando 
`size(feature.properties.f3)` nos devuelve un valor entre 10 y 30 según la cantidad de usos de esa estación.
Entonces incluyendo esto dentro de cada icono, en la propiedad `iconSize`, vamos a tener un marcador con el tamaño mapeado a la cantidad de viajes.


```javascript
	L.geoJson(estaciones,{
		pointToLayer: function (feature, latlng) {
        	return L.marker(latlng, {icon: L.icon({
						    iconUrl: '/images/marker.png',
						    iconSize:     [size(feature.properties.f3),size(feature.properties.f3)], // size of the icon
						    iconAnchor:   [0, 0], // point of the icon which will correspond to marker's location
						    popupAnchor:  [0, 0] // point from which the popup should open relative to the iconAnchor
						})
	 				});
    	}
	}).addTo(map);
```

Ahora si abrimos el mapa vamos a ver cada estación con su tamaño según el uso. Fácilmente distinguimos que Retiro es la estación más usada!

![Mapa](https://github.com/atralice/biciViz/blob/master/public/images/guia/mapaSize.png)

El siguiente paso es dibujar los tramos y pintarlos de un color y la opacidad según la cantidad de viajes del tramo.

Para eso vamos a crear dos escala con d, una de color, que vaya desde 0 a 10000 viajes a un color entre el blanco y el verde, y la segunda que vaya del mismo dominio pero a un rango entre 0 y 1 para la opacidad de la linea.

```javascript

	var freqcolor = d3.scale.linear()
		.domain([0, 10000])
		.range(["white", "green"]);

	var freqopacity = d3.scale.linear()
		.domain([0, 10000])
		.range([0, 1]);

```

Ahora tenemos que dibujar cada linea y ponerle sus estilos según los valores del tramo.
Volvemos a usar la función `geoJson`, pero ahora le pasamos los tramos. Y queremos que en cada uno le aplique los estilos definidos en la propiedad `style`. En ella definimos para cada feature:
* un color usando `freqcolor`, que va a ser cercano a verde si se usa mucho, o blanco si se usa poco.
* una opacidad, los tramos verdes (los más usado) serán menos transparentes para que resalten.
* Le agregamos un nombre de clase para poder manipular los estilos de cada tramo con jQuery más adelante.

Finalmente agregamos la layer nueva al mapa con `addTo(map)`.

```javascript

	 L.geoJson(tramos,{
	    style: function (feature) {
	    		return {
	    			color: freqcolor(feature.properties.f6),
	    			opacity: freqopacity(feature.properties.f6),
	    			className: 'tramo estacion' + feature.properties.f1
	    			};			        
	    }
	}
 	).addTo(map);

```

Ahora deberiamos ver los tramos dibujados!

![Mapa](https://github.com/atralice/biciViz/blob/master/public/images/guia/mapatramos.png)

Pueden jugar cambiando las funciones `freqcolor` y `freqopacity` para cambiar como se mapean los colores y lograr resaltar lo que uno desee.

Por último vamos a darle un poco de dinamismo, queremos que cuando clikeamos en una estación, nos muestre sólo los tramos de esa estación hacia las demás.

Para eso vamos a usar jquery, y el nombre de clase que agregamos en cada tramo previamente, cada tramo tiene una clase con el nombre 'tramo '+ el id de la estación, por ejemplo para retiro todos sus tramos tienen la clase `tramo estacion1'.

Lo que haremos será agregar a cada marcador una función que se ejecutará cada vez que hagan click sobre él.
Dentro de esa función, primero vamos a ocultar todos los tramos, usando la función `hide()` de jQuery. Inmediatamente despueś mostramos sólo los tramos de la estacioen que clikeamos usando la clase que habiamos definido antes. 
En el objeto de estaciones el id estaba en `feature.f2`, entonces buscamos dentro del objeto `e` (objeto donde está toda la info del evento) en la propiedad layer, la propiedad f2 de cada estacion, formando así el selector que necesitamos, por ejemplo: para retiro el selector sería `.estacion3'. Además de mostrar esos tramos usando `show()`, le vamos a cambiar el opacity para que sea más fácil ver todos sus tramos.

```javascript
	L.geoJson(estaciones,{
		pointToLayer: function (feature, latlng) {
        	return L.marker(latlng, {icon: L.icon({
						    iconUrl: '/images/marker.png',
						    iconSize:     [size(feature.properties.f3),size(feature.properties.f3)], // size of the icon
						    iconAnchor:   [0, 0], // point of the icon which will correspond to marker's location
						    popupAnchor:  [0, 0] // point from which the popup should open relative to the iconAnchor
						})
	 				});
    	}
	}).addTo(map).on('click', function(e){
		$('.tramo').hide();
		$('.estacion'+e.layer.feature.properties.f2).show().attr('stroke-opacity',1);
		
	});

```
Ahora, cada vez que hagamos click en una estación, vamos a poder bien sus tramos hacia las otras.
En este punto notamos que hay una diferencia entre los puntos de las estaciones y los tramos, que vamos a intentar corregir más adelante.

![Mapa](https://github.com/atralice/biciViz/blob/master/public/images/guia/mapaClick.png)

Cualquier duda me escriben a: toni@plataforma5.la
Espero que les sirva.