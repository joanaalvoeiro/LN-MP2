#!/bin/bash

rm images/* compiled/*

for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done


#create text2num
fstconcat compiled/horas.fst compiled/e_to_colon.fst compiled/text2num_aux.fst
fstconcat compiled/text2num_aux.fst compiled/minutos.fst compiled/text2num.fst

#create lazy2num
fstconcat compiled/e_to_colon.fst compiled/minutos.fst compiled/lazy2num_aux1.fst
fstunion  compiled/lazy2num_aux1.fst compiled/zero_minutos.fst compiled/lazy2num_aux2.fst
fstconcat compiled/horas.fst compiled/lazy2num_aux2.fst compiled/lazy2num.fst

#create rich2text
fstproject compiled/horas.fst compiled/horas2text.fst
fstproject compiled/e_to_colon.fst compiled/e2text.fst
fstunion compiled/meias.fst compiled/quartos.fst compiled/meias_quartos.fst
fstconcat compiled/horas2text.fst compiled/e2text.fst compiled/rich2text_aux.fst
fstconcat compiled/rich2text_aux.fst compiled/meias_quartos.fst compiled/rich2text.fst

#create rich2num
fstcompose compiled/rich2text.fst  compiled/text2num.fst compiled/rich2num_aux.fst
fstunion compiled/rich2num_aux.fst compiled/lazy2num.fst compiled/rich2num.fst

#create num2text
fstinvert compiled/text2num.fst compiled/num2text.fst

#remove temporary files
rm compiled/e_to_colon.fst compiled/text2num_aux.fst
rm compiled/zero_minutos.fst compiled/lazy2num_aux1.fst compiled/lazy2num_aux2.fst
rm compiled/horas2text.fst compiled/e2text.fst compiled/meias_quartos.fst compiled/rich2text_aux.fst
rm compiled/rich2num_aux.fst

for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

#Testing rich2num

echo "Testing the transducer 'rich2num' with the input 'tests/sleepA_86375.txt'"
fstcompose compiled/sleepA_86375.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/sleepA_89469.txt'"
fstcompose compiled/sleepA_89469.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/wakeupA_86375.txt'"
fstcompose compiled/wakeupA_86375.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'rich2num' with the input 'tests/wakeupA_89469.txt'"
fstcompose compiled/wakeupA_89469.fst compiled/rich2num.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

#Testing num2text

echo "Testing the transducer 'num2text' with the input 'tests/sleepB_86375.txt'"
fstcompose compiled/sleepB_86375.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/sleepB_89469.txt'"
fstcompose compiled/sleepB_89469.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/wakeupB_86375.txt'"
fstcompose compiled/wakeupB_86375.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

echo "Testing the transducer 'num2text' with the input 'tests/wakeupB_89469.txt'"
fstcompose compiled/wakeupB_89469.fst compiled/num2text.fst | fstshortestpath | fstproject --project_type=output | fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt

