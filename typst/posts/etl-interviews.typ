#import "@preview/diagraph:0.3.7"

= Information Worlds

Data is an _asset_ to virtually all companies. They can be grouped into two different systems, _the operational systems_ are where the data is put in, and the _data warehouse_ is where we get the data out. We can boil down the requirements of a data warehouse into several requirements:

- *The Data Warehouse must make an organization's information easily accessible.*
  - The contents of the data warehouse must be understandable and intuitive to the business owner and its stakeholders, not exclusively to developers.
  - _Slicing and Dicing_ is referred to the ability to seperate and combine data in endless combinations.
  - The tools enabling querying of the *Data Warehouse* must be simple, low cost, and fast.

- *The Data warehouse must present the organization's information consistently.*
  - If two performance metrics have the same name then they must mean the same thing.
  - If two performance metrics don't have the same name then they must be labeled differently.

- *The Data warehouse must be secure and protect the information assets.*

- *The Data warehouse must serve as the foundation for improved decision making.*

== Responsibilities for Managing a Data Warehouse
- Understand users by business area, job responsibilities, and computer tolerance.
- What kinds of decisions do the business leaders of the organization want to make with the data warehouse?
- Continously monitoring the the accuracy of the data and content of delivered reports.
- Publish data on a regular basis.

== Components of a Data Warehouse

The components of a data warehouse system can be enumerated as follows:

1. _Operational Source Systems_
2. _Data Staging Area_
3. _Data Presentation Area_
4. _Data Access Tools_

The full ETL pipeline can be viewed as such:

#figure(
  diagraph.render(
    "
    digraph {
      rankdir=LR
      a;
      b;
      c;
      d;

      a -> b;
      b -> c;
      c -> d;
      d -> c;
    }
    ",
    labels: (
      a: "Operational Source System",
      b: "Data Staging Area",
      c: "Data Presentation Area",
      d: "Data Access Tools",
    ),
  ),
)

=== Operational Source Systems
These systems enable recording/capturing of the transactions of the business. The source systems should be thought of as outside the data warehouse since you presumably have no control over the content and format of the data in these operational legacy systems. A good assumption to make is that these *Source System Databases* are not quried in the same manner like how the Data Warehouse is being queried.

=== Data Staging Systems
The data staging area is both a storage area and the set of processes which combined together create the _ETL Pipeline_. A nice analogy for the Data Staging system component of the data warehouse is the concept of the kitchen in the resturant. The kitchen staff is busy transforming raw ingredients into final dishes for the consumption of the customers. Customers aren't invited into the kitchen nor can they eat there. It isn't safe. The most foundational architecturaly requirement at this stage is that it is off limits to all all business users and does not provide query or presentation services.

==== Extraction, Transformation, Load
Extraction entails reading and understanding the source data. This comes from the _Operational Source Systems_.
Afterwards we want to be able to do numerous potential transformations such as cleansing the data. This could be small things such as correcting misspelled words, handling missing elements/values, and deduplicating data. It is also possible that the data can be extracted and normalized into some internal data structure _preprocessed_ before it gets to the staging area. It is important to distinguish this result since it can be incomprehensible to analysts or users it should never make it to the presentation area.

=== Data Presentation
The presentation area is (as far as the business is concerned) is the entire _Data Warehouse_. Since everything before it, such as staging and cleaning are off limits. The _Data Presentation_ layer is comprised of a bunch of _data marts_. A _data mart_ presents data for a single business process.

=== Dimensional Modeling
Is a technique that tries to make databases simpler, more organized, and understandable. One can think of a potential way to model a CEO's business emphasis on delivering products that target multiple markets and measure performance over time. We might be able to create a dimensional model by plotting points in relation to product, market, and time (in the form of a 3D cube). Then we can create slices and dices of the model in this _cube_. This differs from another technique called _3rd Normal Form (3NF)_ which are based off _Entity Relationships_. The data is divided into many discrete entities/tables, which helps prevent the same data happening across different places. The benefits of normalizing data into seperate entities include the processing performance since all the data is in one place. However this architecture might kill the efficiency/speed of a database query since it can be an incredibly complicated spider web of relations among several entities. This kind of architecture in the presentation area is not good since the whole point of the presentation layer is to enable efficent querying of data.

Dimensional modeling attempts to solve overly complicated schemas. The data marts in the presentation layer must contain _atomic data_. Thus it is not sufficient be able to deliver summaries of data/aggregations in dimensional models where the atomic data that was used for the aggregation is stored away in normalized tables. Furthermore the data must be stored in such a way whose design goals are user understandability, query performance, and resilience to change.
