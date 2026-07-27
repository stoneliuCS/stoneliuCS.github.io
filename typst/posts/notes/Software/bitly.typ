#metadata((
  title: "design bitly",
  date: "2026-07-25",
)) <post-meta>
#import "../../../lib/web.typ": aside

#link("https://www.hellointerview.com/practice/system-design/cms0iswuh1hgk08ad41o9xzjc?q=non-functional-requirements")[Problem] goes like this...

== Functional Requirements
We want to design a system that primarily does URL-shortening... the system must support the following requirements

1. Submitting a URL should return a shortened version of the URL.
2. Shortened URLs can also be aliased or expired after a specified date.
3. Users should be able to access the original URL through the shortened URL.

#aside[
  Okay nevermind, I was wrong. We should provide availability vs strict consistency because that would mean that our users would get broken links when our system is down. Since the creation of urls is far less than the number of redirects we want to be very available.

  I also forgot to ensure uniqueness of short-urls.
]

== Non-Functional Requirements
We want to first decide whether we want our system to be consistent vs available, as in if one user submits a URL and receives that shortened URL, that shortened URL should work throughout all systems. Availability means that our service should prioritize always being online. Since this is a URL shortener, I believe that being consistent is much more important.

== Core Entities
- (URL Entity) So want a way to represent a shortened URL, perhaps a map of the provided url vs the actual url.
  - We also want a way to alias shortened URLs.

== API
- `POST /url -> str` Creates a unique shortened URL from the original URL.
  ```json
    {
      original_url : str,
      alias: str | null,
      expiration: datestring | null
    }
  ```

- `GET /url/{shortened_url}` redirects the client to the intended URL destination works with aliases.
- `PATCH /url/{shortened_url}`
  ```json
    {
      alias : str | null,
      expiration: datestring | null
    }
  ```

== High-Level Design
#image("/assets/img/bitly-high-level-design.png", width: 42em)

The client submits a URL to the URL Shortening Service, which writes a new URL Entity (original URL, shortened URL, alias, expiration) to the Database. It generates a unique hash for the URL and checks the database for a collision before inserting, assigning an index on every insert to keep lookups fast. On redirect, the service checks the Redis Cache first; only the first redirect for a given shortened URL or alias misses the cache and falls through to the Database, and every redirect after that is served from Redis.

Some key takeaways is that...
1. Horizontal scaling will enable processing more read requests per second.
2. Add caching on a very read heavy system will be useful like a redis cache that will be populated on the first redirect request for a specific url.
3. To enforce uniqueness, we might want something like a counter then encode it using base62 so the urls are short.
4. Typically we should separate out the API from the services from the database.
