-- -- PREGUNTA 2a
-- -- Se ejecuta la funcion
-- -- shortest_path( origin_city, steps, table_name_out ) sobre
-- -- cada ciudad en la lista de ciudades con maximo una parada (step = 1)

-- SELECT shortest_path( c.id, 1, 'pregunta_2a' )
-- FROM city as c;

-- -- MOSTRAMOS EL RESULTADO
-- SELECT o.name, f.name, p1.price as min_cost, p1.steps, p1.visited as path
-- FROM pregunta_2a as p1
-- JOIN city as o ON o.id = p1.from_city
-- JOIN city as f ON f.id = p1.to_city



-- -- PREGUNTA 2b
-- -- Se ejecuta la funcion
-- -- shortest_path( origin_city, steps, table_name_out ) sobre
-- -- cada ciudad en la lista de ciudades con maximo dos paradas (step = 2)

-- SELECT shortest_path( c.id, 2, 'pregunta_2b' )
-- FROM city as c;

-- -- MOSTRAMOS EL RESULTADO
-- SELECT o.name, f.name, p1.price as min_cost, p1.steps, p1.visited as path
-- FROM pregunta_2b as p1
-- JOIN city as o ON o.id = p1.from_city
-- JOIN city as f ON f.id = p1.to_city

