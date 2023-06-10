#lang eopl

; Proyecto FLP: Mini-Py
;
;; Mini-Py es un lenguaje de programación no tipado, con características
;; de un lenguaje declarativo, imperativo y orientado a objetos.
;; La sintaxis del lenguaje es una recolección de sintaxis de otros
;; lenguajes populares como Java, C++ o Python. La mayor parte de la
;; semantica se realizó teniendo como base Python.
;;
;; Toda la documentación y otra información de interés se encuentra en
;; el archivo README del GitHub.
;; https://github.com/juancortizgonz/FLP_Proyecto/


; Integrantes del grupo:
;; Juan Camilo Ortiz G. - 2023921
;; William Velasco M. - 2042577
;; John Freddy Riascos G. - #TODO
;
;; Profesor: Robinson A. Duque, Ph.D

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Definición de la gramática en Forma Backus-Naur:
;;
;; <programa> ::= <expresion>
;;                (un-programa (exp))
;;            ::= {<class-decls>}* <expresion>
;;                (un-programa-oo (class-decls body))
;; <expresion> ::= <identificador>
;;                 (id-exp (id))
;;             ::= var <identificador> = <expresion> {<identificador> = <expresion>}*(,) in <expresion>
;;                 (var-exp (ids vals body))
;;             ::= const <identificador> = <expresion> {<identificador> = <expresion>}*(,) in <expresion>
;;                 (const-exp (ids vals body))
;;             ::= rec {<identificador> ({<identificador>)}*(,)) = <expresion>}* in <expresion>
;;                 (rec-exp (id params val body))
;;             ::= <numero-entero>
;;                 (int-exp (num))
;;             ::= <numero-flotante>
;;                 (float-exp (num))
;;             ::= <hexadecimal>
;;                 (hexadecimal)
;;             ::= <cadena>
;;                 (string-exp (str))
;;             ::= <bool>
;;                 (bool-exp (bool))
;;             ::= <lista>
;;                 (list-exp (lst))
;;             ::= <tupla>
;;                 (tuple-exp (tpl))
;;             ::= <registro>
;;                 (register-exp (log))
;;             ::= <expr-bool>
;;                 (boolean-app-exp (expr-bool))
;;             ::= begin {<expresion>}+(;) end
;;                 (begin-exp (exps))
;;             ::= if <expr-bool> then <expresion> [ else <expresion> ] end
;;                 (if-exp (cond-exp true-exp false-exp))
;;             ::= while <expr-bool> do <expresion> done
;;                 (while-exp (cond-exp body))
;;             ::= for <identificador> in {<lista> | <tupla> | <registro>} do <expresion> done
;;                 (for-exp (id data-struct body))
;;             ::= <numero-entero> <primitiva-binaria-enteros> <numero-entero>
;;                 (prim-bin-int-exp (num1 prim-bin-int num2))
;;             ::= <primitiva-unaria-enteros> ( <numero-entero> )
;;                 (prim-un-int-exp (prim-un-int num))
;;             ::= <numero-flotante> <primitiva-binaria-flotantes> <numero-flotante>
;;                 (prim-bin-float-exp (num1 prim-bin-float num2))
;;             ::= <primitiva-unaria-flotantes> ( <numero-flotante> )
;;                 (prim-un-float-exp (prim-un-float num))
;;             ::= <primitiva-hexa> ( <hexadecimal> )
;;                 (prim-hexa-exp (prim hexa))
;;             ::= <primitiva-binaria-listas>
;;                 (prim-bin-list-exp)
;;             ::= <primitiva-unaria-listas>
;;                 (prim-un-list-exp)
;;             ::= <primitiva-listas>
;;                 (prim-list-exp)
;;             ::= <primitiva-binaria-tuplas>
;;                 (prim-bin-tuple-exp)
;;             ::= <primitiva-unaria-tuplas>
;;                 (prim-un-tuple-exp)
;;             ::= <primitiva-tuplas>
;;             ::= <primitiva-binaria-registros>
;;                 (prim-bin-register-exp)
;;             ::= <primitiva-unaria-registros>
;;                 (prim-un-register-exp)
;;             ::= <primitiva-registros>
;;                 (prim-register-exp)
;;             ::= <primitiva-unaria-cadenas> ( <cadena> )
;;                 (prim-un-string-exp (str))
;;             ::= <primitiva-binaria-cadenas> ( <cadena>, <cadena> )
;;                 (prim-bin-string-exp (str1 str2))
;;             ::= proc ( {<identificador>}*(,) ) <expresion>
;;                 (proc-exp (ids body))
;;             ::= ( <expresion> {<expresion>}* )
;;                 (app-exp (rator rands))
;;             ::= letrec {<identificador> ( {<identificador>}*(,) ) = <expresion>}* in <expresion>
;;                 (letrec-exp (proc-names ids bodies letrec-body))
;;             ::= set <identificador> = <expresion>
;;                 (varassign-exp (ids rhs-exp))
;;             ::= new <identificador> ( {<expresion>}*(,) )
;;                 (new-object-exp (class-name rands))
;;             ::= send <expresion> <identificador> ( {<expresion>}*(,) )
;;                 (method-app-exp (obj-exp method-name rands))
;;             ::= super <identificador> ( {<expresion>}*(,) )
;;                 (super-call-exp (method-name rands))
;; <class-decl> ::= class <identificador> extends <identificador> { {field <identificador>}*(;) {<method-decl>}*(;) }
;;                  (a-class-decl (class-name super-name fields-ids method-decls))
;; <method-decl> ::= method <identificador> ( {<identificador>}*(,) ) <expresion>
;;                   (a-method-decl (method-name ids body))
;; <identificador> ::= letter {letter | digit | SchemeTextSymbol}*
;;                     (identificador (id))
;; <numero-entero> ::= digit {digit}*
;;                     (int-number (num))
;;                 ::= - digit {digit}*
;;                     (negative-int-number (num))
;; <numero-flotante> ::= digit {digit}* . digit {digit}*
;;                       (float-number (num))
;;                   ::= - digit {digit}* . digit {digit}*
;;                       (negative-float-number (num))
;; <hexadecimal> ::= ( <numero-entero> {<numero-entero>}* )
;;                   (hexadecimal-base10 (nums))
;;               ::= x8 ( <numero-entero> {<numero-entero>}* )
;;                   (hexadecimal-octal (nums))
;;               ::= x16 ( <numero-entero> {<numero-entero>}* )
;;                   (hexadecimal-base16 (nums))
;;               ::= x32 ( <numero-entero> {<numero-entero>}* )
;;                   (hexadecimal-base32 (nums))
;; <cadena> ::= " {digit | letter | SchemeTextSymbol}* "
;;              (string-lit)
;; <bool> ::= True
;;            (true-boolean)
;;        ::= False
;;            (false-boolean)
;; <lista> ::= [ {<expresion>}*(;) ]
;;             (list (exps))
;; <tupla> ::= tuple[ {<expresion>}*(;) ]
;;             (tuple (exps))
;; <registro> ::= { {<identificador> = <expresion>}+(;) }
;;                (register (ids exps))
;; <expr-bool> ::= <pred-prim> ( <expresion>, <expresion> )
;;                 (pred-prim-app (prim exp1 exp2))
;;             ::= <oper-bin-bool> ( <expr-bool>, <expr-bool> )
;;                 (oper-bin-app (bin-oper exp1 exp2))
;;             ::= <oper-un-bool> ( <expr-bool> )
;;                 (oper-un-bool (un-oper exp))
;;             ::= <bool>
;;                 (simple-bool (bool))
;; <pred-prim> ::= < | > | <= | >= | != | <>
;; <oper-bin-bool> ::= and | or
;; <oper-un-bool> ::= not
;; <primitiva-binaria-enteros> ::= + | - | * | / | %
;; <primitiva-unaria-enteros> ::= add1 | sub1
;; <primitiva-binaria-flotantes> ::= + | - | * | / | %
;; <primitiva-unaria-flotantes> ::= add1 | sub1
;; <primitiva-hexa> ::= + | - | * | add1 | sub1
;; <primitiva-binaria-listas> ::= append ( <lista>, <lista> )
;;                                (append-list-prim (list1 list2))
;; <primitiva-unaria-listas> ::= empty-list? ( <lista> )
;;                               (empty-list?-prim (lst))
;;                           ::= list? ( <lista> )
;;                               (is-list?-prim (lst))
;;                           ::= get-head ( <lista> )
;;                               (head-list-prim (lst))
;;                           ::= get-tail ( <lista> )
;;                               (tail-list-prim (lst))
;;                           ::= ref-list ( <lista> )
;;                               (ref-list-prim (lst))
;;                           ::= create-list ( <numero-entero> {<numero-entero>}*(;) )
;;                               (create-list-prim (nums))
;; <primitiva-listas> ::= set-list ( <lista>, <numero-entero>, <numero-entero> )
;;                        (set-list-prim (lst index val))
;; <primitiva-binaria-tuplas> ::= append ( <tupla>, <tupla> )
;;                                (append-tuple-prim (t1 t2))
;; <primitiva-unaria-tuplas> ::= empty-tuple? ( <tupla> )
;;                               (empty-tuple?-prim (t))
;;                           ::= tuple? ( <tupla> )
;;                               (is-tuple?-prim (t))
;;                           ::= get-head ( <tupla> )
;;                               (head-tuple-prim (t))
;;                           ::= get-tail ( <tupla> )
;;                               (tail-tupla-prim (t))
;;                           ::= ref-tuple ( <tupla> )
;;                               (ref-tuple-prim (t))
;;                           ::= create-tuple ( <numero-entero> {<numero-entero>}*(;) )
;;                               (create-tuple-prim (nums))
;; <primitiva-tuplas> ::= set-tuple ( <tupla>, <numero-entero>, <numero-entero> )
;;                        (set-tuple-prim (t index val))
;; <primitiva-binaria-registros> ::= append ( <registro>, <registro> )
;;                                (append-register-prim (r1 r2))
;; <primitiva-unaria-registros> ::= register? ( <registro> )
;;                               (is-register?-prim (r))
;;                           ::= ref-register ( <registro> )
;;                               (ref-register-prim (r))
;;                           ::= create-register ( <numero-entero> {<numero-entero>}*(;) )
;;                               (create-register-prim (nums))
;; <primitiva-registros> ::= set-register ( <registro>, <numero-entero>, <numero-entero> )
;;                        (set-register-prim (r index val))
;; <primitiva-unaria-cadenas> ::= length
;; <primitiva-binaria-cadenas> ::= concat

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Especificación Léxica:
(define lexica
'((white-sp
   (whitespace) skip)
  (comment
   ("%" (arbno (not #\newline))) skip)
  (identifier
   (letter (arbno (or letter digit "?" "." "-" "_"))) symbol)
  (bool
   ((or "@T" "@F")) symbol)
  (txt
   ("\"" (arbno (or letter digit whitespace "," "." ":" "-")) "\"") string)
  (number
   (digit (arbno digit)) number)
  (number
   ("-" digit (arbno digit)) number)
  (number
   (digit (arbno digit) "." (arbno digit)) number)
  (number
   ("-" digit (arbno digit) "." (arbno digit)) number)
  ))


;Especificación Sintáctica (Gramática):
(define gramatica
  '(
    ;; Program
    (program ((arbno class-decl) expression) a-program)

    ;; Expression
    
    ; Tipos de datos básicos
    (expression (number) numero-lit)
    (expression (identifier) var-exp)
    (expression (txt)  texto-lit)
    (expression (expr-bool) boolean-expr)

    ; Aplicación de primitivas básicas
    (expression (uni-primitive "(" expression ")") primapp-un-exp)
    (expression ("(" expression bi-primitive expression ")") primapp-bi-exp)

    ; Aplicación de primitivas para otras estructuras de datos [list, tuple, registers]
    (expression (list-prim) prim-list-exp)
    (expression (tuple-prim) prim-tuple-exp)
    (expression (regs-prim) prim-registro-exp)
    
    ; Condicional if. La sintaxis está basada en Python (https://www.w3schools.com/python/python_conditions.asp)
    (expression ("if" expression ":" expression "else" expression) if-exp)

    ; Procedimiento. La sintaxis está basada en Python, se definen como funciones anonimcas basadas en Lambda
    ; (https://www.programiz.com/python-programming/anonymous-function)
    (expression ("lambda" "(" (separated-list identifier ",") ")" ":" expression) proc-exp)

    ; Evaluar/invocar expresiones
    (expression ("call" "(" expression "(" (separated-list expression ",") ")" ")") app-exp)

    ; Let recursivo (letrec)
    (expression ("letrec" (arbno identifier "(" (separated-list identifier ",") ")" "=" expression)  "{" expression "}") letrec-exp)

    ; Definición de constantes. La sintaxis se basa en Java, para expresiones inmutables
    ; (https://www.scaler.com/topics/constant-in-java/)
    (expression ("final" "(" (separated-list identifier "=" expression ";") ")""{" expression "}") constanteLocal-exp)

    ; Definición de variables mutables con var. La sintaxis está basada en JavaScript
    ; (https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/var)
    (expression ("var" "(" (separated-list identifier "=" expression ";") ")""{" expression "}") variableLocal-exp)

    ; Tipo de dato lista. La sintaxis está basada en Python
    ; (https://www.w3schools.com/python/python_lists.asp)
    (expression ("["(separated-list expression ",") "]") lista)

    ; Tipo de dato tupla. La sintaxis se basa en Python
    ; (https://www.w3schools.com/python/python_tuples.asp)
    (expression ("tupla("(separated-list expression ",") ")") tupla)

    ; Tipo de dato registro. La sintaxis se basa en Python, en el tipo de dato Diccionario
    ; (https://www.w3schools.com/python/python_dictionaries.asp)
    (expression ("{"identifier ":" expression (arbno ";" identifier ":" expression) "}") registro)

    ; Bloque begin para expresiones
    (expression ("begin" "{" expression (arbno ";" expression) "}" "end") begin-exp)
    
    ; print para imprimir en pantalla. Basado en Python.
    (expression ("print" "(" expression ")") print-exp)
    
    ; Ciclo for. Basado en for loop de Python, con ligeras modificaciones
    (expression ("for" identifier "=" expression for-way expression ":" expression "end") for-exp)
    ; Variantes para recorrido de ciclo for
    (for-way ("to") to)
    (for-way ("downto") downto)
    
    ; Ciclo while. La sintaxis se basa en Python
    ; ()
    (expression ("while" expression ":" expression) while-exp)
      
    ; Expresión para base de número hexadecimales
    (expression ("base" expression "(" (arbno expression) ")") base-exp)
    
    ; Set de un valor mutable
    (expression ("set!" identifier "=" expression)updateVar-exp)

    ; Bloque de expresiones (programación imperativa)
    (expression ("block" "{" expression (arbno ";" expression) "}")
                block-exp)

    ; Aplicación de primitivas que generan valores booleanos
    (expr-bool (pred-prim "(" expression "," expression ")") comp-pred)
    (expr-bool (oper-bin-bool "(" expr-bool "," expr-bool ")") comp-bool-bin)
    (expr-bool (bool) booleano-lit)
    (expr-bool (oper-un-bool "(" expr-bool ")") comp-bool-un)
    
    ; Primitivas binarias para números
    (bi-primitive ("+") primitiva-suma)
    (bi-primitive ("~") primitiva-resta)
    (bi-primitive ("*") primitiva-multi)
    (bi-primitive ("/") primitiva-div)
    (bi-primitive ("concat") primitiva-concat)
    (bi-primitive ("mod") primitiva-elmodulo)

    ; Primitivas unarias para números
    (uni-primitive ("add1") primitiva-add1)
    (uni-primitive ("sub1") primitiva-sub1)
    (uni-primitive ("longitud") primitiva-longitud)

    ; Operadores predicados
    (pred-prim ("<") prim-bool-menor)
    (pred-prim (">") prim-bool-mayor)
    (pred-prim ("<=") prim-bool-menor-igual)
    (pred-prim (">=") prim-bool-mayor-igual)
    (pred-prim ("==") prim-bool-equiv)
    (pred-prim ("<>") prim-bool-diff)

    ; Primitivas aplicables sobre booleanos
    (oper-bin-bool ("and") prim-bool-conj)
    (oper-bin-bool ("or") prim-bool-disy)
    (oper-un-bool ("not") prim-bool-neg)

    ; Primitivas de listas
    (list-prim ("empty-lst" "()") prim-make-empty-list)
    (list-prim ("is-empty-lst?" "("expression")") prim-empty-list)
    (list-prim ("create-lst" "("(separated-list expression ",") ")") prim-make-list); crear-lista(<elem1>,<elem2>,<elem3>,...)
    (list-prim ("lst?" "("expression")") prim-list?-list); lista?(<lista>)-> Bool
    (list-prim ("head-lst""(" expression")") prim-head-list);cabeza-lista(<lista>)-> <elem1>
    (list-prim ("tail-lst" "(" expression")") prim-tail-list);cola-lista(<lista>)-> <elem2>,<elem3>,...
    (list-prim ("append-lst""("expression "," expression")") prim-append-list);append-lista([<elem1>,<elem2>,<elem3>,...],[<elemA>,<elemB>,<elemC>,...])-> <elem1>,<elem2>,<elem3>,...,<elemA>,<elemB>,<elemC>,...
    (list-prim ("ref-lst""("expression "," expression")") prim-ref-list);ref-lista(<lista>, pos) 
    (list-prim ("set-lst""("expression "," expression "," expression ")") prim-set-list);set-lista(<lista>, pos, value) 

    ; Primitivas de tuplas
    (tuple-prim ("empty-tuple" "()") prim-make-empty-tuple)
    (tuple-prim ("is-empty-tuple?" "("expression")") prim-empty-tuple)
    (tuple-prim ("create-tuple" "("(separated-list expression ",") ")") prim-make-tuple); crear-tupla(<elem1>,<elem2>,<elem3>,...)
    (tuple-prim ("tuple?" "("expression")") prim-tuple?-tuple); tupla?(<tupla>)-> Bool
    (tuple-prim ("head-tuple""(" expression")") prim-head-tuple);cabeza-tupla(<tupla>)-> <elem1>
    (tuple-prim ("tail-tuple" "(" expression")") prim-tail-tuple);cola-tupla(<lista>)-> <elem2>,<elem3>,...
    (tuple-prim ("ref-tuple""("expression "," expression")") prim-ref-tuple);ref-tupla(<lista>, pos) 

    ; Primitivas de registros
    (regs-prim ("reg?" "(" expression ")") prim-regs?-registro)
    (regs-prim ("create-reg" "(" identifier "=" expression (arbno "," identifier "=" expression) ")") prim-make-registro)
    (regs-prim ("ref-reg" "(" expression ","expression ")") prim-ref-registro); ref-registro(<registro>,<id>) -> <value>
    (regs-prim ("set-reg" "(" expression ","expression","expression ")") prim-set-registro); set-registro(<registro>,<id>, <new-value>)

    ;; Programación Orientada a Objetos. La mayor parte de la sintaxis (simplificada) está basada en Java
    ;; (https://www.w3schools.com/java/java_oop.asp)

    ; Declaración de una clase
    (class-decl ("class" identifier "extends" identifier "{" (arbno "field" identifier ";") (arbno method-decl) "}") a-class-decl)

    ; Declaración de un metodo de una clase.
    (method-decl ("method" identifier "(" (separated-list identifier ",") ")" "{" expression "}")a-method-decl)

    ; Creación de instancias de una clase (objs).
    (expression ("new" identifier "(" (separated-list expression ",") ")") new-object-exp)
    
    ; Super llamados a metodos.
    (expression ("super" identifier "(" (separated-list identifier ",") ")") super-call-exp)

    ; Aplicación de metodos usando send.
    (expression ("send" expression identifier "("  (separated-list expression ",") ")") method-app-exp)

  ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Construidos automáticamente:
(sllgen:make-define-datatypes lexica gramatica)

(define show-the-datatypes
  (lambda () (sllgen:list-define-datatypes lexica gramatica)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Parser, Scanner e Interfaz

; El FrontEnd (Análisis léxico (scanner) y sintáctico (parser) integrados)
(define scan&parse
  (sllgen:make-string-parser lexica gramatica))

; El Analizador Léxico (Scanner)
(define just-scan
  (sllgen:make-string-scanner lexica gramatica))

;El Interpretador (FrontEnd + Evaluación + señal para lectura )
(define interpretador
  (sllgen:make-rep-loop  "--> "
    (lambda (pgm) (eval-program  pgm))
    (sllgen:make-stream-parser
      lexica
      gramatica)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Nota: Algunos de los ejemplos usados en esta sección carecen de utilidad o presentan inconsistencias.
; La única utilidad de estos ejemplos es la de ilustrar el uso de la gramática.

; Identificador
(scan&parse "new-identifier")

; Valores booleanos
(scan&parse "@T")

; Cadenas (String)
(scan&parse "\"Just a Text\"")

; Numbers
(scan&parse "-45.32")
(scan&parse "24")

; Aplicación de primitiva unaria
(scan&parse "add1(45.2)")

; Aplicación de primitiva binaria
(scan&parse "(2*4)")

; Primitivas de listas
(scan&parse "empty-lst ()")
(scan&parse "is-empty-lst?(empty-lst ())")
(scan&parse "create-lst(2,3,4,5)")
(scan&parse "lst?(empty-lst ())")
(scan&parse "head-lst([3,5,8,10])")
(scan&parse "tail-lst([-2.5,-4.6])")
(scan&parse "append-lst([\"monday\",\"Friday\"],[\"September\",\"November\",\"December\"])")
(scan&parse "ref-lst([@T,@F,@F,@T,@T], 3)")
(scan&parse "set-lst([11,23,33,44,55], 1, 22)")

; Primitivas de tuplas
(scan&parse "empty-tuple ()")
(scan&parse "is-empty-tuple?(empty-tuple ())")
(scan&parse "create-tuple(id1, id2, id3)")
(scan&parse "tuple?(tupla(100000,10000000000))")
(scan&parse "head-tuple(tupla(a,b,c))")
(scan&parse "tail-tuple(tupla(x,y,z))")
(scan&parse "ref-tuple(tupla(@T,x,\"Text\",20), 2)")

; Primitivas de registros
(scan&parse "reg?({while-loop-1: while @T: print(@T); a-simple-text: \"Just a random text\"})")
(scan&parse "create-reg(apple=fruit, cow=animal, green=color)")
(scan&parse "ref-reg({a:4;b:1;c:7}, 1)")
(scan&parse "set-reg({a:4; b:1; c:7}, 0, 1000)")

; Condicional if
(scan&parse "if <(2,3): 1 else 2")

; Procedimiento
(scan&parse "lambda (x, y) : (x + y)")

; Evaluar/invocar expresiones
(scan&parse "call (my-proc (param1, param2))")

; letrec
(scan&parse "letrec makeList (name, lastName) = lambda (n, l) : create-lst(n, l) {call (makeList(\"Juan\", \"XYZ\")) }")

; Definición de constantes
(scan&parse "final (x=0; y=1) { block{ sub1(y); if ==(x, y): @T else @F } }")

; Definición de variables mutables con var
(scan&parse "var (name=\"Proyecto\"; course=FLP) { begin { print(name); create-lst(name, course) } end }")

; Estructura begin
(scan&parse "begin { var (x=0) { set! x = 1 }; print(x) } end")

; Llamado a funciones
(scan&parse "call (lambda (x, y) : (x+y) (1,2))")

; Imprimir en pantalla
(scan&parse "print(ref-lst([2,-2,4,-4], 2))")

; Ciclo for
(scan&parse "for x = 0 to 3: create-reg(head=head-tuple(tupla(2,3)), a=add1(x)) end")

; Ciclo while
(scan&parse "while set! x = 10 : begin { print(x); add1(x); print(x) } end")

; Actualización de variable con set!
(scan&parse "begin { var (x=@T) { print(x) }; set! x = 0 } end")

; Bloque de código
(scan&parse "block { while @T : set! x = add1(x); print(\"Infinite loop block\") }")

; Operaciones lógicas (booleanas)
(scan&parse "and(@T,@T)")
(scan&parse "or(@T,>(2,3))")
(scan&parse "not(==(@T,True))")

; Programación Orientada a Objetos
; Definición de clases
(scan&parse "class Animal extends Object
  {
    field tipoAnimal;
    field nombreAnimal;
    method initialize (tipoAnimal, nombreAnimal)
                      {
                        block {set! self.marca = marca; set! self.numRuedas = numRuedas}
                      }
    method sonido (s) { s }
  }

class Perro extends Animal
  {
    field numeroPatas;
    method hacerSonido(Guau)
                      { super sonido(Guau) }
  }

new Animal(Mamifero, Perro)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Ambiente inicial
(define init-env
  (lambda ()
    (extend-env
     '(x)
     (list (direct-target 1))
     (empty-env))))

; Comienzo de definición del interprete

; eval-program: Evalúa un programa con el ambiente dado (ambiente inicializado)
(define eval-program 
  (lambda (pgm)
    (cases program pgm
      (a-program (class-decls exp)
        (elaborate-class-decls! class-decls)
        (eval-expression exp (init-env)))
      )))

; eval-expression: Evalúa una expresión usando un ambiente dado como entrada
(define eval-expression
  (lambda (exp env)
    (cases expression exp
      (numero-lit (num) num)
      (texto-lit (txt) (substring txt 1 (- (string-length txt) 1))) ; \"Text\" - Se abstrae unicamente el texto, sin \"
      (var-exp (id) (apply-env env id))
      (boolean-expr (datum) (eval-bool-exp datum env))

      (primapp-un-exp (prim rand)     
               (let ((arg (eval-primapp-exp-rand rand env))) ; Evalúa el operando y almacena el valor
                 (apply-uni-primitive prim arg))) ; Aplica la primitiva al valor obtenido previamente
      
      (primapp-bi-exp (rand1 prim rand2)
                      ; Se evalúan los operandos para obtener los valores y se almacenan
                      ; Luego, se aplica la primitiva con los valores obtenidos previamente
                      (let((arg1 (eval-primapp-exp-rand rand1 env))
               (arg2 (eval-primapp-exp-rand rand2 env)))
               (apply-bi-primitive arg1 prim arg2)))

      (lista (elems)
             ; Evalua cada elemento de la lista usando map en un ambiente dado
             (list->vector (map (lambda (element) (eval-expression element env) ) elems)))

      (tupla (elems)
             ; Evalúa cada elemento para obtener su valor usando eval-expression con el ambiente dado
             (map (lambda (element) (eval-expression element env) ) elems))

      (registro (id val rest-ids rest-vals)
                ; Crea una lista con los ids y un nuevo vector con los valores obtenidos después de evaluar cada valor (val y rest-vals)
                (list (cons id rest-ids)
                      (list->vector (map (lambda (element) (eval-expression element env) ) (cons val rest-vals)))))

      (prim-list-exp (lst)
                     ; Aplica la primitiva sobre la lista con el ambiente dado
                     (eval-prim-list lst env))

      (prim-tuple-exp (tuple)
                      ; Aplica la primitiva a la tupla con el ambiente dado
                      (eval-prim-tuple tuple env))

      (prim-registro-exp (regs-prim)
                         ; Aplica la primitiva al registro con el ambiente dado
                         (eval-regs-prim regs-prim env))

      (print-exp (exp)
                 (begin (display (eval-expression exp env))
                        (display "\n")
                   ))

      (if-exp (cond-exp true-exp false-exp)
              ; Evalúa la condición y de acuerdo al valor obtenido con get-boolean-val
              ; evalúa unicamente la expresión correspondiente del condicional (true-exp o false-exp)
              (if (get-boolean-val (eval-expression cond-exp env))
                  (eval-expression true-exp env)
                  (eval-expression false-exp env)
                  ))

      (begin-exp (exp lexps)
                 (if (null? lexps) ; Existe más de una expresión
                     (eval-expression exp env) ; Evalúa la única expresión que existe en la estructura begin
                     (letrec
                         [(recorrer (lambda (L)
                                      (cond
                                        [(null? (cdr L)) (eval-expression (car L) env)]
                                        [else (begin (eval-expression (car L) env)
                                                     (recorrer (cdr L))
                                        )]
                                        )
                                      ))
                          ]
                       (begin
                         (eval-expression exp env)
                         (recorrer lexps))
                         )
                     ))

      (for-exp (id exp1 todownto exp2 body)
               (letrec
                   [(start (eval-expression exp1 env)) ; Almacena el valor de inicio de la variable luego de evaluarla
                    (end (eval-expression exp2 env)) ; Almacena el valor de parada luego de evaluar la expresión
                    (route (cases for-way todownto ; Diferenciación del caso para el tipo de recorrido for
                             (to () +)
                             (downto () -)
                             ))
                    (body-for (cerradura (list id) body env)) ; Almacena el cuerpo del for como una cerradura
                    (for (lambda (var) ; Realiza el recorrido for
                           (if (eqv? var end) ; Condición de parada, cuando se llegue al límite definido
                               (apply-procedure body-for (list (direct-target var))) ; Aplica el procedimiento
                               (begin (apply-procedure body-for (list (direct-target var))) (for (route var 1)))
                               )))]
                 (for start) ; Ejecuta el for desde su valor inicial start
                   ))

      (while-exp (cond-exp body)
                 (eval-while-exp cond-exp body env))

      (proc-exp (ids body)
                (cerradura ids body env))

      (app-exp (rator rands)
               (let
                   (
                    (proc (eval-expression rator env)) ; Evalua el operador y almacena el valor
                    (args (eval-rands rands env)) ; Evalua los argumentos y los almacena en args
                    )
                 (if (procVal? proc)
                     (apply-procedure proc args) ; Aplica el procedimiento con los argumentos ya evaluados
                     (eopl:error 'eval-expression
                                 "Attemp to apply non-procedure ~s"))))

      (constanteLocal-exp (ids vals body)
                          (let
                              (
                               (args (eval-variableLocal-exp-rands vals env)) ; Evalua cada argumento, lo prepara para el eval-expression
                               )
                            (if (search&UpdateValExp body) ; Busca la variable para actualizar el valor, aunque no es posible
                                (eopl:error 'eval-expression
                                            "Cannot update the value of a constant ~s" body) ; Lanza el error, con la restricción
                                (eval-expression body (extend-env ids args env)) ; Evalua el cuerpo, y extiende el ambiente con las nuevas variables
                                )))

      (variableLocal-exp (ids vals body)
                     (let
                         (
                          (args (eval-variableLocal-exp-rands vals env)) ; Evalua cada argumento, lo prepara para el eval-expression
                          )
                       (eval-expression body (extend-env ids args env)) ; Evalua el cuerpo, y extiende el ambiente con las nuevas variables
                       ))

      (letrec-exp (proc-names ids bodies letrec-body)
                  (eval-expression letrec-body (extend-env-recursively proc-names ids bodies env))) ; Extiende recursivamente el ambiente con los datos definidios en el letrec

      (block-exp (exp rest-exps)
                 (let loop
                   (
                    (f-exp (eval-expression exp env)) ; Evalua antes de la invocación, la primera expresión
                    (r-exps rest-exps) ; Almacena el resto de la expresión
                    )
                   (if (null? r-exps)
                       f-exp ; En caso de no tener más expresiones, se retorna la primera expresión previamente evaluada
                       (loop (eval-expression (car r-exps) env) ; Evalua recursivamente cada elemento de la lista de expresiones
                             (cdr r-exps))
                       )))

      (updateVar-exp (id new-val)
                     (setref! ; Usando setref! se modifica el valor de una variable
                      (apply-env-ref env id)
                      (eval-expression new-val env)
                      ))
    (base-exp (base vals)
              (eval-base-exp (eval-expression base env) ; Evalua primero la base
                             (map (lambda (element) (eval-expression element env) ) vals) env)) ; Luego evalua cada elemento de la lista vals, y ambos argumentos se los pasa a eval-base-exp
    ; POO
    (new-object-exp (class-name rands)
        (let
            (
             (args (eval-rands rands env))
              (obj (new-object class-name))
              )
          (find-method-and-apply 'init class-name obj args)
          obj
          ))

    ; Invocación de metodos con send
    (method-app-exp (obj-exp method-name rands)
        (let
            (
             (args (eval-rands rands env)) ; Evalúa los argumentos
             (obj (eval-expression obj-exp env)) ; Evalúa el objeto como una expresión
              )
          (find-method-and-apply ; Busca el metodo y lo aplica
            method-name (object->class-name obj) obj args))
        )

    ; Llamado con super
    (super-call-exp (method-name rands)
        (let
            (
             (args (eval-rands rands env))
             (obj (apply-env env 'self))
              )
          (find-method-and-apply
            method-name (apply-env env '%super) obj args))
        )
    (else 1)
      )
    ))
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Funciones especificas de evaluación de otros tipos de datos

; eval-bool-exp: Evalúa expresiones booleanas
(define eval-bool-exp
  (lambda (expr-boolean env)
    (cases expr-bool expr-boolean ; Se aplica cases para las expresiones booleanas, en cada case se evaluan las expresiones de los argumentos
      (comp-pred (pred-prim rand1 rand2)
                (let ((arg1 (eval-expression rand1 env))
                      (arg2 (eval-expression rand2 env)))
                  (eval-comp-pred pred-prim arg1 arg2))) ; Se aplica la primitiva
      (comp-bool-bin (oper-bin-bool rand1 rand2)
                     (let ((arg1 (eval-bool-exp rand1 env))
                           (arg2 (eval-bool-exp rand2 env)))
                          (eval-comp-bool-bin oper-bin-bool arg1 arg2))) ; Se aplica la primitiva
      (booleano-lit (datum) (if (equal? datum '@T) #t #f)) ; Representación de los booleanos simples
      (comp-bool-un (oper-unario-bool rand)
                    (let ((arg1 (eval-bool-exp rand env)))
                          (cases oper-un-bool oper-unario-bool
                            (prim-bool-neg () (not arg1))))) ; Caso para la negación lógica
      )
    ))

; eval-comp-pred: Aplica la primitiva de tipo predicado con dos argumentos dados (ya evaluados) y retorna el resultado de haber aplicado la prim
(define eval-comp-pred
  (lambda (pred-primitive arg1 arg2)
    (cases pred-prim pred-primitive
      ; Cada caso representa una primitiva y su ejecución en Scheme
      (prim-bool-menor () (< arg1 arg2))
      (prim-bool-mayor () (> arg1 arg2))
      (prim-bool-menor-igual () (<= arg1 arg2))
      (prim-bool-mayor-igual () (>= arg1 arg2))
      (prim-bool-equiv () (equal? arg1 arg2))
      (prim-bool-diff () (not (equal? arg1 arg2))))
    ))

; eval-comp-bool-bin: Aplica una operación binaria a dos argumentos dados (ya evaluados) y retorna el resultado de haber aplicado la prim
(define eval-comp-bool-bin
  (lambda (op-bin arg1 arg2)
    (cases oper-bin-bool op-bin
      ; Cada caso representa las dos operaciones lógicas (disyunción y conjunción), se aplican usando las funciones de Scheme
      (prim-bool-conj () (and arg1 arg2))
      (prim-bool-disy () (or arg1 arg2))
      )
    ))

; eval-prim-list: Evalúa las primitivas que se aplican sobre listas
(define eval-prim-list
  (lambda (primitiva env)
    (cases list-prim primitiva
      ; La representación de las listas la realizamos con vectores de Scheme, dado que es una estructura de datos de acceso seguro
      ; esto quiere decir, que lanzará por defecto un error, si la posición solicitada excede el rango, ahorrando la creación de otra
      ; función auxiliar. Además, el acceso a una posición de un vector se realiza en un tiempo O(1), lo que optimiza las operaciones
      ; sobre este tipo de dato. Los vectores de Scheme también brindan la posibilidad de convertirse en estructuras mutables o inmutables
      ; dependiendo de la utilidad que se les dé.
      ; (https://docs.racket-lang.org/reference/vectors.html)
      (prim-make-empty-list () (make-vector 0)) ; Crea un vector vacío para inicializar la lista
      (prim-empty-list (exp) ( = (vector-length (eval-expression exp env)) 0)) ; Compara la longitud del vector usando vector-length de Scheme
      (prim-make-list (list-elem)
                      (list->vector (map (lambda (elem)
                                           (eval-expression elem env)) list-elem))) ; Aplica la función de evaluación a cada elem dado para generar la nueva lista
      (prim-list?-list (exp)
                       (vector? (eval-expression exp env))) ; Compara si la expresión dada es un vector y retorna el valor booleano (vector es representación de las listas para nuestro caso)
      (prim-head-list (exp)
                      (if ( = (vector-length (eval-expression exp env)) 0)
                                (eopl:error 'eval-expression
                                 "Cannot get the head of an empty list. List must have at least one element to get head ~s" )
                                (vector-ref (eval-expression exp env) 0))) ; Retorna el valor de la cabeza de la lista, usando vector ref y la posición 0
      (prim-tail-list (exp)
                      (if ( = (vector-length (eval-expression exp env)) 0)
                                (make-vector 0)
                                (list->vector (cdr (vector->list (eval-expression exp env))) ))) ; Evalua recursivamente para obtener el último elemento de la lista
      (prim-append-list (exp1 exp2)
                        (list->vector (append (vector->list (eval-expression exp1 env)) (vector->list (eval-expression exp2 env)) )) ) ; Une dos listas con append y lo convierte a vector
      (prim-ref-list (list index)
                     (if ( >= (eval-expression index env) (vector-length (eval-expression list env)))
                                (eopl:error 'eval-expression ; Se define un error propio de tipo out of range
                                 "The index ~s is out of range"  (eval-expression index env))
                                (vector-ref (eval-expression list env) (eval-expression index env)) )) ; Usando vector-ref se obtiene la refrencia, pasandole la posición y la lista ya evaluadas
      (prim-set-list (list index val)
                     (if ( >= (eval-expression index env) (vector-length (eval-expression list env)))
                                (eopl:error 'eval-expression
                                 "The index ~s is out of range"  (eval-expression index env))
                                 (vector-set! (eval-expression list env) (eval-expression index env) (eval-expression val env)) )) ; Cambia el valor de una posición de la lista usando vector-set!
    )
    ))

; eva-prim-tuple: Evalúa las primitivas que se aplican sobre tuplas
(define eval-prim-tuple
  ; Se usa listas de Scheme para representar las tuplas
  (lambda (prim env)
    (cases tuple-prim prim
      (prim-make-empty-tuple () (list))
      (prim-empty-tuple (exp)
                        ( = (length (eval-expression exp env)) 0)) ; Retorna un valor booleano, si la tupla está vacía
      (prim-make-tuple (tuple-elem)
                       (map (lambda (elem) (eval-expression elem env)) tuple-elem)) ; Evalua cada expresión dada como argumentos para crear la tupla
      (prim-tuple?-tuple (exp)
                         (list? (eval-expression exp env))) ; Predicado para verificar si es una lista
      (prim-head-tuple (exp)
                       (if ( = (length (eval-expression exp env)) 0)
                                (eopl:error 'eval-expression
                                 "Cannot get the head of an empty tuple" )
                                (list-ref (eval-expression exp env) 0))) ; Obtiene la referencia de la posición 0 (head)
      (prim-tail-tuple (exp)
                       (if ( = (length (eval-expression exp env)) 0)
                                (list)
                                (cdr (eval-expression exp env))))
      
     (prim-ref-tuple (tuple index)
                     (if (>= (eval-expression index env) (length (eval-expression tuple env)))
                                (eopl:error 'eval-expression
                                 "The index ~s is out of range"  (eval-expression index env))
                                (list-ref (eval-expression tuple env) (eval-expression index env)))) ; Evalua la posición y la tupla y retorna la referencia de la posición dada
    )))

; eval-regs-prim: Evalúa las primitivas que se aplican sobre registros
(define eval-regs-prim
  (lambda (regs-primitive env)
    (cases regs-prim regs-primitive
      (prim-regs?-registro (exp)
                           (let
                               (
                                (regs (eval-expression exp env)) ; Almacena los valores evaluados en la variable regs
                                )
                             (if (and (list? regs) (= (length regs) 2))
                                 (if (and (vector? (cadr regs)) (= (length (car regs)) (vector-length (cadr regs))))
                                     #t #f)
                                 #f)))
      (prim-make-registro (id val rest-ids rest-vals) (list (cons id rest-ids)
                                                            (list->vector (map (lambda (element) (eval-expression element env) ) (cons val rest-vals)))))
      (prim-ref-registro (exp id-exp)
                         (let
                             (
                               (regs (eval-expression exp env))
                                        (ids (car (eval-expression exp env)))
                                        (vals (cadr (eval-expression exp env)))
                                        (id (cases expression id-exp
                                              (var-exp (datum) datum)
                                              (else (eopl:error 'eval-expression "Expression ~s is not an identifier" id-exp))))
                                        )
                                    (if (number? (list-find-position id ids))
                                        (vector-ref vals (list-find-position id ids))
                                        (eopl:error 'eval-expression "Identifier ~s not found, in the list of available identifiers ~s" id ids))))
      
      (prim-set-registro (exp id-exp val)
                         (let
                             (
                              (regs (eval-expression exp env))
                                        (ids (car (eval-expression exp env)))
                                        (values (cadr (eval-expression exp env)))
                                        (id (cases expression id-exp
                                              (var-exp (datum) datum)
                                              (else (eopl:error 'eval-expression "Expression ~s is not an identifier" id-exp))))
                                        )
                                    (if (number? (list-find-position id ids))
                                        (vector-set! values (list-find-position id ids) (eval-expression val env))
                                        (eopl:error 'eval-expression "Identifier ~s not found, in the list of available identifiers ~s" id ids))))
      (else 1))
    ))
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; Implementación del ciclo While
(define eval-while-exp
  (lambda (cond-exp body env)
    (if (get-boolean-val (eval-expression cond-exp env))
        (begin (eval-expression body env) (eval-while-exp cond-exp body env))
        'fin
        )
    ))

; Números con distintas bases: Es representado como una lista, cuya cabeza es la base del número
(define eval-base-exp
  (lambda (base vals env)
    (list base vals)
    ))

; Convierte un número a base 10
(define to-base10
  (lambda (nums exponente base)
    (cond
      [(null? nums) 0] ; Si la lista de numeros es vacía, su representación será 0
      [else
       (+ (* (car nums) (expt base exponente)) (to-base10 (cdr nums) (+ exponente 1) base))]
      )
    ))

; Convierte números a decimal
(define to-decimal
  (lambda (nums base)
    (to-base10 nums 0 base)
    ))

; Suma de números en distinta base
(define op-base
  (lambda (op lst-nums-1 lst-num-2 base)
    (cons base (list (to-base (op (to-decimal lst-nums-1 base) (to-decimal lst-num-2 base)) base ))                  )
    ))

; Convertir número a una base dada
(define to-base
  (lambda (numero base)
    (cond
      ((=(quotient numero base)0) (list numero))
      (else
       (cons (remainder numero base) (to-base (quotient numero base) base))
       )
      )
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Evalúa una lista de operandos, aplicando eval-expression a cada elemento
(define eval-rands
  (lambda (rands env)
    (map
     (lambda (x) (eval-rand x env)) rands)
    ))

; Función auxiliar que evalua un único operando
(define eval-rand
  (lambda (rand env)
    (direct-target (eval-expression rand env))
    ))

; Evalúa el operando de una primapp expression
(define eval-primapp-exp-rand
  (lambda (rand env)
    (eval-expression rand env)
    ))

; Evalúa la expresión de asignación de variables locales (var, const)
(define eval-variableLocal-exp-rands
  (lambda (rands env)
    (map
     (lambda (x) (eval-variableLocal-exp-rand x env)) rands)
    ))

; Función auxiliar que evalúa el operando de forma individual
(define eval-variableLocal-exp-rand
  (lambda (rand env)
    (direct-target (eval-expression rand env)) 
    ))

; Aplica la primitiva binaria (expression pŕimitiva-binaria expression)
(define apply-bi-primitive
  (lambda (arg1 prim arg2)
    (cases bi-primitive prim
       (primitiva-suma () (if (and (list? arg1) (list? arg2))
                           (op-base + (car (cdr arg1) ) (car (cdr arg2) ) (car arg1) )
                           (+ arg1 arg2 )
                           ))
      (primitiva-resta () (if (and (list? arg1) (list? arg2))
                              (op-base - (car (cdr arg1) ) (car (cdr arg2) ) (car arg1))
                              (- arg1 arg2 )
                              ))
      (primitiva-multi () (if (and (list? arg1) (list? arg2))
                              (op-base * (car (cdr arg1) ) (car (cdr arg2) ) (car arg1))
                              (* arg1 arg2 )
                              ))
      (primitiva-div () (if (and (list? arg1) (list? arg2))
                            ((eopl:error 'deref
                                                      "This operation is not defined for based numbers (hexadecimal)"))
                            (/ arg1 arg2 )
                              ))
      (primitiva-elmodulo () (if (and (list? arg1) (list? arg2))
                                 ((eopl:error 'deref
                                                      "This operation is not defined for based numbers (hexadecimal)"))
                                 (modulo arg1 arg2 )
                                 ))
      (primitiva-concat () (string-append arg1 arg2) )
    )
    ))

; Aplica la primitiva unaria
(define apply-uni-primitive
  (lambda (prim args)
    (cases uni-primitive prim
      (primitiva-add1 () (if (list? args)
                           (op-base + (car (cdr args) ) '(1) (car args) )
                           (+ args 1 )
                           ))
      (primitiva-sub1 () (if (list? args)
                           (op-base - (car (cdr args) ) '(1) (car args) )
                           (- args 1 )
                           ))
      (primitiva-longitud (string-length args) ) )
    ))
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obtiene el valor booleano de una expresión booleana
(define get-boolean-val
  (lambda (x)
    (if (eqv? x #t)
        #t
        #f
        )
    ))

; Procedimientos: Clausura. Se define el datatype de las clausuras para el manejo de procedimientos
(define-datatype procVal procVal?
  (cerradura
   (lista-ID (list-of symbol?) )
   (exp expression?)
   (amb environment?)
   )
  )

; apply-procedure: Evalúa el cuerpo del procedimiento con el ambiente extendido dado
;apply-procedure: evalua el cuerpo de un procedimientos en el ambiente extendido correspondiente
(define apply-procedure
  (lambda (proc args)
    (cases procVal proc
      (cerradura (ids body env)
               (eval-expression body (extend-env ids args env))) ; Se evalua con el ambiente extendido con los ids y los args
      )
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Manejo de paso por referencia o por valor

; Función auxiliar para la definición del paso por valor. Define que tipos de datos se pasan por valor (se usa más adelante)
(define paso-por-valor?
  (lambda (x)
    (or (string? x) (boolean? x) (number? x) (procVal? x) (vector? x) ) ; Los valores que se pasan por valor
    ))

; Definición del manejo de paso por referencia
(define ref-to-direct-target?
  (lambda (x)
    (and (reference? x) ; Se verifica que x sea una referencia, con el predicado del datatype
         (cases reference x ; Se aplica cases para el tipo de dato reference con el x
           (a-ref (pos vec)
                  (cases target (vector-ref vec pos) ; Se verifica si x es un direct-target o no
                    (direct-target (v)
                                   #t)
                    (indirect-target (v)
                                     #f)
                    ))
           )
         )
    ))

; Definición de los datatypes para target, es importante para el setteo de ref.
(define-datatype target target?
  (direct-target
   (expval paso-por-valor?)) ; direct-target tiene el comportamiento de paso por valor
  (indirect-target
   (ref ref-to-direct-target?) ; indirect-target representa el paso por referencia
                   ))

; Definición del datatype de referencia
(define-datatype reference reference?
  (a-ref (position integer?)
         (vec vector?) ; Recordar que las listas son vectores en Scheme de acuerdo a nuestra representación
         ))

; Obtiene el valor dada una referencia (independiente del paso por valor o por referencia)
(define deref
  (lambda (ref)
    (cases target (primitive-deref ref)
      (direct-target (expval) expval) ; Hace referencia a un valor nativo como un num, string o bool
      (indirect-target (ref1)
                       (cases target (primitive-deref ref1)
                         (direct-target (expval) expval)
                         (indirect-target (p)
                                          (eopl:error 'deref
                                                "Cannot reference to another ref: ~s" ref1)))
                       ; El lenguaje no admite refs a otra ref, esto es dificil de manejar porque se puede volver tan grande que excede la memoria
                       )
      )
    ))

; Función auxiliar que modifica el vector con la posición para dereferenciar dada una ref.
(define primitive-deref
  (lambda (ref)
    (cases reference ref
      (a-ref (pos vec)
             (vector-ref vec pos))
      )
    ))

; Setea una referencia. Si es target directo se cambia la referencia por la expresión.
; Si es target indirecto, se trae la referencia y se setea dicha referencia que es target directo con la expresión evaluada.
(define setref!
  (lambda (ref expval)
    (let
        (
         (ref
          (cases target (primitive-deref ref)
                (direct-target (expval1) ref)
                (indirect-target (ref1) ref1)
            )
              )
         )
      (primitive-setref! ref (direct-target expval))
      )))

; Función auxiliar para el seteo de una referencia.
(define primitive-setref!
  (lambda (ref val)
    (cases reference ref
      (a-ref (pos vec)
             (vector-set! vec pos val))
      )
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Buscar una variable en un cuerpo y modificar el valor
(define search&UpdateValExp
  (lambda (body)
    ; Se debe definir un valor booleano de retorno para cada caso de expression de la gramática
    ; Si es #t se busca y se actualiza, de otra forma no es necesario
    (cases expression body
      (numero-lit (num) #f)
      (while-exp (bool-exp body) #f)
      (texto-lit (datum) #f)
      (var-exp (id) #f)
      (print-exp (exp) #f)
      (begin-exp (exp lexps) #f)
      (base-exp(base valores)#f)
      (primapp-un-exp (prim rand) #f)
      (primapp-bi-exp (rand1 prim rand2) #f)
      (boolean-expr (datum) #f)
      (lista (list-elements) #f)    
      (prim-list-exp (datum) #f)
      (tupla (list-elements) #f)
      (prim-tuple-exp (datum) #f)
      (registro (id val rest-ids rest-vals) #f)
      (prim-registro-exp (regs-prim) #f)
      (if-exp (cond-exp true-exp false-exp) #f)
      (for-exp (id start for-way end body) #f)
      (proc-exp (ids body)
          (search&UpdateValExp body) )
      (app-exp (rator rands) #f)
      (variableLocal-exp (ids vals body)
                        (search&UpdateValExp body) ) ; Llamado recursivo
      (constanteLocal-exp (ids vals body)
                        (search&UpdateValExp body) )
      (updateVar-exp (id newVal) #t)
      (block-exp (exp exps)
                 (if (search&UpdateValExp exp)
                     #t
                     (let loop ; Se debe evaluar cada expresión del bloque, porque cada expresión puede modificar variables
                       (
                        (exps exps)
                        )
                       (if (null? exps)
                           #f ; NO hay más exps
                           (if (search&UpdateValExp (car exps) )
                               #t
                               (loop (cdr exps) )
                           )
                       )
                     )
                 ))
      (letrec-exp (proc-names ids bodies letrec-body)
                  (search&UpdateValExp letrec-body)) ; Solo puede modificar variables en el cuerpo del letrec     
      (new-object-exp (id args) #f)
      (method-app-exp (obj-exp method-name rands) #f)
      (super-call-exp (method-name rands) #f)
    )
  ))
  
  
  ; Manejo de ambientes

; datatype del ambiente
(define-datatype environment environment?
  (empty-env-record)
  (extended-env-record (syms (list-of symbol?))
                       (vec vector?)
                       (env environment?))
  )

(define scheme-value? (lambda (v) #t))

; Define el ambiente vacío, importante para extender los envs
(define empty-env
  (lambda ()
    (empty-env-record)))     

; Extiende un ambiente
(define extend-env
  (lambda (syms vals env)
    (extended-env-record syms (list->vector vals) env)))

; Creación de un ambiente extendido para procedures rec
(define extend-env-recursively
  (lambda (proc-names idss bodies old-env)
    (let ((len (length proc-names)))
      (let ((vec (make-vector len)))
        (let ((env (extended-env-record proc-names vec old-env)))
          (for-each
            (lambda (pos ids body)
              (vector-set! vec pos (direct-target (cerradura ids body env))))
            (iota len) idss bodies)
          env)))))

; Busca un simbolo en un ambiente.
(define apply-env
  (lambda (env sym)
    (deref (apply-env-ref env sym))
    ))

; Busca un simbolo en un ambiente, si el simb es uan ref.
(define apply-env-ref
  (lambda (env sym)
    (cases environment env
      (empty-env-record () (eopl:error 'apply-env-ref "Cannot find ~s in the env" sym))
      (extended-env-record (syms vals env)
                           (let ((pos (rib-find-position sym syms)))
                             (if (number? pos)
                                 (a-ref pos vals)
                                 (apply-env-ref env sym)))))))
  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Llamado al interpretador
(interpretador)

; Ejemplos de uso con el interpretador (funcionalidad del lenguaje de programación)

; Programas recursivos (cálculo del factorial de un número)
; letrec fact(n) = if ==(n,0): 1 else (n * call( fact( (n~1) ) ) ) {call(fact(5))} Expected output: 120
; letrec fact(n) = if ==(n,0): 1 else (n * call( fact( (n~1) ) ) ) {call(fact(5))} Expected output: 1

; Programas con ciclos (cálculo del factorial de un número)
; var (numero=5; acc=1) { for i=numero downto 1: begin { set! acc = (acc*i); set! i = (i+1); print(acc) } end end } ; Expected output: Imprime el factorial de cada número hasta 120, dado que el número final es 5
