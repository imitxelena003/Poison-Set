# Poison-Set

The benchmark employed here to test NOF approximations was developed by Gould and Dale [Phys. Chem. Chem. Phys., 2022, 24, 6398].
Energies given by the GNOF, PNOF5, and PNOF7 approximations are given for each set separately, along with the reference energies and corresponding errors.
The chemical systems involved in the reactions can be found in the YAML files from https://github.com/stephengdale/poison-set/tree/main

## Instrucciones temporales para analizar los archivos

### Actualizar los archivos de cada set

- Colocarse dentro de la carpeta del set.
- Crear una carpeta y llenarla con los nuevos archivos (el nombre no importa)
- Ejecutar el script best.sh. P. ej.:
``` bash
cd P30-5
mkdir new_files #fill with new files
./best.sh
```


> [!TIP]
> Dentro de la carpeta de cada set:
> - `best.sh` hace un loop sobre PNOF5, PNOF7 y GNOF
>   - Lista todos los archivos *.out en el directorio y subdirectorios
>   - Compara la energía de cada archivo con la de la carpeta principal del NOF (PNOF5, PNOF7, GNOF)
>   - Si la energía del archivo de prueba es menor o el archivo no existe en el directorio principal, copia los archivos.
>
> No importa el orden ni el nombre de los subdirectorios, solo que sean del set correcto.

### Generar el Jupyter Book

>[!NOTE]
> Esto requiere tener instalado Anaconda y Jupyter Book
> ``` bash
> conda create -n jb -y
> conda activate jb
> conda install python
> pip install jupyter-book
> ```

Para construir el book localmente y visualizarlo en el navegador:
``` bash
cd jb
conda activate jb
rm -r _build
jupyter book build .
```

Para subir el Jupyter Book local a internet:
```
ghp-import -n -p -f _build/html
```
