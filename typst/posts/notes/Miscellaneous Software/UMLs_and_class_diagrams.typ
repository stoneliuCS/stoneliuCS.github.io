#import "@preview/diagraph:0.3.7"

#metadata((
  title: "UML Diagrams",
  date: "2026-06-29",
)) <post-meta>

== Use Case Diagrams
Are high level diagrams that don't show lower level ideas and components. There are *4* different elements here, which include the _system_, _actors_, _use cases_, and _relationships_. 

*Systems* are whatever you are developing, which can be an app, idea, website, etc. The _system_ is typically represented by a large rectangle that encompasses everything involved inside the system.

*Actors* interact with the system to achieve a desired outcome or goal. This can be a person, organization, another system or component. Actors are typically not given explicit names and are draw outside of the system since they will be the ones interacting with it.
  - *Primary Actors* are the ones that initiate interactions with the system.
  - *Secondary Actors* are the reactionary, as in they respond to primary actors.
  - Primary actors should be to the left of the system while secondary actors should be on the right.

*Use Cases* represent actions that are done within a _system_ to accomplish some task. They are represented as ovals.
  - For example, a banking app might need the following actions to be done: _Log in_, _Check balance_, _Transfer funds_, and _Make payment_.
  - You can model relationships between actors and use cases via straight, solid lines _(association)_. Both the customer and bank will interact with an action like check balance because the bank has to supply the banking app with the customers balance, and the customer will want to check their balance on the banking app.
    - There are other forms of relationships that you can model, including _include_, _extend_, _generalization_.
    - Include involves describing dependencies between some sort of base use case and included use case.
      - The base use case requires an included use case in order to be considered complete. _We typically draw these as dotted arrows going from the base use case to the include use case._
    - Extend use cases may or may not happen whenever a base use case is executed. So it is not a complete dependency.
      - _We draw these as dotted arrows going from the extend use case to the base use case._

    - Generalization/Inheritance use cases are use cases that fall under a parent use case. For example whenever you want to make a payment to a banking platform you can either pay from your checkings or savings account. However both fall under this so called _Specialized Use Cases_.
      - _We typically draw these as a hierarchical arrow from the child to the parent use case_.
      - You can also have these generalizations in other elements of the diagram, such as actors.

== Class Diagrams
Say we want to build a system that represents a zoo, what we want to do is to represent the different sorts of entities in our system via _objects_ or classes.

For example we can create a class called _Animal_ that represents a generic animal. We can then give the class attributes associated with animals generally. We typically give the name of the attribute followed by their data type. Finally we can provide methods on the animal class that represent the types of actions a specific animal instance can do.

*Inheritance* represent hierarchies for our classes. Obviously its clear to us that we have specific types of animals that can inherit from some parent class. When we inherit, it obtains all the methods and attributes of their parent class on top of additional properties that are specific to the animal.
  - *Aggregation* relationships represent classes that can exist seperately without another class. For example a specific tortoise can belong to a _creep_ or group of tortoises but it doesn't have to be.
  - *Compositions* are relationships that are dependent on one another. For a class to compose another class, it must mean that it contains a dependency.
