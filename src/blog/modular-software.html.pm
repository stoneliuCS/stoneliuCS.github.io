#lang pollen

◊headline{modular software}


◊p{
  What is ◊em{modular software design}? It means to build and organize software systems in such a way that only modules interact with each other through their ◊em{Interfaces/public APIs}. This is a good thing, because when software projects get older, things tend to break for uncountably many reasons. Real software systems typically take advantage of modular code because it allows an individual contributor to work on a feature in an otherwise extremely complex and tangled codebase without having to know the underlying complexities underneath. Indeed modular architecture is just a fancy wrapper around ◊em{abstraction}.

  We rely on libraries everyday when building useful software, and one way to leverage modular architecture when integrating other people's software/library code into our own projects is through the concept of ◊em{wrappers}. In my opinion, in general it is always best to wrap any code that you do not own. This is because we do not want to conform our code to somebody else's public API. Here is an example:
}

◊code-block["typescript"]{
 import { fooClient } from './notMyModule';
 // ...
 const baz = fooClient.bar()
 somethingInteresting(baz)
 // ...
}


◊p{
  If this is an external API call, then we should not be directly importing this and using it in our code, because now we have made our code impossible to test without actually invoking a potentially expensive call. More-so, if the API ever gets updated, then our code breaks. Instead we should wrap the library import in a class that we have control over.
}

◊code-block["typescript"]{
 import { fooClient } from './notMyModule';
 class MyFooClient() {
   constructor(fooClient) {
     this.fooClient = fooClient
   }
   baz() {
     return this.fooClient.bar()
   }
   // ...
 }
}

◊p{
  Now we have complete control of the API to the fooClient, and therefore are protected against any breaking API changes. Furthermore, if we only have our code talk to the external API of MyFooClient, then we can easily test this by creating a mock class without breaking our code. In addition, if we ever want to extend functionality to the fooClient, we can do that since we are not restricted to just the public API of the fooClient library, we can add whatever we need as we please.
}
