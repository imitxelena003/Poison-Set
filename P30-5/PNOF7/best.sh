#!/bin/bash

directorio_inicio="/home/jfhlewyee/Dropbox/Solicitudes de archivos/PoisonSet/P30-5/"
nof=7
DIR_ORI="$(pwd)"

archivos_nof=()
while IFS= read -r -d $'\0' archivo; do
  if grep -q "(IPNOF)         $nof" "$archivo"; then
  archivos_nof+=("$archivo")
  fi
done < <(find "$directorio_inicio" -type f -name "*.out" -print0)

# Recorrer todos los archivos en el directorio de prueba
for file_test in "${archivos_nof[@]}"; do
  if [[ -f "$file_test" ]]; then
    # Extraer el nombre del archivo sin la ruta
    filename=$(basename "$file_test")

    # Construir la ruta del archivo correspondiente en el directorio original
    file_ori="$DIR_ORI/$filename"

    # Extraer el valor de E_test
    E_test=0
    if grep -q "Final NOF Total Energy" "$file_test"; then
      E_test=$(grep "Final NOF Total Energy" "$file_test" | awk '{print $6}')
    fi

    # Verificar si el archivo original existe
    E_ori=0
    if [[ -f "$file_ori" ]]; then
      # Extraer el valor de E_ori
      if grep -q "Final NOF Total Energy" "$file_ori"; then
        E_ori=$(grep "Final NOF Total Energy" "$file_ori" | awk '{print $6}')
      fi
    else
      echo "Archivo original no encontrado: $filename"
    fi

    # Imprimir los valores
    echo "Archivo: $filename"
    echo "E_test: $E_test"
    echo "E_ori: $E_ori"

    echo "E_test < E_ori: $(echo "$E_test < $E_ori" | bc -l)"
    ## Comparar E_test y E_ori y copiar el archivo si E_test < E_ori
    if [[ $(echo "$E_test < $E_ori" | bc -l) -eq 1 ]]; then
      echo "E_test es menor que E_ori. Copiando"
      echo "${file_test%.out}".*
      echo "$DIR_ORI"
      cp "${file_test%.out}".* "$DIR_ORI"
    fi
    echo "-------------------------"
  fi
done
