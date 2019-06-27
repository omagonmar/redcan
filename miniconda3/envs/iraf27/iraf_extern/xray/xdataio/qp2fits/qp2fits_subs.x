# -r11.0
# JCC(3/27/98) - put_difference:
#              - don't use 'stridxs' to search for the strings. 
#                "c[" and "macro[". 
#                
# -r9.18
# JCC(9/18/97) - get the flag isAXAF and passed to make_lookup()
#             - remove isHRI and add isAXAF in put_difference
#             - use make_lookup3 for AXAF only
#               [ ie. remove keys in lookup3 from AXAF qpoe hdr. ]
#
# -r9.17
# JCC(9/17/97)-clear buffers for outcomt/buf [blank_buf()] in put_difference.
#
# -r9.16 
# JCC(8/21/97) - add a conditional check for len<=32.
#
# -r9.14 (tested with ROSAT/HRI, PSPC; ASC )
# JCC(8/18/97) - Write STDQLM (in diff.out) to the fits primary header
#                only when the INSTRUME is HRI (ROSAT). (ASC does not 
#                want STDQLM. It causes problem for PSPC.)
#
# -r9.13 (8/11/97) - tested with ROSAT/HRI and ASC :
# - comment out the keyword STDQLM in make_lookup3() 
#   [  ROSAT/HRI needs STDQLM in fits primary header ]
# - the following keywords only appear in ROSAT, no "comment field": 
#   STDGTIRE   XS-STDGT   NSTDGTI   NALLQLM
#
# -r9.11 (8/11/97) 
#   add "comment" to fits header
#   add new code "slength"
#   add a few print statements. 
#
# -r9.7
# JCC(8/5/97)-Add 5 keywords to make_lookup1 :
#               STDQLMRE  NSTDQLM  NTIMES  TIMESREC  XS-TIMES
#            -Add a new code "make_lookup3", increase MAX_LOOKUP.
#             and call it in "make_lookup"
#               DEFATTR1 POISSERR  EVENT   XS-INDXX  XS-INDXY  CHECKSUM
#               DATASUM  XS-STDQL  ALLQLM  XS-ALLQL  ALLQLMRE
#               **STDQLM   TIMES
#            -Notes:  Keywords in any of 3 lookup tables will NOT appear 
#                     in the fits primary header.
#
# -r9.5
# JCC(7/28/97) -put_difference():
#               if the line contains 'c[000]' in qpoe, then don't
#               write to fits primary header.
#              - also add  !found  to  XS-HISTORY
# -r9.1
############################################################################
# JCC - Updated to run fits2qp & qp2fits for AXAF data.
#
# (6/6/96) - Updated  qp2fits_subs.x / put_difference() :
#   The keywords that are in the qpoe header but not in the look-up tables 
#   are written to diff.out. Then they were copied to fits PRIMARY header 
#   with COMMENT in front.  Now, just copy the original line without 
#   COMMENT.
#
# (6/7/96) - Updated  qp2fits_subs.x / put_difference() : 
#   Skip DEFFILT and the event-column-names in fits header.
#
# (6/10/96) - Updated qp2fits_subs.x / make_lookup1 & make_lookup2 :
#  Add the following keywords to the PRIMARY fits (=remove them from 
#  look-up table) :  TELESCOP  MISSION   DETNAM    OBJECT    TITLE  
#                    INSTRUME  DATE-OBJ  TIME-OBJ  DATE-END  TIME-END
# 
############################################################################
include <imhdr.h>
include <imio.h>
include <qpoe.h>
include <wfits.h>    # JCC - added for LEN_CARD
include "qp2fits.h"
#------------------------------------------------------------------
#
# Function:       get_head_info
# Purpose:        To get header information from a QPOE file that 
#   needs special handling or is not known about.
# Called by:	  qp2fits
# Calls:
#                 lookup
# Pre-cond:       Output file is open
# Post-cond:
# Method:
# Description:  The QPOE file is opened as an image file.  The user area
#   of the image is opened as a string buffer and each header record is 
#   read.  If the keyword of the header record is NOT in the lookup 
#   table then the record is written to the temporary file(diff.out).
#
# Notes:          The header records are truncated at 80 chars
#   simply by virtue of being opened as an image.
#
#------------------------------------------------------------------
procedure get_head_info(infile_name, out_fp, table)

char    infile_name[ARB]		# i: input filename
int     out_fp				# i: output file pointer
char	table[KEY_MAX, ARB]		# i: lookup table

bool    hlookup()			# l: table lookup function 
int	min_lenuserarea			# l: minimum length user area
int     stropen()			# l: string open function
int	getline()			# l: get line function
pointer sp				# l: stack pointer
pointer im				# l: image pointer
pointer immap()				# l: image map function
pointer lbuf				# l: char buffer
pointer in				# l: string open pointer

begin
        call smark (sp)
        call salloc (lbuf, SZ_LINE, TY_CHAR)

#--------------------------------------------------------------------------
# Open the image.  By opening the QPOE file as an image, the header records
# will be truncated at 80 chars.  This is a problem for history records,
# and they are handled as a special case later in the routine
# "put_difference"
#--------------------------------------------------------------------------
        im = immap (infile_name, READ_ONLY, 0)

#---------------------------------------------------------------
# The following two lines of code were taken from the function
# "imheader".  Basically, "in" is assigned a pointer to the qpoe
# header area.
#---------------------------------------------------------------
        min_lenuserarea = (LEN_IMDES+IM_LENHDRMEM(im)- IMU)*SZ_STRUCT-1
        in = stropen (USER_AREA(im), min_lenuserarea, READ_ONLY)

#-----------------------------------------------------------------
# Loop through the file and put out the line if a matching keyword
# is NOT found in the lookup table
#-----------------------------------------------------------------
        while (getline (in, Memc[lbuf]) != EOF)
	   if (!hlookup(Memc[lbuf], table))
              call putline (out_fp, Memc[lbuf])

#---------
# Close up
#---------
        call close (in)
        call imunmap (im)
        call sfree (sp)
end



#------------------------------------------------------------------
#
# Function:       put_difference
# Purpose:        To write special header cases out to the FITS file
# Called by:
# Calls:
#                 get_key
#                 qp_gstr
#                 pack_buf
#                 split_line
#                 fts_putc
# Pre-cond:       All input and output files are open
# Post-cond:
# Method:
# Description:    Get each line from the temporary file(diff.out). If the 
#   keyword in a line matches an expected keyword, process appropriately,
#   else write it to the FITS file preceded by the FITS keyword "COMMENT"
#
# Notes:          The HISTORY keywords are currently handled as a
#   special case, in that the function "qp_gstr" is called to get
#   the header records.  This is because the header records in the
#   difference file are truncated at 80 chars because they were read
#   as image headers.  This will be a problem for any header over
#   80 chars.
#       	  The filter keywords "QPFILTnn" cannot be handled this
#   way because the function "qp_gstr" does not recogonize it as a
#   valid QPOE parameter name.
#
#------------------------------------------------------------------
#procedure put_difference(qp, qproot_name, in, out, isHRI)
procedure put_difference(qp, qproot_name, in, out, isAXAF)

pointer qp			# i: qpoe file handle
char	qproot_name[ARB] 	# i: qpoe root
pointer in			# i: input file handle
pointer out			# i: output file handle

bool    found			# l: indicaates whether is recognized keyword
char    token                   # l: char d  elielimeter between keyword and data
int     getline()		# l: get line function
int	strncmp()		# l: string n-compare function
int	stridx()		# l: string index function
#int	stridxs()		# l:Return the index of the first occurrence 
#int	strldxs()		# l:Return the index of the last occurrence 
int	strlen()		# l: string length function
int     qp_gstr()               # l: QPOE get string function
int	ip,                     # l: place holder to skip history keyword
#int	ip1,ip2                 # l: place holder to skip history keyword
int	len, len2               # l: string length
int     nchars			# l: number chars returned by qp_gstr()
int	fnroot()		# l: filename root
pointer buf			# l: pointer to input line
pointer sp			# l: stack pointer
pointer outbuf			# l: return buffer from function pack_buf()
pointer keyword1		# l: keyword string
pointer keyword2		# l: keyword string
pointer comment			# l: comment string
pointer out_root		# l: out string for the qpoe root name

#JCC- begin (8/7/97) - call qp_queryf()
pointer   keywd       # keyword to qp_queryf
pointer   outcomt     # comment from qp_queryf()
pointer   datatype    # from qp_queryf()
int       junk, maxelem, flags, qp_queryf()    #from qp_queryf
pointer   outbuf2, outcomt2
int       ii

bool      addkey         #input from qp2fits.x
bool      isAXAF        
#bool     isHRI

begin
	call smark(sp)

#----------------------
# Allocate stack memory
#----------------------
	call salloc(buf, SZ_LINE, TY_CHAR)
	call salloc(outbuf, SZ_LINE, TY_CHAR)
	call salloc(keyword1, KEY_MAX, TY_CHAR)
        call salloc(keyword2, KEY_MAX, TY_CHAR)
	call salloc(comment, SZ_LINE, TY_CHAR)
	call salloc(out_root, SZ_LINE, TY_CHAR)

        #JCC- allocate the space
        call salloc(keywd,  SZ_LINE, TY_CHAR)
        call salloc(outcomt,  SZ_LINE, TY_CHAR)
        call salloc(outcomt2,  SZ_LINE, TY_CHAR)
        call salloc(outbuf2,  SZ_LINE, TY_CHAR)
        call salloc(datatype, SZ_LINE, TY_CHAR)

#--------------------
# Set local variables
#--------------------
	token = '='
	ip = 0

#--------------------------------------------------------------------------
# Get each line from the temporary file(in=diff.out). If the keyword in a 
# line matches an expected keyword(in look-up tables), process appropriately, 
# else write it to the FITS file preceded by the FITS keyword "COMMENT"
#--------------------------------------------------------------------------
	while (getline(in, Memc[buf]) != EOF)
	{	
	   found = false

      ###########################
      #position for 'Memc[buf+nnn]'
      #nnn      :     0123456789 123456789 123456789 123456789 123456789
      #Memc[buf+nnn]: OBJECT  = '             c[000] target object name'
           #JCC(7/28/97) -  begin
           #for some reason, fits2qp crashes when it reads an integer 
           #field right after any of "c[000]" line from a qpoe header.
           #So, let's skip it in fits header.

           ##ip2 = stridxs("c[", Memc[buf])   #JCC(3/27/98)
           ##call printf("in put_difference(): ip2= %d\n")
           ##call pargi(ip2)
           ##if (ip2==25)  found = true   #JCC(3/27/98)

           #JCC(3/27/98)- replace 'stridxs' with the following lines
           if ((Memc[buf+24]=='c')&&(Memc[buf+25]=='['))
           {   found = true }

           #JCC(7/28/97) - end
      ###########################

	   #----------------------------------------------------------
	   # For each HISTORY, XS-HISnn header keyword:
	   # Get the header record from the QP header using "qp_gstr"
	   # This is necessary because getting it when the header is
	   # accessed as an ordinary image file will truncate the 
	   # record at 80 chars.
	   # Write the keyword in the comment field of the FITS line.
	   # If the line length is greater than a pre-defined constant
	   # split the line as many times as necessary and write the 
	   # lines to the FITS file as HISTORY records
	   #----------------------------------------------------------
           ##JCC (7/28/97) - add     (!found &&...)
           if (!found && (strncmp(Memc[buf],"XS-HIS",6)==0 ||
	       strncmp(Memc[buf],"HISTORY",7)==0))
	   {
              call strcpy("HISTORY", Memc[keyword1], KEY_MAX)

	      call get_key(Memc[buf], Memc[comment])
              ##call printf("get_key:  buf=%sjcc\n")
              ##call pargstr(Memc[buf])
              ##call printf("       :  comment=%sjcc\n")
              ##call pargstr(Memc[comment])

	      nchars = qp_gstr(qp, Memc[comment], Memc[outbuf], SZ_LINE)
              ##call printf("qp_gstr:  comment=%sjcc\n")
              ##call pargstr(Memc[comment])
              ##call printf("       :  outbuf=%sjcc\n")
              ##call pargstr(Memc[outbuf])
              ##call printf("         :  nchars=%d\n")
              ##call pargi(nchars)

	      len = strlen(Memc[outbuf])
              ##call printf("strlen   :  len =%d\n")
              ##call pargi(len)
	      if (len <= SPLIT_LINE)
              call fts_putc(out, Memc[keyword1], Memc[outbuf],
                            Memc[comment])
	      else
		 call split_line(out, len, Memc[outbuf], Memc[keyword1],
                                 Memc[comment])
	      found = true
	   }

           #----------------------------------------------------------
           # For each QPFILTnn header keyword:
           # Write the keyword in the comment field of the FITS line.
           # If the line length is greater than a pre-defined constant
           # split the line as many times as necessary and write the
           # lines to the FITS file as HISTORY records
           #----------------------------------------------------------
           if (!found && strncmp(Memc[buf], "QPFILT", 6) == 0)
           {
              call strcpy("HISTORY", Memc[keyword1], KEY_MAX)
              call get_key(Memc[buf], Memc[comment])
              ip = stridx(token, Memc[buf])
              len = strlen(Memc[buf + ip])
              call pack_buf(Memc[buf + ip], Memc[outbuf], len)

              len = strlen(Memc[outbuf])
              if (len <= SPLIT_LINE)
              call fts_putc(out, Memc[keyword1], Memc[outbuf],
                            Memc[comment])
              else
                 call split_line(out, len, Memc[outbuf], Memc[keyword1],
                                 Memc[comment])
              found = true
           }

	   #------------------------------
	   # Write out the QPOENAME string
	   #------------------------------
           if (!found && strncmp(Memc[buf], "QPOENAME", 8) == 0)
           {
              call strcpy("QPOENAME", Memc[keyword1], KEY_MAX)
              call strcpy("IRAFNAME", Memc[keyword2], KEY_MAX)
              call strcpy("original file name", Memc[comment], SZ_LINE)
	      nchars = fnroot(qproot_name, Memc[out_root], SZ_LINE)
	      call sprintf(Memc[outbuf], SZ_LINE, "%s.qp") 
	      call pargstr(Memc[out_root])
              call fts_putc(out, Memc[keyword1], Memc[outbuf],
                               Memc[comment])
              call fts_putc(out, Memc[keyword2], Memc[outbuf],
                               Memc[comment])
	      found = true
           }

	   #------------------------------------------------------------
	   # Write out the OBJECT string with the FITS keywords "OBJECT"
	   # and "TITLE"
	   #------------------------------------------------------------
           if (!found && strncmp(Memc[buf], "OBJECT", 6) == 0)
	   {
	      call strcpy("OBJECT", Memc[keyword1], KEY_MAX)
	      call strcpy("TITLE", Memc[keyword2], KEY_MAX)
              call strcpy("Title of Observation", Memc[comment], SZ_LINE)
              ip = stridx(token, Memc[buf])
              len = strlen(Memc[buf + ip])
              call pack_buf(Memc[buf + ip], Memc[outbuf], len)
              call fts_putc(out, Memc[keyword1], Memc[outbuf],
                            Memc[comment])
              call fts_putc(out, Memc[keyword2], Memc[outbuf],
                            Memc[comment])
	      found = true
	   }
	   
#JCC (6/7/96) - Updated  qp2fits_subs.x / put_difference() :
#   if DEFFILT in qpoe hdr, skip DEFFILT in fits header.
           if (!found && strncmp(Memc[buf], "DEFFILT", 7) == 0)
           {  
              found = true  
           }


#JCC (9/18/97)-Rosat data do no need the lines in diff.out.
#              Add diff.out to fits hdr for AXAF only.
# 
#JCC (6/5/96) -Just copy the original line without "COMMENT" at the front.
#JCC (6/7/96) - skip  the event-column-names("macro[") in fits header.
	   #if (!found)                 #JCC (9/18/97)
	   if ((!found)&&(isAXAF))      #JCC (9/18/97)
           {
     ########### if qpoe header contains 'macro[', don't write them
     ########### to fits header.

              #ip1 = stridxs("macro[", Memc[buf])  #####JCC(3/27/98)
              #call printf("in put_difference(): ip1= %d\n")
              #call pargi(ip1)

              # don't write "macro[" to fits hdr :  ip1=21
              #if (ip1==21)  found = true         #####JCC(3/27/98)

      #position for 'Memc[buf+nnn]'
      #nnn      :     0123456789 123456789 123456789 123456789 123456789
      #Memc[buf+nnn]: CHIPX   = '         macro[003] macro definition'

      #JCC(3/27/98)- replace 'stridxs' with the following lines
      if ((Memc[buf+20]=='m')&&(Memc[buf+21]=='a')&&(Memc[buf+22]=='c')
      &&(Memc[buf+23]=='r')&&(Memc[buf+24]=='o')&&(Memc[buf+25]=='['))
      {   found = true }


              else  
              {
                #add COMMENT to fits primary header if it's from diff.out
                ##len = strlen(Memc[buf])
                ##call pack_buf(Memc[buf], Memc[outbuf], len)
                ##call fts_putc(out, "COMMENT", Memc[outbuf], "")
                #call printf("strlen   :  len =%d\n")
                #call pargi(len)
                #call printf("pack_buf:   buf =%sjcc\n")
                #call pargstr(Memc[buf])
                #call printf("        :   outbuf =%sjcc\n")
                #call pargstr(Memc[outbuf])
                #
                #JCC-(8/8/97)- comment out below - we want to add
                #              the comment field to fits primary hdr.
                #JCC-(6/6/96)-Now, copy the line from diff.out to fits 
                #             primary header without adding COMMENT.
                ##call wft_write_pixels(out,Memc[buf], LEN_CARD )

                ################################################
                ##JCC(8/7/97) - add this section to write the comment 
                ##              field to the fits primary header if
                ##              it exists in the qpoe.
                ## Use get_key to get keywd from buf, then call 
                ## qp_qperyf(keywd) to find its associated comment 
                ## field.

                call get_key(Memc[buf], Memc[keywd])
                ##jcc call printf("diff.out:   buf =%sjcc\n")
                ##jcc call pargstr(Memc[buf])
                ##jcc call printf("qpoe key:  keywd=%sjcc\n")
                ##jcc call pargstr(Memc[keywd])

                # comment field from qp_queryf has no slash symbol(ie. /)
     junk= qp_queryf(qp,Memc[keywd],Memc[datatype],maxelem,Memc[outcomt],flags)
                #call printf("qp_query :  outcomt=%sjcc\n")
                #call pargstr(Memc[outcomt])
                #call printf("         :  datatype=%sjcc\n")
                #call pargstr(Memc[datatype])
                #call printf("         :  junk = %d\n")
                #call pargi(junk)

                #Eliminate trailing blanks in "buf".
                #slength returns len as "real" length of "buf" 
                #(ie. no trailing blank)
                len = strlen(Memc[buf])   # len=81
                call slength(Memc[buf],Memc[outbuf2],len) #len=real length

                ##jcc call printf("real len for whole buf/outbuf2= %d\n")
                ##jcc call pargi(len)
                ##jcc if (strncmp(Memc[keywd],"MJDREF",6)==0)
                ##jcc {  call printf("outbuf2=%sjcc\n")
                   ##jcc call pargstr(Memc[outbuf2])
                ##jcc }

                #Real length (with EOS) for integer is always 31 
                #STARTMJF=                 5584(real length = 31)
                #MJDREFI =                49352(real length = 31)
                #But Real length for char is not fixed, so...
                #If "buf" datatype is "character", then add trailing 
                #blanks to 31th for fits alignment with integer string
                #If (len >=32), no need for alignments.
                if ((strncmp(Memc[datatype],"c",1)==0)&&(len<=31)) ##8/20/97
                {
                   for (ii= len-1; ii<=31; ii=ii+1)
                   {    
                        Memc[outbuf2+ii] = ' '     
                   }
                   len = 31     
                }    

                # eliminate trailing blanks in "outcomt"
                # outcomt,outcomt2: do not contain a slash symbol (/)
                len2 = strlen(Memc[outcomt])
                call slength(Memc[outcomt], Memc[outcomt2], len2)
                ##jcc call printf("real len for comment in qpoe = %d\n")
                ##jcc call pargi(len2)

                # The following keywords only appear in ROSAT, 
                # No need to add comment to them. 
                #  STDGTIRE  XS-STDGT  NSTDGTI  NALLQLM
                if ((strncmp(Memc[buf],"NALLQLM",7)==0)||
                   (strncmp(Memc[buf],"STDGTIRE",8)==0)||
                   (strncmp(Memc[buf],"XS-STDGT",8)==0)||
                   (strncmp(Memc[buf],"NSTDGTI",7)==0) )
                         len2=1

        #write STDQLM to fits header only when it's ROSAT/HRI 
        addkey = true                               ##8/18/97

        #if (strncmp(Memc[buf],"STDQLM",6)==0)       ##8/18/97
            #if (isHRI)                              ##8/18/97
                #addkey=true                         ##8/18/97
            #else                                    ##8/18/97
                #addkey=false                        ##8/18/97

        if (addkey)                                 ##8/18/97
        {                                           ##8/18/97
                if (len2 > 1 )  #there's comment, so write to fits primary hdr. 
                {
                    call strcpy("  /  ",Memc[outbuf2+len-1], 5)
                    call strcpy(Memc[outcomt2], Memc[outbuf2+len-1+5],len2-1)
                    ##Memc[outbuf2+len-1+5+len2-1] = EOS
                    for (ii= len-1+5+len2-1; ii<=80; ii=ii+1)
                    {
                        Memc[outbuf2+ii] =' '
                    }

                    call wft_write_pixels(out,Memc[outbuf2], LEN_CARD )
                 }
                 else
                 {
                    call wft_write_pixels(out,Memc[buf], LEN_CARD)
                 }
         }                                          ##8/18/97
                found = true
                ################################################

              }
           }

        call blank_buf(Memc[buf])           #9/17/97 JCC
        call blank_buf(Memc[outcomt])       #9/17/97 JCC

	} # end while loop

	call sfree(sp)

end  # procedure put_difference


#------------------------------------------------------------------
#
# Function:       make_lookup
# Purpose:        To build the keyword lookup table
# Calls:
#                 make_lookup1
#                 make_lookup2
#                 make_lookup3
# Description:    This is the driver routine that calls the functions
#   make_lookup1 and make_lookup2.
#
# Notes:          This division into two subroutines was necessary
#   due to the SPP compiler error message:
#   "Too many strings in procedure"
#
# JCC-Note-keywords in 2 lookup tables won't be in fits primary header.
#------------------------------------------------------------------
procedure make_lookup(table, isAXAF)    #add isAXAF

char    table[KEY_MAX, ARB]             # o: lookup table
bool    isAXAF

begin
        call make_lookup1(table)
        call make_lookup2(table)
        if (isAXAF)
            call make_lookup3(table)
end

#------------------------------------------------------------------
# Function:       make_lookup1
# Purpose:        To build the first part of the lookup table
# Called by:      make_lookup
# Description:    Build the first part of the lookup table
#------------------------------------------------------------------
procedure make_lookup1(table)

char    table[KEY_MAX, ARB]             # o: lookup table

begin
        call strcpy("X",         table[1,  1], KEY_MAX)
        call strcpy("Y",         table[1,  2], KEY_MAX)
        call strcpy("PHA",       table[1,  3], KEY_MAX)
        call strcpy("PI",        table[1,  4], KEY_MAX)
        call strcpy("TIME",      table[1,  5], KEY_MAX)
        call strcpy("DX",        table[1,  6], KEY_MAX)
        call strcpy("DY",        table[1,  7], KEY_MAX)
        call strcpy("EVENTS",    table[1,  8], KEY_MAX)
        call strcpy("END",       table[1,  9], KEY_MAX)
        call strcpy("XS-NHIST",  table[1, 10], KEY_MAX)

#JCC    call strcpy("TELESCOP",  table[1, 11], KEY_MAX)
#JCC    call strcpy("INSTRUME",  table[1, 12], KEY_MAX)

        call strcpy("RADECSYS",  table[1, 13], KEY_MAX)
        call strcpy("EQUINOX",   table[1, 14], KEY_MAX)
        call strcpy("CTYPE1",    table[1, 15], KEY_MAX)
        call strcpy("CTYPE2",    table[1, 16], KEY_MAX)
        call strcpy("CRVAL1",    table[1, 17], KEY_MAX)
        call strcpy("CRVAL2",    table[1, 18], KEY_MAX)
        call strcpy("CDELT1",    table[1, 19], KEY_MAX)
        call strcpy("CDELT2",    table[1, 20], KEY_MAX)
        call strcpy("CRPIX1",    table[1, 21], KEY_MAX)
        call strcpy("CRPIX2",    table[1, 22], KEY_MAX)
        call strcpy("CROTA2",    table[1, 23], KEY_MAX)
        call strcpy("MJD-OBS",   table[1, 24], KEY_MAX)
#JCC    call strcpy("DATE-OBS",  table[1, 25], KEY_MAX)

#JCC    call strcpy("TIME-OBS",  table[1, 26], KEY_MAX)
#JCC    call strcpy("DATE-END",  table[1, 27], KEY_MAX)
#JCC    call strcpy("TIME-END",  table[1, 28], KEY_MAX)

        call strcpy("XS-OBSID",  table[1, 29], KEY_MAX)
        call strcpy("XS-SEQPI",  table[1, 30], KEY_MAX)
        call strcpy("XS-SUBIN",  table[1, 31], KEY_MAX)
        call strcpy("XS-OBSV",   table[1, 32], KEY_MAX)
        call strcpy("XS-CNTRY",  table[1, 33], KEY_MAX)
        call strcpy("XS-FILTR",  table[1, 34], KEY_MAX)
        call strcpy("XS-MODE",   table[1, 35], KEY_MAX)
        call strcpy("XS-DANG",   table[1, 36], KEY_MAX)
        call strcpy("XS-MJDRD",  table[1, 37], KEY_MAX)
        call strcpy("XS-MJDRF",  table[1, 38], KEY_MAX)
        call strcpy("XS-EVREF",  table[1, 39], KEY_MAX)
        call strcpy("XS-TBASE",  table[1, 40], KEY_MAX)
        call strcpy("XS-ONTI",   table[1, 41], KEY_MAX)
        call strcpy("XS-LIVTI",  table[1, 42], KEY_MAX)
        call strcpy("XS-DTCOR",  table[1, 43], KEY_MAX)
        call strcpy("XS-BKDEN",  table[1, 44], KEY_MAX)
        call strcpy("XS-MINLT",  table[1, 45], KEY_MAX)
        call strcpy("XS-MAXLT",  table[1, 46], KEY_MAX)
        call strcpy("XS-XAOPT",  table[1, 47], KEY_MAX)
        call strcpy("XS-YAOPT",  table[1, 48], KEY_MAX)
        call strcpy("XS-XAOFF",  table[1, 49], KEY_MAX)
        call strcpy("XS-YAOFF",  table[1, 50], KEY_MAX)
end   # end of make_lookup1()


#------------------------------------------------------------------
# Function:       make_lookup2
# Purpose:        Build the second part of the lookup table
# Called by:      make_lookup
# Description:    Build the second part of the lookup table
#
# Notes: 	  If any more keywords are added to this table, the
#   constant MAX_LOOKUP must be changed in the header file associated
#   with this procedure.  For each entry added to this table,
#   MAX_LOOKUP must be incremented by one (1).
#------------------------------------------------------------------
procedure make_lookup2(table)

char    table[KEY_MAX, ARB]             # o: lookup table

begin
        call strcpy("XS-RAROT",  table[1, 51], KEY_MAX)
        call strcpy("XS-XARMS",  table[1, 52], KEY_MAX)
        call strcpy("XS-YARMS",  table[1, 53], KEY_MAX)
        call strcpy("XS-RARMS",  table[1, 54], KEY_MAX)
        call strcpy("XS-RAPT",   table[1, 55], KEY_MAX)
        call strcpy("XS-DECPT",  table[1, 56], KEY_MAX)
        call strcpy("XS-XPT",    table[1, 57], KEY_MAX)
        call strcpy("XS-YPT",    table[1, 58], KEY_MAX)
        call strcpy("XS-XDET",   table[1, 59], KEY_MAX)
        call strcpy("XS-YDET",   table[1, 60], KEY_MAX)
        call strcpy("XS-FOV",    table[1, 61], KEY_MAX)
        call strcpy("XS-INPXX",  table[1, 62], KEY_MAX)
        call strcpy("XS-INPXY",  table[1, 63], KEY_MAX)
        call strcpy("XS-XDOPT",  table[1, 64], KEY_MAX)
        call strcpy("XS-YDOPT",  table[1, 65], KEY_MAX)
        call strcpy("XS-CHANS",  table[1, 66], KEY_MAX)
        call strcpy("XS-MINCH",  table[1, 67], KEY_MAX)
        call strcpy("XS-MAXCH",  table[1, 68], KEY_MAX)
#---------------------------------------------------------------------
# The following three keywords are written out to the FITS file by the
# routine "a3d_initev"
#---------------------------------------------------------------------
        call strcpy("NAXES",     table[1, 69], KEY_MAX)
        call strcpy("AXLEN1",    table[1, 70], KEY_MAX)
        call strcpy("AXLEN2",    table[1, 71], KEY_MAX)

        call strcpy("WCSDIM",    table[1, 72], KEY_MAX)
        call strcpy("NGTI",      table[1, 73], KEY_MAX)
        call strcpy("GTIREC",    table[1, 74], KEY_MAX)
        call strcpy("XS-GTIRE",  table[1, 75], KEY_MAX)
        call strcpy("TSI",       table[1, 76], KEY_MAX)
        call strcpy("TSIREC",    table[1, 77], KEY_MAX)
        call strcpy("XS-TSIRE",  table[1, 78], KEY_MAX)
        call strcpy("QPWCS",     table[1, 79], KEY_MAX)
        call strcpy("GTI",       table[1, 80], KEY_MAX)
        call strcpy("NTSI",      table[1, 81], KEY_MAX)
        call strcpy("XS-EVENT",  table[1, 82], KEY_MAX)
        call strcpy("EVENT",     table[1, 83], KEY_MAX)
        call strcpy("BLOCKFAC",  table[1, 84], KEY_MAX)
        call strcpy("CD1_1",     table[1, 85], KEY_MAX)
        call strcpy("CD2_2",     table[1, 86], KEY_MAX)
        call strcpy("LTM1_1",    table[1, 87], KEY_MAX)
        call strcpy("LTM2_2",    table[1, 88], KEY_MAX)
        call strcpy("WAT0_001",  table[1, 89], KEY_MAX)
        call strcpy("WAT1_001",  table[1, 90], KEY_MAX)
        call strcpy("WAT2_001",  table[1, 91], KEY_MAX)
        call strcpy("DEFBLOCK",  table[1, 92], KEY_MAX)
        call strcpy("TGR",       table[1, 93], KEY_MAX)
        call strcpy("NTGR",      table[1, 94], KEY_MAX)
        call strcpy("TGRREC",    table[1, 95], KEY_MAX)
        call strcpy("XS-TGRRE",  table[1, 96], KEY_MAX)
        call strcpy("BLT",       table[1, 97], KEY_MAX)
        call strcpy("NBLT",      table[1, 98], KEY_MAX)
        call strcpy("BLTREC",    table[1, 99], KEY_MAX)
        call strcpy("XS-BLTRE",  table[1, 100], KEY_MAX)
        call strcpy("XS-SORT",   table[1, 101], KEY_MAX)
end   # end of make_lookup2()


#------------------------------------------------------------------
# Function:       make_lookup3       (8/5/97 - added )
# Purpose:        Build the third part of the lookup table
# Called by:      make_lookup()
# Description:    Build the third part of the lookup table
#
# Notes:          If any more keywords are added to this table, the
#   constant MAX_LOOKUP must be changed in the header file associated
#   with this procedure.  For each entry added to this table,
#   MAX_LOOKUP must be incremented by one (1).
#------------------------------------------------------------------
procedure make_lookup3(table)

char    table[KEY_MAX, ARB]             # o: lookup table

begin
        call strcpy("STDQLMRE",  table[1, 102], KEY_MAX)    
        call strcpy("NSTDQLM",   table[1, 103], KEY_MAX)   
        call strcpy("NTIMES",    table[1, 104], KEY_MAX)  
        call strcpy("TIMESREC",  table[1, 105], KEY_MAX) 
        call strcpy("XS-TIMES",  table[1, 106], KEY_MAX)

        call strcpy("DEFATTR1",  table[1, 107], KEY_MAX)
        call strcpy("POISSERR",  table[1, 108], KEY_MAX)
        call strcpy("EVENT",     table[1, 109], KEY_MAX)
        call strcpy("XS-INDXX",  table[1, 110], KEY_MAX)
        call strcpy("XS-INDXY",  table[1, 111], KEY_MAX)
        call strcpy("CHECKSUM",  table[1, 112], KEY_MAX)
        call strcpy("DATASUM",   table[1, 113], KEY_MAX)
        call strcpy("XS-STDQL",  table[1, 114], KEY_MAX)

        call strcpy("ALLQLM",    table[1, 115], KEY_MAX)
        call strcpy("XS-ALLQL",  table[1, 116], KEY_MAX)
        call strcpy("ALLQLMRE",  table[1, 117], KEY_MAX)

        #JCC(8/11/97) - ROSAT needs "STDQLM" in the primary header.
        ###call strcpy("STDQLM",    table[1, 113], KEY_MAX)

        call strcpy("STDQLM",    table[1, 118], KEY_MAX)
        call strcpy("TIMES",     table[1, 119], KEY_MAX)
#----------------------------------------------------------------------
# STOP! IMPORTANT! STOP! IMPORTANT! STOP! IMPORTANT! STOP! IMPORTANT!
#
# If any more keywords are added to this table, the constant MAX_LOOKUP
# must be changed in the header file associated with this procedure.
# For each entry added to this table, MAX_LOOKUP must be incremented
# by one (1).
#
# Please leave this message at the end of this procedure.
#
# STOP! IMPORTANT! STOP! IMPORTANT! STOP! IMPORTANT! STOP! IMPORTANT!
#----------------------------------------------------------------------
end   # end of make_lookup3()



#------------------------------------------------------------------
#
# Function:       lookup
# Purpose:        To lookup a keyword in the lookup table
# Called by:      get_head_info
# Calls:
#                 get_key
# Description:    The image header line is passed in.  The keyword is
#   found and a brute force lookup is done.
#------------------------------------------------------------------
bool procedure hlookup(instr, table)

char    table[KEY_MAX, ARB]             # i: lookup table
char    instr[ARB]                      # i: in string 
bool    found                           # o: return variable

char    buf[SZ_LINE]                    # l: local string buffer
bool    streq()                         # l: string equal function
int     i                               # l: loop index

begin
        i = 1
        found = false

#---------------------------------------------------------------------
# Find first whitespace or equals sign.  This indicates the end of the
# keyword.
#---------------------------------------------------------------------
	call get_key(instr, buf)

#-------------------------
# Brute force table lookup
#-------------------------
        while (i <= MAX_LOOKUP && !found)
        {
           if (streq(table[1, i], buf))
               found = true
           i = i + 1
        }
        return(found)
end

#------------------------------------------------------------------
# JCC(9/17/97) - This procedure returns a blank buffer
# buffer (input/output)
#------------------------------------------------------------------
procedure blank_buf( buffer )

char    buffer[ARB]       # u : input a string and output a blank
char    space             # l: space character
int     kk                # l: local indices

begin
        space = ' '
        kk = 1
        while (kk <= 132)
        {   buffer[kk] = space
            kk = kk + 1
        }
        buffer[1]=EOS
end   # procedure blank_buf()

#------------------------------------------------------------------
# JCC(8/8/97) - added
# inbuf (input) :  string with trailing blanks
# outbuf(output):  string of "inbuf" without trailing blanks (with EOS)
# len_buf(update):  input the length of "inbuf" and gets updated 
#                   as the length of "outbuf". 
#------------------------------------------------------------------
procedure slength(inbuf, outbuf, len_buf)

char    inbuf[ARB]          # i: input string
char    outbuf[ARB]         # o: output string
int     len_buf             # u: string length of "inbuf" and "outbuf" 

char    newline                         # l: new line character
char    tab                             # l: tab character
char    space                           # l: space character
char    ch                              # l: local character
int     ii, jj, kk                     # l: local indices

begin
        ii = len_buf    # len_buf includes the trailing blanks 
        newline = '\n'
        space = ' '
        tab = '\t'

        #JCC(9/17/97) - blank the outbuf[] 
        kk = 2
        while (kk <= len_buf)
        {   outbuf[kk] = space
            kk = kk + 1
        }
        outbuf[1]=EOS

        ch = inbuf[ii]

#-------------------------------------------------------------------
# Loop through the input string and reduce multiple whitespaces to a
# single whitespace. Eliminate newlines, tabs, and single quotes
#-------------------------------------------------------------------
        while (ch==newline || ch==space || ch==tab)
        {
           ii = ii - 1
           ch = inbuf[ii]
        }  # end of while

        len_buf = ii + 1

        jj = 1
        while (jj <= len_buf - 1)
        {  
           outbuf[jj] = inbuf[jj]
           jj = jj + 1
        }
        outbuf[len_buf] = EOS
end  # end of procedure slength()

#------------------------------------------------------------------
# Function:       pack_buf
# Purpose:        To pack an input string to help alleviate having to deal
#   with unnecessary wrap-around
# Called by:      put_difference
# Description:    Loop through the input string and reduce multiple
#   whitespaces to a single whitespace.   Eliminate newlines, tabs,
#   and single quotes
#------------------------------------------------------------------
procedure pack_buf(inbuf, outbuf, len_inbuf)

char    inbuf[ARB]                      # i: input string
char    outbuf[ARB]                     # o: output string
int     len_inbuf                       # i: length of input string

char    single_quote                    # l: single quote character
char    newline                         # l: new line character
char    tab                             # l: tab character
char    space                           # l: space character
char    ch                              # l: local character
int     i, j                            # l: local indices
int     seq_white                       # l: sequential whitspace counter

begin
        i = 1
        j = 1
        seq_white = 0
        single_quote = '\''
        newline = '\n'
        space = ' '
        tab = '\t'

#-------------------------------------------------------------------
# Loop through the input string and reduce multiple whitespaces to a
# single whitespace. Eliminate newlines, tabs, and single quotes
#-------------------------------------------------------------------
        while (i <= len_inbuf)
        {
           ch = inbuf[i]

           if (ch == single_quote || ch == tab || ch == newline)
                ch = space

           if (ch == space)
                seq_white = seq_white + 1
           else
                seq_white = 0

           if (seq_white > 1)
                i = i + 1
           else
           {
                outbuf[j] = ch
                i = i + 1
                j = j + 1
           }
        }
        outbuf[j] = EOS
end

#------------------------------------------------------------------
# Function:       get_key
# Purpose:        To find the keyword in a header line
# Called by:      put_difference
# Description:    Find the first occurrence of either a space or an
#   equals sign. This indicates the end of the keyword.
#   Copy it to "out_str"
#------------------------------------------------------------------
procedure get_key(in_str, out_str)

char    in_str[ARB]                     # i: input string
char    out_str[ARB]                    # o: output string

int     stridxs()                       # l: string index in set function
int     ptr                             # l: local pointer

begin
        call strcpy(in_str, out_str, SZ_LINE)
        ptr = stridxs(" =", out_str)
        out_str[ptr] = EOS
end

#------------------------------------------------------------------
#
# Function:       split_line
# Purpose:        To write out a long line to a FITS file
# Called by:      put_difference
# Calls:
#                 fts_putc
# Description:    Loop through the string splitting it at the
#   pre-defined constant "SPLIT_LINE".  Write out each part to
#   the FITS file.
#------------------------------------------------------------------
procedure split_line(out, len, in_str, key, comment)

pointer out                             # i: output file pointer
int     len                             # i: length of input string
char    in_str[ARB]                     # i: input string
char    key[ARB]                        # i: keyword string
char    comment[ARB]                    # i: comment string

char    out_str[SPLIT_LINE]             # l: multiply used output string
int     finish                          # l: pointer to end of current line
int     start                           # l: pointer to start of curr line
int     i                               # l: loop index
int     leftover                        # l: modulo(str_len, MAX_LINE)
int     maxloop                         # l: maximum output lines - 1

begin
        start = 1
        finish = SPLIT_LINE
        leftover  = mod(len, SPLIT_LINE)
        maxloop = len/SPLIT_LINE

        #-----------------------------------------------------------------
        # Loop through the string splitting it at the pre-defined constant
        # "SPLIT_LINE".  Write out each part to the FITS file.
        #-----------------------------------------------------------------
        for (i = 1; i <= maxloop + 1; i = i + 1)
        {
           call strcpy(in_str[start], out_str, SPLIT_LINE)
           out_str[finish + 1] = EOS

           call fts_putc(out, key, out_str, comment)

           start = start + SPLIT_LINE

           if (i == maxloop)
                finish = finish + leftover
           else
                finish = finish + SPLIT_LINE
         }
end

