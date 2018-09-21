(* Simple type aliases.
 * Fig 1. *)
type lab = string
type tag = int
type pos = int
type tok = lab * tag

(* Additional types necessary for using zippers without memoization tables.
 * Fig 19.
 * The implementation of m_0 required the definition of a new `undefined` value,
 * which is given here. It is essentially a placeholder to be discarded. *)
type exp = { mutable m : mem; e : exp' }

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

let string_of_exp (e : exp) : string =
  let rec make_nice_string (e' : exp') (c : int) : string =
    let indent (i : int) (ss : string list) : string list =
      List.map (fun s -> (String.make i ' ') ^ s) ss
    in
    let join (ss : string list) : string =
      String.concat "\n" ss
    in
    let indent_subexp_strings (es : exp list) (ind : int) : string =
      match es with
      | [] -> ""
      | _ -> "\n" ^ (join (indent ind (List.map (fun e -> make_nice_string e ind) (List.map (fun e -> e.e) es))))
    in

    match e' with
    | T (l, t) ->
        "(T " ^ l ^ ")"
    | Seq (l, []) ->
        "(Seq " ^ l ^ ")"
    | Seq (l, e :: es) ->
        (let leader = "(Seq " ^ l ^ " " in
         let ind = c + String.length leader in
         leader ^ (make_nice_string e.e ind) ^ (indent_subexp_strings es ind) ^ ")"
        )
    | Alt (res) ->
        match !res with
        | [] ->
            "(Alt)"
        | e :: es ->
            (let leader = "(Alt " in
             let ind = c + String.length leader in
             leader ^ (make_nice_string e.e ind) ^ (indent_subexp_strings es ind) ^ ")"
            )
  in make_nice_string e.e 0

type zipper = exp' * mem

let rec undefined = {
  m = m_undefined;
  e = T ("undefined", -1) }

and m_undefined = {
  start = -1;
  parents = [];
  end_ = -1;
  result = undefined }

let m_0 = {
  start = -1;
  parents = [];
  end_ = -1;
  result = undefined }

(* A global worklist, used for TODO *)
let worklist : (zipper list) ref = ref []

(* A list of "tops", which gives us parse-null of a Top for free. TODO *)
let tops : exp list ref = ref []

(* An exception when a match fails. Should never appear. *)
exception FailedMatch

(* Core algorithm. Similar to Fig 20, but with additional steps taken. *)
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
    | Alt es                            -> List.iter
                                             (fun e -> d_d (AltC m) e)
                                             !es

  and d_u (e : exp') (m : mem) : unit =
    let e' = { m = m_0; e = e } in
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

let init_zipper (e : exp) : zipper =
  let e' = Seq ("<init_zipper:Seq>", []) in
  let m_top : mem = { start = 0; parents = [Top]; end_ = -1; result = undefined } in
  let c = SeqC (m_top, "<init_zipper:SeqC>", [], [e]) in
  let m_seq : mem = { start = 0; parents = [c]; end_ = -1; result = undefined } in
  (e', m_seq)

let unwrap_top_exp (e : exp) : exp =
  match e.e with
  | Seq (_, [_; e'])    -> e'
  | _                   -> raise FailedMatch

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
