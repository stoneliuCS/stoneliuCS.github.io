#lang pollen

◊headline{learning systematic program design}

◊smaller-headline{1. The foundational building blocks}

◊p{
  When designing programs, at the most foundational level there needs to be some real-world problem that needs to be translated into the proper ◊em{data definitons}.

  Data definitions are how the ◊em{programmer} chooses to interpret entities, ideas, and things from the real world in their software system internally.

  Its important to note that these data definitions dont have to mirror what the outside world sees, indeed, proper internal data representations should hide most of the complexities to client code via a public ◊link["https://en.wikipedia.org/wiki/API"]{◊strong{API}}.

  The next steps might involve creating examples of these internal data representations, because the code probably won't get that far if you can't make examples of your own data representations.

  These tips will apply to any language, no matter how esoteric it can be because every programming language has some concept of ◊em{functions} and ◊em{data}.
}

◊smaller-headline{2. functions and objects}

◊p{
  Every complex software program can be boiled down to a bunch of functions or objects. 

  Objects in the case of ◊link[""]{OOP} provide a nice way to organize more complex data definitions. Objects like those present in languages like ◊link[""]{Java}, ◊link[""]{C#}, ◊link[""]{Python}, and ◊link[""]{TypeScript} ◊em{encapsulate} properties and methods. These methods should be related to what the interpretation of the object is, the same goes with properties.

  A neat thing about objects is that you can ◊em{inherit} from parent classes. The case for inheritance is widely debated, and many prefer a ◊em{dependency injection}, a fancy word for object composition.

  Polymorphism is usually divided into two categories, ◊em{ad-hoc polymorphism} or ◊em{parametric polymorphism}. Basically fancy terms for method-overriding and generics. The former allows the case for ◊em{dynamic dispatch}, where the compiler does not need to know at ◊em{compile-time} what the type of an object is, at ◊em{run-time} it will call the method properly. The latter generics also don't need to know the type is at ◊em{compile-time}, it will behave uniformally for all types.

  Functions on the other hand can be either ◊em{atomic} or ◊em{composite}, ◊em{pure} or ◊em{imperative}. Atomic functions are a little subjective, but usually atomic functions do typically one thing, and their purpose indicates so. Composite functions compose other functions, by keeping these definitions in mind, the structure of the code abstracts away layers of complexities such that any reader can understand at a very high level what a piece of software is doing.

  Pure functions, in my opinion are beautiful. It means that for every single input to some function ◊em{f}, the resulting output is always the same. There is no ◊em{state}. This way of programming makes it incredibly clear the ◊em{invariants} of a software system. Unlike imperative functions which do have some internal state, the temporal chain of method calls could result in different outputs for the same input.

  Mutation and aliasing are some of the most difficult parts of programming. Indeed mutable data will allow for some of the strangest software bugs one might encounter. However they are also necessary in most complex software systems. For example, something as simple as one's first program, printing a message to a console or terminal is ◊em{impure}. Mutability allows modification of the internal workings of a piece of software. For objects, this could mean setting an internal property to a different one than it started with. Aliasing refers to distinct names referring to the same object. This is a common source of bugs in OOP, as modifications to one object in a piece of software may result in changes else where in the code.
}

◊em{Designing reliable software at scale is a monumental challenge. One must approach all software systems with equal appreciation and awe of the complexities that run our modern world.}
