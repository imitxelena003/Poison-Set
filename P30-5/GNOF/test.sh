directorio_inicio="/home/jfhlewyee/Dropbox/Solicitudes de archivos/PoisonSet/P30-5/"
nof=8
DIR_ORI="$(pwd)"

archivos_nof=()
while IFS= read -r -d $'\0' archivo; do
  if grep -q "(IPNOF)         $nof" "$archivo"; then
  archivos_nof+=("$archivo")
  fi
done < <(find "$directorio_inicio" -type f -name "*.out" -print0)

# Recorrer todos los archivos en el directorio de prueba
for file_test in "${archivos_nof[@]}"; do
    echo $file_test
done

