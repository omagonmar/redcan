pro calib_inputs,APER=aper,FIXAPER=fixaper,NGC3256=ngc3256,NGC5135=ngc5135,IC4518W=ic4518w,NGC7130=ngc7130,ALLGAL=allgal,ALLSTEPS=allsteps,FITBACK=fitback,EXTRACT=extract,CALIB=calib,PLOT=plot,SPATDIST=spatdist,SPLINE=spline,AGN=agn,SILENT=silent,_EXTRA=extra

rootdir='/data1/trecs_spec/working/'
rootdir='/tmp_mnt/home67/guests/tanio/data/trecs/sample/spectroscopy/'
rootdir='/home/tanio/data/trecs/sample/spectroscopy/'
IF keyword_set(aper) THEN aper=aper ELSE aper=4.
;spline=0
;silent=1

IF keyword_set(agn) EQ 0 THEN BEGIN


IF keyword_set(ngc3256) OR keyword_set(allgal) THEN BEGIN
; -------- NGC 3256 --------

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'fitback_test',/COMP,/EITHER
fitback_test,'st_S20060307S0084_osc_fs',DIR=rootdir+'ngc3256/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,/NOEXTEN,SILENT=silent
fitback_test,'st_S20060307S0122_osc_fs',DIR=rootdir+'ngc3256/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,/NOEXTEN,SILENT=silent
fitback_test,'st_S20060307S0089_osc_fs',DIR=rootdir+'ngc3256/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,/NOEXTEN,SILENT=silent
fitback_test,'st_S20060307S0094_osc_fs',DIR=rootdir+'ngc3256/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,/NOEXTEN,SILENT=silent
fitback_test,'st_S20060307S0100_osc_fs',DIR=rootdir+'ngc3256/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,/NOEXTEN,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'extract_spec',/COMP,/EITHER
extract_spec,'st_S20060307S0084_osc_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set1_std1',STEPS=[0,0,1],GAL='ngc3256',/SAVE,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0084_osc_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set2_std1',STEPS=[0,0,1],GAL='ngc3256',/SAVE,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0084_osc_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set3_std1',STEPS=[0,0,1],GAL='ngc3256',/SAVE,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0122_osc_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set3_std2',STEPS=[0,0,1],GAL='ngc3256',/SAVE,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',APER=aper,NAME='ngc3256_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set1_nuc',STEPS=[0,0,1],GAL='ngc3256',/SAVE,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',APER=aper,NAME='ngc3256_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set2_nuc',STEPS=[0,0,1],GAL='ngc3256',/SAVE,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',APER=aper,NAME='ngc3256_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set3_nuc',STEPS=[0,0,1],GAL='ngc3256',/SAVE,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir

extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=aper,NAME='ngc3256_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set1_std1',STEPS=[-80,40,1],GAL='ngc3256',/SAVE,FIXAPER=fixaper,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=aper,NAME='ngc3256_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set2_std1',STEPS=[-80,40,1],GAL='ngc3256',/SAVE,FIXAPER=fixaper,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',APER=aper,NAME='ngc3256_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set3_std2',STEPS=[-80,40,1],GAL='ngc3256',/SAVE,FIXAPER=fixaper,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'calib_spec',/COMP,/EITHER
calib_spec,GALAXY='ngc3256',APER=aper,FIXAPER=fixaper,STEPS=[-80,40,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc3256',APER=aper,FIXAPER=fixaper,STEPS=[-80,40,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH
ENDIF

IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'spat_dist_panel',/COMP,/EITHER
spat_dist_panel,GALAXY='ngc3256',APER=aper,FIXAPER=fixaper,STEPS=[-80,40,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC,PLOT=plot
spat_dist_panel,GALAXY='ngc3256',APER=aper,FIXAPER=fixaper,STEPS=[-80,40,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/FLUX
spat_dist_panel,GALAXY='ngc3256',APER=aper,FIXAPER=fixaper,STEPS=[-80,40,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/EW
spat_dist_panel,GALAXY='ngc3256',APER=aper,FIXAPER=fixaper,STEPS=[-80,40,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/RATIO
print,'NGC3256 SPATIAL STEPS DONE ------------------------------------------'
ENDIF

; Nucleo 4pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=4.,NAME='ngc3256_ap4pix_nuc_set1_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,0.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=4.,NAME='ngc3256_ap4pix_nuc_set2_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,0.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',APER=4.,NAME='ngc3256_ap4pix_nuc_set3_std2',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,0.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc3256',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc3256',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc3256',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC
ENDIF

; Nucleo2 4pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=4.,NAME='ngc3256_ap4pix_nuc2_set1_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-58.5],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=4.,NAME='ngc3256_ap4pix_nuc2_set2_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-58.5],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',APER=4.,NAME='ngc3256_ap4pix_nuc2_set3_std2',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-58.5],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc3256',APTYPE='ap4pix_nuc2',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc3256',APTYPE='ap4pix_nuc2',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc3256',APTYPE='ap4pix_nuc2',APER=4.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC
ENDIF

; Nucleo2 40pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=40.,NAME='ngc3256_ap40pix_nuc2_set1_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-58.5],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=40.,NAME='ngc3256_ap40pix_nuc2_set2_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-58.5],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',APER=40.,NAME='ngc3256_ap40pix_nuc2_set3_std2',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-58.5],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc3256',APTYPE='ap40pix_nuc2',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc3256',APTYPE='ap40pix_nuc2',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc3256',APTYPE='ap40pix_nuc2',APER=40.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC
ENDIF

; Diffuse 30pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=30.,NAME='ngc3256_ap30pix_diffuse_set1_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-30.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=30.,NAME='ngc3256_ap30pix_diffuse_set2_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-30.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',APER=30.,NAME='ngc3256_ap30pix_diffuse_set3_std2',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,-30.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc3256',APTYPE='ap30pix_diffuse',APER=30.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH,/CALC
calib_spec,GALAXY='ngc3256',APTYPE='ap30pix_diffuse',APER=30.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc3256',APTYPE='ap30pix_diffuse',APER=30.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC
ENDIF

; Total 40pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'st_S20060307S0089_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=40.,NAME='ngc3256_ap40pix_total_set1_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,0.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0094_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0084_osc_fs_bs_ADUs-1',APER=40.,NAME='ngc3256_ap40pix_total_set2_std1',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,0.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
extract_spec,'st_S20060307S0100_osc_fs_bs_ADUs-1',REFPOSAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',REFWIDAPER='st_S20060307S0122_osc_fs_bs_ADUs-1',APER=40.,NAME='ngc3256_ap40pix_total_set3_std2',STEPS=[0,0,1],GAL='ngc3256',inputs=[0,0.],/SAVE,/FIXROW,FIXAPER=2,/NOEXTEN,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc3256',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH,/CALC
calib_spec,GALAXY='ngc3256',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc3256',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,/NOEXTEN,ROOTDIR=rootdir,/CALC
ENDIF

;resolve_routine,'nucspatspec',/COMP,/EITHER
;nucspatspec,OBJNAME='ngc3256_ap4pix_cal',GAL='ngc3256',SPLINE=spline,/NOEXTEN,SILENT=silent

;resolve_routine,'regionspec',/COMP,/EITHER
;regionspec,OBJNAME='ngc3256_ap40pix_total_cal',GAL='ngc3256',SPLINE=spline,/NOEXTEN,SILENT=silent

print,'Done with NGC3256'
ENDIF

;siabs_spat_dist_panel,GALAXY='ngc3256',APER=4,FIXAPER=2,/SAVE,/SILENT


IF keyword_set(ic4518w) OR keyword_set(allgal) THEN BEGIN
; --------------------------- IC 4518W ----------------------------

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'fitback_test',/COMP,/EITHER
fitback_test,'tr_st_st_S20060417S0073_fs',DIR=rootdir+'ic4518w/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060417S0088_fs',DIR=rootdir+'ic4518w/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060417S0081_fs',DIR=rootdir+'ic4518w/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060417S0082_fs',DIR=rootdir+'ic4518w/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060417S0083_fs',DIR=rootdir+'ic4518w/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'extract_spec',/COMP,/EITHER
; ATENCIÓN: ANTES ESTABA ESCOGIDO EL 0073 PERO NO ME ACUERDO
; PORQUE. EL CASO ES QUE ESTA OBS. NO ES DIFF. LIMITED. ASI PUES
; CAMBIO LA STD. A LA 0088. PUES NO, NO LA CAMBIO PORQUE LA RAZON FUE
; QUE LA MASA DE AIRE ERA MENOR Y +/- IGUAL A LA DE LA GALAXIA. ASI
; PUES DEJAMOS 0073 PORQUE CORRIGIENDO BIEN POR EL SLIT LOSS ES MEJOR
; ESCOGER LA STD. CON MASA DE AIRE SIMILAR.
extract_spec,'tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set1_std1',STEPS=[0,0,1],GAL='ic4518w',FIXAPER=2,/SAVE,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set2_std1',STEPS=[0,0,1],GAL='ic4518w',FIXAPER=2,/SAVE,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set3_std1',STEPS=[0,0,1],GAL='ic4518w',FIXAPER=2,/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060417S0088_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_std2',STEPS=[0,0,1],GAL='ic4518w',/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',APER=aper,NAME='ic4518w_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set1_nuc',STEPS=[0,0,1],GAL='ic4518w',/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',APER=aper,NAME='ic4518w_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set2_nuc',STEPS=[0,0,1],GAL='ic4518w',/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',APER=aper,NAME='ic4518w_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set3_nuc',STEPS=[0,0,1],GAL='ic4518w',/SAVE,SILENT=silent,ROOTDIR=rootdir

extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=aper,NAME='ic4518w_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set1_std1',STEPS=[-40,40,1],GAL='ic4518w',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=aper,NAME='ic4518w_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set2_std1',STEPS=[-40,40,1],GAL='ic4518w',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=aper,NAME='ic4518w_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set3_std1',STEPS=[-40,40,1],GAL='ic4518w',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'calib_spec',/COMP,/EITHER
calib_spec,GALAXY='ic4518w',APER=aper,FIXAPER=fixaper,STEPS=[-40,40,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ic4518w',APER=aper,FIXAPER=fixaper,STEPS=[-40,40,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF

IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'spat_dist_panel',/COMP,/EITHER
spat_dist_panel,GALAXY='ic4518w',APER=aper,FIXAPER=fixaper,STEPS=[-40,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,PLOT=plot
spat_dist_panel,GALAXY='ic4518w',APER=aper,FIXAPER=fixaper,STEPS=[-40,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/FLUX
spat_dist_panel,GALAXY='ic4518w',APER=aper,FIXAPER=fixaper,STEPS=[-40,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/EW
spat_dist_panel,GALAXY='ic4518w',APER=aper,FIXAPER=fixaper,STEPS=[-40,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/RATIO
print,'IC4518W SPATIAL STEPS DONE ------------------------------------------'
ENDIF

; nucleo 4pix
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ic4518w',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=0,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ic4518w',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=0,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ic4518w',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=0,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; nucleo 4pix con fixaper
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,/FIXAPER,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,/FIXAPER,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,/FIXAPER,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ic4518w',APTYPE='ap4pix_nuc',APER=4.,/FIXAPER,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ic4518w',APTYPE='ap4pix_nuc',APER=4.,/FIXAPER,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ic4518w',APTYPE='ap4pix_nuc',APER=4.,/FIXAPER,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; nucleo2 4pix
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc2_set1_std1',STEPS=[0,0,1],inputs=[0,5.5],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc2_set2_std1',STEPS=[0,0,1],inputs=[0,5.5],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=4.,NAME='ic4518w_ap4pix_nuc2_set3_std1',STEPS=[0,0,1],inputs=[0,5.5],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ic4518w',APTYPE='ap4pix_nuc2',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ic4518w',APTYPE='ap4pix_nuc2',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ic4518w',APTYPE='ap4pix_nuc2',APER=4.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; ??? HII reg???
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=8.,NAME='ic4518w_ap8pix_HII_set1_std1',STEPS=[0,0,1],inputs=[0,-17.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=8.,NAME='ic4518w_ap8pix_HII_set2_std1',STEPS=[0,0,1],inputs=[0,-17.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=8.,NAME='ic4518w_ap8pix_HII_set3_std1',STEPS=[0,0,1],inputs=[0,-17.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ic4518w',APTYPE='ap8pix_HII',APER=8.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ic4518w',APTYPE='ap8pix_HII',APER=8.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ic4518w',APTYPE='ap8pix_HII',APER=8.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; Total 40pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060417S0081_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=40.,NAME='ic4518w_ap40pix_total_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0082_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=40.,NAME='ic4518w_ap40pix_total_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060417S0083_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060417S0073_fs_bs_ADUs-1',APER=40.,NAME='ic4518w_ap40pix_total_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ic4518w',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ic4518w',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ic4518w',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ic4518w',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

;resolve_routine,'nucspatspec',/COMP,/EITHER
;nucspatspec,OBJNAME='ic4518w_ap4pix_cal',GAL='ic4518w',SPLINE=spline,SILENT=silent

;resolve_routine,'regionspec',/COMP,/EITHER
;regionspec,OBJNAME='ic4518w_ap40pix_total_cal',GAL='ic4518w',SPLINE=spline,SILENT=silent

print,'Done with IC4518W'
ENDIF


IF keyword_set(ngc5135) OR keyword_set(allgal) THEN BEGIN
; ---------------------------- NGC 5135 ---------------------------

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'fitback_test',/COMP,/EITHER
fitback_test,'tr_st_st_bk_S20060306S0092_fs',DIR=rootdir+'ngc5135/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060310S0101_fs',DIR=rootdir+'ngc5135/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_bk_S20060310S0115_fs',DIR=rootdir+'ngc5135/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060306S0098_fs',DIR=rootdir+'ngc5135/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060310S0106_fs',DIR=rootdir+'ngc5135/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060310S0107_fs',DIR=rootdir+'ngc5135/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
print,'NGC5135 fitback FINISHED -------------------------------'
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'extract_spec',/COMP,/EITHER
extract_spec,'tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set1_std1',STEPS=[0,0,1],GAL='ngc5135',FIXAPER=2,/SAVE,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set2_std1',STEPS=[0,0,1],GAL='ngc5135',FIXAPER=2,/SAVE,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set3_std1',STEPS=[0,0,1],GAL='ngc5135',FIXAPER=2,/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_bk_S20060310S0115_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_set3_std2',STEPS=[0,0,1],GAL='ngc5135',/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',APER=aper,NAME='ngc5135_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set1_nuc',STEPS=[0,0,1],GAL='ngc5135',/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',APER=aper,NAME='ngc5135_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set2_nuc',STEPS=[0,0,1],GAL='ngc5135',/SAVE,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',APER=aper,NAME='ngc5135_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set3_nuc',STEPS=[0,0,1],GAL='ngc5135',/SAVE,SILENT=silent,ROOTDIR=rootdir

; 4pix ap. w/ reference
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=aper,NAME='ngc5135_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set1_std1',STEPS=[-60,40,1],GAL='ngc5135',/SAVE,fixaper=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=aper,NAME='ngc5135_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set2_std1',STEPS=[-60,40,1],GAL='ngc5135',/SAVE,fixaper=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=aper,NAME='ngc5135_ap'+strtrim(string(aper,format='(i)'),2)+'pix_set3_std1',STEPS=[-60,40,1],GAL='ngc5135',/SAVE,fixaper=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'calib_spec',/COMP,/EITHER
calib_spec,GALAXY='ngc5135',APER=aper,STEPS=[-60,40,1],STDNAME='HD_ap25pix',/SAVE,FIXAPER=fixaper,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APER=aper,STEPS=[-60,40,1],STDNAME='HD_ap25pix',/SAVE,FIXAPER=fixaper,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF

IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'spat_dist_panel',/COMP,/EITHER
spat_dist_panel,GALAXY='ngc5135',APER=aper,FIXAPER=fixaper,STEPS=[-50,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,PLOT=plot
spat_dist_panel,GALAXY='ngc5135',APER=aper,FIXAPER=fixaper,STEPS=[-50,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/FLUX
spat_dist_panel,GALAXY='ngc5135',APER=aper,FIXAPER=fixaper,STEPS=[-50,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/EW
spat_dist_panel,GALAXY='ngc5135',APER=aper,FIXAPER=fixaper,STEPS=[-50,40,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/RATIO
print,'NGC5135 SPATIAL STEPS DONE ------------------------------------------'
ENDIF

; Nucleo 4pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_nuc_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_nuc_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_nuc_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=0,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=0,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=0,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; Nucleo 4pix ap. con fixaper (grow intrinsic psf)
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_nuc_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc5135',/SAVE,/FIXROW,/FIXAPER,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_nuc_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc5135',/SAVE,/FIXROW,/FIXAPER,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_nuc_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc5135',/SAVE,/FIXROW,/FIXAPER,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_nuc',APER=4.,/FIXAPER,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_nuc',APER=4.,/FIXAPER,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap4pix_nuc',APER=4.,/FIXAPER,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; HII region 4pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_HII_set1_std1',STEPS=[0,0,1],inputs=[0,-29.5],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_HII_set2_std1',STEPS=[0,0,1],inputs=[0,-29.5],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_HII_set3_std1',STEPS=[0,0,1],inputs=[0,-29.5],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=0,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_HII',APER=4.,FIXAPER=0,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_HII',APER=4.,FIXAPER=0,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap4pix_HII',APER=4.,FIXAPER=0,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; HII region 4pix ap. fix=2
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_HII_set1_std1',STEPS=[0,0,1],inputs=[0,-29.5],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_HII_set2_std1',STEPS=[0,0,1],inputs=[0,-29.5],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=4.,NAME='ngc5135_ap4pix_HII_set3_std1',STEPS=[0,0,1],inputs=[0,-29.5],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_HII',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap4pix_HII',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap4pix_HII',APER=4.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; Diffuse 8pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=8.,NAME='ngc5135_ap8pix_diffuse_set1_std1',STEPS=[0,0,1],inputs=[0,-18.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=8.,NAME='ngc5135_ap8pix_diffuse_set2_std1',STEPS=[0,0,1],inputs=[0,-18.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=8.,NAME='ngc5135_ap8pix_diffuse_set3_std1',STEPS=[0,0,1],inputs=[0,-18.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap8pix_diffuse',APER=8.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap8pix_diffuse',APER=8.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap8pix_diffuse',APER=8.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; Diffuse 10pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=10.,NAME='ngc5135_ap10pix_diffuse_set1_std1',STEPS=[0,0,1],inputs=[0,-18.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=10.,NAME='ngc5135_ap10pix_diffuse_set2_std1',STEPS=[0,0,1],inputs=[0,-18.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=10.,NAME='ngc5135_ap10pix_diffuse_set3_std1',STEPS=[0,0,1],inputs=[0,-18.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap10pix_diffuse',APER=10.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap10pix_diffuse',APER=10.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap10pix_diffuse',APER=10.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

; Total 40pix ap.
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060306S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060306S0092_fs_bs_ADUs-1',APER=40,NAME='ngc5135_ap40pix_total_set1_std1',STEPS=[0,0,1],inputs=[0,-15.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0106_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=40,NAME='ngc5135_ap40pix_total_set2_std1',STEPS=[0,0,1],inputs=[0,-15.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060310S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060310S0101_fs_bs_ADUs-1',APER=40,NAME='ngc5135_ap40pix_total_set3_std1',STEPS=[0,0,1],inputs=[0,-15.],GAL='ngc5135',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc5135',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc5135',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SPLINE=spline,SILENT=silent,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc5135',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

;resolve_routine,'nucspatspec',/COMP,/EITHER
;nucspatspec,OBJNAME='ngc5135_ap4pix_cal',GAL='ngc5135',SPLINE=spline,SILENT=silent

;resolve_routine,'regionspec',/COMP,/EITHER
;regionspec,OBJNAME='ngc5135_ap40pix_total_cal',GAL='ngc5135',SPLINE=spline,SILENT=silent

print,'Done with NGC5135'
ENDIF


IF keyword_set(ngc7130) OR keyword_set(allgal) THEN BEGIN
; -------- NGC 7130 --------

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'fitback_test',/COMP,/EITHER
; NIGHT 0
fitback_test,'tr_st_st_S20050918S0055_fs',DIR=rootdir+'ngc7130/night0_050918/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20050918S0097_fs',DIR=rootdir+'ngc7130/night0_050918/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_mv_st_S20050918S0061_fs',DIR=rootdir+'ngc7130/night0_050918/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_mv_st_S20050918S0062_fs',DIR=rootdir+'ngc7130/night0_050918/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'extract_spec',/COMP,/EITHER
extract_spec,'tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n0_set1_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night0_050918',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n0_set2_std2',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night0_050918',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n0_set1_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night0_050918',SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n0_set2_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night0_050918',SILENT=silent,ROOTDIR=rootdir

extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n0_set1_std1',STEPS=[-40,120,1],GAL='ngc7130/night0_050918',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n0_set2_std2',STEPS=[-40,120,1],GAL='ngc7130/night0_050918',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
; NIGHT 1
fitback_test,'tr_st_st_S20060704S0106_fs',DIR=rootdir+'ngc7130/night1_060704/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_mv_st_S20060704S0111_fs',DIR=rootdir+'ngc7130/night1_060704/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_mv_st_S20060704S0112_fs',DIR=rootdir+'ngc7130/night1_060704/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_mv_st_S20060704S0113_fs',DIR=rootdir+'ngc7130/night1_060704/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n1_set1_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night1_060704',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n1_set2_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night1_060704',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n1_set3_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night1_060704',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_mv_st_S20060704S0111_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n1_set1_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night1_060704',SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_mv_st_S20060704S0112_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n1_set2_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night1_060704',SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_mv_st_S20060704S0113_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n1_set3_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night1_060704',SILENT=silent,ROOTDIR=rootdir

extract_spec,'tr_st_mv_st_S20060704S0111_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n1_set1_std1',STEPS=[-40,80,1],GAL='ngc7130/night1_060704',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0112_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n1_set2_std1',STEPS=[-40,80,1],GAL='ngc7130/night1_060704',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0113_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n1_set3_std1',STEPS=[-40,80,1],GAL='ngc7130/night1_060704',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
; NIGHT 2
fitback_test,'tr_st_st_S20060829S0051_fs',DIR=rootdir+'ngc7130/night2_060829/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060829S0057_fs',DIR=rootdir+'ngc7130/night2_060829/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n2_set1_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night2_060829',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n2_set1_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night2_060829',SILENT=silent,ROOTDIR=rootdir

extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n2_set1_std1',STEPS=[-40,120,1],GAL='ngc7130/night2_060829',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
; NIGHT 3
fitback_test,'tr_st_st_bk_S20060916S0102_fs',DIR=rootdir+'ngc7130/night3_060916/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_bk_S20060916S0114_fs',DIR=rootdir+'ngc7130/night3_060916/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060916S0107_fs',DIR=rootdir+'ngc7130/night3_060916/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060916S0108_fs',DIR=rootdir+'ngc7130/night3_060916/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
;extract_spec,'tr_st_st_bk_S20060916S0102_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n3_set1_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night3_060916',SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n3_set1_std2',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night3_060916',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n3_set2_std2',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night3_060916',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060916S0107_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n3_set1_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night3_060916',SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060916S0108_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n3_set2_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night3_060916',SILENT=silent,ROOTDIR=rootdir

extract_spec,'tr_st_st_S20060916S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n3_set1_std2',STEPS=[-40,80,1],GAL='ngc7130/night3_060916',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0108_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n3_set2_std2',STEPS=[-40,80,1],GAL='ngc7130/night3_060916',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(fitback) OR keyword_set(allsteps) THEN BEGIN
; NIGHT 4
fitback_test,'tr_st_st_bk_S20060925S0092_fs',DIR=rootdir+'ngc7130/night4_060925/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060925S0108_fs',DIR=rootdir+'ngc7130/night4_060925/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060925S0097_fs',DIR=rootdir+'ngc7130/night4_060925/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
fitback_test,'tr_st_st_S20060925S0098_fs',DIR=rootdir+'ngc7130/night4_060925/postredux/',TYPE='spec',SIGMA=1.75,/SAVE,SILENT=silent
ENDIF

IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n4_set1_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night4_060925',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n4_set2_std1',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night4_060925',FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060925S0108_fs_bs_ADUs-1',APER=25.,NAME='HD_ap25pix_n4_set1_std2',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night4_060925',SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n4_set1_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night4_060925',SILENT=silent,ROOTDIR=rootdir
;extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n4_set2_nuc',/SAVE,STEPS=[0,0,1],GAL='ngc7130/night4_060925',SILENT=silent,ROOTDIR=rootdir

extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n4_set1_std1',STEPS=[-40,120,1],GAL='ngc7130/night4_060925',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=aper,NAME='ngc7130_ap'+strtrim(string(aper,format='(i)'),2)+'pix_n4_set2_std1',STEPS=[-40,120,1],GAL='ngc7130/night4_060925',/SAVE,FIXAPER=fixaper,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'calib_spec',/COMP,/EITHER
calib_spec,GALAXY='ngc7130',APER=aper,FIXAPER=fixaper,STEPS=[-40,120,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc7130',APER=aper,FIXAPER=fixaper,STEPS=[-40,120,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF

IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
resolve_routine,'spat_dist_panel',/COMP,/EITHER
spat_dist_panel,GALAXY='ngc7130',APER=aper,FIXAPER=fixaper,STEPS=[-40,120,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,PLOT=plot
spat_dist_panel,GALAXY='ngc7130',APER=aper,FIXAPER=fixaper,STEPS=[-40,120,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/FLUX
spat_dist_panel,GALAXY='ngc7130',APER=aper,FIXAPER=fixaper,STEPS=[-40,120,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/EW
spat_dist_panel,GALAXY='ngc7130',APER=aper,FIXAPER=fixaper,STEPS=[-40,120,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/RATIO
print,'NGC7130 SPATIAL STEPS DONE ------------------------------------------'
ENDIF

; nucleus ap4pix
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n0_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n0_set2_std2',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0111_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n1_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0112_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n1_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0113_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n1_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n2_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night2_060829',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n3_set1_std2',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night3_060916',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0108_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n3_set2_std2',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night3_060916',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n4_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=4.,NAME='ngc7130_ap4pix_nuc_n4_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc7130',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc7130',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc7130',APTYPE='ap4pix_nuc',APER=4.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF


; Total ap40pix
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n0_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n0_set2_std2',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0111_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n1_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0112_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n1_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0113_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n1_set3_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n2_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night2_060829',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n3_set1_std2',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night3_060916',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0108_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n3_set2_std2',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night3_060916',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n4_set1_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=40.,NAME='ngc7130_ap40pix_total_n4_set2_std1',STEPS=[0,0,1],inputs=[0,0.],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc7130',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc7130',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc7130',APTYPE='ap40pix_total',APER=40.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF


; Total 140pix
;extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=140.,NAME='ngc7130_ap140pix_total_n0_set1_std1',STEPS=[0,0,1],inputs=[0,50],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,/FIXAPER,SILENT=silent
;extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=140.,NAME='ngc7130_ap140pix_total_n0_set2_std2',STEPS=[0,0,1],inputs=[0,50],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,/FIXAPER,SILENT=silent
;extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=140.,NAME='ngc7130_ap140pix_total_n2_set1_std1',STEPS=[0,0,1],inputs=[0,50],GAL='ngc7130/night2_060829',/SAVE,/FIXROW,/FIXAPER,SILENT=silent
;extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=140.,NAME='ngc7130_ap140pix_total_n4_set1_std1',STEPS=[0,0,1],inputs=[0,50],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,/FIXAPER,SILENT=silent
;extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=140.,NAME='ngc7130_ap140pix_total_n4_set2_std1',STEPS=[0,0,1],inputs=[0,50],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,/FIXAPER,SILENT=silent

;calib_spec,'ngc7130_ap140pix_total','HD_ap25pix',GALAXY='ngc7130',STEPS=[0,0,1],/OUTOFB,/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir

; HII region?
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=8.,NAME='ngc7130_ap8pix_HII_n0_set1_std1',STEPS=[0,0,1],inputs=[0,107.5],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=8.,NAME='ngc7130_ap8pix_HII_n0_set2_std2',STEPS=[0,0,1],inputs=[0,107.5],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=8.,NAME='ngc7130_ap8pix_HII_n2_set1_std1',STEPS=[0,0,1],inputs=[0,107.5],GAL='ngc7130/night2_060829',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=8.,NAME='ngc7130_ap8pix_HII_n4_set1_std1',STEPS=[0,0,1],inputs=[0,107.5],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=8.,NAME='ngc7130_ap8pix_HII_n4_set2_std1',STEPS=[0,0,1],inputs=[0,107.5],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc7130',APTYPE='ap8pix_HII',APER=8.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/OUTOFB,/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc7130',APTYPE='ap8pix_HII',APER=8.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/OUTOFB,/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc7130',APTYPE='ap8pix_HII',APER=8.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF


; Diffuse region?
IF keyword_set(extract) OR keyword_set(allsteps) THEN BEGIN
extract_spec,'tr_st_mv_st_S20050918S0061_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0055_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n0_set1_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20050918S0062_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20050918S0097_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n0_set2_std2',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night0_050918',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0111_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n1_set1_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0112_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n1_set2_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_mv_st_S20060704S0113_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060704S0106_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n1_set3_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night1_060704',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060829S0057_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_S20060829S0051_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n2_set1_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night2_060829',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0107_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n3_set1_std2',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night3_060916',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060916S0108_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060916S0114_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n3_set2_std2',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night3_060916',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0097_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n4_set1_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
extract_spec,'tr_st_st_S20060925S0098_fs_bs_ADUs-1',REFPOSAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',REFWIDAPER='tr_st_st_bk_S20060925S0092_fs_bs_ADUs-1',APER=60.,NAME='ngc7130_ap60pix_diffuse_n4_set2_std1',STEPS=[0,0,1],inputs=[0,60.],GAL='ngc7130/night4_060925',/SAVE,/FIXROW,FIXAPER=2,SILENT=silent,ROOTDIR=rootdir
ENDIF

IF keyword_set(calib) OR keyword_set(allsteps) THEN BEGIN
calib_spec,GALAXY='ngc7130',APTYPE='ap60pix_diffuse',APER=60.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/OUTOFB,/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC,/SYNTH
calib_spec,GALAXY='ngc7130',APTYPE='ap60pix_diffuse',APER=60.,FIXAPER=2,STEPS=[0,0,1],STDNAME='HD_ap25pix',/OUTOFB,/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/SYNTH
ENDIF
IF keyword_set(spatdist) OR keyword_set(allsteps) THEN BEGIN
spat_dist_panel,GALAXY='ngc7130',APTYPE='ap60pix_diffuse',APER=60.,FIXAPER=2,STEPS=[0,0,1],/SAVE,SILENT=silent,SPLINE=spline,ROOTDIR=rootdir,/CALC
ENDIF

;resolve_routine,'nucspatspec',/COMP,/EITHER
;nucspatspec,OBJNAME='ngc7130_ap4pix_cal',GAL='ngc7130',SPLINE=spline,SILENT=silent

;resolve_routine,'regionspec',/COMP,/EITHER
;regionspec,OBJNAME='ngc7130_ap40pix_total_cal',GAL='ngc7130',SPLINE=spline,SILENT=silent

print,'Done with NGC7130'
ENDIF


ENDIF ELSE BEGIN

resolve_routine,'singleagn',/COMP,/EITHER
IF keyword_set(allgal) OR keyword_set(ngc5135) THEN BEGIN
singleagn,galaxy='ngc5135',aper=4.,FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit,tsize='010'
singleagn,galaxy='ngc5135',aptype='ap4pix_HII',FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
singleagn,galaxy='ngc5135',aptype='ap40pix_total',FIXAPER=2,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
ENDIF
IF keyword_set(allgal) OR keyword_set(ic4518w) THEN BEGIN
singleagn,galaxy='ic4518w',aper=4.,FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
singleagn,galaxy='ic4518w',aptype='ap4pix_nuc2',FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
singleagn,galaxy='ic4518w',aptype='ap40pix_total',FIXAPER=2,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
ENDIF
IF keyword_set(allgal) OR keyword_set(ngc7130) THEN BEGIN
singleagn,galaxy='ngc7130',aper=4.,FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
singleagn,galaxy='ngc7130',aptype='ap8pix_HII',FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
singleagn,galaxy='ngc7130',aptype='ap40pix_total',FIXAPER=2,steps=[0,0,1],SPLINE=spline,/gfit,BKFIT=bkfit
ENDIF
IF keyword_set(allgal) OR keyword_set(ngc3256) THEN BEGIN
singleagn,galaxy='ngc3256',aper=4.,FIXAPER=fixaper,steps=[0,0,1],SPLINE=spline,/noexten,/gfit,BKFIT=bkfit
singleagn,galaxy='ngc3256',aper=4.,FIXAPER=fixaper,steps=[-58,-58,1],SPLINE=spline,/noexten,/gfit,BKFIT=bkfit
singleagn,galaxy='ngc3256',aptype='ap40pix_total',FIXAPER=2,steps=[0,0,1],SPLINE=spline,/noexten,/gfit,BKFIT=bkfit
ENDIF

;singleagn,galaxy='circinus',name='Cir_nuc_10',steps=[0,0,1],save=save,galdir='/data/gal_Pat/',/gfit,/extgal,tsize='030'
;singleagn,galaxy='ngc3094',name='n3094',steps=[0,0,1],save=save,galdir='/data/gal_Pat/',/gfit,/extgal,tsize='030'
;singleagn,galaxy='ngc5506',name='n5506_nucleus',steps=[0,0,1],save=save,galdir='/data/gal_Pat/',/gfit,/extgal
;singleagn,galaxy='ngc7172',name='n7172',steps=[0,0,1],save=save,galdir='/data/gal_Pat/',/gfit,/extgal
;singleagn,galaxy='ngc1068',name='ngc1068_P20A_cen.txt',steps=[0,0,1],save=save,galdir='/data/trecs/',/gfit,/extgal

ENDELSE


print,'All done and OK'

end
