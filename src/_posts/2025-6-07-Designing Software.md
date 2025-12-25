---
layout: posts
author: Stone Liu
---
# learning systematic program design

## 1. the foundational building blocks

  When designing programs, at the most foundational level there needs to be some real-world problem that needs to be translated into the proper _data definitons_.

  Data definitions are how the _programmer_ chooses to interpret entities, ideas, and things from the real world in their software system internally.

  Its important to note that these data definitions dont have to mirror what the outside world sees, indeed, proper internal data representations should hide most of the complexities to client code via a public _API_

  The next steps might involve creating examples of these internal data representations, because the code probably won't get that far if you can't make examples of your own data representations.

  These tips will apply to any language, no matter how esoteric it can be because every programming language has some concept of _functions_ and _data_.

## 2. functions and objects

  Every complex software program can be boiled down to a bunch of functions or objects. 

  Objects in the case of _OOP_ provide a nice way to organize more complex data definitions. Objects like those present in languages like _Java_, _C#_, _Python_, and _TypeScript_ encapsulate properties and methods. These methods should be related to what the interpretation of the object is, the same goes with properties.

  A neat thing about objects is that you can _inherit_ from parent classes. The case for inheritance is widely debated, and many prefer a _dependency injection_, a fancy word for object composition.

  Polymorphism is usually divided into two categories, _ad-hoc polymorphism_ or _parametric polymorphism_. Basically fancy terms for method-overriding and generics. The former allows the case for _dynamic dispatch_, where the compiler does not need to know at _compile-time_ what the type of an object is, at _run-time_ it will call the method properly. The latter generics also don't need to know the type is at _compile-time_, it will behave uniformally for all types.

  Functions on the other hand can be either _atomic_ or _composite_, _pure_ or _imperative_. Atomic functions are a little subjective, but usually atomic functions do typically one thing, and their purpose indicates so. Composite functions compose other functions, by keeping these definitions in mind, the structure of the code abstracts away layers of complexities such that any reader can understand at a very high level what a piece of software is doing.

  Pure functions, in my opinion are beautiful. It means that for every single input to some function _f_, the resulting output is always the same. There is no _state_. This way of programming makes it incredibly clear the _invariants_ of a software system. Unlike imperative functions which do have some internal state, the temporal chain of function calls could result in different outputs for the same input.

  Mutation and aliasing are some of the most difficult parts of programming. Indeed mutable data will allow for some of the strangest software bugs one might encounter. However they are also necessary in most complex software systems. For example, something as simple as one's first program, printing a message to a terminal is _impure_. Mutability allows modification of the internal workings of a piece of software. For objects, this could mean setting an internal property to a different one than it started with. Aliasing happens when distinct names refer to the same object. This is a common source of bugs in OOP, as modifications to one object in a piece of software may result in changes else where in the code.


_Designing reliable software at scale is a monumental challenge. One must approach all software systems with equal appreciation and awe of the complexities that run our modern world._
