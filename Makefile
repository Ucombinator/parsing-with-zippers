OCAMLC := ocamlc

WORKLIST_EXEC := worklist
EXECS := $(WORKLIST_EXEC)

WORKLIST_LIB := worklist.cma
ARITH_LIB := arith.cma

.PHONY: all
all: $(WORKLIST_EXEC)

$(WORKLIST_EXEC): $(WORKLIST_LIB) worklist.ml
	$(OCAMLC) $^ -o $@

$(WORKLIST_LIB): $(ARITH_LIB) pwZ_Worklist.cmo arithGrammar_Worklist.cmo
	$(OCAMLC) -a $^ -o $@

arithGrammar_Worklist.cmo: $(ARITH_LIB) pwZ_Worklist.cmo arithGrammar_Worklist.ml
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
