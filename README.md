# biciViz
## Mapeando datos

La idea es aprender a usar datos geolocalizados, y usando librerías de javascript poder dibujar mapas interactivos.

Vamos a hacer un mapa visualización los datos del uso del sistema de transporte público de bicicletas de la Ciudad de Buenos Aires, provistos por [Buenos Aires Data](http://data.buenosaires.gob.ar/).

Para hacerlo vamos a utilizar las librerías de javascript (leaflet)[http://leafletjs.com/] y un poco de [d3.js](https://d3js.org/).

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

Para eso se hizo un trabajo previo en los datos que vamos a explicar en un post aparte por la complejidad que se merece.

En este paso también agregamos los datos de recorridos entre todas las estaciones a lo que llamamos 'tramos'. Cada tramo es una línea recta entre dos estaciones, y tiene asociada la cantidad de veces que se registro un viaje en ese tramo, y el tiempo promedio en hacer ese tramo.
Esto lo podemos ver en el archivo `tramos.geojson` dentro de la carpeta `data`.
Las features de tramos son:

f1: ID estacion origen.
f2: Nombre estacion origen.
f3: ID estacion destino.
f4: Nombre estacion destino.
f5: Tiempo promedio (en minutos).
f6: Cantidad de viajes del tramo.

Los datos de las estaciones están en el archivo `estaciones.geojson`, también dentro de `data`.

Sus features son:
f1: Nombre de la Estación
f2: ID
f3: Cantidad de usos (Como origen o destino).


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

Creamos el mapa y en la función setView pasamos por parámetro las coordenadas donde queremos que se centre el mapa y el nivel de zoom al iniciar, por prueba y error elegí el valor 12.

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

![Mapa](https://github.com/atralice/biciViz/blob/master/public/images/guia/mapa.png")