#!/bin/csh
#

######################   Subroutine for the inputs of Redcan.csh


set startdir = `pwd`

set infile = $1
set entry_point = $2
set method = $3
set target_ext = $4
set radial_profile = $5
set offset = $6
set modify = $7

set infilen = `echo $infile | cut -f1 -d"."`

if ("${infile}" == "-h" ) then
	echo ' ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '########################################################################################################'  >> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##      Purpose: Pipeline for data reduction of Imaging and spectroscopy of CanariCam data	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##      Author: O. Gonzalez Martin (Instituto de Astrofisica de Canarias, Tenerife, Spain)	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##      Staring date: Monday 20th of February 2011						      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##      Finished date: 6th of April (v1.0)							      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##			redcan -h : Displays this help  					      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##			redcan -i : Interactive mode. It will aask for the inputs interactivelly      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##			redcan -d : Default mode. It will only ask for the input file interactivelly. ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					For the others it will assume: 0 3 "[2, 10, 20, 30]"	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##	Inputs: 										      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		1. Infile:		ASCII file with a list of all the observations  	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		2. Entry_point: 	Start point of the proccess				      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  0  Indentification of files  	  		      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  1  Stacking  	        			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  2  Image flux calibration    			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  3  Slit-losses	        			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  4  Wavelength calibration    			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  5  Trace determination       			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  6  Spectral extraction       			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					#  7  Combining spectra         			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		3. Method:		Selection of the method to determine the width  	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						to extract the spectrum:			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					# 0	Fixed aperture  				      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					# 1	Width determined using the trace of the standard      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						Note 1. The trace of the object determines	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##							the center of the extraction.		      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						Note 2. The trace of the standard determines	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##							the center and width used to extract	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##							the standards.  			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		4. Target extension:		Selection of the extension selected for 	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						the target:					      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					# 0	Point like source				      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					# 1	Extended source 				      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					# 2	Interactive selection				      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						Note 1. #2 is Usefull for more than one source        ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		5. Radii:		String of the form 2,5,10,20 with the number of pixels        ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						to make the spectral extraction 		      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						Note 1. expressed in pixels for extended source       ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						 and in number of sigmas for point-like sources       ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		6. Offsets:		String of the form 2,5,10,20 with the number of pixels        ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					       to extract the spectrum from the center of the source  ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						Note 1. Note than the pipeline allows 1 offset with   ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						      several aperture radii of 1 aperture radii with ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##						      several offsets.  			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##		7. Stacking:		Option to modify the stacking procedure:	              ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##  						a.Skip-flatfielding correction? NO	 	      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##  						b.Remove bad chop-nods pairs above 5-sig              ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##  						c. Check bad chops manually? NO                       ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					If you want to modify any of them put "Y"		      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##	Example:	Data process of a set of data contained in "infile.lst", from the initial     ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					point (0), determining a set of spectra (method 3)with        ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##					a set of widths of "2.,10,20,30"			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##				redcan infile.lst 0 0 0  2,10,20,30 0				      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##                   redcan -d infile.lst  :=> redcan infile.lst 0 1 0  1 0			      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '##												      ##'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo '########################################################################################################'>> ${startdir}/PRODUCTS/Status_${infilen}.txt
	echo "STOP" >! init.lst
	goto endloop2
endif

if "${infile}" == "-d" then
	set infile = $2
	if $infile == "" then
		echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '##    		                   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '##  List of fit files to be used:  ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '##    		                   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo -n 'Write the name of the file:			       ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		set infile = $<
	endif
	set entry_point = 0
	set method = 1
	set target_ext = 0
	set radial_profile = "1"
	set offset = "0"
	set skipflat = 'yes'
	set sigm_back = 5.
	set check_back = 'no'
else
	if "${infile}" == "-i" then
		echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '##  List of fit files to be used:  ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo -n 'Write the name of the file:		       ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		set infile = $<
		echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '##  Starting point                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  0  Indentification of files    ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  1  Stacking			   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  2  Image flux calibration   	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  3  Slit-losses		   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  4  Wavelength calibration	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  5  Trace determination	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  6  Spectral extraction	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  7  Combining spectra		   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo -n 'Write the starting point of the process:       ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		set entry_point = $<
		echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  Method: Selection of the method to determine the width      ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  0 	Fixed aperture along wv.			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo "##  1 	Width determined using the trace of the standard        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		echo -n 'Write the desired method: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
		set method = $<
		if ($method == 1) then 
			set target_ext = 0
					set radial_profile = 1
					set offset = 0
		else
			echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  Extension of the sources:      				##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  0 	Point-like source			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  1 	Extended					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  2 	Interactivelly					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Extension of the source: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set target_ext = $<		
					echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  List of radii to extract the         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  spectrum of the target:  	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##    e.g.  2,10,20,30     	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  (pixels)                                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo -n 'Write the radii to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					set radial_profile = $<
					echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					set offset = $<
		endif
	else
		if $infile == "" then
			echo -n 'Write the name of the file:			       ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set infile = $<
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Starting point                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  0  Indentification of files    ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  1  Stacking			   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  2  Image flux calibration   	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  3  Slit-losses		   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  4  Wavelength calibration	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  5  Trace determination	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  6  Spectral extraction	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  7  Combining spectra		   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Write the starting point of the process:       ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set entry_point = $<
			echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  Method: Selection of the method to determine the width      ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  0 	Fixed aperture along wv.			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo "##  1 	Width determined using the trace of the standard        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Write the desired method: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set method = $<
			if ($method == 1) then 
				set target_ext = 0
						      set radial_profile = 1
						      set offset = 0
			else
				echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  Extension of the sources:      				##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  0 	Point-like source			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  1 	Extended					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  2 	Interactivelly					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo -n 'Extension of the source: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				set target_ext = $<		
				echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##  List of radii to extract the         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##  spectrum of the target:  	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##    e.g.  2,10,20,30     	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##  (pixels)                                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo -n 'Write the radii to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				set radial_profile = $<
				echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				set offset = $<
					endif
		else
			if $entry_point == "" then
				echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##  Starting point                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  0  Indentification of files    ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  1  Stacking			   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  2  Image flux calibration   	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  3  Slit-losses		   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  4  Wavelength calibration	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  5  Trace determination	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  6  Spectral extraction	   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  7  Combining spectra		   ##  " >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo -n 'Write the starting point of the process:       ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				set entry_point = $<
				echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  Method: Selection of the method to determine the width      ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  0 	Fixed aperture along wv.			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo "##  1 	Width determined using the trace of the standard        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				echo -n 'Write the desired method: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
				set method = $<
				if ($method == 1) then 
					set target_ext = 0
						      		    set radial_profile = 1
						                       set offset = 0
				else
					echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  Extension of the sources:      				##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  0 	Point-like source			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  1 	Extended					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  2 	Interactivelly					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo -n 'Extension of the source: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					set target_ext = $<		
					echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  List of radii to extract the         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  spectrum of the target:  	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##    e.g.  2,10,20,30     	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  (pixels)                                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo -n 'Write the radii to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					set radial_profile = $<
					echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					set offset = $<
							endif
			else
				if $method == "" then
					echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  Method: Selection of the method to determine the width      ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  0 	Fixed aperture along wv.		     	  ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo "##  1 	Width determined using the trace of the standard        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					echo -n 'Write the desired method: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
					set method = $<
					if ($method == 1) then 
						set target_ext = 0
						      		   		 set radial_profile = 1
						                      		 set offset = 0
					else
						echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  Extension of the sources:      				##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  0 	Point-like source			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  1 	Extended					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  2 	Interactivelly					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo -n 'Extension of the source: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						set target_ext = $<		
						echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  List of radii to extract the         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  spectrum of the target:  	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##    e.g.  2,10,20,30     	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  (pixels)                                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo -n 'Write the radii to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						set radial_profile = $<				
						echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						set offset = $<
								endif
				else
					if ($target_ext == "") then
						echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  Extension of the sources:      				##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##	to extract the spectrum:  			        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  0 	Point-like source			     	        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  1 	Extended					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo "##  2 	Interactivelly					        ##" >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##################################################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo -n 'Extension of the source: 		      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						set target_ext = $<
						echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  List of radii to extract the         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  spectrum of the target:  	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##    e.g.  2,10,20,30     	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  (pixels)                                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo -n 'Write the radii to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						set radial_profile = $<				
						echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
						set offset = $<
					else	
						if $radial_profile == "" then
							echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##  List of radii to extract the         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##  spectrum of the target:  	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##    e.g.  2,10,20,30     	       ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##  (pixels)                                 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '###########################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo -n 'Write the radii to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							set radial_profile = $<				
							echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
							set offset = $<
						else	
							if $offset == "" then
								echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
								echo '##  List of offsets performed with    ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
								echo '##  respect to the targets center: ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
								echo '##    e.g.  2,10,20,30   (pixels)	   ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
								echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
								echo -n 'Write the list of offsets to extract the spectrum:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
								set offset = $<
							endif
						endif						
					endif
				endif
			endif	
		endif	
	endif
	set skipflat = 'yes'
	set sigm_back = 5.
	set check_back = 'no'
	if ${entry_point} == 0  then 
		if $modify == "" then
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Do you want to change the stacking     ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  options?				 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Skip-flatfielding correction? YES	 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Remove bad chop-nods pairs above 5-sig ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Check bad chops manually? NO           ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Write "Y" if you want to modify any of the above conditions:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set modify = $<
		endif	
		if $modify == "Y" then
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Skip-flatfielding correction?	 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  yes : skip flatfielding	 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  no :  DO flatfielding	         ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Do you want to skip flatfielding?      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set skipflat = $<
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Bad chops sigma       	 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  e.g. 5			 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Write the number of sigmas above to which remove bad-chops:      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set sigm_back = $<
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  Bad-chops checking       	 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  yes: to check them		 ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '##  no: to select them automatic.  ##  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo '#####################################  ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			echo -n 'Do you want to check bad chops-nods manually?      ' >> ${startdir}/PRODUCTS/Status_${infilen}.txt
			set check_back = $<		
		endif
	endif
endif
if ( $method == 1 ) then
	if ( $target_ext == 1 ) then
		set target_ext = 0
		echo "WARNING:      For aperture structure changing with wavelength only point-like source is possible. Changing!
	endif
endif
echo $infile $entry_point $method $target_ext $radial_profile $offset $skipflat $check_back $sigm_back >! init.lst

endloop2:
