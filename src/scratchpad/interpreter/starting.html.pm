#lang pollen

◊headline{Learning about compilers and interpreters.}

◊p{
  From my understanding a compiler is just a ◊em{very, very, very} sophisticated function.

  In essence it takes source code, and translates that into a ◊em{semantically} equivalent form in the target language.

  The compiler usually outputs an executable in machine code. This greatly varies depending on computer architectures. Compilers that compile to another high level programming language is called a transpiler.
}

◊code-block["racket"]{
  ;; The signature of a example compiler function in ISL.
  compiler: String -> String
  (define (compiler source)
    ...
  )
}

◊p{
  For now, lets try to translate this program written in an imaginary programming language called ◊em{StoneScript} (Creative am I right?)

  In my language, I prefer the arrow syntax to better communicate assignment statements.
}

◊code-block[""]{
  var x <- 2;
  var y <- 2;
  var z <- x + y;
}

◊p{
  Lets break down at the highest level where to start. Every compiler/interpreter relies on a ◊em{frontend}. This is what parses the source code into a more easily managable data structure called ◊em{tokens}.

  At this rate, I forsee at the top level of my lexer doing this:
  ◊code-block["c"]{
    token_list *tokenize(const char *source) {
      token_ctx ctx = ...
      while (!is_end(ctx)) {
        ...
        scan_token(ctx);
      }
      return tokens;
    }
  }
  What is a ◊em{token_ctx} you might ask? Good question, since C doesn't really support object oriented programming, I need to have a struct which contains all the necessary information for all my helper functions throughout parsing.
  ◊code-block["c"]{
    // A Token Context is Structured Data
    // It holds
    // A starting index
    // A Current index
    // The current line number
    // The current source program.
    // The current running list of tokens.
    // A flag to see if the source program has errors.
    typedef struct token_ctx {
      int start;
      int current;
      int line;
      const char *source;
      token_list_t *tokens;
      bool error;
    } token_ctx;
  }
}

