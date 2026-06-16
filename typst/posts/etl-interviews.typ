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

=== Operational Source Systems
These systems enable recording/capturing of the transactions of the business. The source systems should be thought of as outside the data warehouse since you presumably have no control over the content and format of the data in these operational legacy systems. A good assumption to make is that these *Source System Databases* are not quried in the same manner like how the Data Warehouse is being queried.

=== Data Staging Systems
The data staging area is both a storage area and the set of processes which combined together create the _ETL Pipeline_. A nice analogy for the Data Staging system component of the data warehouse is the concept of the kitchen in the resturant. The kitchen staff is busy transforming raw ingredients into final dishes for the consumption of the customers. Customers aren't invited into the kitchen nor can they eat there. It isn't safe.
