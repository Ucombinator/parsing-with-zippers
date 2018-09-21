OCAMLC := ocamlc

ARITHLIB := arith.cma

.PHONY: worklist
worklist: worklist.cma

worklist.cma: $(ARITHLIB) pwZ_Worklist.cmo arithGrammar_Worklist.cmo
	$(OCAMLC) -a $^ -o $@

arithGrammar_Worklist.cmo: $(ARITHLIB) arithGrammar_Worklist.ml
	$(OCAMLC) -c $^ -o $@

$(ARITHLIB): arithTags.cmo arithTokenizer.ml
	$(OCAMLC) -a $^ -o $@

%.cmo: %.ml
	$(OCAMLC) -c $^

.PHONY: clean
clean:
	$(RM) *.cmi *.cmo *.cma *.cmxa
