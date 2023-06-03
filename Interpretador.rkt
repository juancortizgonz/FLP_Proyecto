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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Especificación Léxica:
(define lexica
'(
  (white-sp
   (whitespace) skip)
  (comment
   ("#" (arbno (not #\newline))) skip)
  (identificador
   (letter (arbno (or letter digit "?" "$" "_" "@" "/"))) symbol)
  (numero-entero
   (digit (arbno digit)) number)
  (numero-entero
   ("-" digit (arbno digit)) number)
  (numero-flotante
   (digit (arbno digit) "." digit (arbno digit)))
  (numero-flotante
   ("-" digit (arbno digit) "." digit (arbno digit)))
  (texto
   ("\"" (arbno (or letter digit whitespace "." "," ":" "+" "-" "_" "$" "#" "@")) "\"") string)
  (caracter
   ("'" letter "'") symbol)
  (null
   ("null") string)
  ))


; Gramática (Especificación Sintactica):
(define gramatica
  '(
    (programa (expresion)
              un-programa)
    (expresion (identificador)
               id-exp)
    (expresion ("var" (separated-list identificador "=" expresion) "in" "{" expresion "}")
               var-exp)
    (expresion ("const" (separated-list identificador "=" expresion) "in" "{" expresion "}")
               const-exp)
    (expresion ( "rec" "{" (arbno identificador (separated-list identificador ",") "=" expresion) "}" "in" "{" expresion "}" )
               rec-exp)
    (expresion (numero-entero)
               int-exp)
    (expresion (numero-flotante)
               float-exp)
    (expresion (hexadecimal)
               hexadecimal)
    (expresion (texto)
               string-exp)
    (expresion (bool)
               bool-exp)
    (expresion (lista)
               list-exp)
    (expresion (tupla)
               tuple-exp)
    (expresion (registro)
               register-exp)
    (expresion (expr-bool)
               boolean-app-exp)
    (expresion ("begin" "[" (separated-list expresion ";") "]" "end")
               begin-exp)
    (expresion ("if" "(" expr-bool ")" "{" expresion "}" "else" "{" expresion "}")
              if-exp)
    (expresion ("while" "(" expr-bool ")" "{" expresion "}")
               while-exp)
    (expresion ("for" identificador "in" (or lista tupla registro) "{" expresion "}")
               for-exp)
    (expresion ("(" numero-entero primitiva-binaria-enteros numero-entero ")")
               prim-bin-int-exp)
    (expresion (primitiva-unaria-enteros "(" numero-entero ")")
               prim-un-int-exp)
    (expresion ("(" numero-flotante primitiva-binaria-flotantes numero-flotante ")")
               prim-bin-float-exp)
    (expresion (primitiva-unaria-flotantes "(" numero-flotante ")")
               prim-un-float-exp)
    ;#TODO: COntinuación de gramática
    ))