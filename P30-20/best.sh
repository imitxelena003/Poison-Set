#!/bin/bash

nofs=("PNOF5" "PNOF7" "GNOF")
nofidxs=("5" "7" "8")

DIR="$(pwd)"

# Recorre PNOF5, PNOF7 y GNOF
for ((i = 0; i < 3; i++)); do
  nof="${nofs[$i]}"
  nofidx="${nofidxs[$i]}"

  # Recorrer todos los archivos en el directorio de prueba
  archivos_nof=()
  while IFS= read -r -d $'\0' archivo; do
    if grep -q "(IPNOF)         $nofidx" "$archivo"; then
      archivos_nof+=("$archivo")
    fi
  done < <(find "$DIR" -type f -name "*.out" -print0)

  # Recorrer los archivos extraídos y verificar si E_test < E_ori
  echo "---------------------------------------------------------------------"
  echo "Comparando energías: $nof"
  echo "---------------------------------------------------------------------"
  for file_test in "${archivos_nof[@]}"; do

    # Extraer el nombre del archivo sin la ruta
    filename=$(basename "$file_test")

    # Extraer el valor de E en el archivo de prueba
    E_test=0
    if grep -q "Final NOF Total Energy" "$file_test"; then
      E_test=$(grep "Final NOF Total Energy" "$file_test" | awk '{print $6}')
    fi

    # Construir la ruta del archivo en el directorio principal
    file_ori="$DIR/$nof/$filename"

    E_ori=0
    # Si el archivo existen en el directorio principal
    if [[ -f "$file_ori" ]]; then
      # Extraer el valor de E en el archivo principal
      if grep -q "Final NOF Total Energy" "$file_ori"; then
        E_ori=$(grep "Final NOF Total Energy" "$file_ori" | awk '{print $6}')
      fi
    else
      echo "Archivo original no encontrado: $filename"
    fi

    # Imprimir los valores
    echo "Archivo a probar: $file_test"
    echo "E_test: $E_test"
    echo "E_original: $E_ori"

    ## Compara E_test y E_ori y copia el archivo al directorio principal si E_test < E_ori
    if [[ $(echo "$E_test < $E_ori" | bc -l) -eq 1 ]]; then
      echo "E_test es menor que E_original. Copiando archivos"
      echo "${file_test%.out}".*
      echo "al directorio:"
      echo "$DIR/$nof"
      cp "${file_test%.out}".* "$DIR/$nof"
    fi
    echo "-------------------------"
  done
done
