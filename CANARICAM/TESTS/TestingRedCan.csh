#!/bin/csh
#


echo "##############################################################" 
echo "##             RedCan needs the following software:         ##"
echo "##                  (25 September 2013)                     ##"
echo "##                  O. Gonzalez-Martin                      ##"
echo "##                                                          ##"
echo "##     - Gemini 1.11.1                                      ##"
echo "##     - login.cl of IRAF at your home directory            ##"
echo "##     - wcstools (no version restriction detected)         ##"
echo "##     - python                                             ##"
echo "##     - idl                                                ##"
echo "##     - tcsh/csh                                           ##"
echo "##     - IRAF2.14 or IRAF2.15                               ##"
echo "##     - PyRAF                                              ##"
echo "##         >> If IRAF2.15 PyRAF v1.11 is mandatory          ##"
echo "##                                                          ##"
echo "##      This procedure will check these dependences         ##"
echo "##     giving a list of needed changes of versions          ##"
echo "##      or new installations.                               ##"
echo "##                                                          ##"
echo "##############################################################"
echo "Started... " `date`

(ln -sf ${HOME}/login.cl .)  >& /dev/null
set IRAFVERS = "NOREQUIRED"
set PYRAFVERS = "NOREQUIRED"

echo " "
echo "#### 1. Computer: 32- or 64-bits?..."
set BITTS = `uname -m | cut -f2 -d"_"`
echo "Computer using: "${BITTS}
pyraf -c gemini > kk.txt		

echo " "
echo "#### 2. Trying to find IRAF..."
locate /iraf/ > kk2.txt
set numcolumnsiraf = `cat -n kk2.txt | tail -1 | awk '{print $1}'`
if ("${numcolumnsiraf}" <= 10) then
	echo "NO IRAF AT ALL"
	#if ("${BITTS}" == '64') then 
	#	echo "ERROR: YOU NEED TO INSTALL IRAF VERSION 2.14"
	#else
	echo "ERROR: YOU NEED TO INSTALL IRAF VERSION 2.14 or 2.15"
	echo "		 IF YOU INSTALL IRAF VERSION 2.15 REMEMBER THAT YOU WILL NEED PyRAF v1.11"	
	#endif
else
	echo "GOOD: IRAF found!"
	echo " "
	echo "#### 3. Checking IRAF version..."
	set currentirafversion = `cat kk.txt | grep Revision | cut -f2 -d"." | cut -f1 -d" "`
	if ("${currentirafversion}" != "14" ) then
		if ( "${currentirafversion}" != "15") then
			echo "ERROR: No correct IRAF version"
			echo "ERROR: You need IRAF v2.14 or v2.15 while you have v2."${currentirafversion}
		else
			echo "GOOD: IRAF v2."${currentirafversion}
		endif
	else
		echo "GOOD: IRAF v2."${currentirafversion}
	endif
	
endif
#############################################################

echo " "
echo "#### 4. Trying to find PyRAF..."
locate pyraf > kk2.txt
set numcolumnspyraf = `cat -n kk2.txt | tail -1 | awk '{print $1}'`
if ("${numcolumnspyraf}" <= 10) then
	echo "ERROR: NO PYRAF AT ALL."	
	if ("${IRAFVERS}" == '15') then
		set PYRAFVERS = '1.11'
		echo "ERROR: You don't have PyRAF: Need to install PyRAF v1.11"	
	else
		echo "ERROR: You don't have PyRAF: Any PyRAF version should be fine"	
	endif
else
	echo "GOOD: PYRAF found."
	echo " "
	echo "#### 5. Checking PyRAF version..."
	#pyraf -c gemini > kk.txt		
	set currentpyrafversion = `cat kk.txt  | grep PyRAF | cut -f2 -d" "`
	#echo "PyRAF v${currentpyrafversion}  "$PYRAFVERS 
	if ("${currentpyrafversion}" != "${PYRAFVERS}" ) then
		if ( "${PYRAFVERS}" != 'NOREQUIRED') then
			echo "ERROR: You need PyRAF v"${PYRAFVERS}" but you have v${currentpyrafversion}" 
		else
			echo "GOOD: PyRAF v${currentpyrafversion}"	
		endif
	else
		echo "GOOD: PyRAF v${currentpyrafversion}"
	endif
endif

echo " "
echo "#### 6. Trying to find Gemini package..."
locate gemini | grep iraf > kk2.txt 
set numcolumnsgemini = `cat -n kk2.txt | tail -1 | awk '{print $1}'`
if (${numcolumnsgemini} >= 100) then
	echo "GOOD: Gemini found." 
	echo " "
	echo "#### 7. Checking Gemini version..."
	set currentgeminiversion = `cat kk.txt  | grep Version | cut -f1 -d"," | cut -f2 -d"n" | cut -f2 -d" "`
	if ("${currentirafversion}" == '15') then
		if ("${currentgeminiversion}" != '1.11' ) then
			echo "ERROR: You need Gemini v1.11 but you have v${currentgeminiversion}" 		
		else
			echo "GOOD: Gemini v${currentgeminiversion}" 
		endif
		if ("${currentirafversion}" == '14') then	
			echo "GOOD: Gemini v${currentgeminiversion}" 
		endif
	endif
else
	if ("${currentirafversion}" == '15') then
		echo "ERROR: Please install Gemini v1.11"
	else
		echo "ERROR: Please install Gemini v1.11"
	endif
endif

echo " "
echo "#### 8. Trying to find login.cl in your home..."
if (-e ${HOME}/login.cl) then
	echo "GOOD: login.cl found at:" `ls ${HOME}/login.cl`
else
	echo "ERROR: login.cl not found. Please go to your home and type mkiraf."
endif

echo " "
echo "#### 9. Trying to find WCSTOOLS..."
echo "NONE" > kk1.txt
echo "NONE" > kk2.txt
which wcstools >> kk1.txt
which gethead >> kk2.txt
set numcolumnwcs = `cat -n kk1.txt | tail -1 | awk '{print $1}'`
set numcolumngethead = `cat -n kk2.txt | tail -1 | awk '{print $1}'`
if (${numcolumnwcs} >= 2) then 
	if (${numcolumngethead} >= 2) then 
		echo "GOOD: WCSTOOLS found." 
	else
		echo "ERROR: WCSTOOLS not found. Please install it." 	
	endif
else
	echo "ERROR: WCSTOOLS not found. Please install it." 
endif

echo " "
echo "#### 10. Trying to find Python..."
echo "NONE" > kk1.txt
which python >> kk1.txt
set numcolumnpython = `cat -n kk1.txt | tail -1 | awk '{print $1}'`
if (${numcolumnpython} >= 2) then 
	echo "GOOD: Python found." 
else
	echo "ERROR: Python not found. Please install it." 
endif

echo " "
echo "#### 11. Trying to find csh/tcsh..."
echo "NONE" > kk1.txt
echo "NONE" > kk2.txt
which csh >> kk1.txt
which tcsh >> kk2.txt
set numcolumncsh = `cat -n kk1.txt | tail -1 | awk '{print $1}'`
set numcolumntcsh = `cat -n kk2.txt | tail -1 | awk '{print $1}'`
if (${numcolumntcsh} >= 2) then 
	echo "GOOD: TCSH found." 
else
	echo "ERROR: TCSH not found. Please install it." 	
endif

if (${numcolumncsh} >= 2) then 
	echo "GOOD: CSH found." 
else
	echo "ERROR: CSH not found. Please install it." 
endif

echo " "
echo "#### 12. Trying to find IDL..."
echo "NONE" > kk1.txt
which idl >> kk1.txt
set numcolumnidl = `cat -n kk1.txt | tail -1 | awk '{print $1}'`
if (${numcolumnidl} >= 2) then 
	echo "GOOD: IDL found." 
else
	echo "ERROR: IDL not found. Please install it." 
endif

echo "Finished... " `date`
rm kk1.txt kk2.txt kk.txt


exit
