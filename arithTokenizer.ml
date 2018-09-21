open ArithTags
open Char

exception FailedMatch

type token = string * int

let getInt (s : string) : token = (s, t_INT)

let getToken (c : char) : token =
  match c with
  | '(' -> ("(", t_OPEN_PAREN)
  | ')' -> (")", t_CLOSE_PAREN)
  | '*' -> ("*", t_TIMES)
  | '+' -> ("+", t_PLUS)
  | _   -> raise FailedMatch

let isInt (c : char) : bool =
  Char.code c >= 48 && Char.code c <= 57

let tokenize (str : string) : token list =
  let acc = ref "" in

  let append s n =
    s := !s ^ (String.make 1 n)
  in
  let rest s =
    String.sub s 1 ((String.length s) - 1)
  in
  let accumulate s xs =
    if String.length s > 0
    then (acc := "";
          (getInt s) :: xs)
    else xs
  in

  let rec iter s xs =
    match s with
    | "" -> List.rev (accumulate !acc xs)
    | _ ->
        (match s.[0] with
         | ' ' ->
             iter (rest s) xs
         | c when isInt c ->
             (append acc c;
              iter (rest s) xs)
         | c ->
             iter (rest s) ((getToken c) :: (accumulate !acc xs))
        )
  in iter str []
