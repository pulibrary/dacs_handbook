## Experimenting with finite state transducers using thrax

A Finite State Transducer (FST) is a way to map input strings to output strings using rules.  [Lucene contains an FST implementation](https://github.com/apache/lucene/blob/main/lucene/core/src/java/org/apache/lucene/util/fst/FST.java).
[Solr uses it as its default lookup](https://solr.apache.org/guide/solr/9_8/query-guide/suggester.html#fstlookupfactory)
for the Suggester (auto-suggest).

Thrax is a good way to quickly get feedback on whether a particular rule will work or not.

### Setup with homebrew

```
brew install thrax
```

### Create a grammar to mess around with

```
cp $(brew --prefix thrax)/share/thrax/grammars/example.grm my-thrax.grm
```

### Test your rules

1. Create a list of strings that you would like to test, say names.txt
1. `thraxmakedep my-thrax.grm` (ignore the SyntaxWarning)
1. `make`
1. `cat names.txt | thraxrewrite-tester --far=my-thrax.far --rules=TOKENIZER`
