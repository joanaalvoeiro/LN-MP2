#!/bin/bash

mkdir -p compiled images

for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

fstconcat compiled/horas.fst compiled/e_to_colon.fst compiled/text2num_aux.fst
fstconcat compiled/text2num_aux.fst compiled/minutos.fst compiled/text2num.fst

fstconcat compiled/e_to_colon.fst compiled/minutos.fst compiled/lazy2num_aux1.fst
fstunion  compiled/lazy2num_aux1.fst compiled/zero_minutos.fst compiled/lazy2num_aux2.fst
fstconcat compiled/horas.fst compiled/lazy2num_aux2.fst compiled/lazy2num.fst

fstproject compiled/horas.fst compiled/horas2text.fst
fstproject compiled/e_to_colon.fst compiled/e2text.fst
fstunion compiled/meias.fst compiled/quartos.fst compiled/meias_quartos.fst
fstconcat compiled/horas2text.fst compiled/e2text.fst compiled/rich2text_aux.fst
fstconcat compiled/rich2text_aux.fst compiled/meias_quartos.fst compiled/rich2text.fst

fstcompose  compiled/rich2text.fst  compiled/text2num.fst compiled/rich2num_aux.fst
fstunion compiled/rich2num_aux.fst compiled/lazy2num.fst compiled/rich2num.fst

rm compiled/e_to_colon.fst compiled/text2num_aux.fst
rm compiled/zero_minutos.fst compiled/lazy2num_aux1.fst compiled/lazy2num_aux2.fst
rm compiled/horas2text.fst compiled/e2text.fst compiled/meias_quartos.fst compiled/rich2text_aux.fst

for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

echo "Testing the transducer 'horas' with the input 'tests/teste_horas.txt'"
fstcompose compiled/teste_horas.fst compiled/horas.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'minutos' with the input 'tests/teste_minutos.txt'"
fstcompose compiled/teste_minutos.fst compiled/minutos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'meias' with the input 'tests/teste_meias.txt'"
fstcompose compiled/teste_meias.fst compiled/meias.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'quartos' with the input 'tests/teste_quartos.txt'"
fstcompose compiled/teste_quartos.fst compiled/quartos.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'text2num' with the input 'tests/teste_text2num.txt'"
fstcompose compiled/teste_text2num.fst compiled/text2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'lazy2num' with the input 'tests/teste_lazy2num.txt'"
fstcompose compiled/teste_lazy2num.fst compiled/lazy2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2text' with the input 'tests/teste_rich2text.txt'"
fstcompose compiled/teste_rich2text.fst compiled/rich2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/teste_rich2num.txt'"
fstcompose compiled/teste_rich2num.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
