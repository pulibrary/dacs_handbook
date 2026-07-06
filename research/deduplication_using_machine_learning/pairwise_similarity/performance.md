# Performance of machine learning algorithms for deduplicating data records

The main performance issue is that comparing every single record in a corpus against
every other record has a time complexity of O(n^2).  So, even a relatively quick
comparison will take a lot of time when comparing millions of records against each
other.

One major approach is to use blocking.
[Dedupe.io's](https://docs.dedupe.io/en/latest/how-it-works/Making-smart-comparisons.html)
documentation has a nice description of blocking.

