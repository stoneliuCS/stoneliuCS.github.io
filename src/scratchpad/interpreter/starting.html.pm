#lang pollen

◊headline{Learning about compilers and interpreters.}

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
}

◊p{
  Lets try a warm up since my C skills are quite awful. Lets try writing a doubly linked list to get comfortable with pointers in C.

  Lets start with this definition of a linked list node with strings.
  ◊code-block["c"]{
    // A LinkedListNode is a 
    // struct LinkedListNode { LinkedListNode, LinkedListNode, char* }
    // Interpretation, LinkedListNode contains pointers to both the previous and next.
    typedef struct LinkedListNode {
      struct LinkedListNode* previous;
      struct LinkedListNode* next;
      const char* val;
    } LinkedListNode;
  }

  It should support the following operations:
  ◊code-block["c"]{
    // Inserts the node at the back of the list.
    // Mutates the underlying list to point the last node to the given node.
    void insert_node(LinkedListNode* list, LinkedListNode* node);

    // Finds the node at the given index (zero-indexed) in the list.
    LinkedListNode* find_node(LinkedListNode* list, const int idx);

    // Deletes the node at the given (zero-indexed) index in the list.
    void delete_node(LinkedListNode* list, const int idx);

    // Returns the length of that linked list.
    int list_length(LinkedListNode* list);
  }

  Lets start with these simple implementations for the header file.
  ◊code-block["c"]{
    void insert_node(LinkedListNode* list, LinkedListNode* node) {
      assert(list != NULL);
      assert(node != NULL);
      LinkedListNode* current = list;

      // Traverse the linked list until it reaches the end.
      while (current->next != NULL) {
        current = current->next;
      }
      current->next = node;
      node->previous = current;
    }


    LinkedListNode* find_node(LinkedListNode* list, const int idx) {
      assert(list != NULL);

      int length = list_length(list);
      int counter = 0;

      LinkedListNode* current = list; 

      while (current->next != NULL && counter < idx) {
        current = current->next;
        counter = counter + 1;
      }
      return current;
    }

    int list_length(LinkedListNode *list) {
      assert(list != NULL);
      LinkedListNode* current = list;
      int len = 1; // To account for the fact that LinkedListNode is already a node.
      while (current->next != NULL) {
        current = current->next;
        len = len + 1;
      }
      return len;
    }
  }
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
