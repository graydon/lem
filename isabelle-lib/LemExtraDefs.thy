(*========================================================================*)
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
(*========================================================================*)

header{* Auxiliary Definitions needed by Lem *}

theory "LemExtraDefs" 

imports 
 	 Main
   "~~/src/HOL/Map"
 	 "~~/src/HOL/Library/Efficient_Nat"
 	 "~~/src/HOL/Library/Char_nat"

begin 

subsection{* Sets *}

abbreviation (input) "set_choose s \<equiv> (SOME x. (x \<in> s))"

lemma set_choose_thm[simp]:
  "s \<noteq> {} \<Longrightarrow> (set_choose s) \<in> s"
by (rule someI_ex) auto

definition set_lfp:: "'a set \<Rightarrow> ('a set \<Rightarrow> 'a set) \<Rightarrow> 'a set" where
  "set_lfp s f = lfp (\<lambda>s'. f s' \<union> s)"
  
lemma set_lfp_tail_rec_def :
assumes mono_f: "mono f"
shows "set_lfp s f = (if (f s) \<subseteq> s then s else (set_lfp (s \<union> f s) f))" (is "?ls = ?rs")
proof (cases "f s \<subseteq> s")
  case True note fs_sub_s = this

  from fs_sub_s have "\<Inter>{u. f u \<union> s \<subseteq> u} = s" by auto
  hence "?ls = s" unfolding set_lfp_def lfp_def .
  with fs_sub_s show "?ls = ?rs" by simp
next
  case False note not_fs_sub_s = this
  
  from mono_f have mono_f': "mono (\<lambda>s'. f s' \<union> s)"
    unfolding mono_def by auto

  have "\<Inter>{u. f u \<union> s \<subseteq> u} = \<Inter>{u. f u \<union> (s \<union> f s) \<subseteq> u}" (is "\<Inter>?S1 = \<Inter>?S2")
  proof 
    have "?S2 \<subseteq> ?S1" by auto
    thus "\<Inter>?S1 \<subseteq> \<Inter>?S2" by (rule Inf_superset_mono)
  next  
    { fix e
      assume "e \<in> \<Inter>?S2"
      hence S2_prop: "\<And>s'. f s' \<subseteq> s' \<Longrightarrow> s \<subseteq> s' \<Longrightarrow> f s \<subseteq> s' \<Longrightarrow> e \<in> s'" by simp
      
      { fix s'
        assume "f s' \<subseteq> s'" "s \<subseteq> s'"
        
        from mono_f `s \<subseteq> s'` 
        have "f s \<subseteq> f s'" unfolding mono_def by simp
        with `f s' \<subseteq> s'` have "f s \<subseteq> s'" by simp
        with `f s' \<subseteq> s'` `s \<subseteq> s'` S2_prop
        have "e \<in> s'" by simp
      }
      hence "e \<in> \<Inter>?S1" by simp
    }  
    thus "\<Inter>?S2 \<subseteq> \<Inter>?S1" by auto
  qed
  hence "?ls = (set_lfp (s \<union> f s) f)" 
     unfolding set_lfp_def lfp_def .     
  with not_fs_sub_s show "?ls = ?rs" by simp
qed
  
lemma set_lfp_simps [simp] :
"mono f \<Longrightarrow> f s \<subseteq> s \<Longrightarrow> set_lfp s f = s" 
"mono f \<Longrightarrow> \<not>(f s \<subseteq> s) \<Longrightarrow> set_lfp s f = (set_lfp (s \<union> f s) f)" 
by (metis set_lfp_tail_rec_def)+



definition list_of_set :: "'a set \<Rightarrow> 'a list" where
   "list_of_set s = (SOME l. (set l = s \<and> distinct l))"

lemma list_of_set [simp] : 
  assumes fin_s: "finite s"
  shows "(set (list_of_set s) = s \<and> distinct (list_of_set s))"
unfolding list_of_set_def
proof (rule someI_ex)
  show "\<exists>l. set l = s \<and> distinct l" using fin_s
  proof (induct s)
    case empty
      show ?case by auto
    case (insert e s)
      note e_nin_s = insert(2)
      from insert(3) obtain l where set_l: "set l = s" and dist_l: "distinct l" by blast

      from set_l have set_el: "set (e # l) = insert e s" by auto
      from dist_l set_l e_nin_s have dist_el: "distinct (e # l)" by simp

      from set_el dist_el show ?case by blast
  qed
qed

subsection {* sum *}

find_consts "'a list => ('a list * _)"

fun sum_partition :: "('a + 'b) list \<Rightarrow> 'a list * 'b list"  where 
  "sum_partition [] = ([], [])"
| "sum_partition ((Inl l) # lrs) =
     (let (ll, rl) = sum_partition lrs in
     (l # ll, rl))"
| "sum_partition ((Inr r) # lrs) =
     (let (ll, rl) = sum_partition lrs in
     (ll, r # rl))"

lemma sum_partition_length :
  "List.length lrs = List.length (fst (sum_partition lrs)) + List.length (snd (sum_partition lrs))"
proof (induct lrs)
  case Nil thus ?case by simp
next
  case (Cons lr lrs) thus ?case
    by (cases lr) (auto split: prod.split)
qed  

subsection {* num to string conversions *}

definition nat_list_to_string :: "nat list \<Rightarrow> string" where
  "nat_list_to_string nl = map char_of_nat nl"
  
definition is_digit where
  "is_digit (n::nat) = (n < 10)"

lemma is_digit_simps[simp] : 
  "n < 10 \<Longrightarrow> is_digit n"  
  "\<not>(n < 10) \<Longrightarrow> \<not>(is_digit n)"
unfolding is_digit_def by simp_all  

lemma is_digit_expand :
  "is_digit n \<longleftrightarrow>
     (n = 0) \<or> (n = 1) \<or> (n = 2) \<or> (n = 3) \<or>  (n = 4) \<or>
     (n = 5) \<or> (n = 6) \<or> (n = 7) \<or> (n = 8) \<or>  (n = 9)"
unfolding is_digit_def by auto     

lemmas is_digitE = is_digit_expand[THEN iffD1,elim_format]
lemmas is_digitI = is_digit_expand[THEN iffD2,rule_format]

definition is_digit_char where
  "is_digit_char c \<longleftrightarrow>
     (c = CHR ''0'') \<or> (c = CHR ''5'') \<or> 
     (c = CHR ''1'') \<or> (c = CHR ''6'') \<or> 
     (c = CHR ''2'') \<or> (c = CHR ''7'') \<or> 
     (c = CHR ''3'') \<or> (c = CHR ''8'') \<or> 
     (c = CHR ''4'') \<or> (c = CHR ''9'')" 

lemma is_digit_char_simps[simp] : 
  "is_digit_char (CHR ''0'')"
  "is_digit_char (CHR ''1'')"
  "is_digit_char (CHR ''2'')"
  "is_digit_char (CHR ''3'')"
  "is_digit_char (CHR ''4'')"
  "is_digit_char (CHR ''5'')"
  "is_digit_char (CHR ''6'')"
  "is_digit_char (CHR ''7'')"
  "is_digit_char (CHR ''8'')"
  "is_digit_char (CHR ''9'')"
unfolding is_digit_char_def by simp_all  

lemmas is_digit_charE = is_digit_char_def[THEN iffD1,elim_format]
lemmas is_digit_charI = is_digit_char_def[THEN iffD2,rule_format]

definition digit_to_char :: "nat \<Rightarrow> char" where
  "digit_to_char n = (
     if n = 0 then CHR ''0'' 
     else if n = 1 then CHR ''1'' 
     else if n = 2 then CHR ''2'' 
     else if n = 3 then CHR ''3'' 
     else if n = 4 then CHR ''4'' 
     else if n = 5 then CHR ''5'' 
     else if n = 6 then CHR ''6'' 
     else if n = 7 then CHR ''7'' 
     else if n = 8 then CHR ''8'' 
     else if n = 9 then CHR ''9'' 
     else CHR ''X'')"

lemma digit_to_char_simps [simp]: 
  "digit_to_char 0 = CHR ''0''"
  "digit_to_char (Suc 0) = CHR ''1''"
  "digit_to_char 2 = CHR ''2''"
  "digit_to_char 3 = CHR ''3''"
  "digit_to_char 4 = CHR ''4''"
  "digit_to_char 5 = CHR ''5''"
  "digit_to_char 6 = CHR ''6''"
  "digit_to_char 7 = CHR ''7''"
  "digit_to_char 8 = CHR ''8''"
  "digit_to_char 9 = CHR ''9''"
  "n > 9 \<Longrightarrow> digit_to_char n = CHR ''X''"
unfolding digit_to_char_def
by simp_all
     
definition char_to_digit :: "char \<Rightarrow> nat" where
  "char_to_digit c = (
     if c = CHR ''0'' then 0  
     else if c = CHR ''1'' then 1 
     else if c = CHR ''2'' then 2 
     else if c = CHR ''3'' then 3 
     else if c = CHR ''4'' then 4 
     else if c = CHR ''5'' then 5 
     else if c = CHR ''6'' then 6 
     else if c = CHR ''7'' then 7 
     else if c = CHR ''8'' then 8 
     else if c = CHR ''9'' then 9 
     else 10)"

lemma char_to_digit_simps [simp]: 
  "char_to_digit (CHR ''0'') = 0"
  "char_to_digit (CHR ''1'') = 1"
  "char_to_digit (CHR ''2'') = 2"
  "char_to_digit (CHR ''3'') = 3"
  "char_to_digit (CHR ''4'') = 4"
  "char_to_digit (CHR ''5'') = 5"
  "char_to_digit (CHR ''6'') = 6"
  "char_to_digit (CHR ''7'') = 7"
  "char_to_digit (CHR ''8'') = 8"
  "char_to_digit (CHR ''9'') = 9"
unfolding char_to_digit_def by simp_all  


lemma diget_to_char_inv[simp]:
assumes is_digit: "is_digit n"
shows "char_to_digit (digit_to_char n) = n"
using is_digit unfolding is_digit_expand by auto

lemma char_to_diget_inv[simp]:
assumes is_digit: "is_digit_char c"
shows "digit_to_char (char_to_digit c) = c"
using is_digit
unfolding char_to_digit_def is_digit_char_def
by auto

lemma char_to_digit_div_mod [simp]:
assumes is_digit: "is_digit_char c"
shows "char_to_digit c < 10"
using is_digit
unfolding char_to_digit_def is_digit_char_def
by auto


lemma is_digit_char_intro[simp]: 
  "is_digit (char_to_digit c) = is_digit_char c"
unfolding char_to_digit_def is_digit_char_def is_digit_expand 
by auto

lemma is_digit_intro[simp]: 
  "is_digit_char (digit_to_char n) = is_digit n"
unfolding digit_to_char_def is_digit_char_def is_digit_expand 
by auto

lemma digit_to_char_11:
"digit_to_char n1 = digit_to_char n2 \<Longrightarrow> 
 (is_digit n1 = is_digit n2) \<and> (is_digit n1 \<longrightarrow> (n1 = n2))"
by (metis diget_to_char_inv is_digit_intro)

lemma char_to_digit_11:
"char_to_digit c1 = char_to_digit c2 \<Longrightarrow> 
 (is_digit_char c1 = is_digit_char c2) \<and> (is_digit_char c1 \<longrightarrow> (c1 = c2))"
by (metis char_to_diget_inv is_digit_char_intro)

function nat_to_string :: "nat \<Rightarrow> string" where
  "nat_to_string n =
     (if (is_digit n) then [digit_to_char n] else
      nat_to_string (n div 10) @ [digit_to_char (n mod 10)])"
by auto
termination 
  by (relation "measure id") (auto simp add: is_digit_def)
      
lemma nat_to_string_simps[simp]:
   "is_digit n \<Longrightarrow> nat_to_string n = [digit_to_char n]"
  "\<not>(is_digit n) \<Longrightarrow> nat_to_string n = nat_to_string (n div 10) @ [digit_to_char (n mod 10)]"
by simp_all
declare nat_to_string.simps[simp del]

lemma nat_to_string_neq_nil[simp]: 
  "nat_to_string n \<noteq> []" 
  by (cases "is_digit n") simp_all

lemmas nat_to_string_neq_nil2[simp] = nat_to_string_neq_nil[symmetric]

lemma nat_to_string_char_to_digit [simp]:
  "is_digit_char c \<Longrightarrow> nat_to_string (char_to_digit c) = [c]"
by auto

lemma nat_to_string_11[simp] :
  "(nat_to_string n1 = nat_to_string n2) \<longleftrightarrow> n1 = n2"
proof (rule iffI)
  assume "n1 = n2"
  thus "nat_to_string n1 = nat_to_string n2" by simp
next
  assume "nat_to_string n1 = nat_to_string n2"
  thus "n1 = n2" 
  proof (induct n2 arbitrary: n1 rule: less_induct)
    case (less n2')
    note ind_hyp = this(1)
    note n2s_eq = less(2) 
    
    have is_dig_eq: "is_digit n2' = is_digit n1" using n2s_eq
      apply (cases "is_digit n2'")
      apply (case_tac [!] "is_digit n1")
      apply (simp_all)
    done

    show ?case
    proof (cases "is_digit n2'")
      case True with n2s_eq is_dig_eq show ?thesis by simp (metis digit_to_char_11)
    next
      case False 
      with is_dig_eq have not_digs : "\<not> (is_digit n1)"  "\<not> (is_digit n2')" by simp_all       
    
      from not_digs(2) have "n2' div 10 < n2'" unfolding is_digit_def by auto
      note ind_hyp' = ind_hyp [OF this, of "n1 div 10"]

      from not_digs n2s_eq ind_hyp' digit_to_char_11[of "n1 mod 10" "n2' mod 10"]
      have "(n1 mod 10) = (n2' mod 10)" "n1 div 10 = n2' div 10" by simp_all 
      thus "n1 = n2'" by (metis mod_div_equality)
    qed
  qed
qed 

definition "is_nat_string s \<equiv> (\<forall>c\<in>set s. is_digit_char c)"
definition "is_strong_nat_string s \<equiv> is_nat_string s \<and> (s \<noteq> []) \<and> (hd s = CHR ''0'' \<longrightarrow> length s = 1)"

lemma is_nat_string_simps[simp]: 
  "is_nat_string []"
  "is_nat_string (c # s) \<longleftrightarrow> is_digit_char c \<and> is_nat_string s"
unfolding is_nat_string_def by simp_all

lemma is_strong_nat_string_simps[simp]: 
  "\<not>(is_strong_nat_string [])"
  "is_strong_nat_string (c # s) \<longleftrightarrow> is_digit_char c \<and> is_nat_string s \<and>
                                    (c = CHR ''0'' \<longrightarrow> s = [])"
unfolding is_strong_nat_string_def by simp_all


fun string_to_nat_aux :: "nat \<Rightarrow> string \<Rightarrow> nat" where
   "string_to_nat_aux n [] = n"
 | "string_to_nat_aux n (d#ds) =
    string_to_nat_aux (n*10 + char_to_digit d) ds"

definition string_to_nat :: "string \<Rightarrow> nat option" where
   "string_to_nat s \<equiv> 
    (if is_nat_string s then Some (string_to_nat_aux 0 s) else None)"

lemma string_to_nat_aux_inv :
assumes "is_nat_string s"
assumes "n > 0 \<or> is_strong_nat_string s"
shows "nat_to_string (string_to_nat_aux n s) =
(if n = 0 then '''' else nat_to_string n) @ s"
using assms
proof (induct s arbitrary: n)
  case Nil 
  thus ?case
    by (simp add: is_strong_nat_string_def)
next
  case (Cons c s n)
  from Cons(2) have "is_digit_char c" "is_nat_string s" by simp_all
  note cs_ok = Cons(3) 
  let ?m = "n*10 + char_to_digit c"
  note ind_hyp = Cons(1)[OF `is_nat_string s`, of ?m]
  
  from `is_digit_char c` have m_div: "?m div 10 = n" and
                              m_mod: "?m mod 10 = char_to_digit c"                              
    unfolding is_digit_char_def                               
    by auto
  
  show ?case
  proof (cases "?m = 0")
    case True
    with `is_digit_char c` 
    have "n = 0" "c = CHR ''0''" unfolding is_digit_char_def by auto 
    moreover with cs_ok have "s = []" by simp
    ultimately show ?thesis by simp  
  next
    case False note m_neq_0 = this
    with ind_hyp have ind_hyp':
      "nat_to_string (string_to_nat_aux ?m s) = (nat_to_string ?m) @ s" by auto

    hence "nat_to_string (string_to_nat_aux n (c # s)) = (nat_to_string ?m) @ s"
      by simp
       
    with `is_digit_char c` m_div show ?thesis by simp
  qed    
qed

lemma string_to_nat_inv :
assumes strong_nat_s: "is_strong_nat_string s"
assumes s2n_s: "string_to_nat s = Some n"
shows "nat_to_string n = s"
proof -
  from strong_nat_s have nat_s: "is_nat_string s" unfolding is_strong_nat_string_def by simp 
  with s2n_s have n_eq: "n = string_to_nat_aux 0 s" unfolding string_to_nat_def by simp

  from string_to_nat_aux_inv[of s 0, folded n_eq] nat_s strong_nat_s
  show ?thesis by simp
qed

lemma nat_to_string_induct [case_names "digit" "non_digit"]:
assumes digit: "\<And>d. is_digit d \<Longrightarrow> P d"
assumes not_digit: "\<And>n. \<not>(is_digit n) \<Longrightarrow> P (n div 10) \<Longrightarrow> P (n mod 10) \<Longrightarrow> P n"
shows "P n"
proof (induct n rule: less_induct)
  case (less n)
  note ind_hyp = this
  
  show ?case
  proof (cases "is_digit n")
    case True with digit show ?thesis by simp
  next
    case False note not_dig = this
    hence "n div 10 < n" "n mod 10 < n" unfolding is_digit_def by auto
    with not_dig ind_hyp not_digit show ?thesis by simp
  qed
qed

lemma nat_to_string___is_nat_string [simp]: 
  "is_nat_string (nat_to_string n)"
unfolding is_nat_string_def
proof (induct n rule: nat_to_string_induct)
  case (digit d)
  thus ?case by simp
next
  case (non_digit n)
  thus ?case by simp
qed

lemma nat_to_string___eq_0 [simp]: 
  "(nat_to_string n = (CHR ''0'')#s) \<longleftrightarrow> (n = 0 \<and> s = [])"
unfolding is_nat_string_def
proof (induct n arbitrary: s rule: nat_to_string_induct)
  case (digit d) thus ?case unfolding is_digit_expand by auto
next
  case (non_digit n)
  
  obtain c s' where ns_eq: "nat_to_string (n div 10) = c # s'"
     by (cases "nat_to_string (n div 10)") auto

  from non_digit(1) have "n div 10 \<noteq> 0" unfolding is_digit_def by auto
  with non_digit(2) ns_eq have c_neq: "c \<noteq> CHR ''0''" by auto 
     
  from `\<not> (is_digit n)` c_neq ns_eq
  show ?case by auto
qed

lemma nat_to_string___is_strong_nat_string: 
  "is_strong_nat_string (nat_to_string n)"
proof (cases "is_digit n")
  case True thus ?thesis by simp
next
  case False note not_digit = this
  
  obtain c s' where ns_eq: "nat_to_string n = c # s'"
     by (cases "nat_to_string n") auto

  from not_digit have "0 < n" unfolding is_digit_def by simp
  with ns_eq have c_neq: "c \<noteq> CHR ''0''" by auto
  hence "hd (nat_to_string n) \<noteq> CHR ''0''" unfolding ns_eq by simp
  
  thus ?thesis unfolding is_strong_nat_string_def 
    by simp 
qed

lemma nat_to_string_inv :
  "string_to_nat (nat_to_string n) = Some n"
by (metis nat_to_string_11 
          nat_to_string___is_nat_string 
          nat_to_string___is_strong_nat_string 
          string_to_nat_def 
          string_to_nat_inv)

definition The_opt where
  "The_opt p = (if (\<exists>!x. p x) then Some (The p) else None)"

lemma The_opt_eq_some [simp] :
"((The_opt p) = (Some x)) \<longleftrightarrow> ((p x) \<and> ((\<forall> y.  p y \<longrightarrow> (x = y))))"
    (is "?lhs = ?rhs")
proof (cases "\<exists>!x. p x")
  case True 
  note exists_unique = this
  then obtain x where p_x: "p x" by auto

  from the1_equality[of p x] exists_unique p_x 
  have the_opt_eq: "The_opt p = Some x"
    unfolding The_opt_def by simp
  
  from exists_unique the_opt_eq p_x show ?thesis
    by auto
next
  case False 
  note not_unique = this

  hence "The_opt p = None"
    unfolding The_opt_def by simp
  with not_unique show ?thesis by auto
qed  

lemma The_opt_eq_none [simp] :
"((The_opt p) = None) \<longleftrightarrow> \<not>(\<exists>!x. p x)"
unfolding The_opt_def by auto


end
