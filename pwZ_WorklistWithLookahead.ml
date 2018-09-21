(* Simple type aliases.
 * Fig 1. *)
type lab = string       (* token and sequence labels *)
type tag = int          (* token tag, used for lookahead and token comparison *)
type pos = int          (* token position in input *)
type tok = lab * tag    (* token *)

(* An exception when a match fails. Should never appear.
 * This is primarily to suppress warnings in a safe manner. *)
exception FailedMatch

(* Additional types necessary for using zippers without memoization tables.
 * Fig 19.
 * The implementation of m_0 required the definition of a new `undefined` value,
 * which is given here. It is essentially a placeholder to be discarded. *)
type exp = { mutable m : mem; e : exp'; first : bool array }

and exp' = T of tok
         | Seq of lab * exp list
         | Alt of (exp list) ref

and cxt  = Top
         | SeqC of mem * lab * exp list * exp list
         | AltC of mem

and mem  = {
  start : pos;
  mutable parents : cxt list;
  mutable end_ : pos;
  mutable result : exp }

type zipper = exp' * mem

let rec undefined : exp = {
  m = m_undefined;
  e = T ("undefined", -1);
  first = [| |] }

and m_undefined : mem = {
  start = -1;
  parents = [];
  end_ = -1;
  result = undefined }

let m_0 : mem = {
  start = -1;
  parents = [];
  end_ = -1;
  result = undefined }

(* A global worklist. This is used for keeping track of what to do next. *)
let worklist : (zipper list) ref = ref []

(* A list of "tops", which gives us parse-null of a Top for free. This is useful
 * so that in the end we can simply return the result. *)
let tops : exp list ref = ref []

(* Core algorithm. Similar to Fig 20, but with additional steps taken for
 * performance. Note that the return type is now `unit`. *)
let derive (p : pos) ((t, i) : tok) ((e, m) : zipper) : unit = 

  let rec d_d (c : cxt) (e : exp) : unit =
    if p == e.m.start
    then (e.m.parents <- c :: e.m.parents;
          if p == e.m.end_
          then d_u' e.m.result c
          else ())
    else (let m = { start = p; parents = [c]; end_ = -1; result = undefined } in
          e.m <- m;
          d_d' m e.e)

  and d_d' (m : mem) (e : exp') : unit =
    match e with
    | T (t', i') ->
          if i == i'
            then worklist := (Seq (t, []), m) :: !worklist
            else ()
    | Seq (l, [])                       -> d_u (Seq (l, [])) m
    | Seq (l, e :: es)                  -> d_d (SeqC (m, l, [], es)) e
    | Alt es ->
          List.iter
            (fun e ->
              if e.first.(i)
              then d_d (AltC m) e
              else ())
            !es

  and d_u (e : exp') (m : mem) : unit =
    let e' = { m = m_0; e = e; first = [| |] } in
    m.end_ <- p;
    m.result <- e';
    List.iter (fun c -> d_u' e' c) m.parents

  and d_u' (e : exp) (c : cxt) : unit =
    match c with
    | Top                               -> tops := e :: !tops
    | SeqC (m, l, es, [])               -> d_u (Seq (l, List.rev (e :: es))) m
    | SeqC (m, l, left, e' :: right)    -> d_d (SeqC (m, l, e :: left, right)) e'
    | AltC m                            -> if p == m.end_
                                           then match m.result.e with
                                             | Alt es -> es := e :: !es
                                             | _ -> raise FailedMatch
                                           else d_u (Alt (ref [e])) m

  in d_u e m

(* Here we construct the initial zipper. This allows us to properly traverse the
 * grammar from the first step. This construction is similar in spirit to the
 * Seq/SeqC pair used on l318 (near the end of Section 4) of the paper. *)
let init_zipper (e : exp) : zipper =
  let e' = Seq ("<init_zipper:Seq>", []) in
  let m_top : mem = { start = 0; parents = [Top]; end_ = -1; result = undefined } in
  let c = SeqC (m_top, "<init_zipper:SeqC>", [], [e]) in
  let m_seq : mem = { start = 0; parents = [c]; end_ = -1; result = undefined } in
  (e', m_seq)

(* When a result is produced, it will have some vestigial structure remaining
 * from the initial zipper (see above). This function removes those extra bits
 * so only the important stuff is returned once the parse is complete. *)
let unwrap_top_exp (e : exp) : exp =
  match e.e with
  | Seq (_, [_; e'])    -> e'
  | _                   -> raise FailedMatch

(* This is our wrapper/driver function. It initializes blank worklist and tops
 * lists for each element in the worklist. This allows for a generational style
 * of worklist (where "child processes" can each have their own worklist).
 *
 * The token tag 0 is assumed to be reserved for the end of the input. *)
let parse (ts : tok list) (e : exp) : exp list =
  let rec parse (p : pos) (ts : tok list) : exp list =
    (let w = !worklist in
     worklist := [];
     tops := [];
     match ts with
     | [] -> List.iter (fun z -> derive p ("EOF", 0) z) w;
             List.map unwrap_top_exp !tops
     | ((t, s) :: ts') -> 
             List.iter (fun z -> derive p (t, s) z) w;
             parse (p + 1) ts')
  in worklist := [init_zipper e];
     parse 0 ts
