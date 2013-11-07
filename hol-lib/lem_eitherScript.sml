(*Generated by Lem from ../library-new/either.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_boolTheory basic_classesTheory listTheory rich_listTheory lem_listTheory lem_numTheory sortingTheory sumTheory;

val _ = numLib.prefer_num();



val _ = new_theory "lem_either"



(*open import Bool Basic_classes List Tuple*)
(*open import {hol} `sumTheory`*)

(*type either 'a 'b
  = Left  of 'a
  | Right of 'b*)


(* -------------------------------------------------------------------------- *)
(* Equality.                                                                  *)
(* -------------------------------------------------------------------------- *)

(*val eitherEqual : forall 'a 'b. Eq 'a, Eq 'b => (either 'a 'b) -> (either 'a 'b) -> bool*)
(*val eitherEqualBy : forall 'a 'b. ('a -> 'a -> bool) -> ('b -> 'b -> bool) -> (either 'a 'b) -> (either 'a 'b) -> bool*)

val _ = Define `
 (eitherEqualBy eql eqr (left: ('a, 'b) sum) (right: ('a, 'b) sum) =  
((case (left, right) of
      ((INL l), (INL l')) => eql l l'
    | ((INR r), (INR r')) => eqr r r'
    | _ => F
  )))`;

(*let eitherEqual = eitherEqualBy (=) (=)*)

val _ = Define `
(instance_Basic_classes_Eq_Either_either_dict dict_Basic_classes_Eq_a dict_Basic_classes_Eq_b =(<|

  isEqual_method := (=)|>))`;

                           

(* -------------------------------------------------------------------------- *)
(* Utility functions.                                                         *)
(* -------------------------------------------------------------------------- *)

(*val isLeft : forall 'a 'b. either 'a 'b -> bool*)

(*val isRight : forall 'a 'b. either 'a 'b -> bool*)


(*val either : forall 'a 'b 'c. ('a -> 'c) -> ('b -> 'c) -> either 'a 'b -> 'c*)
(*let either fa fb x = match x with
  | Left a -> fa a
  | Right b -> fb b
end*)


(*val partitionEither : forall 'a 'b. list (either 'a 'b) -> (list 'a * list 'b)*)
 val _ = Define `
 (SUM_PARTITION l = ((case l of
    [] => ([], [])
  | x :: xs => (
      let (ll, rl) = (SUM_PARTITION xs) in
      (case x of 
          (INL l) => ((l::ll), rl)
        | (INR r) => (ll, (r::rl))
      )
    )
)))`;



(*val lefts : forall 'a 'b. list (either 'a 'b) -> list 'a*)


(*val rights : forall 'a 'b. list (either 'a 'b) -> list 'b*)


val _ = export_theory()
