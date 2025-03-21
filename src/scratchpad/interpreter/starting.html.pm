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
  Some popular compilers today include ◊em{gcc, clang, javac, and go}. I've decided to write the project in ◊em{C} even though I know little to nothing about it.
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
    // Creates a LinkedListNode pointer in memory. Callers must be responsible for freeing it.
    LinkedListNode* create_node(LinkedListNode* previous, LinkedListNode* next, const char* val);

    // Frees the LinkedListNode.
    void free_node(LinkedListNode* head);

    // Inserts the node to the desired zero-indexed position. Returns the head of the new list.
    // The node will always be inserted behind the current index of the node in the original linked list.
    LinkedListNode* insert_node_at_idx(LinkedListNode* head, LinkedListNode* node, const int idx);

    // Finds the node at the given index (zero-indexed) in the list.
    LinkedListNode* find_node_at_idx(LinkedListNode* head, const int idx);

    // Deletes the node at the given (zero-indexed) index in the list.
    // Returns the head of the new list.
    LinkedListNode* delete_node_at_idx(LinkedListNode* head, const int idx);

    // Pretty Prints the linked list head.
    void pretty_print_node(LinkedListNode* head);
  }

  Lets start with one of these simple implementations from the header file.
  ◊code-block["c"]{
    static LinkedListNode *insert_node_at_idx_impl(LinkedListNode *head,
                                                  LinkedListNode *node,
                                                  const int idx) {
      int counter = 0;
      LinkedListNode *current = head;
      while (current->next != NULL && counter < idx) {
        current = current->next;
        counter = counter + 1;
      }
      assert(current != NULL);
      // We always insert the node to be before the current.
      if (current->previous != NULL) {
        current->previous->next = node;
        node->previous = current->previous;
      }
      node->next = current;
      current->previous = node;
      return walk_back(current);
    }

    LinkedListNode *insert_node_at_idx(LinkedListNode *head, LinkedListNode *node,
                                      const int idx) {
      assert(head != NULL && "Head pointer cannot be null.");
      assert(node != NULL && "Node to be inserted cannot be null.");
      assert(idx < get_length_node(head) &&
            "Cannot insert a node if the idx is greater the"
            "length of the list.");
      return insert_node_at_idx_impl(head, node, idx);
    }
  }
}

◊p{
  An odd thing one might ask is why the usage of ◊em{assert} in the source code? Asserts are typically for test cases.

  That is true, test cases utilize asserts to validate assumptions of written code with expected and actual outputs.

  But asserts are also great for programming ◊em{invariants} in your code. Meaning everything that comes after the assert line will do so knowing that whatever that was asserted beforehand is true.
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
