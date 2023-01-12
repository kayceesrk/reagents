# reagents — Composable lock-free data and synchronization structures

reagents library is in experimental stage. It is distributed under the 
ISC license.

Homepage: https://github.com/ocaml-multicore/reagents

## Installation

The library is not in opam at the moment. But do feel invited to hack! 
```
$ opam switch create 5.0.0
$ git clone git@github.com:ocaml-multicore/reagents.git
```

## Documentation

The documentation and API reference is automatically generated from 
the source interfaces. It can be consulted [online](https://ocaml-multicore.github.io/reagents/doc/).

## Sample programs

The sample programs and tests are located in the [`examples`](examples) 
directory of the distribution. They can be built and run with:

    dune build @runtest
