PRO FlatCorrect, skipflat=skipflat

;
;  FlatCorrect      :    Routine to apply the flatcorrection
;
;      Subroutines  :    ApplyFlat.pro  

readcol, 'PRODUCTS/toflat.txt', obs, flat,  nods, nnodsets, nsavesets, format = '(A,A,I,I,I)'
FOR i = 0,n_elements(obs) -1 DO ApplyFlat, 'b_'+obs(i),'atb_'+flat(i), dir = 'OUTPUTS/', nnods=NNODSETS(i)*NODS(i), skipflat=skipflat

END
