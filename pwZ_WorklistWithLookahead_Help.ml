open PwZ_WorklistWithLookahead

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
