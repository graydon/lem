(**************************************************************************)
(*                        Lem                                             *)
(*                                                                        *)
(*          Dominic Mulligan, University of Cambridge                     *)
(*          Francesco Zappa Nardelli, INRIA Paris-Rocquencourt            *)
(*          Gabriel Kerneis, University of Cambridge                      *)
(*          Kathy Gray, University of Cambridge                           *)
(*          Peter Boehm, University of Cambridge (while working on Lem)   *)
(*          Peter Sewell, University of Cambridge                         *)
(*          Scott Owens, University of Kent                               *)
(*          Thomas Tuerk, University of Cambridge                         *)
(*                                                                        *)
(*  The Lem sources are copyright 2010-2013                               *)
(*  by the UK authors above and Institut National de Recherche en         *)
(*  Informatique et en Automatique (INRIA).                               *)
(*                                                                        *)
(*  All files except ocaml-lib/pmap.{ml,mli} and ocaml-libpset.{ml,mli}   *)
(*  are distributed under the license below.  The former are distributed  *)
(*  under the LGPLv2, as in the LICENSE file.                             *)
(*                                                                        *)
(*                                                                        *)
(*  Redistribution and use in source and binary forms, with or without    *)
(*  modification, are permitted provided that the following conditions    *)
(*  are met:                                                              *)
(*  1. Redistributions of source code must retain the above copyright     *)
(*  notice, this list of conditions and the following disclaimer.         *)
(*  2. Redistributions in binary form must reproduce the above copyright  *)
(*  notice, this list of conditions and the following disclaimer in the   *)
(*  documentation and/or other materials provided with the distribution.  *)
(*  3. The names of the authors may not be used to endorse or promote     *)
(*  products derived from this software without specific prior written    *)
(*  permission.                                                           *)
(*                                                                        *)
(*  THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS    *)
(*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED     *)
(*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE    *)
(*  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY       *)
(*  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL    *)
(*  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE     *)
(*  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS         *)
(*  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER  *)
(*  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR       *)
(*  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN   *)
(*  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                         *)
(**************************************************************************)



(* TODO: Implement this function in an external file and write a simple parser *)
let constant_label_to_path_name (label : string) : (string list * string) =
match label with
  | "equality" -> (["Pervasives"], "=")
  | "compare" -> (["Ocaml"], "compare")
  | "identity" -> (["Pervasives"], "id")

  | "conjunction" -> (["Bool"], "&&")
  | "implication" -> (["Bool"], "-->")

  | "addition" -> (["Pervasives"], "+")
  | "multiplication" -> (["Pervasives"], "*")
  | "subtraction" -> (["Pervasives"], "-")
  | "less_equal" -> (["Pervasives"], "<=")
  | "num_suc" -> (["Num"], "suc")

  | "list_concat" -> (["List"], "concat")
  | "list_cons" -> (["Pervasives"], "::")
  | "list_exists" -> (["List"], "exists")
  | "list_fold_right" -> (["List"], "fold_right")
  | "list_forall" -> (["List"], "forall")
  | "list_map" -> (["List"], "map")
  | "list_member" -> (["List"], "mem")

  | "maybe_just" -> (["Pervasives"], "just")
  | "maybe_nothing" -> (["Pervasives"], "none")

  | "nat_list_to_string" -> (["Pervasives"], "nat_list_to_string")

  | "set_add" -> (["Set"], "add")
  | "set_cross" -> (["Set"], "cross")
  | "set_exists" -> (["Set"], "exists")
  | "set_filter" -> (["Set"], "filter")
  | "set_fold" -> (["Set"], "fold")
  | "set_forall" -> (["Set"], "for_all")
  | "set_from_list" -> (["Set"], "from_list")
  | "set_image" -> (["Set"], "image")
  | "set_member" -> (["Set"], "IN")
  | "set_sigma" -> (["Set"], "set_sigma")

  | "vector_access" -> (["Vector"], "vector_access")
  | "vector_slice" -> (["Vector"], "vector_slice")
  | s -> Reporting_basic.report_error (Reporting_basic.Err_general (true,				     
            (Ast.Trans (false, "constant_label_to_path_name", None)),
            ("Unknown label '" ^ s ^ "'")))




