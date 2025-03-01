#lang racket/base

;; Require All Necessary Packages.
(require
pollen/decode
pollen/file
pollen/tag
sugar
txexpr
pollen/unstable/typography)
(require pollen/pagetree pollen/tag pollen/template pollen/core txexpr sugar/coerce)
(require pollen/unstable/pygments)

;; Export all defined functions.
(provide (all-defined-out))

;; BEGIN: Tags/TExprs
(define headline (default-tag-function 'h3))
(define smaller-headline (default-tag-function 'h4))
(define items (default-tag-function 'ul))
(define item (default-tag-function 'li 'p))
(define (link url text) `(a ((href ,url)) ,text))

;; code-block: String String -> TExpr
(define (code-block lang . text)
  (define joined-text (apply string-append text))
  `(pre ((class "code-block"))
       (code ((class ,(string-append lang)))
             ,joined-text)))

;; code-block: String String -> TExpr
(define (image src #:width [width "100%"] #:border [border? #t])
  (define img-tag (attr-set* '(img) 'style (format "width: ~a" width)
                             'src (build-path "images" src)))
  (if border?
      (attr-set img-tag 'class "bordered")
      img-tag))
