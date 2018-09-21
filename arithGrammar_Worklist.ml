open PwZ_Worklist
open ArithTags

(* This format is the construction of our grammar.
 *
 * We have a Racket program that can generate these types of files, but this
 * example was written by hand. We would not recommend handwriting more complex
 * grammars, so we assume a "full" implementation of PwZ would utilize a similar
 * program to pre-generate these grammars. *)

let rec g_INT       = { m = m_0; e = T ("INT", t_INT) }
and g_OPEN_PAREN    = { m = m_0; e = T ("(", t_OPEN_PAREN) }
and g_CLOSE_PAREN   = { m = m_0; e = T (")", t_CLOSE_PAREN) }
and g_TIMES         = { m = m_0; e = T ("*", t_TIMES) }
and g_PLUS          = { m = m_0; e = T ("+", t_PLUS) }

and g_NUM           = { m = m_0; e = Seq ("NUM", [ g_INT ]) }
and g_PAREN         = { m = m_0; e = Seq ("PAREN", [ g_OPEN_PAREN; g_EXPR; g_CLOSE_PAREN ]) }
and g_ATOM          = { m = m_0; e = Alt (ref [ g_NUM; g_PAREN ]) }

and g_MULT          = { m = m_0; e = Seq ("MULT", [ g_TERM; g_TIMES; g_TERM ]) }
and g_T_ATOM        = { m = m_0; e = Seq ("T_ATOM", [ g_ATOM ]) }
and g_TERM          = { m = m_0; e = Alt (ref [ g_MULT; g_T_ATOM ]) }

and g_E_TERM        = { m = m_0; e = Seq ("E_TERM", [ g_TERM ]) }
and g_ADD           = { m = m_0; e = Seq ("ADD", [ g_EXPR; g_PLUS; g_EXPR ]) }
and g_EXPR          = { m = m_0; e = Alt (ref [ g_E_TERM; g_ADD ]) }

