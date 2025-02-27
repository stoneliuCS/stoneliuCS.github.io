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
(define (highlight code lang)
  (format "<pre><code class=\"language-~a\">~a</code></pre>" lang code))
(provide (all-defined-out))
(define headline (default-tag-function 'h3))
(define smaller-headline (default-tag-function 'h5))
(define items (default-tag-function 'ul))
(define item (default-tag-function 'li 'p))
(define (link url text) `(a ((href ,url)) ,text))
;; BEGIN: Site Variables
(define site-title "Stone Liu")
(define AGE "21")
