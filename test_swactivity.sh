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
not_equal=0
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
        cycles=$(($cycles+$(grep 'cycles' program.out | egrep -o '[0-9]*' | head -1)))
        not_equal=$(($not_equal+$(tail program.out | head -1 | egrep -o '[0-9]*')))
done 
echo $cycles
echo $not_equal
