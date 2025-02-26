# Poison-Set

The benchmark employed here to test NOF approximations was developed by Gould and Dale [Phys. Chem. Chem. Phys., 2022, 24, 6398].
Energies given by the GNOF, PNOF5, and PNOF7 approximations are given for each set separately, along with the reference energies and corresponding errors.
The chemical systems involved in the reactions can be found in the YAML files from https://github.com/stephengdale/poison-set/tree/main

# Para actualizar los archivos

- Colocarse dentro del set, p. ej.
```
cd P30-5
```
- Crear una carpeta y llenarla con los nuevos archivos (el nombre no importa)
```
mkdir new_files
```
- Ejecutar el script best.sh:
```
  ./best.sh
```

> [!TIP]
> - `best.sh` hace un loop sobre PNOF5, PNOF7 y GNOF
>   - Lista todos los archivos *.out en el directorio y subdirectorios del set
>   - Compara la energía de cada archivo con la de la carpeta principal del NOF
>   - Si la energía es menor o el archivo no existe en el directorio principal, copia los archivos.
>
> No importa el orden ni el nombre de los subdirectorios, solo que sean del set correcto.
