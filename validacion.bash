#!/bin/bash

# SCRIPT DE VALIDACIÓN

COMPROBAR_COMANDOS=("node" "npm" "jq" "git")


# Comprueba si el sistema operativo se parece a un entorno Windows (Git Bash, Cygwin, etc.).
if [[ "$(uname)" == CYGWIN* || "$(uname)" == MINGW* ]]; then
    # En Windows, añadimos 'curl.exe'
    COMPROBAR_COMANDOS+=("curl.exe")
else
    # En Linux/macOS, añadimos 'curl'
    COMPROBAR_COMANDOS+=("curl")
fi

# Paquetes npm globales que se deben poder ejecutar como comandos (como nodemon)
COMPROBAR_NPM_GLOBAL=("nodemon")

# Lista de carpetas (directorios) que deben existir en la ubicación donde se ejecuta el script.
CARPETAS=("scripts" "src")

# Lista de ficheros (archivos regulares) que deben existir.
FICHEROS=(".gitignore" ".env.example")

# Contador de elementos que SÍ están instalados/existen (inicializado a cero)
COUNT=0

# Cálculo del número TOTAL de elementos a verificar para el resumen final.
# ${#ARRAY[@]} para obtener la longitud de un array.
TOTAL_ELEMENTOS=$(( ${#COMPROBAR_COMANDOS[@]} + ${#COMPROBAR_NPM_GLOBAL[@]} + ${#CARPETAS[@]} + ${#FICHEROS[@]} ))




# FUNCIONES

# Función para verificar si un programa está instalado y es ejecutable.
check_tool() {
    local TOOL_NAME=$1 # 'local' asegura que la variable solo exista dentro de la función. $1 es el primer argumento pasado.
    echo -n "  Verificando $TOOL_NAME... " # 'echo -n' evita el salto de línea para escribir el resultado a continuación.

    # 'command -v' busca el ejecutable en el PATH. Si lo encuentra, devuelve un código de salida 0 (éxito).
    # >/dev/null 2>&1 silencia toda la salida del comando, evitando mensajes innecesarios en la consola.
    if command -v "$TOOL_NAME" >/dev/null 2>&1; then
        echo "✅ OK."
        COUNT=$((COUNT + 1))
    else
        echo "❌ FALTA! Instala $TOOL_NAME."
    fi
}

# Función para verificar si una carpeta/directorio existe.
check_dir() {
    local DIR_NAME=$1
    echo -n "  Verificando Carpeta '$DIR_NAME'... "

    # [ -d "$DIR_NAME" ] es la condición de prueba: -d significa "existe y es un Directorio".
    if [ -d "$DIR_NAME" ]; then
        echo "✅ OK."
        COUNT=$((COUNT + 1))
    else
        echo "❌ FALTA! Crea la carpeta '$DIR_NAME'."
    fi
}

# Función para verificar si un archivo/fichero existe.
check_file() {
    local FILE_NAME=$1
    echo -n "  Verificando Archivo '$FILE_NAME'... "

    # [ -f "$FILE_NAME" ] es la condición de prueba: -f significa "existe y es un Fichero regular".
    if [ -f "$FILE_NAME" ]; then
        echo "✅ OK."
        COUNT=$((COUNT + 1))
    else
        echo "❌ FALTA! Crea el archivo '$FILE_NAME'."
    fi
}




# VERIFICACIONES

echo "--- 1. VERIFICANDO COMANDOS DE SISTEMA ---"

# Bucle For: Itera sobre cada elemento del array COMPROBAR_COMANDOS.
# "${COMPROBAR_COMANDOS[@]}" expande el array a una lista de elementos (ej: node npm jq git...).
for COMANDO in "${COMPROBAR_COMANDOS[@]}"; do
    check_tool "$COMANDO" # Llama a la función de verificación de comandos para cada elemento.
done


# Bucle For: Itera sobre el array de paquetes globales de npm (como nodemon).
for PAQUETE in "${COMPROBAR_NPM_GLOBAL[@]}"; do
    check_tool "$PAQUETE" # Se usa la misma función, asumiendo que está en el PATH.
done

echo -e "\n--- 2. VERIFICANDO CARPETAS ---"
# El '-e' permite interpretar caracteres especiales como \n (salto de línea).


# Bucle For: Itera sobre cada nombre de carpeta en el array CARPETAS.
for CARPETA in "${CARPETAS[@]}"; do
    check_dir "$CARPETA" # Llama a la función de verificación de directorios.
done

echo -e "\n--- 3. VERIFICANDO FICHEROS ---"


# Bucle For: Itera sobre cada nombre de fichero en el array FICHEROS.
for FICHERO in "${FICHEROS[@]}"; do
    check_file "$FICHERO" # Llama a la función de verificación de archivos.
done




# RESULTADO

echo -e "\n--- RESUMEN FINAL ---"

# Condición final: Compara el número de elementos encontrados (COUNT) con el total (TOTAL_ELEMENTOS).
# El test '-eq' significa "es igual a" (equal to).
if [ "$COUNT" -eq "$TOTAL_ELEMENTOS" ]; then
    echo "🎉 ¡ÉXITO! $COUNT/$TOTAL_ELEMENTOS elementos están correctos. El entorno está listo."
    exit 0 # El código de salida 0 indica que el script terminó sin errores.
else
    echo "🛑 ¡ATENCIÓN! Se encontraron fallos: $COUNT de $TOTAL_ELEMENTOS elementos son correctos."
    echo "Por favor, revisa los puntos marcados con ❌ y las dependencias de dotenv si aplica."
    exit 1 # El código de salida 1 indica que el script terminó con errores/fallos.
fi




