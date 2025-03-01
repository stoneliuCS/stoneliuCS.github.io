#lang racket/base
(require
pollen/decode
pollen/file
pollen/tag
sugar
txexpr
pollen/unstable/typography)
(require pollen/tag pollen/template pollen/core txexpr sugar/coerce)
(require
  "images.rkt")
(provide (all-defined-out))
(define headline (default-tag-function 'h3))
(define smaller-headline (default-tag-function 'h5))
(define items (default-tag-function 'ul))
(define item (default-tag-function 'li 'p))
(define (link url text) `(a ((href ,url)) ,text))

(define (code-block lang . text)
  (define joined-text (apply string-append text))
  `(pre ((class "code-block"))
       (code ((class ,(string-append lang)))
             ,joined-text)))
