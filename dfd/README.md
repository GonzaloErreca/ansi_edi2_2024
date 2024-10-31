Diagrama de Flujo de Datos
==========================

Para generar los DFD, es necesario tener la herramienta `dot`. La misma es parte de [Graphviz](https://graphviz.org/).

Ésta herramienta se puede instalar, en [Ubuntu](https://en.wikipedia.org/wiki/Ubuntu), de la siguiente manera:

```bash
sudo apt install graphviz
```

Una vez instalada, la herramienta, se utiliza de la siguiente manera para generar un DFD (imagen) a partir de un archivo `.dot`:

```bash
dot -Tpng dfd_vet_context.dot > dfd.png
```

Para generar todos los DFD, de una vez, se puede utilizar el siguiente comando:

```bash
for i in $(ls *.dot); do dot -Tpng "${i}" > "$(echo $i | sed -e 's/\.dot//g' -).png"; done
```

## Documentación

- [Introduction to Graphviz](https://www.worthe-it.co.za/blog/2017-09-19-quick-introduction-to-graphviz.html)
- [Graphviz Examples](https://sketchviz.com/graphviz-examples)
- [Graphviz Resources](https://graphviz.org/resources/)
