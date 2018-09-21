open PwZ_Worklist
open PwZ_Worklist_Help
open ArithGrammar_Worklist
open ArithTokenizer

exception Bad_Arg_Count of int

let parse (s : string) : exp list =
  parse (tokenize s) g_EXPR

let string_list_of_exp_list (es : exp list) : string list =
  List.map string_of_exp es

let print_string_list (ss : string list) : unit =
  List.iter print_string (ss @ ["\n"])

let () =
  if Array.length Sys.argv != 2
  then raise (Bad_Arg_Count (Array.length Sys.argv))
  else print_string_list (string_list_of_exp_list (parse Sys.argv.(1)))
