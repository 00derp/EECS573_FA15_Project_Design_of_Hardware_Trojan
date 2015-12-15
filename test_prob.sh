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
T1=0
T2=0
cycles=0
for file in testgenerator/*.s; do
	file=$(echo $file | cut -d'.' -f1)
	./vs-asm < $file.s > program.mem
	./simv > program.out
	
	grep 'Total' program.out
	if [ $? -eq "0" ] 
	then
		echo "Total Triggered: $file"
	fi
	T1=$(($T1+$(grep 'T1' program.out | wc -l)))
	T2=$(($T2+$(grep 'T2' program.out | wc -l)))
        cycles=$(($cycles+$(grep 'cycles' program.out | egrep -o '[0-9]{5}' | head -1)))
done 
echo $T1
echo $T2
echo $cycles
