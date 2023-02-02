(*
 * Copyright (c) 2015, Théo Laurent <theo.laurent@ens.fr>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

module Scheduler = Sched_ws.Make (struct
  let num_domains = 1
  let is_affine = false
  let work_stealing = false
end)

module Reagents = Reagents.Make (Scheduler)
open Scheduler
open Reagents
open Reagents.Channel

let mk_tw_chan () =
  let a_p, a_m = mk_chan ~name:"a" () in
  let b_p, b_m = mk_chan ~name:"b" () in
  ((a_p, b_p), (a_m, b_m))

let tw_swap (c1, c2) = swap c1 >>> swap c2

let work sw v () =
  let x = run (tw_swap sw) v in
  Printf.printf "%d" x

let main () =
  let sw1, sw2 = mk_tw_chan () in
  fork (work sw1 1);
  work sw2 2 ()

let _ = Scheduler.run_allow_deadlock main
