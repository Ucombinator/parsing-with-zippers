OCAMLC := ocamlc

.PHONY: worklist
arithGrammar.cma: pwZ_Worklist.cma arithGrammar.ml
	$(OCAMLC) -a $^ -o $@

pwZ_Worklist.cma: pwZ_Worklist.ml
	$(OCAMLC) -a $^ -o $@

.PHONY: clean
clean:
	$(RM) *.cmi *.cmo *.cma *.cmxa
