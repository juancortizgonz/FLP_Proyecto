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
    (class-decl ("Clase" identifier "extends" identifier (arbno "field" identifier ";") (arbno method-decl)) a-class-decl)

    ; Declaración de un metodo
    (method-decl ("method" identifier "(" (separated-list identifier ",") ")" "{" expression "}")a-method-decl)

    ; Nueva instancia de una clase (objeto)
    (expression ("new" identifier "(" (separated-list expression ",") ")") new-object-exp)
    
    ; Super llamado de un metodo
    (expression ("super" identifier "(" (separated-list identifier ",") ")") super-call-exp)

    ; Llamado de un metodo de una clase
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
#|(define interpretador
  (sllgen:make-rep-loop  "--> "
    (lambda (pgm) (eval-program  pgm))
    (sllgen:make-stream-parser
      lexica
      gramatica)))|#


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

; Imprimir en pantalla
(scan&parse "print(ref-lst([2,-2,4,-4], 2))")

; Ciclo for
(scan&parse "for x = 0 downto [a, b, c, d, e, f]: create-reg(head=head-tuple(tupla(2,3)), a=add1(x)) end")

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
; (scan&parse "class teacher extends person () field name; field age; field experience; field courses; method initialize (nombre, edad, experiencia, cursos) { create-reg(nombre=name, edad=age, experiencia=experience, cursos=courses) }")