pro ApplyFlat,datasetname,flatfieldname,dir=dir,nnods=nnods,skipflat=skipflat

print, datasetname,flatfieldname, format='("Correcting for flat observation:  ",A25,"  with flatfield:  ", A25)'
dataset=readfits(dir+datasetname,mainhdr,exten=0,/silent)

IF skipflat eq "yes" THEN BEGIN
    flatfield = 1. 
ENDIF ELSE BEGIN 
    flatfield=readfits(dir+flatfieldname,flathdr,exten=1)
    flatfield=float(flatfield)/mean(flatfield)
ENDELSE

writefits,dir+'flt'+datasetname,0,mainhdr
FOR nodi=1,nnods DO BEGIN
   saveset=float(readfits(dir+datasetname,hdri,exten=nodi,/silent))
   IF nodi EQ 1 THEN BEGIN
    	savesetsize=size(saveset)
	IF savesetsize[0] EQ 4 THEN nchops=savesetsize[4] ELSE nchops=1
   ENDIF
   FOR chopi=0,nchops-1 DO BEGIN
      FOR posi=0,1 DO saveset[*,*,posi,chopi]= saveset[*,*,posi,chopi]/flatfield
   ENDFOR
   writefits,dir+'flt'+datasetname,saveset,hdri,/append
ENDFOR
;spawn,'\mv '+dir+'tmp'+datasetname+' '+dir+datasetname

END
