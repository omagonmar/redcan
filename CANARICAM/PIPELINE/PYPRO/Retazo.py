#
##
#### Dividing by flat
##
#
print   "STACKING DATA"
infile = sys.argv[3:4]
infile = infile[0]
file = open(infile,'r')
lines = file.readlines()
listaA = listaB = listaC = ""
j = 1
for line in lines:
	line = line.replace('\n','')
	line = line.split('\t')
	line = line[0].split(',')
	fileName = line[0]
	fileNameFlat = line[1]
	print fileName 
	print fileNameFlat
	if j == 1:			
		listaA += 'tb_'+fileName
		listaB += 'fl_'+fileName
		listaC += 'flat_'+fileNameFlat
	else:
		listaA += ',tb_'+fileName
		listaB += ',fl_'+fileName
		listaC += ',flat_'+fileNameFlat
	j = int(j) +1
print listaA
print listaB
print listaC
iraf.mireduce(inimages=listaA,outimages=listaB, stackop='stack',fl_back='no',combine='average',framety='dif', fl_flat='yes',flatfieldfile=listaC,verbose='yes',fl_disp='no',fl_check='no')
#iraf.mireduce(inimages=listaA,outimages=listaB, stackop='stack',fl_back='no',combine='average',framety='dif', fl_flat='no',verbose='yes',fl_disp='no',fl_check='no')

