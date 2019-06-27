# JCC(7/97)- modified from _rdffits2pros.cl for capital extension
#            (e.g.  root_BAS.FITS >
# ======================================================================
procedure rdffits2prosc(inpfile,instrument,unscreened,outpfile)
# ======================================================================

  string inpfile   	  	  {prompt="input filename [root]"}
  string instrument	          {min="hri|pspc", prompt="instrument"}
  bool   unscreened		  {no,prompt="output unscreened dataset?"}
  string outpfile   	  	  {".",prompt="output filename"} 
  bool	autoname		  {yes,prompt="Rename to IRAFNAME?",mode="h"}
  bool	clobber			  {no,prompt="Okay to delete existing file?",mode="h"}
  bool	debug			  {no,prompt="retain temp files?",mode="h"}
  int	allext	  {6,prompt="QPOE extension number for ALL events",mode="h"}
  int	stdext	  {5,prompt="QPOE extension number for STD events",mode="h"}
  string hkscr  {"xdataiodata$tsiqlm.tab",prompt="tsi/qlm match table",mode="h"}
  bool	qpi		  {no,prompt="Specify QP internal parameters?",mode="h"}
  int	qp_psize		  {2048,prompt="system page size",mode="h"}
  int	qp_blen			  {4096,prompt="system bucket len",mode="h"}
  int   qp_blfact		  {1,prompt="qpoe blocking factor",mode="h"}
  bool	qp_index		  {yes,prompt="make position index?",mode="h"}
  string qp_ky			  {"",prompt="sort key(s) for index",mode="h"}
  int	qp_deb		 	 {0,prompt="qp debug print level",mode="h"}

  begin

# Declare the intrinsic parameters:
 
	string infile			# input file suite
	string outfile			# output file suite
        string tab_file
	string instr			# instrument	
	string empty = ""
	string msg = ""
	string infits = ""		# HRI/PSPC input event file
	string inimg = ""		# HRI image file
	string inim = ""		# PSPC broad image file
	string inbk = ""		# PSPC broad background file
	string insky = ""		# HRI/PSPC sky table
	string insrc = ""		# HRI/PSPC source table
	string inanc = ""		# HRI/PSPC ancillary table
	string inprt = ""		# HRI/PSPC print table
	string inhis = ""		# HRI/PSPC history table
	string inmex = ""		# PSPC exposure image
	string insp = ""		# PSPC spectral source table
	string ineph = ""               # Emphemeris input file
	string inltc = ""               # PSPC light curve input file
        string tmpname = ""             # temporary name

	string outfits = ""
	string outtab = ""
	string outpl = ""
	string outqp   = ""
	string outroot = ""
	string key
	string equal
	string test,testpix,test2
	string ext
	bool   auto
	bool   clob
#	bool   correct

	bool qpii
	int skip
	int  deb
	int  qpp
	int  qpb
	int  qpbl
	int  qpd
        bool qpix
        bool unscreen
	string qpk
	int idx1
	int idx2 
	bool exp_rename

	qpii = qpi
	qpp  = qp_psize
	qpb  = qp_blen
	qpbl = qp_blfact
	qpd  = qp_deb
        qpix = qp_index
	qpk = qp_ky
#	correct = corkey

# make sure packages are loaded
        if ( !deftask ("fits2qp") )
          error (1, "Requires xray/xdataio to be loaded!")
        if ( !deftask ("strfits") )
          error (1, "Requires tables or stsdas/fitsio to be loaded!")
        if (!defpac("tables"))
            error(1, "Tables package must be loaded.")


# Get query parameters 
	infile = inpfile	
	instr = instrument
	auto = autoname		
	unscreen = unscreened
	if( !auto )
	    outfile = outpfile
	else
	    outfile = "."
	clob = clobber
	list = ""


	if (instr == "hri") {

#		Create HRI PROS qpoe file - root.qp
	        _rtname(infile, empty, "_BAS.FITS")
		infits = s1
		outqp = "udummy.qp"
		if( !auto ){
	            _rtname(infile, outfile, ".qp")
		    outfits = s1
		}
		else{
		    outfits = outfile//"/"//"dummy.qp"
		}

		if( !access(infits) ){
		   _errmsg(infits)
		}
	        else
		{
		    delete(outqp,ver-,>& "dev$null" )
            	    if (clob)
		    {
		       delete(outfits,ver-,>& "dev$null" )
		    }
           	    else
		    {
		       if( auto )
		          delete(outfits,ver-,>& "dev$null" )
		       else
			{
		          if( access(outfits) )
				_errmsg2(outfits)
			}
		    }
		    if( unscreen)
		    {
			_rdfrall(infits, outqp, instr, status=no, hkscr=hkscr, 
                        qp_psize=qpp, qp_blen=qpb, clobber=clob, debug=debug,
                        which_qlm="all", all_ext=allext, std_ext=stdext)
		    
		 	qpix = no  # means don't use qpsort output filename
		    }
		    else
		    {
			 fits2qp (infits, outqp, naxes=0, axlen1=0, axlen2=0, 
	         	 mpe_ascii_fits=no, 
			 clobber=clob, oldqpoename=no, 
			 display=0, fits_cards="xdataio$fits.cards", 
			 qpoe_cards="xdataio$qpoe.cards", 
			 ext_cards="xdataio$ext.cards", 
			 wcs_cards="xdataio$wcshri.cards", 
			 old_events="EVENTS", std_events="STDEVT", 
			 rej_events="REJEVT", which_events="standard", 
			 oldgti_name="GTI", allgti_name="ALLGTI", 
			 stdgti_name="STDGTI", which_gti="standard", 
                         scale=yes, key_x="x", key_y="y",
			 qp_internals=yes, qp_pagesize=qpp, 
			 qp_bucketlen=qpb, qp_blockfact=qpbl, 
			 qp_mkindex=no, qp_key=qpk, qp_debug=qpd)
		    }

                    if( qpix )
                    {
		        delete(outfits,ver-,>& "dev$null" )
                        msg = " Sorting file "//outqp
                        print (msg)
                        qpsort (outqp,
                        "", outfits, "", "position", exposure="NONE", 
                        expthresh=0., clobber=clob, display=0, 
                        qp_internals=yes, qp_pagesize=qpp, qp_bucketlen=qpb,
                        qp_blockfact=qpbl, qp_mkindex=yes, qp_key=qpk, 
                        qp_debug=qpd)
		        delete(outqp,ver-,>& "dev$null")

		        # apply the gapmap to hri rawx/y and write detx/y
		        upqpoerdf (outfits, display=1, qp_psize=qpp, 
				   qp_blen=qpb, filelist="")

                    } else {

		       # apply the gapmap to hri rawx/y and write detx/y
		       upqpoerdf (outqp, display=1, qp_psize=qpp, qp_blen=qpb, 
                                  filelist="")
	            }

		   if( auto )
		   {
	               catfits (infits,
       		       "", format_file="", log_file="foo.log", long_header=yes,
           	       short_header=yes, ext_print=yes, offset=0) | match ("QPOENAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test) ##JCC- | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
           	   if (clob)
              	         delete(test,yes,>&"dev$null")
           	   else
		      if( access(test) )
			_errmsg2(test)
		   if( qpix )
		       rename( outfits, test)
		   else
		       rename( outqp, test)
		   outfits = test
		   }

		   
		skip = 0
		_rtname(outfits, empty, "_stdqlm.tab")
		outtab = s1
           	if (clob)
		{
              	    delete(outtab,yes,>&"dev$null")
		}
          	else
		{
		   if( access(outtab) )
		    {
			_errmsg2(outtab)
			_errmsg1(outtab)
		     skip = 1
		    }
		}
		if( skip != 1)
                    strfits (infits//"[5]"," ",outtab, template="none",
                        long_header=no, short_header=yes, datatype="default",
                        blank=0., scale=yes, xdimtogf=no, oldirafname=no,
                        offset=0, force=yes)
		skip = 0
 
		_rtname(outfits, empty, "_allqlm.tab")
		outtab = s1
           	if (clob)
		{
              	    delete(outtab,yes,>&"dev$null")
		}
           	else
		{
		   if( access(outtab) )
		    {
			_errmsg2(outtab)
			_errmsg1(outtab)
		     skip = 1
		    }
		}
		if( skip != 1)
                    strfits (infits//"[6]"," ",outtab, template="none",
                        long_header=no, short_header=yes, datatype="default",
                        blank=0., scale=yes, xdimtogf=no, oldirafname=no,
                        offset=0, force=yes)
 
		skip = 0

		}

# 		Create HRI PROS Image map - root_im1.imh
		_rtname(infile, empty, "_IM1.FITS")
		inim = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im1.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_im1*.tab")
		    outroot = s1
		}
		else
		    outfits = outfile//"/" //"dummy_im1.imh"

		if( !access(inim) ){
		   _errmsg(inim)
		}
	        else
		{
            	    if (clob)
		    {
              	       imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
		    }
           	    else
		    {
		       if( auto )
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
		       else
			{
		          if( access(outfits) )
				_errmsg2(outfits)
			}
		    }

		    strfits (inim, " ", outfits, template="none", 
				   long_header=no, short_header=yes, 
				   datatype="default", blank=0., 
			 	   scale=yes, xdimtogf=no, oldirafname=no, 
				   offset=0, force=yes)
		   if( auto )
		   {
	           catfits (inim,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
           	   if (clob)
              	      imdelete(test,yes,ver-,default_acti+, >& "dev$null")
           	   else
		       if( access(test) )
				_errmsg2(test)
		   imrename( outfits, test, verbose=no)
		   }
		}

# 		Create HRI PROS backround map image - root_bk1.imh
		_rtname(infile, empty, "_BK1.FITS")
		inbk = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk1.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_bk1*.tab")
		    outroot = s1
		}
		else
		    outfits = outfile//"/"//"dummy_bk1.imh"

		if( !access(inbk) ){
		   _errmsg(inbk)
		}
	        else
		{
            	    if (clob || auto)
		    {
              	       imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
  		    }
           	    else
		    if( access(outfits) )
			_errmsg2(outfits)

     strfits (inbk," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., scale=yes, 
	 xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( auto )
		    {
	            catfits (inbk,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test)
		   msg = "          renaming file to "//test
		   print(msg)
           	   if (clob)
              	      imdelete(test,yes,ver-,default_acti+, >& "dev$null")
           	   else
		      if( access(test) )
			_errmsg2(test)

		   imrename( outfits, test, verbose=no)
		   }
		}

# 		Create HRI PROS Detected Source Table - root_src.tab
		_rtname(infile, empty, "_SRC.FITS")
		insrc = s1
		if( !auto ){
	            _rtname(infile, outfile, "_src.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_src")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_src.hhh"
		    outroot = outfile//"/"//"dummy_src"
		}

		if( !access(insrc) ){
		   _errmsg(insrc)
		}
	        else
		{
            	    if (clob || auto)
		    {
              	       imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	       delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
		      if( access(outfits) )
			_errmsg2(outfits)

       strfits (insrc," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		   if( auto)
		   {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (insrc,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
		              if( access(test) )
				_errmsg2(test)
#                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			       if( access(test) )
					_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}

# 		Create HRI PROS Ancillary Table - root_anc.tab
		_rtname(infile, empty, "_ANC.FITS")
		inanc = s1
		if( !auto ){
	            _rtname(infile, outfile, "_anc.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_anc")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_anc.hhh"
		    outroot = outfile//"/"//"dummy_anc"
		}

		if( !access(inanc) ){
		   _errmsg(inanc)
		}
	        else
		{
            	    if (clob || auto)
	            {		 	
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
			if( access(outfits) )
				_errmsg2(outfits)

        strfits (inanc," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( auto )
		    {
		    delete ("tmp$foo.lis",yes)
	            catfits (inanc,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                   i=0
                   list = "tmp$foo.lis"
                   while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
#                           imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
# 		Create HRI PROS History - root_his.tab
		_rtname(infile, empty, "_HIS.FITS")
		inhis = s1
		if( !auto ){
	            _rtname(infile, outfile, "_his.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_his")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_his.hhh"
		    outroot = outfile//"/"//"dummy_his"
		}

		if( !access(inhis) ){
		   _errmsg(inhis)
		}
	        else
		{
            	    if (clob || auto)
	            {		 	
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
			if( access(outfits) )
				_errmsg2(outfits)

	 strfits (inhis," ", outfits, template="none", long_header=no, 
	    short_header=yes, datatype="default", blank=0., 
	    scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( auto )
		    {
		    delete ("tmp$foo.lis",yes)
	            catfits (inhis,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                   i=0
                   list = "tmp$foo.lis"
                   while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
#                           imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".trl"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
# 		Create HRI PROS PRINT Table - root_prt.tab
		_rtname(infile, empty, "_PRT.FITS")
		inprt = s1
		if( !auto ){
	            _rtname(infile, outfile, "_prt.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_prt")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_prt.hhh"
		    outroot = outfile//"/"//"dummy_prt"
		}

		if( !access(inprt) ){
		   _errmsg(inprt)
		}
	        else
		{
            	    if (clob || auto)
	            {		 	
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
			if( access(outfits) )
				_errmsg2(outfits)

	 strfits (inprt," ", outfits, template="none", long_header=no, 
	    short_header=yes, datatype="default", blank=0., 
	    scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( auto )
		    {
		    delete ("tmp$foo.lis",yes)
	            catfits (inprt,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                   i=0
                   list = "tmp$foo.lis"
                   while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
#                           imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".trl"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}

	}
	else  {
	  if (instr == "pspc") {
# 		Create PSPC PROS qpoe file - root.qp

                _rtname(infile, empty, "_BAS.FITS")
                infits = s1
                outqp = "udummy.qp"
                if( !auto ){    
                    _rtname(infile, outfile, ".qp")
                    outfits = s1
                }
                else{
                    outfits = outfile//"/"//"dummy.qp"
                }

                if( !access(infits) ){
		   _errmsg(infits)
                }
                else
		{
                    delete(outqp,ver-,>& "dev$null" )
                    if (clob)
                    {
                       delete(outfits,ver-,>& "dev$null" )
                    }
                    else
                    {
                       if( auto )
                          delete(outfits,ver-,>& "dev$null" )
                       else
                        {  
                          if( access(outfits) )
				_errmsg2(outfits)
                        } 
                    }   
		    if( unscreen){
			_rdfrall(infits,outqp,instr,status=no,
					hkscr=hkscr,
					qp_psize=qpp,qp_blen=qpb,
					clobber=clob,debug=debug,
					which_qlm="all",
					all_ext=allext, std_ext=stdext)
		   	qpix = no # means don't use the QPSORT filename 
		    }
		    else

                    fits2qp (infits, outqp, naxes=0, axlen1=0, axlen2=0,
                         mpe_ascii_fits=no,
                         clobber=clob, oldqpoename=no,
                         display=0, fits_cards="xdataio$fits.cards",
                         qpoe_cards="xdataio$qpoe.cards",
                         ext_cards="xdataio$ext.cards",
                         wcs_cards="xdataio$wcspspc.cards",
                         old_events="EVENTS", std_events="STDEVT",
                         rej_events="REJEVT", which_events="standard",
                         oldgti_name="GTI", allgti_name="ALLGTI",
                         stdgti_name="STDGTI", which_gti="standard",
                         scale=yes, key_x="x", key_y="y",
                         qp_internals=yes, qp_pagesize=qpp,
                         qp_bucketlen=qpb, qp_blockfact=qpbl,
                         qp_mkindex=no, qp_key=qpk, qp_debug=qpd)

                    if( qpix )
                    {
                        delete(outfits,ver-,>& "dev$null" )
                        msg = " Sorting file "//outqp
                        print (msg)
                        qpsort (outqp,
                        "", outfits, "", "position", exposure="NONE",
                        expthresh=0., clobber=clob, display=0,
                        qp_internals=yes, qp_pagesize=qpp, qp_bucketlen=qpb,
                        qp_blockfact=qpbl, qp_mkindex=yes, qp_key=qpk,
                        qp_debug=qpd)
                        delete(outqp,ver-,>& "dev$null")
                    }
                   if( auto )
                   {
                   catfits (infits,
                    "", format_file="", log_file="foo.log", long_header=yes,
                   short_header=yes, ext_print=yes, offset=0) | match ("QPOENAME", "", stop=no, print_file_n=yes, metacharacte=yes) | scan(key,test) ##JCC- | scan(key,test)
                   msg = "          renaming file to "//test
                   print(msg)
                   if (clob)
                         delete(test,yes,>&"dev$null")
                   else    
			if( access(test) )
				_errmsg2(test)
                   if( qpix )
                       rename( outfits, test)
                   else
                       rename( outqp, test)
		   outfits = test
                   }

		skip = 0
		print(outfits)
		print(empty)
		_rtname(outfits, empty, "_stdqlm.tab")
		print(s1)
		outtab = s1
          	if (clob)
		{
              	    delete(outtab,yes,>&"dev$null")
		}
           	else
		{
	       if( access(outtab) )
		    {
			_errmsg2(outtab)
			_errmsg1(outtab)
		     skip = 1
		    }
		}
		print(infits)
		print(outtab)
		if( skip != 1)
             strfits (infits//"[5]"," ",outtab, template="none",
               long_header=no, short_header=yes, datatype="default",
               blank=0., scale=yes, xdimtogf=no, oldirafname=no,
               offset=0, force=yes)
		skip = 0
 
		_rtname(outfits, empty, "_allqlm.tab")
		outtab = s1
           	if (clob)
		{
              	    delete(outtab,yes,>&"dev$null")
		}
           	else
		{
		   if( access(outtab) )
		    {
			_errmsg2(outtab)
			_errmsg1(outtab)
		     skip = 1
		    }
		}
 
		if( skip != 1)
                    strfits (infits//"[6]"," ",outtab, template="none",
                        long_header=no, short_header=yes, datatype="default",
                        blank=0., scale=yes, xdimtogf=no, oldirafname=no,
                        offset=0, force=yes)
		skip = 0

		}

# 		Create PSPC PROS broad image - root_im1.imh
		_rtname(infile, empty, "_IM1.FITS")
		inim = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im1.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_im1")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_im1.imh"
		    outroot = outfile//"/"//"dummy_im1"
		}

		if( !access(inim) ){
		   _errmsg(inim)
		}
	        else
		{
            	   if (clob || auto)
		   {	
              	        imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	        delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
			if( access(outfits) )
				_errmsg2(outfits)

	strfits (inim," ", outfits, template="none", long_header=no, 
		 short_header=yes, datatype="default", blank=0., 
		 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inim,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 

# 		Create PSPC PROS soft image - root_im2.imh
		_rtname(infile, empty, "_IM2.FITS")
		inim = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im2.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_im2")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_im2.imh"
		    outroot = outfile//"/"//"dummy_im2"
		}

		if( !access(inim) ){
		   _errmsg(inim)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
		 
	strfits (inim," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inim,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}

# 		Create PSPC PROS Image 3 map - root_im3.imh
		_rtname(infile, empty, "_IM3.FITS")
		inim = s1
		if( !auto ){
	            _rtname(infile, outfile, "_im3.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_im3")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_im3.imh"
		    outroot = outfile//"/"//"dummy_im3"
		}

		if( !access(inim) ){
		   _errmsg(inim)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inim," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inim,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
# 		Create PSPC PROS Background 1 map - root_bk1.imh
		_rtname(infile, empty, "_BK1.FITS")
		inbk = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk1.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_bk1")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_bk1.imh"
		    outroot = outfile//"/"//"dummy_bk1"
		}

		if( !access(inbk) ){
		   _errmsg(inbk)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inbk," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inbk,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
# 		Create PSPC PROS Background 2 map - root_bk2.imh
		_rtname(infile, empty, "_BK2.FITS")
		inbk = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk2.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_bk2")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_bk2.imh"
		    outroot = outfile//"/"//"dummy_bk2"
		}

		if( !access(inbk) ){
		   _errmsg(inbk)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inbk," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inbk,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
# 		Create PSPC PROS Background Image 3 map - root_bk3.imh
		_rtname(infile, empty, "_BK3.FITS")
		inbk = s1
		if( !auto ){
	            _rtname(infile, outfile, "_bk3.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_bk3")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_bk3.imh"
		    outroot = outfile//"/"//"dummy_bk3"
		}

		if( !access(inbk) ){
		   _errmsg(inbk)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inbk," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inbk,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
# 		Create PSPC PROS Energy Image map - root_ime.imh
		_rtname(infile, empty, "_IME.FITS")
		inim = s1
		if( !auto ){
	            _rtname(infile, outfile, "_ime.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_ime")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_ime.imh"
		    outroot = outfile//"/"//"dummy_ime"
		}

		if( !access(inim) ){
		   _errmsg(inim)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inim," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inim,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
# 		Create PSPC PROS Exposure map - root_mex.imh
		_rtname(infile, empty, "_MEX.FITS")
		inmex = s1
		if( !auto ){
	            _rtname(infile, outfile, "_mex.imh")
		    outfits = s1
	            _rtname(infile, outfile, "_mex")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_mex.imh"
		    outroot = outfile//"/"//"dummy_mex"
		}

		if( !access(inmex) ){
		   _errmsg(inmex)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inmex," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inmex,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".imh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}

# 	Create PSPC PROS Exposure map - root_mex.pl
	inmex = ""
	_rtname(infile, empty, "_MEX.FITS")
	inmex = s1
	if( !auto ){
            _rtname(infile, outfile, "_mexi.imh")
	    outfits = s1
            _rtname(infile, outfile, "_mex.pl")
	    outpl = s1
            _rtname(infile, outfile, "_mex")
	    outroot = s1
	}
	else {
	    outfits = outfile//"/"//"dummi_mex.imh"
	    outroot = outfile//"/"//"dummi_mex"
	}

	if( !access(inmex) ){
	   _errmsg(inmex)
	}
        else {
       	   if (clob || auto) {
       	      imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
       	   }
       	   else {
	      if( access(outfits) )
	         _errmsg2(outfits)
           }
        strfits (inmex," ",outfits,template="none",long_header=no, 
	  short_header=yes, datatype="default", blank=0., 
	  scale=no, xdimtogf=no, oldirafname=no, offset=0, force=yes)
	   if( auto) {
	      delete ("tmp$foo.lis",yes,>&"dev$null")
	      catfits (inmex, "",format_file="",log_file="foo.log",
                      long_header=yes, short_header=yes, ext_print=yes, 
                      offset=0) | match ("IRAFNAME","",stop=no,
                      print_file_n=yes,metachar=yes, > "tmp$foo.lis")
              i=0
              list = "tmp$foo.lis"
              while( fscan(list,key,test) != EOF){
                 if( i == 0 ) {
                    ext = ".pl"
	            test2 = substr(test,1,stridx("x",test)) // ext
                    testpix = substr(test,1,stridx("x",test)) // ".pix"
                    test = outfits
           	    if (clob)
              	       imdelete(test2,yes,ver-,default_acti+,>&"dev$null")
           	    else  {
		       if( access(test2) )
		          _errmsg2(test2)
                    }
# jd - 5/94 - added if access before imcopy
                    if(access(test)&&access(testpix)&&(!access(test2))) {
                       msg = "          renaming file to "//test2
                       print(msg)
                       imcopy( test, test2)
                    }
              	    imdelete(test,yes,ver-,default_acti+,>&"dev$null")
                 }   # ( i == 0 )
#JCC - no need to create duplicated *.tab  if there is any.
    	#        else
        #        {   
        #           ext = ".tab"
        #           if( i < 10 )
        #              test2 = outroot // "0" // i // ext
        #           else if ( i < 100 )
        #               test2 = outroot // i // ext
       	#     	    if (clob)
       	#               delete(test,yes,>&"dev$null")
       	#           else
	#               if( access(test) )
	#	           _errmsg2(test)
        #           rename( test2, test)
        #        }
                 i = i+1
	      } # (while)
           }     # (auto)
	   else  # (! auto)
	   {
              test = outfits
              testpix = outroot // ".pix" 
              test2 = outroot // ".pl"
              if(access(test)&&access(testpix)&&(!access(test2))) {
                 msg = "          renaming file to "//test2
                 print(msg)
                 imcopy( test, test2)
              }
              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           }        #  (else   ! auto)
	}  # ( access (inmex) )

#### 		Create PSPC PROS Ssource tables - root_src.imh
		_rtname(infile, empty, "_SRC.FITS")
		insrc = s1
		if( !auto ){
	            _rtname(infile, outfile, "_src.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_src")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_src.hhh"
		    outroot = outfile//"/"//"dummy_src"
		}

		if( !access(insrc) ){
		   _errmsg(insrc)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)

        strfits (insrc," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
         scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (insrc,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
				_errmsg2(test)
#                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			       if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
# 		Create PSPC PROS Ancillary tables - root_anc.tab
		_rtname(infile, empty, "_ANC.FITS")
		inanc = s1
		if( !auto ){
	            _rtname(infile, outfile, "_anc.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_anc")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_anc.hhh"
		    outroot = outfile//"/"//"dummy_anc"
		}

		if( !access(inanc) ){
		   _errmsg(inanc)
		}
	        else
		{
            	        if (clob || auto)
			{
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
			}
           	       else
			  if( access(outfits) )
				_errmsg2(outfits)
	strfits (inanc," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)
		 if( auto)
		 {
		    delete ("tmp$foo.lis",yes,>&"dev$null")
	            catfits (inanc,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	    short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                    i=0
                    list = "tmp$foo.lis"
                    while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
#                            imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".tab"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
			      if( access(test) )
				_errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}

#************************************************
#JCC - add light curve table files for PSPC
#      Create PSPC PROS LIGHTCURVE -root_lc*.tab
#
#auto=no,output name *_lc01.tab,*_lc02.tab,*_lc03.tab.(strfits)
#auto=yes,output filename *_ltgti.tab, *_lc0001.tab, *_lc0002.tab.(catfits)
                _rtname(infile, empty, "_LTC.FITS")
                inltc = s1
                if( !auto )
                {  _rtname(infile, outfile, "_lc")
                   outroot = s1  
                }
                else 
                   outroot = outfile//"/"//"dummy_lc" 

                if( !access(inltc) )
                   _errmsg(inltc)
                else 
                {  if (clob || auto) 
                      delete(outroot//"*.tab",yes,>&"dev$null") 
                   else
                   {  tmpname = outroot//"01.tab"
                      if (access(tmpname))
                         _errmsg2(tmpname)
                   }

         strfits (inltc," ",outroot,template="none",long_header=no,
         short_header=yes,datatype="default",blank=0.,scale=yes,
         xdimtogf=no, oldirafname=no, offset=0, force=yes)

                   if( auto) 
                   {  delete ("tmp$foo.lis",yes,>&"dev$null")
                      catfits(inltc,"",format_file="",log_file="foo.log",
long_header=yes,short_header=yes,ext_print=yes,offset=0) | match("IRAFNAME","",
stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                      i=0
                      list = "tmp$foo.lis"
                      while( fscan(list,key,test) != EOF)
                      {  if( i >= 1 )     
                         {  ext = ".tab"
                            if( i < 10 )
                               test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                               test2 = outroot // i // ext
                            if (clob) 
                            {  delete(test,yes,>&"dev$null")
                               msg = "          renaming "//test2//" to "//test
                               print(msg)
                               rename( test2, test) 
                            }
                            else
                            {  if (access(test))
                                  _errmsg2(test)
                               else
                               {msg = "          renaming "//test2//" to "//test
                                  print(msg)
                                  rename( test2, test)
                               }
                            }
                         }  # end of (if (i>=1))
                         i = i+1  
                      }   # end of "while (fscan..)"
                   } # end of (if (auto)) 
                }    #JCC - end of light curve 
#**********************************************
# 		Create PSPC PROS PRINT - root_prt.tab
		_rtname(infile, empty, "_PRT.FITS")
		inprt = s1
		if( !auto ){
	            _rtname(infile, outfile, "_prt.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_prt")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_prt.hhh"
		    outroot = outfile//"/"//"dummy_prt"
		}

		if( !access(inprt) ){
		   _errmsg(inprt)
		}
	        else
		{
            	    if (clob || auto)
	            {		 	
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
			if( access(outfits) )
				_errmsg2(outfits)

	strfits (inprt," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( auto )
		    {
		    delete ("tmp$foo.lis",yes)
	            catfits (inprt,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                   i=0
                   list = "tmp$foo.lis"
                   while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
				if( access(test) )
				   _errmsg2(test)
#                           imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".trl"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
				if( access(test) )
				   _errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
# 		Create PSPC PROS History - root_his.tab
		_rtname(infile, empty, "_HIS.FITS")
		inhis = s1
		if( !auto ){
	            _rtname(infile, outfile, "_his.hhh")
		    outfits = s1
	            _rtname(infile, outfile, "_his")
		    outroot = s1
		}
		else
		{
		    outfits = outfile//"/"//"dummy_his.hhh"
		    outroot = outfile//"/"//"dummy_his"
		}

		if( !access(inhis) ){
		   _errmsg(inhis)
		}
	        else
		{
            	    if (clob || auto)
	            {		 	
              	          imdelete(outfits,yes,ver-,default_acti+,>&"dev$null")
              	          delete(outroot//"*.tab",yes,>&"dev$null")
		    }
           	    else
			if( access(outfits) )
				_errmsg2(outfits)

	strfits (inhis," ", outfits, template="none", long_header=no, 
	 short_header=yes, datatype="default", blank=0., 
	 scale=yes, xdimtogf=no, oldirafname=no, offset=0, force=yes)

		    if( auto )
		    {
		    delete ("tmp$foo.lis",yes)
	            catfits (inhis,
       		    "", format_file="", log_file="foo.log", long_header=yes,
           	   short_header=yes, ext_print=yes, offset=0) | match ("IRAFNAME", "", stop=no, print_file_n=yes,metachar=yes, > "tmp$foo.lis")
                   i=0
                   list = "tmp$foo.lis"
                   while( fscan(list,key,test) != EOF){
                       msg = "          renaming file to "//test
                       print(msg)
                        if( i == 0 )
                        {
                            ext = ".hhh"
                            test2 = outroot // ext
           	       	    if (clob)
              	              imdelete(test,yes,ver-,default_acti+,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
#                           imrename( test2, test)
                        }
                        else
                        {   
                            ext = ".trl"
                            if( i < 10 )
                                test2 = outroot // "0" // i // ext
                            else if ( i < 100 )
                                test2 = outroot // i // ext
           	       	    if (clob)
              	               delete(test,yes,>&"dev$null")
           	            else
				if( access(test) )
				    _errmsg2(test)
                            rename( test2, test)
                        }
                       i = i+1
		    }
		    }
		}
 
	  }
	  else
		error(1, "Unsupported instrument!")
       }

end
