-- PREGUNTA 2a
-- Se ejecuta la funcion
-- shortest_path( origin_city, table_name_out, steps ) sobre
-- cada ciudad en la lista de ciudades con maximo una parada (step = 1)

SELECT shortest_path( c.id, 'pregunta_2a', 1 )
FROM city as c;

-- MOSTRAMOS EL RESULTADO
SELECT o.name as origin, f.name as destination, p1.price as min_cost, p1.steps, p1.visited as path
FROM pregunta_2a as p1
JOIN city as o ON o.id = p1.from_city
JOIN city as f ON f.id = p1.to_city;



-- PREGUNTA 2b
-- Se ejecuta la funcion
-- shortest_path( origin_city, table_name_out, steps ) sobre
-- cada ciudad en la lista de ciudades con maximo dos paradas (step = 2)

SELECT shortest_path( c.id, 'pregunta_2b', 2 )
FROM city as c;

-- MOSTRAMOS EL RESULTADO
SELECT o.name as origin, f.name as destination, p1.price as min_cost, p1.steps, p1.visited as path
FROM pregunta_2b as p1
JOIN city as o ON o.id = p1.from_city
JOIN city as f ON f.id = p1.to_city;

-- PREGUNTA 2c
-- Se ejecuta la funcion
-- shortest_path( origin_city, table_name_out, steps ) sobre
-- cada ciudad en la lista de ciudades sin paradas maximas

SELECT shortest_path( c.id, 'pregunta_2c')
FROM city as c;

-- MOSTRAMOS EL RESULTADO
SELECT o.name as origin, f.name as destination, p1.price as min_cost, p1.steps, p1.visited as path
FROM pregunta_2c as p1
JOIN city as o ON o.id = p1.from_city
JOIN city as f ON f.id = p1.to_city;


-- PREGUNTA 2d
-- Se ejecuta la funcion
-- shortest_path( origin_city, table_name_out, steps ) sobre
-- cada ciudad en la lista de ciudades con maximo 3 paradas

SELECT shortest_path( c.id, 'pregunta_2d_tmp')
FROM city as c;

-- SE RETORNA EL NOMBRE DE LA CIUDAD Y EL DESTINO NO ALCANZABLE
-- DESDE ESTA CIUDAD. EL RESULTADO SE ALMACENA EN LA TABLA pregunta_2d
CREATE TABLE IF NOT EXISTS 'pregunta_2d' (
    from varchar,
    not_reacheable varchar
);

INSERT INTO 'pregunta_2d'
SELECT c1.name as from, c2.name as not_reacheable
	-- DEL PRODUCTO CRUZ city X city
	-- SE TOMAN LOS NOMBRES LAS CIUDADES NO ALCANZABLES
	FROM city as c1
	CROSS JOIN city as c2
	WHERE
	( c1.id, c2.id ) in
    (
        -- DEL PRODUCTO CRUZ city X city
        -- SE EXCLUYEN LAS CIUDADES ALCANZADAS DESDE
        -- CADA CIUDAD OBTENIDA DE LA QUERY ANTERIOR
        SELECT c3.id, c4.id
            FROM city as c3
            CROSS JOIN city as c4
            WHERE c3.id != c4.id
        EXCEPT
        (
        SELECT p1.from_city, p1.to_city
            FROM pregunta_2d_tmp as p1
            GROUP BY p1.from_city, p1.to_city
            ORDER BY p1.from_city, p1.to_city ASC
        )
    );
-- SE ELIMINA LA TABLA TEMPORAL
DROP TABLE pregunta_2d_tmp;