#!/bin/bash


#for file in test_progs/*.s; do
#	file=$(echo $file | cut -d'.' -f1)
#	#echo "Assembling $file"
#	./vs-asm < $file.s > program.mem
#	#echo "Running $file"
#	./simv > program.out
#	#echo "Saving $file output"
#	cp writeback.out ./$file"_writeback.out"
#	grep '@@@' ./program.out > ./$file"_program.out"
#done 

#cd ../project3
for file in test_progs/*.s; do
	file=$(echo $file | cut -d'.' -f1)
	./vs-asm < $file.s > program.mem
	./simv > program.out
	diff writeback.out ./test_progs_ans/$file"_writeback.out"
	if [ $? -eq "0" ] 
	then
		echo "PASSED"
	else 
		echo "@@@$file FAILED writeback.out comparison."
	fi
	
	grep '@@@' program.out > program_grep.out
	diff program_grep.out ./test_progs_ans/$file"_program.out"
	if [ $? -eq "0" ] 
	then
		echo "PASSED"
	else
		echo "@@@$file FAILED program.out comparison."
	fi
done 

