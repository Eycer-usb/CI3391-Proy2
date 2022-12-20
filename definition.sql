-- SE GENERAN LOS ESQUEMAS DE LA BASE DE DATOS --

-- Se genera la tabla 'city' que contendra la lista
-- de las 100 ciudades con mayor poblacion del mundo
-- esta informacion se carga desde el archivo city.csv

CREATE TABLE city(
    id bigint NOT NULL PRIMARY KEY,
    name varchar NOT NULL,
    country varchar NOT NULL,
    population bigint NOT NULL    
);


-- Se crea la tabla 'flight' de vuelos entre ciudades

CREATE TABLE flight(
    id bigserial NOT NULL PRIMARY KEY,
    from_city bigint NOT NULL,
    to_city bigint NOT NULL,
    price money NOT NULL,
    CONSTRAINT from_city_fk FOREIGN KEY (from_city)
        REFERENCES city (id),
    CONSTRAINT to_city_fk FOREIGN KEY (to_city)
        REFERENCES city (id)
);


-- Se cargan los datos de la tabla obtenida en csv
\copy city from 'city.csv' WITH DELIMITER ',' CSV;


------------------- METODOS Y FUNCIONES -----------------------

-- funcion de precios valores numericos aleatorios entre rango

CREATE OR REPLACE FUNCTION random_between(low NUMERIC ,high NUMERIC) 
RETURNS numeric AS
$$
BEGIN
   RETURN random()* (high-low + 1) + low;
END;
$$ language 'plpgsql';


-- Se crea procedimiento de creacion de vuelos aleatorios
-- desde un origen dado

CREATE OR REPLACE PROCEDURE random_flight(
	IN table_name character varying,
	IN from_id bigint,
	IN number bigint,
	IN min_price numeric,
	IN max_price numeric)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
row record;
other_cities varchar;
price money;
BEGIN
	other_cities := format
    (
        'SELECT id FROM %s AS c WHERE c.id != %L ORDER BY RANDOM() LIMIT %L',
        table_name, from_id, number
    );
	
	FOR row IN EXECUTE other_cities
	LOOP
		SELECT random_between(min_price, max_price) into price;
		INSERT INTO flight (from_city, to_city, price)
		VALUES ( from_id, row.id ,  price );
	END LOOP;
END;
$BODY$;
ALTER PROCEDURE public.random_flight(character varying, bigint, bigint, numeric, numeric)
    OWNER TO postgres;

-- Metodo de creacion de vuelos aleatorios sobre toda ciudad en tabla recibida como argumento
-- Con precio entre un rango recibido como argumento
CREATE OR REPLACE PROCEDURE create_random_flights( t_name varchar, number bigint, min_price numeric, max_price numeric )
LANGUAGE plpgsql
AS $BODY$
DECLARE
	row record;
	cities varchar;
BEGIN
	cities := format (
		'SELECT id FROM %s as c',
		t_name
	);
	FOR row in EXECUTE cities
	LOOP
		CALL random_flight( t_name, row.id, number, min_price, max_price );
	END LOOP;
END;
$BODY$;

-- Se ejecuta el metodo de llenado automatico de tabla de vuelos
-- con 25 vuelos a destinos aleatorios y con precios entre el rango $100 - $900
CALL create_random_flights('city', 25, 100, 900);




-- VARIANTE DEL ALGORITMO DE DIJKSTRA PARA CAMINO DE COSTO MINIMO
-- DESDE NODO INICIAL EN UN GRAFO HACIA LOS DEMAS
CREATE OR REPLACE FUNCTION trip(
	from_city_id bigint,
	depth integer DEFAULT -1)
    RETURNS TABLE(from_city bigint, to_city bigint, price money, step integer, visited bigint[]) 
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	RETURN QUERY
	WITH RECURSIVE sp AS 
	(
		SELECT f.from_city, f.to_city, f.price, 0 AS level, ARRAY[ f.from_city, f.to_city ] as visited
		FROM flight f
		WHERE f.from_city = $1

		UNION all

		SELECT sp.from_city, f.to_city, sp.price + f.price, sp.level + 1, array_append( sp.visited, f.to_city )
		FROM flight f
		JOIN sp ON sp.to_city = f.from_city
		WHERE (sp.level < $2 OR $2 = -1) AND
		NOT ARRAY[f.to_city ] <@ sp.visited
	)
	SELECT distinct *
	FROM sp;
	
END; 
$BODY$;


-- SE EJECUTA EL ALGORITMO DE DIJKSTRA PARA CAMINO DE COSTO MINIMO
-- DESDE NODO INICIAL HASTA TODOS LOS DEMAS Y SE AGREGAN LOS COSTOS MINIMOS
-- A LA TABLA RECIBIDA
CREATE OR REPLACE FUNCTION shortest_path( origin BIGINT, table_out varchar, steps int DEFAULT -1 )
RETURNS VARCHAR
AS $$
BEGIN
	-- Se crea tabla temporal del recorrido trip
	-- esta tabla se crea para mejorar el rendimiento del
	-- algoritmo, dado que Dijkstra calcula el camino de costo
	-- minimo desde nodo inicial hasta el resto de nodos.
	-- Luego lo que se hace es filtrar unicamente los caminos de costo
	-- minimo y estos valores se agregan a la tabla de salida 
	-- con nombre recibido como parametro
	DROP TABLE IF EXISTS trip;
	CREATE TABLE IF NOT EXISTS trip(
		from_city bigint,
		to_city bigint,
		price money,
		steps int,
		visited bigint[]
	);
	
	-- Si la tabla donde se almacenara el resultado no existe 
	-- entonces se crea
	EXECUTE format( 'CREATE TABLE IF NOT EXISTS %s(
		from_city bigint,
		to_city bigint,
		price money,
		steps int,
		visited bigint[]
	)', table_out);
	
	-- Se ejecuta la funcion de recorrido desde nodo inicial y se almacena en trip
	EXECUTE format( 'INSERT INTO trip select * from trip(%L::bigint, %L)', origin, steps );
	
	-- Una vez ejecutada la funcion de recorrido desde el nodo inicial se
	-- filtraran los recorridos minimos y almacenan en la tabla de salida
	EXECUTE format('
	INSERT INTO %s 
	SELECT t.*
	FROM (
		select s.from_city, s.to_city, min(s.price) as min_cost
		FROM trip as s
		GROUP BY s.from_city, s.to_city
	) AS s
	JOIN trip as t 
	ON s.from_city = t.from_city and s.to_city = t.to_city and t.price = s.min_cost
	ORDER BY t.to_city ASC;', table_out);
	
	-- Se elimina la tabla temporal
	DROP TABLE IF EXISTS trip;
	RETURN 'DONE!';
END; $$
LANGUAGE 'plpgsql';

--CALL shortest_path( 1, 3, 'salida' )

