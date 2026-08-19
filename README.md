# Ingeniería de Datos

Repositorio de la asignatura "Ingeniería de Datos". Este repositorio contiene los trabajos realizados en clase y el proyecto del curso, principalmente en formato de notebooks Jupyter.

## Contenido

- trabajos_de_clase/: ejercicios y prácticas realizadas durante las clases, organizados por corte.
- proyecto/: desarrollo del proyecto de la asignatura, organizado por corte.

## Estructura del repositorio

```
Ingenieria_de_datos/
├── trabajos_de_clase/     # Trabajos y ejercicios realizados durante las clases
│   ├── corte_1/
│   │   └── ETL/           # Archivos de ETL del corte 1
│   ├── corte_2/
│   └── corte_3/
└── proyecto/               # Proyecto de la asignatura
    ├── corte_1/
    │   └── ETL/
    ├── corte_2/
    └── corte_3/
```

## Requisitos

- Python 3.8+ (recomendado)
- Jupyter / JupyterLab o Google Colab para abrir los notebooks

Si hay un archivo `requirements.txt` en el repositorio, instale dependencias con:

```bash
pip install -r requirements.txt
```

## Cómo usar

1. Clone el repositorio:

```bash
git clone https://github.com/Davidx34/Ingenieria_de_datos.git
cd Ingenieria_de_datos
```

2. Abra JupyterLab o Jupyter Notebook en la carpeta del repositorio:

```bash
jupyter lab
# o
jupyter notebook
```

3. Navegue a la carpeta correspondiente (trabajos_de_clase/ o proyecto/) y abra el notebook deseado.

También puede abrir los notebooks directamente en Google Colab (si los notebooks no dependen de archivos locales no incluidos en Colab).

## Convenciones

- Cada "corte" agrupa el material correspondiente a ese periodo (corte_1, corte_2, corte_3).
- Las carpetas `ETL/` contienen pipelines, scripts o notebooks relacionados con extracción, transformación y carga de datos.

## Contribuciones

Si quieres contribuir:

1. Haz un fork del repositorio.
2. Crea una rama con tu cambio: `git checkout -b feat/mi-cambio`.
3. Realiza tus cambios y commitea: `git commit -m "Descripción del cambio"`.
4. Abre un Pull Request describiendo los cambios.

## Contacto

Para preguntas o sugerencias, abre un issue o contacta al mantenedor del repositorio.
