Fake REST API
-------------

A continuación se documentan dos formas de crear un servicio que ejecute una REST API falsa, basada en la documentación OpenAPI (archivo YAML).

Primero hay que crear un entorno virtual donde instalar las herramientas.

```bash
virtualenv venv
source venv/bin/activate
pip install nodeenv
nodeenv -p
deactivate
```

Luego, como primera opción, se puede usar [counterfact](https://github.com/pmcelhaney/counterfact) para crear el servicio de la REST API falsa.

```bash
source venv/bin/activate
npx counterfact@latest openapi.yaml api
# ... trabajar ...
deactivate
```

La segunda opción, para ejecutar la REST API falsa, es usar [prism](https://github.com/stoplightio/prism).

```bash
source venv/bin/activate
# Instalar `prism` (solo una vez)
npm install -g @stoplight/prism-cli
# Ejecutar el servicio con `prism`
prism mock -d openapi.yaml
# ... trabajar ...
deactivate
```

También existe otra herramienta llamada [mockoon](https://github.com/mockoon/mockoon).

```bash
source venv/bin/activate
# Instalar `mockoon` (solo una vez)
npm install -g @mockoon/cli
# Ejecutar el servicio con `mockoon`
mockoon-cli start --data openapi.yaml
# ... trabajar ...
deactivate
```

--------------------------------------------------------------------------------

Pruebas Automatizadas
---------------------

Para correr todas las pruebas automatizadas, ejecutar el script `test-api.sh` de la siguiente manera.

```bash
bash test-api.sh [HOST] [PORT]
```

Donde `[HOST]` y `[PORT]` hacen referencia, respectivamente, al servidor y puerto donde está corriendo el servicio de la API REST.

De querer detener la ejecución de las pruebas en el primer error, se puede usar la variable global `STOP_ON_FAILURE` de la siguiente forma.

```bash
STOP_ON_FAILURE='true' bash test-api.sh [HOST] [PORT]
```
