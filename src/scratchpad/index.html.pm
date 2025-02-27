#lang pollen

◊headline{technical recollections}

◊(define-meta template "../template.html.p")
◊(require pollen/pagetree pollen/template sugar/coerce)
◊(let () (current-pagetree (load-pagetree "../index.ptree")) "")

◊items{
  ◊item{◊link["/scratchpad/leetcode.html"]{leetcode}}
}
