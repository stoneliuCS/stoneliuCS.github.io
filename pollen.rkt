#lang racket/base
(require
  pollen/decode
  pollen/file
  pollen/tag
  sugar
  txexpr
  pollen/unstable/typography)

(require
  (for-syntax racket/base racket/syntax)
  racket/list
  racket/format
  racket/string
  racket/function
  racket/contract
  racket/match
  racket/system)

(provide (all-defined-out))
(define headline (default-tag-function 'h2))
(define items (default-tag-function 'ul))
(define item (default-tag-function 'li 'p))
(define (link url text) `(a ((href ,url)) ,text))
(define (image src #:width [width "100%"] #:border [border? #t])
  (define img-tag (attr-set* '(img) 'style (format "width: ~a" width)
                             'src (build-path "images" src)))
  (if border?
      (attr-set img-tag 'class "bordered")
      img-tag))
(define (image-wrapped img-path)
  (attr-set* (image img-path)
             'style "width: 120px;"
             'align "center"))
(define (div-scale factor . tx-elements)
  (define base (txexpr 'div null tx-elements))
  (attr-set base 'style (format "width: ~a" factor)))
;; BEGIN: Site Variables
(define site-title "Stone Liu")
(define AGE "21")
