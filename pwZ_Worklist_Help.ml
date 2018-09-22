open PwZ_Worklist

let concat_map (f : 'a -> 'b list) (l : 'a list) : 'b list =
  List.concat (List.map f l)

let plug ((e, c) : zipper) (p : pos) : exp list =
  let rec up (e : exp') (m : mem) : exp list =
    let e' = { m = m_0; e = e } in
    m.end_ <- p;
    m.result <- e';
    concat_map (up' e') m.parents
  and up' (e : exp) (c : cxt) : exp list =
    match c with
    | Top -> [e]
    | SeqC (m, l, left, right) ->
        up (Seq (l, List.append (List.rev left) (e :: right))) m
    | AltC m ->
        if p == m.end_
        then match m.result.e with
             | Alt es -> es := e :: !es; []
             | _ -> raise FailedMatch
        else up (Alt (ref [e])) m
  in up e c

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
