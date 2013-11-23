# Lem

Lem is a tool for lightweight executable mathematics, for writing,
managing, and publishing large-scale semantic definitions, with export
to LaTeX, executable code (currently OCaml) and interactive theorem
provers (currently Coq, HOL4, and Isabelle/HOL).

It is also intended as an intermediate language for generating
definitions from domain-specific tools, and for porting definitions
between interactive theorem proving systems.

Lem is under active development and has been used in several
applications, some of which can be found in the `examples` directory.  It is made available under the BSD 3-clause license, with the
exception of a few files derived from the OCaml, which are under the GNU
Library GPL.

Lem depends on [OCaml](http://caml.inria.fr/). Lem is tested against OCaml
3.12.1. and 4.00.0. Other versions might or might not work.

To build Lem run make in the top-level directory. This builds the
executable lem, and places a symbolic link to it in that directory. 

A high-level description of Lem is in the paper in `doc/lem-draft.pdf`.
The source language grammar and type system are defined in language/lem.ott,
available in a typeset form in language/lem.pdf.  There is also a very
preliminary manual (not currently up to date)
(http://www.cl.cam.ac.uk/~so294/lem/).



