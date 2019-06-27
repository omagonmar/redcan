#!/bin/csh -f
#
##### 	idl_prueba.csh
##
##	Date: Monday 27th of December 2010
##	Purpose: Prueba de reduccion de imagenes MIR de CanariCAM
##
### 	Usage:
##
##
##	Example:

### Inputs:

set dir = $1
set entry_point = $2
cd $dir

### Loops to choose the step:

if (${entry_point} == 0) then
     goto loop0
else if (${entry_point} == 1) then
     goto loop1
else
     echo "ERROR"
     echo "Entry point: "${entry_point}" not supported."
     exit
endif

loop0:

ls *fits > imagenes.lst  	  ### Create list of images
(mkdir OUTPUT_IM) >& /dev/null    ### Create directory for outputs

cat << EOF_IDL >resta.pro
readcol,'imagenes.lst',imgs,format='(A)'
for i = 0, n_elements(imgs) -1 do begin & \$
    im=readfits( '',exten_no=1,cab) & \$
    imr=im(*,*,1,0)-im(*,*,0,0) & \$
    writefits,'${dir}/r_'+imgs(i),cab & \$
endfor

idl < resta.pro
loop1:
