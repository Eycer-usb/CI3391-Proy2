# Consultas de Bases de datos Proyecto 2 CI3391 – Taller de Bases de Datos

# Intrucciones de Ejecucion
Inicialmente se le debe dar permiso de ejecucion al script start.sh
para esto ejecute el siguiente comando ubicado en el directorio raiz del proyecto:

$ chmod +x start.sh

Ya se puede ejecutar el script.

## Descripcion

Con esto ya el archivo start.sh tendra permiso de ejecucion y 
se puede ejecutar con la siguiente sintaxis

$ ./start.sh [-d database_name] [-f csv_file] [-u db_username] \
    [-s sql_script.sql] [-q queries.sql] [-w database_password]

Por defecto la base de datos se llamara 16-10216 (se creara), el nombre del usuario de la base de datos por defecto es postgres y ademas el nombre del script sql por defecto es definition.sql. Al finalizar la importacion se ejecutara el script determinado por la flag -q (por defecto queries.sql)

### OJO -> Las respuestas a las preguntas se guardan como tablas de la base de datos

## Nota en caso de error
En caso de error similar al siguiente:

psql: error: connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  Peer authentication failed for user "postgres"

Se debe editar el contenido del archivo pg_hba.conf (ubicado en un ruta similar a /etc/postgresql/14/main/) y sustituir el metodo peer a md5 de la linea siguiente

local   all             postgres                                peer

quedando...

local   all             postgres                                md5

## Nota de otros archivos
- error.log almacena los errores de la ejecucion de las queries
- queries_result contiene la salida estandar de la ejecucion del script y de la query
- city.csv contiene el listado de las 100 ciudades mas pobladas del mundo
- header.txt es la cabecera con los creditos al inicio de la ejecucion del script de bash
- definition.sql tiene la definicion de las tablas maestras de la base de datos asi como la definicion de procedimientos y funciones
- queries.sql son las queries solicitadas en el documento
- Trabajo2.pdf es el enunciado recibido por el profesor.

