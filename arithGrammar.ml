open PwZ_Worklist

let rec g_INT = { m = m_0; e = T ("INT", 1) }
and g_OPEN_PAREN = { m = m_0; e = T ("(", 2) }
and g_CLOSE_PAREN = { m = m_0; e = T (")", 3) }
and g_TIMES = { m = m_0; e = T ("*", 4) }
and g_PLUS = { m = m_0; e = T ("+", 5) }

and g_NUM = { m = m_0; e = Seq ("NUM", [ g_INT ]) }
and g_PAREN = { m = m_0; e = Seq ("PAREN", [ g_OPEN_PAREN; g_EXPR; g_CLOSE_PAREN ]) }
and g_ATOM = { m = m_0; e = Alt (ref [ g_NUM; g_PAREN ]) }

and g_MULT = { m = m_0; e = Seq ("MULT", [ g_TERM; g_TIMES; g_TERM ]) }
and g_T_ATOM = { m = m_0; e = Seq ("T_ATOM", [ g_ATOM ]) }
and g_TERM = { m = m_0; e = Alt (ref [ g_MULT; g_T_ATOM ]) }

and g_E_TERM = { m = m_0; e = Seq ("E_TERM", [ g_TERM ]) }
and g_ADD = { m = m_0; e = Seq ("ADD", [ g_EXPR; g_PLUS; g_EXPR ]) }
and g_EXPR = { m = m_0; e = Alt (ref [ g_E_TERM; g_ADD ]) }

