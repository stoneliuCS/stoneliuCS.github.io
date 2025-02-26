#lang racket
 (require
  pollen/decode
  pollen/file
  pollen/tag
  sugar
  txexpr
  pollen/unstable/typography)

;; image: String width? border? -> TXExpr
(define (image src #:width [width "100%"] #:border [border? #t])
  (define img-tag (attr-set* '(img) 'style (format "width: ~a" width)
                             'src (build-path "images" src)))
  (if border?
      (attr-set img-tag 'class "bordered")
      img-tag))
