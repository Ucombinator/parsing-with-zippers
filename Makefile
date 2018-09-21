OCAMLC := ocamlc

WORKLIST_EXEC := worklist
LOOKAHEAD_EXEC := lookahead
EXECS := $(WORKLIST_EXEC) $(LOOKAHEAD_EXEC)

WORKLIST_LIB := worklist.cma
LOOKAHEAD_LIB := lookahead.cma
ARITH_LIB := arith.cma

.PHONY: all
all: $(WORKLIST_EXEC) $(LOOKAHEAD_EXEC)

$(WORKLIST_EXEC): $(WORKLIST_LIB) worklist.ml
	$(OCAMLC) $^ -o $@

$(WORKLIST_LIB): $(ARITH_LIB) pwZ_Worklist.cmo pwZ_Worklist_Help.cmo arithGrammar_Worklist.cmo
	$(OCAMLC) -a $^ -o $@

arithGrammar_Worklist.cmo: $(ARITH_LIB) pwZ_Worklist.cmo arithGrammar_Worklist.ml
	$(OCAMLC) -c $^ -o $@


$(LOOKAHEAD_EXEC): $(LOOKAHEAD_LIB) lookahead.ml
	$(OCAMLC) $^ -o $@

$(LOOKAHEAD_LIB): $(ARITH_LIB) pwZ_WorklistWithLookahead.cmo pwZ_WorklistWithLookahead_Help.cmo arithGrammar_WorklistWithLookahead.cmo
	$(OCAMLC) -a $^ -o $@

arithGrammar_WorklistWithLookahead.cmo: $(ARITH_LIB) pwZ_WorklistWithLookahead.cmo arithGrammar_WorklistWithLookahead.ml
	$(OCAMLC) -c $^ -o $@


$(ARITH_LIB): arithTags.cmo arithTokenizer.ml
	$(OCAMLC) -a $^ -o $@

%.cmo: %.ml
	$(OCAMLC) -c $^

.PHONY: clean-all
clean-all: clean
	$(RM) $(EXECS)

.PHONY: clean
clean:
	$(RM) *.cmi *.cmo *.cma *.cmxa
