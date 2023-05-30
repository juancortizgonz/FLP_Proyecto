#lang eopl
;; Integrantes del grupo
;; Juan Camilo Ortiz Gonzalez - 2023921
;; William Velasco Muñoz - 2042577
;;
;; Link al GitHub: https://github.com/juancortizgonz/FLP_Taller_3

;------------------------------------------------------------------------------------
;;;;; Interpretador

;; La definición BNF para las expresiones del lenguaje:
;;
;;  <programa>       ::= <expresion>
;;                      <un-programa (exp)>
;;  <expresion>    ::= <numero>
;;                      <numero-lit (num)>
;;                  ::= "$" <texto>
;;                      <texto-lit (txt)>
;;                  ::= <identificador>
;;                      <var-exp (id)>
;;                  ::= "(" <expresion> <primitiva-binaria> <expresion> ")"
;;                      <primapp-bin-exp (exp1 prim-binaria exp2)>
;;                  ::= <primitiva-unaria> "(" <expresion> ")"
;;                      primapp-un-exp (prim-unaria exp)
;;                  ::= let "{" {identifier = <expression>}(;)* "}" in <expresion>
;;                      <let-exp (ids rands body)>
;;                  ::= function <identificador> "(" {<identificador>}*(,) ")" "{" {<expresion>}*(;) "}"
;;                      <funcion-exp (ids body)>
;;                  ::= (<expresion> {<expresion>}*)
;;                      <app-exp proc rands>
;;                  ::= if "(" <expresion> ")" "{" <expresion> "}" "else" "{" <expresion> "}"
;;                      <condicional-exp (test-exp true-exp false-exp)>
;;                  ::= local "(" {<identificador> = <expresion> (;)}* ")" "{" <expresion> "}"
;;                      variableLocal-exp (ids exps cuerpo)
;;                  ::= procedure (<identificador>*',') do "{" <expresion> "}"
;;                      <procedimiento-exp (ids cuerpo)>
;;                  ::= "evaluate" expresion (expresion ",")*
;;                      <app-exp (exp exps)>
;;                  ::= letrec "{" {identificador ({identificador}*(,)) "=" <expresion>}* "}" in <expression>
;;                      <letrec-exp proc-names ids bodies body-letrec>
;;  <primitiva-binaria> ::= "+"
;;                          <primitiva-suma>
;;                      ::= "-"
;;                          <primitiva-resta>
;;                      ::= "*"
;;                          <primitiva-multi>
;;                      ::= "/"
;;                          <primitiva-div>
;;                      ::= "concat"
;;                          <primitiva-concat>
;;  <primitiva-unaria> ::= "longitud"
;;                         <primitiva-longitud>
;;                     ::= "add1"
;;                         <primitiva-add1>
;;                     ::= "sub1"
;;                         <primitiva-sub1>
;******************************************************************************************

;******************************************************************************************
;Especificación Léxica

(define lexica
'(
  (white-sp (whitespace) skip)
  (comment ("#" (arbno (not #\newline))) skip)
  (identificador (letter (arbno (or letter digit "?"))) symbol)
  (numero (digit (arbno digit)) number) ; Enteros positivos
  (numero ("-" digit (arbno digit)) number) ; Enteros negativos
  (flotante (digit (arbno digit) "." digit (arbno digit)) number) ; Decimales positivos
  (flotante ("-" digit (arbno digit) "." digit (arbno digit)) number) ; Decimales negativos
  (texto ("$" (arbno (or letter digit whitespace "." "," ":" "+" "-" "_" "$" "#"))"$") string) ; Se definieron solo algunos simbolos del alfabeto
  (caracter ("'" letter "'") symbol)
  (null ("null") string)
  ))


;Especificación Sintáctica (gramática)

(define gramatica
  '(
    (programa (expresion) un-programa)
    (programa ((arbno class-decl)"" expresion)
              un-programa-oo)
    (expresion (numero) numero-lit)
    (expresion (flotante) flotante-lit)
    (expresion (texto) texto-lit)
    (expresion (caracter) caracter-lit)
    (expresion (null) null)
    (expresion (identificador) id-exp)
    (expresion ("var" identificador "=" expresion)
               var-exp)
    (expresion ("const" identificador "=" expresion)
               const-exp)
    (expresion ("&" identificador)
               ref-exp)
    (expresion ("print" "(" expresion ")")
               imprimir-exp)
    (expresion (exp-bool)
               boolean-exp)
    (expresion ("[" primitiva (separated-list expresion ",") "]")
               primitiva-exp)
    (expresion ("("expresion primitiva-binaria expresion")") primapp-bin-exp)
    (expresion (primitiva-unaria "("expresion")") primapp-un-exp)
    (expresion ("list" "[" (separated-list expresion ",") "]")
               lista-exp)
    (expresion ("vector" "(" (separated-list expresion ",") ")")
               vector-exp)
    (expresion ("log" "(" (separated-list identificador "->" expresion ";") ")")
               registro-exp)
    (expresion ("if" "(" expresion ")" "{" expresion "}" "else" "{" expresion "}")
               condicional-exp)
    (expresion ("local" "(" (separated-list expresion ";") ")" "{" expresion "}")
                variableLocal-exp)
    (expresion ("procedure" "(" (separated-list identificador ",") ")" "{" expresion "}")
                procedimiento-exp)
    (expresion ("function" identificador "(" (separated-list identificador ",") ")" "{" (separated-list expresion ";") "}")
               funcion-exp)
    (expresion ("evaluate" "{" expresion ";" (separated-list expresion ";") "}")
               app-exp)
    (expresion ("letrec" "{" identificador ";" (separated-list identificador ";") "}"  "in" expresion)
               letrec-exp)
    (expresion ("begin" "{" expresion ";" (separated-list expresion ";") "}")
               begin-exp)
    (expresion ("while" "(" expresion ")" "{" expresion "}")
               while-loop-exp)
    (expresion ("for" identificador "=" expresion "to" expresion "{" expresion "}")
               for-loop-exp)
    (expresion ("set!" identificador "=" expresion)
               set-exp)
    (expresion ("call" identificador"()")
               llamado-funcion-exp)
    (expresion ("new" identificador "("(separated-list expresion ",")")")
               nuevo-objeto-exp)
    (expresion ("send" expresion identificador "(" (separated-list expresion ",") ")")
               metodo-app-exp)
    (expresion ("super" identificador "(" (separated-list expresion ",") ")")
               super-llamado-exp)
    (class-decl ("class" identificador "extends" identificador "(" (separated-list identificador ",") ")" "{" (separated-list "field" identificador ";") (separated-list method-decl ";") "}")
               declaracion-clase-exp)
    (method-decl ("method" identificador "(" (separated-list identificador ",") ")" "{" expresion "}")
                 declaracion-metodo-clase-exp)
    (exp-bool (boolean)
              exp-bool-simple)
    (exp-bool (operacion-binaria-bool "(" expresion "," expresion ")")
              exp-bool-bin)
    (exp-bool (operacion-unaria-bool "(" expresion ")")
              exp-bool-un)
    (exp-bool (predicado-primitiva "(" expresion "," expresion ")")
              predicado-primitiva-bool)
    (boolean ("True")
             true-boolean)
    (boolean ("False")
             false-boolean)
    (predicado-primitiva (">")
                         mayor-bool)
    (predicado-primitiva (">=")
                         mayor-igual-bool)
    (predicado-primitiva ("<")
                         menor-bool)
    (predicado-primitiva ("<=")
                         menor-igual-bool)
    (predicado-primitiva ("==")
                         igual-bool)
    (predicado-primitiva ("!=")
                         diferente-bool)
    (operacion-binaria-bool ("and")
                            and-primitiva-bool)
    (operacion-binaria-bool ("or")
                            or-primitiva-bool)
    (operacion-unaria-bool ("not")
                           not-primitiva-bool)
    (primitiva-binaria ("+") primitiva-suma)
    (primitiva-binaria ("~") primitiva-resta)
    (primitiva-binaria ("/") primitiva-div)
    (primitiva-binaria ("*") primitiva-multi)
    (primitiva-binaria ("%") primitiva-mod)
    (primitiva-binaria ("concat") primitiva-concat)
    (primitiva-unaria ("length") primitiva-longitud)
    (primitiva-unaria ("add1") primitiva-add1)
    (primitiva-unaria ("sub1") primitiva-sub1)

    (expresion ("X8(" (arbno expresion) ")")
               hexadecimal-base8-exp)
    (expresion ("X16(" (arbno expresion) ")")
               hexadecimal-base16-exp)
    (expresion ("X32(" (arbno expresion) ")")
               hexadecimal-base32-exp)

    (primitiva ("empty-list?")
                      lista-vacia?-prim)
    (primitiva ("empty")
                      lista-vacio-prim)
    (primitiva ("list?")
                      es-lista?-prim)
    (primitiva ("new List()")
                      crear-lista-prim)
    (primitiva ("get-head")
                      cabeza-lista-prim)
    (primitivaa ("get-tail")
                      cola-lista-prim)
    (primitiva ("append")
                      append-lista-prim)

    (primitiva ("vector?")
                      es-vector?-prim)
    (primitiva ("ref-vector")
                      ref-vector-prim)
    (primitiva ("set-vector")
                       set-vector-prim)
    (primitiva ("new Vect()")
                       crear-vector-prim)

    (primitiva ("log?")
               es-registro?-prim)
    (primitiva ("ref-log")
               ref-registro-prim)
    (primitiva ("set-log")
               set-registro-prim)
    (primitiva ("new Log()")
               crear-registro-prim)
    
    ))


;Tipos de datos construidos automáticamente:

(sllgen:make-define-datatypes lexica gramatica)

(define show-the-datatypes
  (lambda () (sllgen:list-define-datatypes lexica gramatica)))

;-----------------------------------------------------------------------------------------
;Parser, Scanner, Interfaz

;El FrontEnd (Análisis léxico (scanner) y sintáctico (parser) integrados)

(define scan&parse
  (sllgen:make-string-parser lexica gramatica))

;El Analizador Léxico (Scanner)

(define just-scan
  (sllgen:make-string-scanner lexica gramatica))

;El Interpretador (FrontEnd + Evaluación + señal para lectura )

(define interpretador
  (sllgen:make-rep-loop  "=> "
    (lambda (pgm) (evaluar-programa  pgm)) 
    (sllgen:make-stream-parser 
      lexica
      gramatica)))


;--------------------------------------------------------------------------------------------
; Comienzo del interprete

;; eval-program: <un-programa> => numero
;; Función que evalua el programa dado usando el ambiente dado (ambiente inicial)
(define evaluar-programa
  (lambda (pgm)
    #t
    ))


;--------------------------------------------------------------------------------------------

; Ejemplos de uso de gramática con scan&parse:

(scan&parse "var x = if (True) { print('a') } else { print('b') }")
















