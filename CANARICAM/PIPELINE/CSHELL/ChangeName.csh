#!/bin/csh
#

######################  Subroutine to change the long names provided by GTC

##
#### Inputs:
##
set infile = $1
(rm -rf tmp_${infile}) >& /dev/null
touch tmp_${infile}
set count=`wc -l ${infile} | awk '{ print $1 }'`
set i = `expr 1`
while ( $i <= $count )
	set infilei =  `cat ${infile} | head -${i} | tail -1 | awk '{print $1}'`
	set num1 =   `cat ${infile} | head -${i} | tail -1 | awk '{print $1}' |  cut -f1 -d"-" | cut -c7-11 ` 
	set num2 =   `cat ${infile} | head -${i} | tail -1 | awk '{print $1}' |  cut -f2 -d"-"` 
	echo "Converting...  "${infilei}" to    ===:>    S"${num2}"S"${num1}".fits"
	cp ${infilei} S${num2}S${num1}.fits
	echo S${num2}S${num1}.fits >> tmp_${infile}
	set i = `expr $i + 1`
end
mv tmp_${infile} ${infile} 
