
# Mini-Py: Lenguaje de programación

Mini-Py es una lenguaje de programación no tipado, que contiene características de un lenguaje declarativo, imperativo y orientado a objetos.

Este lenguaje de programación se desarrolló como proyecto final del curso Fundamentos de Interpretación y compilación de Lenguajes de Programación, de la Universidad del Valle.




## Autores

-  [Juan Camilo Ortiz Gonzalez (2023921)](https://www.github.com/juancortizgonz)
-  [William Velasco Muñoz (2042577)](https://github.com/WilliamVel16)
- John Freddy Riascos G. (2024464)
## Definición de gramática y especificación léxica

Este proyecto académico usa SLLGEN de Racket, para generar los tipos de datos de forma automatica, dada una especificación sintáctica (gramática) y léxica.

A continuación, se muestra una tabla con los tipos de datos definidos y cómo se trata en el lenguaje de programación usando Scheme.

| Tipo de dato | Tipo de dato en Scheme     | Descripción                |
| :-------- | :------- | :------------------------- |
| `white-sp` | `skip` | Espacio en blanco. Carece de semantica. |
| `comment` | `skip` | Comentario de una línea. Se ignora cualquier línea que comience de esta forma. |
| `identifier` | `symbol` | Identificador que comienza con una letra. Se usa dentro del lenguaje de programación para darle nombre a las variables, entre otros usos. |
| `bool` | `symbol` | Valores booleanos. |
| `txt` | `string` | Cadena de caracteres (string). |
| `number` | `number` | Un número. Contiene los números enteros y flotantes. |

#### Gramática en forma Backus-Naur

En la tabla que se muestra a continuación, se define la gramática de cada instrucción disponible en el lenguaje. Esto se realiza mediante Backus-Naur Form, una notación que permite definir gramáticas libres de contexto de manera formal.

En una sección más abajo, se definen algunos usos de la gramática, con el metodo `scan&parse`, el cual retorna el árbol de sintaxis abstracta.

| Caso | Nombre     | Descripcion |Gramática                       |
| :-------- | :------- | :------- |:-------------------------------- |
| `program`      | `a-program` | Un programa. Estructura base del lenguaje. | `{class-decl}* <expression>` |
| `class-decl`      | `a-class-decl` | Definición de una nueva clase. | `class <identifier> extends <identifier> {field <identifier>}*(;) {<method-decl>}*` |
| `method-decl`      | `a-method-decl` | Declaración de un metodo perteneciente a una clase. | `method <identifier> ({<identifier>}*(,)) <expresion>` |
| `expression`      | `numero-lit` | Tipo de dato número. Enteros y flotantes. | `{class-decl}* <expression>` |
| `expression`      | `var-exp` | Un identificador. Comienza con una letra. | `<number>` |
| `expression`      | `texto-lit` | Una cadena de caracteres (string). | `<txt>` |
| `expression`      | `boolean-expr` | Expresión booleana. | `<expr-bool>` |
| `expression`      | `primapp-un-exp` | Aplicación de primitiva unaria básica. | `<uni-primitive> (<expression>)` |
| `expression`      | `primapp-bi-exp` | Aplicación de primitiva binaria básica. | `<expression> <bi-primitive> <expression>` |
| `expression`      | `prim-list-exp` | Expresión de primitivas para listas. | `<list-prim>` |
| `expression`      | `prim-tuple-exp` | Expresión de primitivas para tuplas. | `<tuple-prim>` |
| `expression`      | `prim-registro-exp` | Expresión de primitivas para registros. | `<regs-prim>` |
| `expression`      | `if-exp` | Expresión condicional. | `if <expression> : <expression> else <expression>`|
| `expression`      | `proc-exp` | Declaración de nuevo procedimiento. | `lambda ({<identifier>}*(,)) : <expression>`|
| `expression`      | `app-exp` | Evaluar/invocar expresiones. | `call (<expression> (<expression>)*(,))`|
| `expression`      | `letrec-exp` | Estructura let para metodos recursivos. | `letrec {<identifier> ({<identifier>}*(,)) = <expression>}* {<expression>}`|
| `expression`      | `constanteLocal-exp` | Definición de constantes locales (inmutables). | `final ({<identifier> = <expression>}+(;)) {<expression>}`|
| `expression`      | `variableLocal-exp` | Definición de variables locales (mutables). | `var ({<identifier> = <expression>}+(;)) {<expression>}`|
| `expression`      | `lista` | Definición de la estructura de datos lista. | `[{<expression>}*(,)]`|
| `expression`      | `tupla` | Definición de la estructura de datos tupla. | `tupla({<expression>}*(,))`|
| `expression`      | `registro` | Definición de la estructura de datos registro. | `{{<identifier> = <expression>}+(;)}`|
| `expression`      | `begin-exp` | Expresión para la instrucción begin. | `begin {{<expression>}+(;)}end`|
| `expression`      | `print-exp` | Expresión para imprimir en pantalla. | `print(<expression>)`|
| `expression`      | `for-exp` | Definición de un ciclo For. | `for <identifier> = <expression> <for-way> <expression> : <expression> end`|
| `expression`      | `while-exp` | Definición de un ciclo While. | `while <expression> : <expression>`|
| `expression`      | `base-exp` | Definición de estructura para números hexadecimales. | `base <expression>({<expression>}*)`|
| `expression`      | `updateVar-exp` | Expresión para actualización del valor de una variable mutable. | `set! <identifier> = <expression>`|
| `expression`      | `block-exp` | Expresión para creación de bloques de código. | `block {{<expression>}+(;)}`|
| `expression`      | `variableLocal-exp` | Definición de variables locales (mutables). | `var ({<identifier> = <expression>}+(;)) {<expression>}`|
| `expression`      | `new-object-exp` | Creación de una nueva instancia de una clase (objeto). | `new <identifier> ({<expression>}+(,))`|
| `expression`      | `super-call-exp` | Llamado a un método de la super clase. | `super <identifier> ({<identifier>}+(,))`|
| `expression`      | `method-app-exp` | Llamado a un metodo de la clase. | `send <expression> <identifier> ({<expression>}+(,))`|
| `expr-bool`      | `comp-pred` | Aplicación de predicado sobre dos expresiones. | `<pred-prim> (<expression>,<expression>)`|
| `expr-bool`      | `comp-bool-bin` | Aplicación de primitiva binaria sobre booleanos. | `<oper-bin-bool> (<expr-bool>,<expr-bool>)`|
| `expr-bool`      | `booleano-lit` | Expresión booleana simple. | `<bool>`|
| `expr-bool`      | `comp-bool-un` | Aplicación de primitiva unaria sobre un booleano. | `<oper-un-bool> (<expr-bool>)`|
| `bi-primitive`      | `primitiva-suma` | Definición de la primitiva suma. | `+`|
| `bi-primitive`      | `primitiva-resta` | Definición de la primitiva resta. | `~`|
| `bi-primitive`      | `primitiva-multi` | Definición de la primitiva multiplicación. | `*`|
| `bi-primitive`      | `primitiva-div` | Definición de la primitiva división. | `/`|
| `bi-primitive`      | `primitiva-elmodulo` | Definición de la primitiva modulo. | `mod`|
| `bi-primitive`      | `primitiva-concat` | Definición de la primitiva concatenación. | `concat`|
| `uni-primitive`      | `primitiva-add1` | Definición de la primitiva add1. | `add1`|
| `uni-primitive`      | `primitiva-sub1` | Definición de la primitiva sub1. | `sub1`|
| `uni-primitive`      | `primitiva-longitud` | Definición de la primitiva longitud. | `longitud`|
| `pred-prim`      | `prim-bool-menor` | Definición del predicado menor que. | `<`|
| `pred-prim`      | `prim-bool-mayor` | Definición del predicado mayor que. | `>`|
| `pred-prim`      | `prim-bool-menor-igual` | Definición del predicado menor o igual que. | `<=`|
| `pred-prim`      | `prim-bool-mayor-igual` | Definición del predicado mayor o igual que. | `>=`|
| `pred-prim`      | `prim-bool-equiv` | Definición del predicado de equivalencia. | `==`|
| `pred-prim`      | `prim-bool-diff` | Definición del predicado diff. | `<>`|
| `oper-bin-bool`      | `prim-bool-conj` | Representación de la conjunción lógica. | `and`|
| `oper-bin-bool`      | `prim-bool-disy` | Representación de la disyunción lógica. | `or`|
| `oper-un-bool`      | `prim-bool-neg` | Representación de la negación lógica. | `not`|
| `list-prim`      | `prim-make-empty-list` | Constructor recursivo de una lista que extiende de una lista vacía. | `empty-lst ()`|
| `list-prim`      | `prim-empty-list` | Verificación de una lista vacía. | `is-empty-lst?`|
| `list-prim`      | `create-lst` | Creación de una nueva lista. | `create-lst({<expression>}*(,))`|
| `list-prim`      | `prim-list?-list` | Predicado de verificación de tipo lista. | `lst?(<expression>)`|
| `list-prim`      | `prim-head-list` | Retorna la cabeza de una lista. | `head-lst(<expression>)`|
| `list-prim`      | `prim-tail-list` | Retorna la cola de una lista. | `tail-lst(<expression>)`|
| `list-prim`      | `prim-append-lst` | Adjunta una lista al cuerpo de otra lista. | `append-lst(<expression,<expression>)`|
| `list-prim`      | `prim-ref-list` | Retorna la referencia de una posición de la lista. | `ref-lst(<expression,<expression>)`|
| `list-prim`      | `prim-set-list` | Modifica el valor de una posición de la lista. | `set-lst(<expression>,<expression>,<expression>)`|
| `tuple-prim`      | `prim-make-empty-tuple` | Constructor recursivo de una tupla que extiende de una tupla vacía. | `empty-tuple ()`|
| `tuple-prim`      | `prim-empty-tuple` | Predicado de una tupla vacía. | `is-empty-tuple?(<expression>)`|
| `tuple-prim`      | `prim-make-tuple` | Crea una nueva tupla con los elementos dados. | `create-tuple({<expression>}+(,))`|
| `tuple-prim`      | `prim-tuple?-tuple` | Verifica si la expresión dada es una tupla. | `tuple?`|
| `tuple-prim`      | `prim-head-tuple` | Retorna la cabeza de una tupla. | `head-tuple(<expression>)`|
| `tuple-prim`      | `prim-tail-tuple` | Retorna la cola de una tupla. | `tail-tuple(<expression>)`|
| `tuple-prim`      | `prim-ref-tuple` | Retorna la referencia de una posición de la tupla. | `ref-tuple(<expression>,<expression>)`|
| `regs-prim`      | `prim-regs?-registro` | Verifica si la expresión dada es un registro. | `reg?(<expression>)`|
| `regs-prim`      | `prim-make-registro` | Crea un registro con las parejas llave valor dadas. | `create-reg({<identifier> = <expression>}+(,))`|
| `regs-prim`      | `prim-ref-registro` | Retorna la referencia de una posición del registro. | `ref-reg(<expression>,<expression>)`|
| `regs-prim`      | `prim-set-reg` | Asigna un valor en una posición dada del registro. | `set-reg(<expression>,<expression>,<expression>)`|









