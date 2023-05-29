#lang eopl

;; Proyecto FLP
;; Grupo: 09


;; Integrantes:
;; Juan Camilo Ortiz Gonzalez - 2023921
;; William Velasco Muñoz - 2042577
;; John Riascos -

;; Enlace al Github: https://github.com/juancortizgonz/FLP_Proyecto

;; Definición de gramática en Backus-Naur Form (BNF) para definir el lenguaje.
;
; <program> ::= <expression>
;               <a-program (exp)>
; <expression> ::= <number> (Numero)
;              ::= <lit-exp> (Datum)
;              ::= <identifier>
;                  <var-exp (id)>
;              ::= <true-value> (True)
;              ::= <false-value> (False)
;              ::= <empty-exp> (null)
;              ::= <primitive> "("{<expression>}*(,)")"
;                  <primapp-exp (prim rands)>
;              ::= <char>
;                  <char-exp>
;              ::= <string>
;                  <string-exp>
;              ::= begin {<expression>}+(;) end
;                  <begin-exp (exp exps)>
;              ::= if "("<expression>")" "{" <expression> "}" else "{" <expression> "}"
;                  <if-exp (cond exp1 exp2)>
;              ::= while "("<expression>")" "{" <expression> "}"
;                  <while-loop-exp (cond exp)>
;              ::= for "(" <identifier> in <expression> ")" "{" <expression> "}"
;                  <for-loop-exp (id data-struct exp)>
;              ::= let {<identifier> = <expression>}* in <expression>
;                  <let-exp (id rands body)>
;              ::= proc ({<identifier>*(,)}) <expression>
;                  <proc-exp (ids body)>
;              ::= (<expression> {<expression>}*)
;                  <app-exp (proc rands)>
;              ::= letrec {<identifier> ({<identifier>}*(,)) "=" <expression>}* in <expression>
;                  <letrec-exp proc-names ids bodies body-letrec>
;              := (hex number {, number}*)
;                 <hex-number>
;              := (oct-number) (oct number {, number}*)
;                 <oct-number>
; <pred-exp> ::= <pred-prim> (<expression>, <expression>)
;                <pred-prim (exp1 exp2)>
;
; <list>     ::= [{<expression>}*(,)]
; <vector>   ::= vect[{expression}*(,)]
; <log> ::= #TODO
;
; <binary-prim> ::= "+"
;                   <add-prim>
;               ::= "-"
;                   <sub-prim>
;               ::= "*"
;                   <mult-prim>
;               ::= "/"
;                   <div-prim>
;               ::= "%"
;                   <mod-prim>
;               ::= "s+"
;                   <concat-prim>
;
; <unary-prim> ::= "length"
;                  <length-prim>
;              ::= "add1"
;                  <add1-prim>
;              ::= "sub1"
;                  <sub1-prim>
;
; <bool-exp> ::= <bool>
;                <simple-bool-exp>
;            ::= <unary-bool-prim> (<bool-exp>)
;                <unary-bool-exp>
;            ::= <binary-bool-prim> (<expression> <expression>)
;                <binary-bool-exp (bool-exp1 bool-exp2)>
;
; <binary-bool-prim> ::= "<" | "<=" | ">" | ">=" | "==" | "!=" | "and" | "or"
; <unary-bool-prim>  ::= not
;                        <not-boolean>
;
;
; <primitive-8> ::= (addX8) +x8
;               ::= (subX8) -x8
;               ::= (multX8) *x8
;
; <primitive-16> ::= (addX16) +x16
;                ::= (subX16) -x16
;                ::= (multX16) *x16
;
; <primitive-32> ::= (addX32) +x32
;                ::= (subX32) -x32
;                ::= (multX32) *x32
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
; Especificación Léxica:

(define lexica
'((blank-space (whitespace) skip)
  (comment ("#" (arbno (not #\newline))) skip)
  (identifier (letter (arbno (or letter digit))) symbol)
  (null ("null") string)
  (number (digit (arbno digit)) number) 
  (number ("-" digit (arbno digit)) number)
  (float (digit (arbno digit)"."digit (arbno digit)) number)
  (float ("-" digit (arbno digit)"."digit (arbno digit)) number)
  (string ("$"(or letter whitespace digit) (arbno (or whitespace letter digit))) string)
  (char ("'"letter"'") symbol)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
; Especificación Sintáctica (Gramática):

(define gramatica

  '(
    (program (expression) a-program)
    
    ; Se incluye un breve comentario especificando el lenguaje de programación base.

    ; var: Creación de variables en Java. Tiene una estructura como "var" <identifier> "=" <expression>
    ; (https://www.arquitecturajava.com/java-var-keyword-y-su-uso-con-jdk10/)
    (expression ("var" (separated-list identifier "=" expression ",") "in" expression) var-exp)
    ;const: Basado en JavaScript. Tiene una estructura como "const" <identifier> "=" <expression>
    ; (https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Statements/const)
    (expression ("const" (separated-list identifier "=" expression ",") "in" expression) const-exp)

    
    ; Tipos de datos

    ; identifier: Basado en JavaScript.
    ; (https://www.w3schools.com/js/js_variables.asp) en la sección JavaScript Identifiers
    (expression (identifier) id-exp)
    ; number: Basado en JavaScript (https://developer.mozilla.org/es/docs/Learn/JavaScript/First_steps/Math)
    (expression (num) num-exp)
    (num (number) number-exp)
    (num (float)  float-exp)
    ;char: Basado en Java. Ejemplo: (https://www.aprendeaprogramar.com/fuentes/view.php?f=java-char)
    (expression (char) char-exp)
    ; string: Basado en Java.
    (expression (string) string-exp)
     ; &: Paso por referencia basado en PHP (https://cybmeta.com/pasar-por-referencia-y-pasar-por-valor-en-php)
    (expression ("&" identifier) ref-val-exp)
    ; print: Impresión en pantalla basada en Python (https://www.w3schools.com/python/ref_func_print.asp)
    (expression ("print("expression")") print-exp)
    ; expr-bool: Basado en JavaScript.
    (expression (expr-bool) bool-exp)
    ;null-exp
    (expression (null) null-exp)

    ;Constructores de Datos Predefinidos

    ; prim: basado en Java, forma de escribir una primitiva.
    (expression ("[" primitive (separated-list expression ",") "]") primitive-exp)
    ; list: Basado en Python (https://www.w3schools.com/python/python_lists.asp)
    (expression ("[" (separated-list expression ",") "]") list-exp)
    ;vect: Basado en Python. Se agrega el identificador "vect" para diferenciar de una lista.
    (expression ("vect["(separated-list expression ",") "]") vector-exp)
    ; log: basado en Java
    ; #TODO: Qué son los registros y cómo se podría representar

    ; Expresiones booleanas.
    (expr-bool (pred-prim "(" expression "," expression ")") pred-bool-exp)
    (expr-bool (binary-bool-prim "(" expression "," expression ")") binary-bool-exp)
    (expr-bool (unary-bool-prim"(" expression")") unary-bool-exp)
    (expr-bool (boolean-value) simple-bool-exp)
    ; Valores booleanos: Basado en Python (https://www.w3schools.com/python/python_booleans.asp)
    (boolean ("True") true-value)
    (boolean ("False") false-value)
    ; pred-prim y binary-bool-prim: Basadas en Python (https://realpython.com/python-bitwise-operators/)
    (pred-prim (">") mayor-prim)
    (pred-prim (">=") mayor-igual-prim)
    (pred-prim ("<") menor-prim)
    (pred-prim ("<=") menor-igual-prim)
    (pred-prim ("==") igual-prim)
    (pred-prim ("!=") diferente-prim)
    (binary-bool-prim ("and") and-bool-prim)
    (binary-bool-prim ("or")  or-bool-prim)
    ; not (boolean): Basado en Python (https://realpython.com/python-not-operator/)
    (unary-bool-prim ("not") not-boolean)
    
    ;Definición de expresiones hexadecimales

    ; Números en base [8, 16, 32]
    (expression ("x8(" (arbno expression)")") hexadecimal-exp)
    (expression ("x16(" (arbno expression)")") hexadecimal-exp)
    (expression ("x32(" (arbno expression)")") hexadecimal-exp)
    
    ;Estructuras de Control

    ; begin.
    (expression ("begin" expression ";" (separated-list expression ";")"end") begin-exp)
    ; if: Basado en Java (https://www.w3schools.com/java/java_conditions.asp)
    (expression ("if" "(" expression")" "{" expression "}" "else" "{" expression "}") if-exp)
    ; while: Basado en Java (https://www.w3schools.com/java/java_while_loop.asp)
    (expression ("while" "("expression")" "{"expression"}" ) while-loop-exp)
    ; for: Basado en Python (https://www.w3schools.com/python/python_for_loops.asp)
    (expression ("for" identifier "in" identifier":" expression) for-loop-exp)
    
    ;Asignación de Variables
    
    ; set.
    (expression ("set" identifier "=" expression) set-exp)

    ; Procedimientos:
    
    ; function: Basado en JavaScript (https://www.w3schools.com/js/js_functions.asp)
    (expression ("function" identifier "("(separated-list identifier ",") ")" "{" expression "}") procedure-exp)
    ; invocar.
    (expression ("invocar" expression "(" (separated-list expression ",") ")") procedure-call-exp)
    
    ; Primitivas para enteros.
    (primitive ("+") add-prim)
    (primitive ("-") sub-prim)
    (primitive ("*") mult-prim)
    (primitive ("%") mod-prim)
    (primitive ("/") div-prim)
    ; Primitivas unarias.
    (primitive ("add1") add1-prim)    
    (primitive ("sub1") sub1-prim)
    ; Primitivas para cadenas (strings).
    (primitive ("s+") concat-prim)
    (primitive ("length") length-prim)

   ; Primitivas para listas, vectores y registros.

    ; Para listas.
    (primitive ("empty-list?") empty-list-prim)
    (primitive ("empty") empty-list)
    (primitive ("is-list?") is-list-prim)
    (primitive ("create-list") create-list-prim)
    (primitive ("head") head-list-prim)
    (primitive ("tail") tail-list-prim)
    (primitive ("append") append-list-prim)
    
    ; Para vectores.
    (primitive ("is-vector?") is-vector-prim)
    (primitive ("ref-vector") vec-ref-prim)
    (primitive ("set-vector") vec-set-prim)
    (primitive ("create-vector") create-vector-prim)
    
    ; Para registros.
    (primitive ("is-log?") is-log-prim)
    (primitive ("ref-log") log-ref-prim)
    (primitive ("set-log") log-set-prim)
    (primitive ("create-log") create-log-prim)
  )
)












