#metadata(
  (
    title: "cypress",
    date: "2026-07-30",
  ),
) <post-meta>

#link("https://learn.cypress.io/cypress-fundamentals/how-to-write-a-test")[Cypress] is a framework for testing front-end javascript applications. It follows the pattern of _Arrange_, _Act_, _Assert_. The following is an example of the arranging a test suite in Cypress.

```javascript
cy.visit("localhost:3000") // Arrange
cy.get(".new-todo").type("Buy Milk{enter}") // Act
cy.get(".todo-list li").should("have.length", 1) // Assert
```

There are a few functions that we want to be able to use, including `describe` and `it`. The `describe` function takes a callback which can execute multiple test cases defined in `it` blocks.

== Command Chaining
This is very similar to a #link("https://en.wikipedia.org/wiki/Fluent_interface")[Fluent] API where you can chain multiple methods on a cypress object onto each other.

```javascript
// Example with method chaining that gets the H1 element tag of the website and asserts that it contains a specific piece of text.
cy.get("h1").contains("Testing Next.js Applications")
```

== Constructs
1. `describe()` is a function that groups the area of the testing suite. It also accepts a callback that contains/groups a test suite.
2. `it()` defines a singular test case, it is typically placed within the `describe` callback and accepts a callback with the testing code in it.
3. `before()` runs a single time before a test suite.
4. `after()` runs a single time after a test suite.
5. `beforeEach()` runs before each individual test inside a testing suite.
6. `afterEach()` runs after each individual testing suite. 
7. `skip()` skip testing suites.

== Asynchronous Nature of Cypress
`Cypress` commands do not return their subjects. Cypress commands *yield* their subjects. Which means that they are asynchronous and get queued for execution
