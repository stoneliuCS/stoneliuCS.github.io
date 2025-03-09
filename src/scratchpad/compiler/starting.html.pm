#lang pollen

◊headline{Learning about the compiler.}

◊p{
  From my understanding a compiler is just a ◊em{very, very, very} sophisticated function.

  In essence it takes source code, and translates that into a ◊em{semantically} equivalent form in the target language.
}

◊code-block["racket"]{
  ;; The signature of a example compiler function in ISL.
  compiler: String -> String
  (define (compiler source)
    ...
  )
}

◊p{
  Some popular compilers today include ◊em{gcc, clang, javac, and go}.

  So lets try writing my own, in ◊em{C}.

  The first stage is ◊link["https://en.wikipedia.org/wiki/Lexical_analysis"]{lexical analysis}, essentially I need to write a program that can read in a source file and tokenize it. ◊em{(I won't worry about preprocessing and other fancy stuff right now.)}
}

◊code-block["c"]{
  // Reading from a source file in c.
  printf("Compiling...\n");
  const char* filePath = argv[1];
  char* fileContents = readFile(filePath);
}

◊p{
  For now, lets try to translate this program written in an imaginary programming language called ◊em{StoneScript} (Creative am I right?)

  In my language, I prefer the arrow syntax to better communicate assignment statements.
}

◊code-block[""]{
  integer x <- 2;
  integer y <- 2;
  integer z <- x + y;
}
