---
layout: article
title: "pg-jev Puts Jev Inside PostgreSQL's WHERE Clause—With an API Call Behind It"
short_title: "pg-jev: Jev in Postgres"
date: 2026-10-04
type: "Article Bite"
read_time: "3 min read"
source_name: "pg-jev"
source_url: "https://github.com/realZachi/pg-jev/releases/tag/v0.2.1"
source_published: 2026-10-03
last_reviewed: 2026-10-04
tags:
  - Databases
  - AI Models
  - Developer Tools
summary: "pg-jev makes Jev's probabilistic judgments callable from PostgreSQL, but its convenience comes with batched API requests containing row data, installation privileges, and data-sharing decisions."
additional_sources:
  - name: "pg-jev repository and README"
    url: "https://github.com/realZachi/pg-jev"
  - name: "pg-jev extension control file"
    url: "https://github.com/realZachi/pg-jev/blob/master/jev.control"
  - name: "TypeSafe System One API reference"
    url: "https://docs.typesafe.ai/api"
---

A SQL query can already answer whether a ticket is open. Could it also decide whether the customer *sounds ready to cancel*? [pg-jev](https://github.com/realZachi/pg-jev) brings TypeSafe's Jev decision model into PostgreSQL as ordinary functions. Its [October 3, 2026, v0.2.1 release](https://github.com/realZachi/pg-jev/releases/tag/v0.2.1) also permits a Jev-compatible local server without an API key. This is a community extension, not a TypeSafe product; it turns a natural-language condition into a model judgment, not a new kind of SQL index.

<figure class="remote-publisher-image" data-source-url="https://github.com/realZachi/pg-jev">
  <a href="https://github.com/realZachi/pg-jev/raw/master/docs/assets/header.svg">
    <img src="https://github.com/realZachi/pg-jev/raw/master/docs/assets/header.svg" width="1280" height="526" loading="lazy" decoding="async" referrerpolicy="no-referrer" alt="pg-jev project wordmark beside a cartoon PostgreSQL elephant holding a small data table.">
  </a>
  <figcaption>pg-jev's original project header, shown as identification—not a diagram of its SQL or API behavior. Image from the <a href="https://github.com/realZachi/pg-jev">project repository</a>; © 2026 Zachi, <a href="https://github.com/realZachi/pg-jev/blob/master/LICENSE">PostgreSQL License and notice</a>. <a href="https://github.com/realZachi/pg-jev/raw/master/docs/assets/header.svg">Open original image ↗</a></figcaption>
</figure>

## A predicate that calls a model

A [project example](https://github.com/realZachi/pg-jev/blob/master/.agents/skills/pgjev/SKILL.md) has the shape `SELECT * FROM tickets WHERE jev(tickets, 'the customer threatens to cancel');`. The first argument is the *row*, not a string column. `jev()` returns a boolean after applying a threshold to Jev's yes/no probability. Other functions expose the probability (`jev_prob`), choose from named options (`jev_choice`), or score an ordered set of levels (`jev_score`). You can combine them with normal SQL filters and sorting, but the prose condition is a semantic judgment—not a substitute for exact joins, date comparisons, or arithmetic.

Under the hood, pg-jev serializes rows and [batches questions](https://github.com/realZachi/pg-jev#how-it-works) into calls to TypeSafe's `POST /v1/systemone` contract. Its default batch holds 20 rows; the project says larger batches became less reliable at locating the intended row in its own tests. It reads ahead on base tables or views, keeps HTTPS connections around, and caches answers per backend session. Anonymous subquery rows cannot use that read-ahead path. A `LIMIT` can stop future work, but already in-flight requests may still finish; the default cache and total session memory are not capped by the prefetch-row setting.

The author's 2,000-row example reports roughly **3.5 seconds**, **100 requests**, and **$0.012** on a first pass, then about **50 milliseconds** from a warm session cache. Those are project-reported measurements for one setup, not an independent benchmark or a promise that your table will behave the same way. Cache hits do not make a new condition—or another database session—free.

## The trust boundary is in the database server

The extension's [control file](https://github.com/realZachi/pg-jev/blob/master/jev.control) requires `plpython3u`, PostgreSQL's untrusted Python language. Installation needs a superuser and PostgreSQL **14–17**, according to the project; managed services that withhold those capabilities cannot simply enable it. The SQL syntax is convenient, but the server process is now making model API requests on behalf of a query. With the default TypeSafe endpoint, row contents leave the database for that service. The local-compatible endpoint added in v0.2.1 can keep those requests on your network, but only if you configure and operate a compatible server.

The project exposes `jev.max_rows_per_statement` and `jev.max_chars_per_statement` as spend guards; both default to **off**. Apply cheap filters and column projection within the table or view supplied to `jev()` where possible. Its [read-ahead implementation](https://github.com/realZachi/pg-jev/blob/v0.2.1/sql/jev--0.2.1.sql#L326-L386) can send rows that an outer `WHERE` filter or `LIMIT` would later discard. For sensitive or large tables, test the actual rows sent, use the statement caps, and inspect `jev_stats()` rather than assuming a simple-looking query is cheap or private.

## Before trying it on real data

- Check whether you control a PostgreSQL 14–17 server with `plpython3u` and superuser access. Test in a disposable environment before installing an untrusted-language extension.
- Decide which row fields may cross the API boundary, and whether the hosted or a Jev-compatible local endpoint meets your data rules.
- Start with a small, labeled sample. Compare `jev_prob()` with your expected decisions and tune thresholds around uncertain cases rather than trusting a boolean by default.
- Set row and character caps; test whether the supplied relation narrows the data actually sent. Measure request count, cache growth, latency, and cost in your own sessions.

## Sources

- [pg-jev v0.2.1 release — realZachi](https://github.com/realZachi/pg-jev/releases/tag/v0.2.1)
- [pg-jev repository, README, examples, limits, and license](https://github.com/realZachi/pg-jev)
- [pg-jev repository license and copyright notice](https://github.com/realZachi/pg-jev/blob/master/LICENSE)
- [pg-jev agent skill and SQL query example](https://github.com/realZachi/pg-jev/blob/master/.agents/skills/pgjev/SKILL.md)
- [pg-jev v0.2.1 SQL implementation — read-ahead and batch submission](https://github.com/realZachi/pg-jev/blob/v0.2.1/sql/jev--0.2.1.sql#L326-L386)
- [pg-jev extension control file](https://github.com/realZachi/pg-jev/blob/master/jev.control)
- [TypeSafe System One API reference](https://docs.typesafe.ai/api)
