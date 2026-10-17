<div align = center>

# Fowl Play

Patos sobre una marisma, un perro en la hierba y tres cartuchos: el juego de
pistola de luz de los ochenta, jugado con el ratón, un mando o un dedo. Escrito
en [pleamar].

<img src="assets/marsh.webp" width="49%" alt="Un pato volando sobre la marisma, el marcador sobre la tierra"> <img src="assets/dog.webp" width="49%" alt="El perro enseñando un pato que encontró en la hierba">

<sub>*In English: [README.md](README.md).*</sub>

</div>

> [!IMPORTANT]
> **Juego de fans no oficial.** No lo ha hecho, aprobado ni respaldado
> Nintendo, y no lleva ningún archivo de otro juego: cada dibujo lo hacen los
> scripts de `art/`, cada sonido es un tono hecho mientras se juega y cada
> melodía es suya. Gratis para jugar y compartir, **no para vender**. Mira
> [NOTICE.md](NOTICE.md).

## Jugar

```sh
git clone https://github.com/k4ditano/fowl-play
cd fowl-play
./play.sh
```

Necesita [pleamar] 0.4.14 o más nuevo (trae su propia fuente y toca sus
melodías con notas que mantienen el tiempo a la muestra) y cualquier compositor
Wayland. La ventana puede ser tan grande como quieras: la imagen, dibujada a los
256 × 240 de la consola, crece un número entero de veces y sigue nítida.

| | |
| --- | --- |
| **Juego A** | un pato cada vez, diez por ronda |
| **Juego B** | dos patos a la vez |
| **Juego C** | platos, de dos en dos, lanzados lejos de ti |

Tres cartuchos por pato (por pareja en B y C). Acierta bastantes de los diez
—seis en las primeras rondas, los diez desde la ronda 20— o esa ronda será la
última. Los diez dan un premio. El pato negro es el más lento y el que menos
vale; el rojo, el más rápido y el que más. Todos vuelan más rápido cada ronda.

| | |
| --- | --- |
| Ratón | apuntar y hacer clic: la pistola |
| Mando | el stick izquierdo mueve una mira, A dispara, Start pausa |
| Tableta | toca donde está el pato (con `pleamar-wm remote`) |
| ↑ ↓ y Enter | elegir juego en la portada |
| P o Esc | pausa; Q, en pausa, vuelve a la portada |
| M | sonido sí o no |
| F | el destello de la pistola sí o no |

**El destello.** Al apretar el gatillo la pantalla se pone negra un fotograma y
luego enseña los blancos como recuadros blancos otro más: así sabía la pistola
de luz adónde apuntaba. Aquí el ratón ya lo sabe, pero se mantiene porque era
parte del juego. F lo quita.

## Por dentro

- `fowl.plm` es la escena: la marisma, el campo de tiro, el marcador y la
  portada, dibujados con lo que dice la lógica.
- `fowl.luau` y `logic/` son la lógica, en pasos de un sesentavo de segundo
  como los contaba la consola: `marsh.luau` (el perro y los patos),
  `range.luau` (los platos), `board.luau` (el marcador y el final de ronda) y
  `music.luau` (los sonidos y las melodías, escritas como notas).
- `art/make.py` dibuja todas las imágenes en `pieces/`: los patos letra a letra
  (`ducks.py`), el perro con formas y un contorno alrededor (`dog.py`) y la
  marisma, el campo y las piezas pequeñas (`field.py`).

## Licencia

El código y los scripts de dibujo: MIT ([LICENSE](LICENSE)). La fuente, Press
Start 2P: SIL Open Font License 1.1 ([fonts/OFL.txt](fonts/OFL.txt)).

[pleamar]: https://github.com/k4ditano/pleamar
