#lang pollen

As chief of software for Generate, I want to push two key agendas.
The primary goal is to raise the level of software engineering across the entire branch. (More on this later.)
The secondary goal is to get products deployed and make that the new normal.
What does it mean to raise the level of software engineering?
One of the goals is to really emphasize testing, and writing code that can be tested.
Exhibit one, when writing good software, end to end tests are the gold standard. Mocking complex API calls come second, and unit tests are third.
Composing databases are crucial, as you want the flexibility to pass in a production/development/test database.
Mocking complex services, S3 is huge but the key part is to construct the software such that it cannot discern between the real AWS service or not.

In TypeScript there is a great example of this with the AWS SDK Mocks, which can be typecasted into the client classes which services can compose of.

Git:
  - Rebasing!
  - Git rerere 
  - Merge conflicts!
  - Best practices.

My vision is for the software branch to deploy their applications and make shipping software the new normal.
My vision is also for the chiefs to be continously more involved with the branch as a whole
  - How I intend to do that is to faciliate more workshops, and foster newer levels of communications between TLs and Chiefs.
  - Git workshops! How to rebase, resolve merge conflicts, hacks! 
  - Docker Workshop, how to ship reliable software!
  - Nix Workshop, how to build reliable dev environments for everyone!
