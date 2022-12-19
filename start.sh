#!/bin/bash


# Variables por defecto
DATABASE_NAME='16-10216'
FILE_NAME='city.csv'
DB_USER='postgres'
SQL_SCRIPT='definition.sql'
SQL_QUERIES='queries.sql'

# Se muestra una cabecera con los creditos
print_usage(){
    printf "Sintaxis:\n$ $(basename $0) [-d DATABASE_NEW_NAME] [-f CITIES_CSV_FILE_NAME] [-u DB_USER] [-w DB_PASSWORD] [-s SQL_SCRIPT] [-q SQL_QUERIES]\n"
    printf '\n'
}
cat header.txt
print_usage
while getopts 'd:f:u:s:q:w:' flag; do
    case "${flag}" in
        d)
            DATABASE_NAME="${OPTARG}"
            ;;
        f)
            FILE_NAME="${OPTARG}"
            ;;
        u)
            DB_USER="${OPTARG}"
            ;;
        w)
            DB_PASSWORD="${OPTARG}"
            ;;
        s)
            SQL_SCRIPT="${OPTARG}"
            ;;
        q)
            SQL_QUERIES="${OPTARG}"
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
done


# Se procede a ejecutar en sesion de psql como usuario (por defecto postgres)
# y se crea la base de datos
printf "\nCreando la base de Datos ${DATABASE_NAME}...\n"
PGPASSWORD=${DB_PASSWORD} psql -U ${DB_USER} -c "CREATE DATABASE \"${DATABASE_NAME}\";" 2> /dev/null

if [ $? -ne 0 ]
    then
        printf  "\nError en el nombre de la base de datos o en el nombre de usuario o clave. \nPor favor verifique.\n"
        exit 10
fi
echo "OK"

# Ejecutando script sql de creacion de tablas
echo Localizando el archivo de creacion de tablas y csv
cat ${SQL_SCRIPT} &> /dev/null && cat ${FILE_NAME} &> /dev/null
if [ $? -ne 0 ]
    then
        printf  "\nError en el archivo de definion de esquema de la base de datos.\n"
        exit 10
fi
echo "OK"

printf "\nEjecutando script de creacion y migracion de tablas sql\n"
PGPASSWORD=${DB_PASSWORD} psql -U ${DB_USER} -d ${DATABASE_NAME} -f ${SQL_SCRIPT} &>/dev/null
if [ $? -ne 0 ]
    then
        printf  "\nError en la ejecucion del script.\n"
        exit 10
fi
echo "OK"

# Ejecucion de Querys solicitadas
echo Localizando el archivo de queries
cat ${SQL_QUERIES} &>/dev/null
if [ $? -ne 0 ]
    then
        printf  "\nError en el archivo de queries.\n"
        exit 10
fi
echo "OK"

printf "\nEjecucion de las Queries solicitadas sobre la base de datos ${DATABASE_NAME}\n"
PGPASSWORD=${DB_PASSWORD} psql -U ${DB_USER} -a -d ${DATABASE_NAME} -f ${SQL_QUERIES} > queries_result.out
echo "OK"