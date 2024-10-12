Fake REST API
=============

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
prism mock -d openapi.yaml
# ... trabajar ...
deactivate
```
