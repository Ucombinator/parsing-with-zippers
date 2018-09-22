# Parsing with Zippers

Parsing with Zippers (PwZ) is an extension of Parsing with Derivatives (Might
et al. 2011) using McBride derivatives (McBride 2001) and zippers (Huet 1997).

This repository is an implementation of two extensions to the
algorithm presented in our paper, namely:

1. A global worklist
2. One-token downward lookahead

## Building

The code is written in OCaml and was tested with OCaml 4.06.1.

There are two executables that can be built: `worklist` and `lookahead` which
correspond to the algorithms implemented in `pwZ_Worklist.ml` and
`pwZ_WorklistWithLookahead.ml`, respectively.

To build both, simply run `make`. They can also be built independently using
`make worklist` or `make lookahead`. (Note that `lookahead` is simply a short
name for the algorith which uses both a worklist and lookahead.)

To clean, run `make clean` or (if you wish to remove the executables)
`make clean-all`.

## Running

Once the executables are built, they can be run from the command line. They
each expect a single string representing a sequence of tokens for a simple
arithmetic grammar (detailed below). For example:

```
$ ./lookahead "6 * 9"
```

The program will print the resulting parse tree if the parse is successful or
a blank line if there was not a successful parse.

## Arithmetic Grammar

The included grammar is very straightforward. It is:

```
NUM     ::= <INT>
PAREN   ::= '(' EXPR ')'
ATOM    ::= NUM
          | PAREN

MULT    ::= TERM '*' TERM
T_ATOM  ::= ATOM
TERM    ::= MULT
          | T_ATOM

E_TERM  ::= TERM
ADD     ::= EXPR '+' EXPR
EXPR    ::= E_TERM
          | ADD
```

(`<INT>` represents any positive integer (a terminal), and items in single
quotes are terminals.)

Some examples of valid expressions:

- 42
- 1 + 3
- 4 * 3 + 2
- (3 + 4) * 7

This grammar is written in two files: `arithGrammar_Worklist.ml` and
`arithGrammar_WorklistWithLookahead.ml`. The latter file is identical to the
first except that each expression is also given a `first` array, where each
element corresponds to a token tag in the grammar and determines whether that
token is in the FIRST set of the respective expression.

Note that token tag 0 is the EOF, which is reserved for use by the parse
function that wraps the algorithm. It should not be used by user-implemented
tokens.

The token tags are defined in `arithTags.ml`.
