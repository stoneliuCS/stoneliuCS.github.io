#lang pollen

◊p{
  Given the roots of two binary trees p and q, write a function to check if they are the same or not.
  
  Two binary trees are considered the same if they are structurally identical, and the nodes have the same value.
}

◊p{
  The data definition is provided as follows:
  ◊code-block["python"]{
    class TreeNode:
        def __init__(self, val=0, left=None, right=None):
            self.val = val
            self.left = left
            self.right = right
  }

  This is ◊em{a structurally recursive data definiton, one can also write the same in ISL+}

  ◊code-block["racket"]{
    ;; A TreeNode is one of:
    ;; (make-leaf val)
    ;; (make-treenode TreeNode TreeNode)

    (define (tree-node-temp node)
      (cond [(leaf? node) (leaf-val node)]
            [(treenode? node) (...
                              (tree-node-temp (tree-node left)) 
                              (tree-node-temp (tree-node right)))]
      )
    )
  }
}

◊p{
  Trees are structurally recursive data structures. They are also self-referential. Meaning recursion is the perfect way to tackle this problem.
}
◊code-block["python"]{
    def isSameTree(self, p: Optional[TreeNode], q: Optional[TreeNode]) -> bool:
        if (p is None and q is None):
            return True
        elif (p is None or q is None):
            return False
        else:
           return p.val == q.val and self.isSameTree(p.left, q.left) and self.isSameTree(p.right, q.right)
}
