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
for file in testgenerator/*.s; do
	file=$(echo $file | cut -d'.' -f1)
	./vs-asm < $file.s > program.mem
	./simv > program.out
	
	grep 'Total' program.out
	if [ $? -eq "0" ] 
	then
		echo "Total Triggered: $file"
	fi
	grep 'T1' program.out
	if [ $? -eq "0" ]
	then
		echo "T1 Triggered: $file"
	fi
done 

