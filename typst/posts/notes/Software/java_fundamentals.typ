#metadata((
  title: "java fundamentals",
  date: "2026-07-24",
)) <post-meta>

Given that I have an upcoming Java interview, I think it would be a nice time to catergorize and index some notes about this programming language. #link("https://en.wikipedia.org/wiki/Java")[Java] provides a bunch of features including its strong emphasis on _Object Oriented Programming_ paradigm. Its also secure in the fact that you can share java programs without given the underlying source code.

== 1. What is the JVM
The #link("https://www.geeksforgeeks.org/java/how-jvm-works-jvm-architecture/")[Java Virtual Machine] enables java source code to be run on all platforms/OSes given that they have a compatiable _JVM_ installed. It acts as an intermediate interpreter that takes bytecode files, often referred to as `.class` files from the `javac` compiler. It then turns the bytecode files into machine code that can be directly ran on the underlying hardware. It uses techniques such as #link("https://en.wikipedia.org/wiki/Just-in-time_compilation")[(JIT) Just in time compliation] to make the execution of specific methods faster.

== 2. Strings in Java
Strings are _immutable_ objects that store a sequence of characters. Java provides access to a shared _String pool_ to optimize memory usage across an application by storing the literals of the string for reuse. Due to their immutable nature, they are sometimes less memory efficient than _StringBuilders_ which act as _mutable_ representations of strings in the case of very extensive writing of data. Strings are obviously thread-safe since they are immutable. The same cannot be said about _StringBuilders_ since two threads can call the same method at the same time, leading to race conditions. For the case of multi-threaded environments, use _StringBuffer_ since the methods are thread safe (synchronized).

== 3. Class Variables
Class variables are static variables that are stored within the Class itself. That is, it can be referenced without instantiating an object of a particular class. Instance variables require instantiation. Static variables thus have only one single reference and is shared among all objects instead of instance variables.

== 4. Stack Vs. Heap
Stack memory is typically allocated when a function is called. It pushes things like the arguments of the function, local variables, and return addresses. Once the function returns, everything on the stack is popped off meaning memory management is automatic. Heap memory is different since it can be accessed globally across the entire program. This is typically done when the size of something is unknown at compile-time, for example a resize-able array list.
