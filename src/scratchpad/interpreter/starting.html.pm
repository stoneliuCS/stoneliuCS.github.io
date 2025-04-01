#lang pollen

◊headline{Learning about compilers and interpreters.}

◊p{
  From my understanding a compiler is just a ◊em{very, very, very} sophisticated function.

  In essence it takes source code, and translates that into a ◊em{semantically} equivalent form in the target language.

  The compiler usually outputs an executable in machine code. This greatly varies depending on computer architectures. Compilers that compile to another high level programming language is called a transpiler.
}

◊code-block["racket"]{
  ;; compiler: String -> String
  (define (compiler source) ...)
}

◊p{
  But where do you start from a behemoth as sophisticated as a ◊em{compiler}? Lets start with the basics, defining the very foundation of our programming language, our ◊em{grammar}.

  Lets write an incredibly simple programming language, one that is essentially an arithmetic calculator supporting 4 basic operations, addition, subtraction, multiplication, and division.
}
