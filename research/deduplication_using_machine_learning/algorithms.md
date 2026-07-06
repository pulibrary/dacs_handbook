# Algorithms for record deduplication

In the scholarly literature, record deduplication is also known as
"record linkage", "data cleaning" and "record matching"[1] -- a lot of articles come up for that search query.

A very classic algorithm in this domain is called Fellegi-Sunter.
[Here is an irreverent but interesting introduction to Fellegi-Sunter](https://horkan.com/2026/01/05/wtf-is-the-fellegi-sunter-model-a-practical-guide-to-record-matching-in-an-uncertain-world).
Fellegi and Sunter's method[2] depends on the definition of two boundary values that are used to classify a pair of records as being duplicates or not.[1] 

Lately, Markov Chain Monte Carlo algorithms seem very promising.
Two interesting examples:
   * [A Bayesian Approach to Graphical Record Linkage and De-duplication](https://arxiv.org/abs/1312.4645).
   * [Scaling Bayesian Probabilistic Record Linkage with Post-Hoc Blocking](https://arxiv.org/abs/1905.05337)

Also of interest is the question of which algorithms you use to determine
the similarity of a given pair of data records.

## Further reading

* [Classification algorithms](https://recordlinkage.readthedocs.io/en/latest/guides/classifiers.html) from the Python Record Linkage Toolkit
* [A nice tutorial on Fellegi Sunter](https://www.robinlinacre.com/probabilistic_linkage/)

References:
[1] Miss. J. R. Waykole et al Int. Journal of Engineering Research and Applications, A Survey Paper on Deduplication by Using Genetic Algorithm Alongwith Hash-Based Algorithm
  
[2]I.P. Fellegi and A.B. Sunter, “A Theory for Record Linkage,” J. Am. Statistical Assoc.,
vol. 66, no. 1, pp. 1183-1210, 1969
