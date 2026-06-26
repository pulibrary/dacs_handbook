# Algorithms for record deduplication

In the scholarly literature, record deduplication is also known as
"record linkage" -- a lot of articles come up for that search query.

A very classic algorithm in this domain is called Fellegi-Sunter.
[Here is an irreverent but interesting introduction to Fellegi-Sunter](https://horkan.com/2026/01/05/wtf-is-the-fellegi-sunter-model-a-practical-guide-to-record-matching-in-an-uncertain-world).

Lately, Markov Chain Monte Carlo algorithms seem very promising.
Two interesting examples:
   * [A Bayesian Approach to Graphical Record Linkage and De-duplication](https://arxiv.org/abs/1312.4645).
   * [Scaling Bayesian Probabilistic Record Linkage with Post-Hoc Blocking](https://arxiv.org/abs/1905.05337)

Also of interest is the question of which algorithms you use to determine
the similarity of a given pair of data records.

## Further reading

* [Classification algorithms](https://recordlinkage.readthedocs.io/en/latest/guides/classifiers.html) from the Python Record Linkage Toolkit
* [A nice tutorial on Fellegi Sunter](https://www.robinlinacre.com/probabilistic_linkage/)
