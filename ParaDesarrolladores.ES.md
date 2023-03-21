# Bienvenido a la edición comentada de Makeup

Es mi deseo que MakeUp puede ser utilizado como base para crear más y mejores shaders, es por eso que escribo esta texto explicativo del código fuente.

Los comentarios que encuentres en el mismo espero te sean de ayuda para modificar y/o extender MakeUp de acuerdo a tus necesidades.

¡Feliz edición!

## Organización de los archivos del shader

### shaders/common

Con el propósito de evitar el código duplicado, los diversos shaders que se emplean en las distintas dimensiones de Minecraft hacen referencia a los archivos que se encuentran en este directorio. Es aquí donde se encuentran las rutinas principales, para cada uno de los diferentes tipos de bloques, así como el resto de pasos en la tubería de trabajo de Optifine/Iris.

Los shaders de vertice y fragmento de cada paso se encuentran separados en archivos separados, que podrás identificar claramente por el nombre del archivo en cuestión.

No necesariamente existe aquí un archivo para cada paso o tipo de bloque, pues algunos bloques o pasos comparten muchas cosas en común, y en MakeUp son tratados igual (o casi igual).

Los mejores ejemplos de esto último son solid_blocks_fragment.glsl y solid_blocks_vertex.glsl, que controlan el dibujado de la gran mayoría de los bloques del juego que no sean translúcidos o merezcan una atención muy especial.

El nombre de los archivos intenta ser explícito sobre su contenido o propósito.

### shaders/lang

Los archivos de traducción. Le dan nombre a las opciones en las pantallas de configuración.

### shaders/lib

Aquí se encuentran archivos con rutinas o declaraciones específicas que son empleadas en diversos lugares de las rutinas principales. 

Los archivos que se encuentran en este directorio son tomados como "bibliotecas", y son llamados FUERA de la función principal del shader que los solicita (es decir, que no se insertan dentro de la función main del shader en cuestión). Usualmente porque declaran funciones o valores empleados por quien los solicita.

El nombre de los archivos intenta ser explícito sobre su contenido o propósito.

### shaders/src

Los archivos aquí cumplen un papel similar a los que se encuentran en shaders/lib. La diferencia radica en la forma en que son insertados en el código del shader que los solicita.

En este caso, el código está pensado para ser insertado DENTRO de la función main del shader en cuestión. Son simples retazos de código que, al ser empleados varias veces, sólo están escritos una vez aquí, y son incluidos de forma "sucia" en el código, sin ser funciones estrictamente hablando.

### shaders/textures

Como su nombre lo indica, aquí se almacenan las texturas de las que hace uso el shader.

### shaders/worldX

Las ya conocidas carpetas que alojan a los shaders que corresponden a cada dimensión:

- world0: Overworld
- world-1: Nether
- world1: The End

Los shaders que se emplean para cualquier otra dimensión no especificada son descendientes directos del directorio "shaders".

-----

# Flujo de dibujado principal

## Buffers

Los buffers son utilizados y asignados de la siguiente manera:

- noisetex: Almacena las normales del agua en dos canales, el tercer componente es calculado al momento. (RG8)
- colortex0: Ruido azul (no cargado). (R8)
- colortex1: Buffer principal. Cuando está actvo el DOF, es de cuatro canales, donde el cuarto canal almacena la profundidad de la escena para ser también suavizada por el antialias, y así evitar problemas en cambios de enfoque súbitos por la sacudida de la cámara. (Sin DOF: R11F_G11F_B10F, con DOF: RGBA16)
- colortex2: Almacena el mapa para las nubes en formato "blocky". (R8)
- colortex3: Aquí se almacena el historial empleado por el muestreo temporal. Cuando está actvo el DOF, es de cuatro canales, donde el cuarto canal almacena la profundidad de la escena para ser también suavizada por el antialias, y así evitar problemas en cambios de enfoque súbitos por la sacudida de la cámara. (Sin DOF: R11F_G11F_B10F, con DOF: RGBA16) 
- gaux1: Aquí se almacena una versión de la escena que será empleada en los reflejos y refracciones de espacio de pantalla. Después de ser empleado para ello, se utiliza como auxiliar para almacenar el bloom de la escena. (R11F_G11F_B10F)
- gaux2: Almacena el mapa para las nubes en formato "natural". (R8)
- gaux3: Almacena el valor histórico de autoexposición de la escena. El valor de autoexposición se obtiene haciendo un promedio ponderado con el valor de este canal y el calculado en la escena actual, a fin de hacer una transición de autoexposición gradual en el tiempo. Sí, es un exceso usar un buffer entero para guardar un único valor flotante, pero es lo que hay. Sólo es usado si se usa el método de autoexposición predeterminado. (R16F)
- gaux4: Almacena el color del cielo (sin nubes ni otros objetos), para otorgar el color que deberá emplearse en la niebla (sí, la niebla siempre es del color del "cielo"). De esta forma, los objetos se difuminan y confunden con el cielo a la distancia.

-----

# Pasos generales de dibujado

Esta es sólo una descripción general de los pasos que sigue el dibujado de una escena típica. No tiene todos los detalles, y puede varíar según la dimensión y opciones activadas.

1. Se calcula el color del cielo o distancia infinita en 'prepare'. Este color escribe en dos lugares:
 - colortex1: Se empleará después para escribir ahí los bloques sólidos.
 - gaux4: Este buffer se empleará para extraer de ella el color de la niebla.

2. En gbuffers_skybasic se dibujan elementos como las estrellas sobre el cielo previamente dibujado. Posteriormente se dibujan los elementos del cielo texturizados (gbuffers_skytextured). Todo esto se escribe en colortex1.

3. Los bloques sólidos se crean en los correspondientes programas gbuffer. Aquí se calcula la iluminación de los bloques (sombras incluídas).
El resultado se escribirá en:
 - colortex1

4. En deferred, se calcularán las nubes y la oclusión ambiental. Los resultados se escribirán en:
 - colortex1: Se escribe la escena calculada, el canal "a" almacenará la profundidad (sólo si tiene sentido).
 - gaux1: Se empleará posteriormente como fuente de datos para el calculo de los reflejos y refracciones de espacio de pantalla en el paso siguiente.

5. Se dibujan los bloques translúcidos. Se calculan de nuevo las nubes en baja calidad para ser empleadas en los reflejos. Se lee gaux1 como fuente para las refracciones y reflejos de pantalla. Se sigue empleando el canal alpha para almacenar la profundidad. Los resultados se escriben en:
  - colortex1

6. En Composite se calcula el nivel de autoexposure del cuadro actual, y se pondera con el valor histórico guardado en gaux3. Se calcula también la luz volumétrica, y se prepara el bloom. El auto exposure no toma en cuenta ninguno de estos últimos efectos ni los posteriores.
"Preparar el bloom", significa guardar una versión de la escena actual con el nivel de exposición aplicado, en: gaux1.
Se guarda también el valor calculado de la autoexposición en: gaux3. 

7. En Composite1 se calcula el DOF, y se aplica el Bloom. Para aplicar el Bloom se lee un nivel de mipmap del buffer gaux3 calculado en el paso anterior. El resutado se escribe en: colortex1

8. En Composite2 se calcula el AA y el motion blur. El resultado se escribe en: colortex0. Si el supermuestreo temporal está activo, se escribe el histórico en colortex3.

9. En Final, se aplican efectos de postprocesado, como aberración cromática, la autoexposición, el mapa de tonos, y ayudas para ceguera al color.
Para terminar, la imagen es enviada a la pantalla. 

-----

Revisa el resto de directorios o el código fuente para encontrar información alusiva a ese elemento.
