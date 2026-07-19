#metadata((
  title: "maintain price levels for a single-symbol order book",
  date: "2026-07-16",
  wip: true,
)) <post-meta>
#import "../../../lib/web.typ": aside

#link("https://prachub.com/interview-questions/maintain-price-levels-for-a-single-symbol-order-book")[Problem] goes like this...

We want to implement a #link("https://en.wikipedia.org/wiki/Nasdaq")[NASDAQ] data book for a single symbol. We get callbacks when orders are inserted, modified, or canceled.

An order has:
1. An id: `int`
2. A side: `str` _what is a side?_
  - A side is a enum of either _buy_ or _sell_
3. A price: `int`
4. A Quantity: `int`

We need to implement a data structure called `OrderBook` with the following function signature

```
def on_order_insert(self, order_id: int, side: str, price: int, qty: int) -> None:
def on_order_modify(self, order_id: int, price: int, qty: int) -> None:
def on_order_cancel(self, order_id: int) -> None:
def get_price_level(self, side: str, level_index: int) -> tuple[int, int] | None:
```

Specifically `get_price_level` means to get the price of a side at a specific level. This was pretty confusing to interalize and comprehend but what we want to do is effectively and efficiently store and retrieve the highest buy prices and the lowest sell prices. For example they give us the following example:

```
Insert buy id 1 price 100 qty 5; insert buy id 2 price 101 qty 3. get_price_level('buy', 0) returns (101, 3).
-> on_order_insert(1, "buy", 100, 5)
-> on_order_insert(2, "buy", 101, 3)
Since 101 > 100, the current highest price order should be (101,3).
```
So we need to keep track of a few things, the first thing we need to keep track of is the buy id to prices and quantity. We could create a hashmap that maps a buy id to its price and quantity, that would be efficient for storing it. We would also need to maintain the highest buy prices and the lowest sell prices in order according to the level. This is most likely the trickest caveat here because we could keep two running lists for both but that would be $n log (n)$ average time per insertion.

Another example we could have is that we place two buy orders with the same price

```
on_order_insert(1, "buy", 101, 5)
on_order_insert(2, "buy", 101, 3)
The current highest price order should still be 101 but we return a quantity of 5 + 3 = 8.
```
So it seems like we need to keep track of prices and their gross quantities. The biggest bottleneck is probably this insertion vs query tradeoff. The simplest thing that I can do is represent the buy and sell levels as a list. The worse case scenario is that inserts are going to be at the front which means that at worse case my inserts will take $O(n)$ time. So I need a way to be able to insert and query in sorted order at a reasonable rate. One data structure that lets me do inserts and maintain order of my entire order history would have to be a balanced binary tree such as a #link("https://en.wikipedia.org/wiki/AVL_tree")[AVL Tree] or #link("https://en.wikipedia.org/wiki/Red%E2%80%93black_tree")[Red-Black Trees].

== Self Balancing Binary Trees
For this problem I will implement an AVL tree for efficient search, deletions, and insertions. The AVL Tree is a collection of nodes with a value that is called the _Balance Factor_.

$
  "Balance"("Node_X)" = "Height"("Node_X.left") - "Height"("Node_X.right")
$

So I will represent the node as this:
```c
class Node {
  public:
    Node* left;
    Node* right;
    int balance;
    int size; // The number of nodes in the left and right sub tree + 1
    int price;
    Node(Node* left, Node* right, int balance, int size, int price) {
      this->left = left;
      this->right = right;
      this->balance = balance;
      this->size = size;
      this->price = price;
    }
};
```
The key will be represented as $3$ values, the price which will be the price of the order. But we also want a fast way to query the $k$th level which means that we want to store the number of nodes that are below it include the current node as well as the balance factor.
