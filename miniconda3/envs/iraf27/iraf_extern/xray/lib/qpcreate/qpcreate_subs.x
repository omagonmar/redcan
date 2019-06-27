#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcreate_subs.x,v 11.0 1997/11/06 16:22:05 prosb Exp $
#$Log: qpcreate_subs.x,v $
#Revision 11.0  1997/11/06 16:22:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:45  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:13:43  dvs
#Modified algorithm for parsing descriptor -- we should pad between
#columns if necessary.  Made other minor adjustments.
#
#Revision 8.0  94/06/27  14:33:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:28  prosb
#General Release 2.3
#
#Revision 6.2  93/12/16  09:26:27  mo
#MC	12/1/93		Update for QPOE buf - qpx_addf
#
#Revision 6.1  93/07/02  14:25:49  mo
#MC	7/2/93		Fix the code to check 'skip_gti' to decide
#			on how to calculate exposure
#			This cures bad ONTIME For output QPOE without time
#
#Revision 6.0  93/05/24  15:58:45  prosb
#General Release 2.2
#
#Revision 1.4  93/05/19  17:21:41  mo
#MC	5/23/93		fix typos
#
#Revision 1.3  93/04/22  12:17:29  jmoran
#JMORAN - changed call to "get_gtitimes" (added "GTI")
#
#Revision 1.2  93/04/22  12:10:58  mo
#MC	22 Apr 93	Split the uppeffilt routine into subroutines to use
#				with the new QPAPPEND utility.
#
#Revision 1.1  93/03/02  17:58:13  jmoran
#Initial revision
#

include <ctype.h>
include <mach.h>
include <qpoe.h>
include <qpset.h>
include <evmacro.h>
include	<einstein.h>
include <rosat.h>
include "qpcreate.h"

procedure qp_movedata(cnt, ptr_idx, in_buf, out_buf)

int     cnt
pointer ptr_idx
pointer in_buf, out_buf

int     idx
pointer ptr

begin
	#------------------------------------------------------------
	# loop through the data structure moving each value from the
	# input buffer to the output buffer.  The WHERE_FOUND element
	# is the byte offset where the input value is located.  The
	# BYTE_OFFSET element is the byte offset where the output
	# value is to be moved to.
	#------------------------------------------------------------
        for (idx = 1; idx <= cnt; idx = idx + 1)
        {
           ptr = MACRO_STRUCT(ptr_idx, idx)
	   if (WHERE_FOUND(ptr) != -1)
	   {
              call amovs(Mems[in_buf  + WHERE_FOUND(ptr)],
                         Mems[out_buf + BYTE_OFFSET(ptr)], SIZE(ptr))
	   }
        }

end

procedure compare_descriptors(in_ptr_idx, out_ptr_idx, in_cnt, out_cnt)

pointer in_ptr_idx		#i: main ptr for input structure
pointer out_ptr_idx		#i/o: main ptr for output structure
int	in_cnt			#i: number of input "macros"
int	out_cnt			#i: number of output "macros"

pointer in_ptr			#l: sub ptr for input structure
pointer out_ptr			#l: sub ptr for output structure
int	ii, jj			#l: loop indices
int	len1, len2		#l: string lengths
int     strlen()		#l: string length function
int     strcmp()		#l: string compare function
bool    found			#l: boolean set to true if strings match

begin

	#---------------------------------------------------
	# Loop through the output event definition structure
	#---------------------------------------------------
        for (ii = 1; ii <= out_cnt; ii = ii + 1)
        {
	   found = false
           out_ptr = MACRO_STRUCT(out_ptr_idx, ii)
	   len1 = strlen(NAME_STR(out_ptr))

	   #---------------------------------------------------------------
	   # For each "macro" loop through the entire input event structure
           #---------------------------------------------------------------
	   for (jj = 1; jj <= in_cnt; jj = jj + 1)
	   {
	      in_ptr = MACRO_STRUCT(in_ptr_idx, jj)
	      len2 = strlen(NAME_STR(in_ptr))

	      #--------------------------------------------------
	      # If names are equal, set the "where_found" output
	      # event element to the "byte_offset" element of the 
	      # input event
	      #--------------------------------------------------
	      if (len1 == len2)
	      {
	         if (strcmp(NAME_STR(in_ptr), NAME_STR(out_ptr)) == 0)
		 {
		     WHERE_FOUND(out_ptr) = BYTE_OFFSET(in_ptr)
		     found = true
	 	 } 
	      } 
	   } # end inner loop

	   #------------------------------------------------------------
	   # If output element doesn't exist in input event defintion
	   # list, write out default null value to "where_found" element
	   #------------------------------------------------------------
           if (!found)
           {
              WHERE_FOUND(out_ptr) = NOT_FOUND_VAL
           }

        } # end outer loop
end

procedure block_move_check(in_ptr_idx, out_ptr_idx, in_cnt, out_cnt, 	
			   max_move, block_move)

pointer in_ptr_idx		#i: main ptr for input structure
pointer out_ptr_idx		#i: main ptr for output structure
int	in_cnt			#i: number of input "macros"
int     out_cnt			#i: number of output "macros"
int	max_move		#o: max number of "macros" to block move
bool    block_move		#o: bool set to true if a block move 

pointer in_ptr			#l: sub ptr for input structure
pointer out_ptr			#l: sub ptr for output structure
int     idx			#l: loop index
int     len1, len2		#l: string lengths
int     strlen()		#l: string length function
int     strcmp()		#l: string compare function
bool    compare_failed		#l: boolean set to true if compare fails 

begin
	if (in_cnt <= out_cnt) 	
	{
	   max_move = in_cnt
	}
	else 
	{
	   max_move = out_cnt
	}

	block_move = false
	compare_failed = false
	idx = 1
	
	while ((!compare_failed) && (idx <= max_move)) 
	{
           out_ptr = MACRO_STRUCT(out_ptr_idx, idx)
           len1 = strlen(NAME_STR(out_ptr))

           in_ptr = MACRO_STRUCT(in_ptr_idx, idx)
           len2 = strlen(NAME_STR(in_ptr))

           if ((len1 != len2)  || (TYPE(in_ptr) != TYPE(out_ptr)) ||
	      (strcmp(NAME_STR(in_ptr), NAME_STR(out_ptr)) != 0))
	   {
	      compare_failed = true
	   }
	   idx = idx + 1
        } # end loop

	if (!compare_failed)
	{
	   block_move = true
	}
end


procedure parse_descriptor(str, ptr_idx, sz_rec, cnt)

char	str[ARB]
pointer ptr_idx
int	sz_rec
int     cnt

bool	found
char	type_ch
int	max_size
int	pos
int	name_len
int	offset
pointer	name_str
pointer ptr

bool 	get_token_pos()
int	size_in_shorts()


begin

	max_size = MAX_NUM_MACRO
	call calloc(ptr_idx, SZ_MACRO_STRUCT*max_size, TY_STRUCT)
	call calloc(name_str, SZ_LINE, TY_CHAR)

	cnt = 0
	offset = 0
	found = true
	pos = 1

	while (found)
	{
 	   found = get_token_pos(str, pos)
	   
	   if (found)
	   {
	      call get_name_and_type(str, pos, Memc[name_str], 
				     name_len, type_ch)
	      cnt = cnt + 1
	   

	      if (cnt > max_size)
	      {
	        max_size = max_size + MAX_NUM_MACRO
	        call realloc(ptr_idx, SZ_MACRO_STRUCT*max_size, TY_STRUCT)
	      }

	      ptr = MACRO_STRUCT(ptr_idx, cnt) 
	      TYPE(ptr) = type_ch

	      # make sure offset is legal for this typesize
	      call adjust_offset(offset, type_ch)

              BYTE_OFFSET(ptr) = offset / (SZ_SHORT * SZB_CHAR)
	      SIZE(ptr) = size_in_shorts(type_ch)

	      call calloc(NAME_PTR(ptr), name_len, TY_CHAR)

	      call strcpy(Memc[name_str], NAME_STR(ptr), name_len)

              call get_next_offset(offset, type_ch)

	   } # end if found
	} # end loop

	sz_rec = offset
	call realloc(ptr_idx, SZ_MACRO_STRUCT*cnt, TY_STRUCT)

end 


int procedure size_in_shorts(ch)

char 	ch
int	val

int	sz_type()
begin
        switch(ch)
        {
           case 's','i','l','r','d','x':
              val = sz_type(ch) / SZ_SHORT

           default:
              call error(1, "unknown data type")
        }

	return (val)
end


procedure get_next_offset(offset, ch)

int     offset  # in bytes
char    ch

int	typesize
int	byte_size()
begin

        switch(ch)
        {
           case 's','i','l','r','d','x':
              typesize=byte_size(ch)


	      offset = offset + byte_size(ch)

           default:
              call error(1, "unknown data type")
        }

end

procedure adjust_offset(offset, ch)

int	offset
char	ch
int     typesize
int     byte_size()
begin

        switch(ch)
        {
           case 's','i','l','r','d','x':

              typesize=byte_size(ch)
 
              if (mod(offset,typesize)!=0)
                   offset=offset+typesize-mod(offset,typesize)

           default:
              call error(1, "unknown data type")
        }

end




bool procedure get_token_pos(str, pos)

char	str[ARB]
int	pos

int	stridx()
int	idx

bool	retval 
char	ch

begin

	ch = ':'
	idx = stridx(ch, str[pos])

	if (idx == 0)
	  retval = false
	else 
	  retval = true

	pos = pos + idx - 1

	return retval
end

procedure get_name_and_type(str, pos, name_str, name_len, type_ch)

char	str[ARB]
int	pos
char	name_str[ARB]
int	name_len
char 	type_ch
int	strlen()
int	idx


begin

	type_ch = str[pos-1]

        idx = 1
	pos = pos + 1
        while ((str[pos] != ',') && (str[pos] != '}') &&
               (str[pos] != EOS) && (!IS_WHITE(str[pos])))
        {
           name_str[idx] = str[pos]
           pos = pos + 1
           idx = idx + 1
        }
        name_str[idx] = EOS
	
	name_len = strlen(name_str)


end
 

#---------------------------------------------------------------------------
procedure print_descriptor(ptr_idx, cnt)

pointer ptr_idx
int     cnt

int     idx
pointer ptr

begin

        call printf("------------------\n")
	call printf("STRUCTURE CONTENTS\n")
	call printf("------------------\n")

        for (idx = 1; idx <= cnt; idx = idx + 1)
        {
           ptr = MACRO_STRUCT(ptr_idx, idx)

	   call printf("byte offset: %d where found: %d size_in_shorts: %d type: %c name: %s\n")
	   call pargi(BYTE_OFFSET(ptr))
	   call pargi(WHERE_FOUND(ptr))
	   call pargi(SIZE(ptr))
	   call pargc(TYPE(ptr))
	   call pargstr(NAME_STR(ptr))
	   
        }

        call printf("\n")
        call flush(STDOUT)


end


#---------------------------------------------------------------------------
procedure free_descriptor(ptr_idx, cnt)

pointer ptr_idx
int	cnt

int	idx
pointer ptr

begin


	for (idx = 1; idx <= cnt; idx = idx + 1)
	{
	   ptr = MACRO_STRUCT(ptr_idx, idx)
	   call mfree(NAME_PTR(ptr), TY_CHAR)
	}

        call mfree(MACRO_STRUCT(ptr_idx, 1), TY_STRUCT)


end



#------------------------------------------------------------------------
#  Procedure to update the deffilt keyword from current deffilt keyword
#	(to support 'old' files, if no deffilt keyword found, GTI
#	 records will be used.  If neither, then XS-FHIST will be
#	 looked for which is the filter history keyword )
#------------------------------------------------------------------------
procedure updeffilt(inqp,qp,timespec,filtkey,qphead) 

pointer	inqp		# i: input QPOE file handle ( for reading GTI)
pointer	qp		# i: output QPOE file handle ( for writing GTI and DEFFILT)
pointer	timespec	# i: user timefilter string 
char	filtkey[ARB]	# i: name of qpoe header string to write filter to
pointer	qphead		# i/o: qpoe header to be updated with ONTIME

pointer	filtstr		# l: pointer to DEFFILT filter string
pointer	ex
pointer	sp
pointer	timsp
pointer	mw
double	duration

bool	get_expstr()
pointer	qpex_open()
int 	qpex_modfilter()
int	status
double	update_exp()

bool	skip_gti_code

begin

	call smark(sp)
	call calloc(filtstr,SZ_LINE,TY_CHAR)
	call salloc(timsp,SZ_DATA,TY_CHAR)
	skip_gti_code = false

	call strip_qpfilt(timespec,timsp,SZ_DATA)
	ex = qpex_open(inqp,"")

	#-------------------------------------------------------------
	# call routine to retrieve time-filter (gti) info from input file(s)
	#-------------------------------------------------------------
	skip_gti_code = !get_expstr(inqp,filtstr)
	if( skip_gti_code )  # if GTI info not available update HISTORY instead
	    call strcpy("XS-FHIST",filtkey,SZ_LINE)

	#-------------------------------------------------------------
	#  Update fllter with the existing filter string from input file( GTIS)
	#-------------------------------------------------------------
	status = qpex_modfilter(ex,Memc[filtstr])

	#-------------------------------------------------------------
	#  Update filter with the user specified filter
	status = qpex_modfilter(ex,Memc[timsp])
	#-------------------------------------------------------------
 
	#-------------------------------------------------------------
	# call routine to update time-filter (gti) info to output file(s)
	#-------------------------------------------------------------
	duration = update_exp(filtkey,filtstr,qp,ex,skip_gti_code,qphead)

	call qpex_close(ex)
	#-------------------------------------------------------------
	# call routine to fix  the WCS reference pixels for Einstein and ROSAT
	#-------------------------------------------------------------
        call fix_wcsref(qphead)
        if( QP_MISSION(qphead) == ROSAT || QP_MISSION(qphead) == EINSTEIN)
        {
            call qph2mw(qphead,mw)
            call qp_savewcs(qp,mw,2)
            call mw_close(mw)
        }

	#-------------------------------------------------------------
	# call routine to fix times with "duration" as the new on time
	#-------------------------------------------------------------
	QP_ONTIME(qphead) = duration
	call fix_qphead_times(duration, qp, qphead)

        call mfree(filtstr, TY_CHAR)
	call sfree(sp)
end



procedure fix_qphead_times(on_time, qp, qphead)

double	on_time
pointer	qp
pointer qphead

real    dead_time_cf
double	temp_doub

begin

	#---------------------------------------------------------
	# get current dead time correction factor from qpoe header
	#---------------------------------------------------------
	dead_time_cf = QP_DEADTC(qphead)

	#-------------------------------------------------------------
	# call routine to fix inverted and zero dead time corr factors
	#-------------------------------------------------------------
	call fix_dead_time_cf(dead_time_cf)

	#------------------------------------------------------------------
	# set the qpoe header dead time corr factor to the newly calculated 
	# dead time corr factor
	#------------------------------------------------------------------
	QP_DEADTC(qphead) = dead_time_cf

	#-------------------------------------------------------------
	# calculate qpoe live time (using double precision arithmetic)
	#-------------------------------------------------------------

	temp_doub = double(QP_DEADTC(qphead))
        QP_LIVETIME(qphead) = on_time * temp_doub

	#----------------------------
	# put out the new qpoe header
	#----------------------------
	call put_qphead(qp, qphead)

end


procedure fix_dead_time_cf(dead_time_cf)

real	dead_time_cf
bool	fp_equalr()

begin

        #---------------------------------------------------------------
        # if dead time corr factor greater than 1, invert it (should be
        # true ONLY for EINSTEIN times).   if it's 0, then set it to 1
        #---------------------------------------------------------------
        if (dead_time_cf > 1.0)
        {
           dead_time_cf = 1.0 / dead_time_cf
        }
        else
        {
           if (fp_equalr(dead_time_cf, 0.0))
           {
                dead_time_cf = 1.0
           }
        }

end

procedure get_sort_params(sort,  sortsize, sortstr, qphead)

int     sort                            # YES if we sort
int     sortsize                        # max events in a sort buffer
char	sortstr[ARB]
pointer qphead

int     btoi()                          # l: bool to int
int	clgeti()
bool	clgetb()

begin
        if (sort != NO)
        {
           #-----------------------------------
           # prompt for sort if not already set
           #-----------------------------------
           if (sort != YES)
           {
                sort = btoi(clgetb("sort"))
           }
           call clgstr("sorttype", sortstr, SZ_LINE)

           #-----------------------------------------------------------
           # convert to a type and enter default sort comparisons, etc.
           #-----------------------------------------------------------
           call qpc_sorttype(sortstr, qphead)

           #-------------------------------------
           # get the sort buffer size (in events)
           #-------------------------------------
           if( sort != NO )
           {
               sortsize = clgeti("sortsize")
           }
           else
           {
               sortsize = MAX_RECS
           }
        }
        else
        {
           sortsize = MAX_RECS
        }

end

bool procedure get_expstr(qp,filtstr)
pointer	qp		# i: input qpoe file handle
pointer	filtstr		# o: returned time interval filter
bool	gti		# o: returned value if 'time' filter info found

bool	skip_gti_code
int	display
#int	i
int	ngti		# l: number of intervals
int	maxch
int	len
double	duration	# l: total duration of new timefilter
pointer	blist,elist	# l: pointer to good time intervals

int	qp_accessf()
int	qp_gstr()
double	get_gtitimes()

begin
#  Get the filter string from the input file - there must either be an existing
#    deffilt parameter - or if an old QPOE - then a set of GTIs
	display = 1
        if( qp_accessf(qp,"deffilt") == YES){
            maxch = 0
            len = 0
            while( len == maxch ){
                maxch = maxch + 2048
                call realloc(filtstr,maxch+SZ_LINE,TY_CHAR)
                len =  qp_gstr(qp,"deffilt",Memc[filtstr],maxch)
            }
        }
        else if( qp_accessf(qp,"XS-FHIST") == YES){
            maxch = 0
            len = 0
            while( len == maxch ){
                maxch = maxch + 2048
                call realloc(filtstr,maxch+SZ_LINE,TY_CHAR)
                len =  qp_gstr(qp,"XS-FHIST",Memc[filtstr],maxch)
            }
        }
        else if( qp_accessf(qp,"NGTI") == YES){
            duration = get_gtitimes(qp, blist, elist, ngti, display, "GTI")
            call put_gtifilt(blist,elist,ngti,filtstr)
            call mfree(blist, TY_DOUBLE)
            call mfree(elist, TY_DOUBLE)
        }
        else{
            call printf("No GTI records in file - no TIME update done\n")
            skip_gti_code = TRUE
        }
	gti = !skip_gti_code          
	return(gti)
end

double procedure update_exp(filtkey,filtstr,qp,ex,skip_gti_code,qphead)
char    filtkey[ARB]    # i: name of qpoe header string to write filter to
pointer qp              # i: QPOE file handle ( for writing GTI and DEFFILT)
pointer ex		# i: handle for QPOE expression filters
bool	skip_gti_code	# i: Is there good time info for updating?
pointer qphead          # i: qpoe header 
double  duration        # o: returned total duration of new timefilter

int     display
int     ngti            # l: number of intervals
int	len
pointer blist,elist     # l: pointer to good time intervals
pointer	filtstr
 
#bool    streq()
#bool	ck_qpatt()
int     strlen()
int     qp_accessf()
int     qpex_attrld()
int     xlen
double	sumtimes()
 
begin
	display = 1
            if( qp_accessf(qp,"deffilt") == YES)
                call qp_deletef(qp,"deffilt")

        if( !skip_gti_code ){
            blist = NULL; elist = NULL; duration = 0.0; xlen=0
            ngti = qpex_attrld(ex,"time",blist,elist,xlen)
            #  blist and elist MUST have length ngti+1 for sumtimes
            if( xlen <= ngti ){
                call realloc(blist,ngti+1,TY_DOUBLE)
                call realloc(elist,ngti+1,TY_DOUBLE)
            }
	    if( ngti > 0 )
	       duration = sumtimes(blist,elist,ngti,display)
	    else
		duration = 0.0D0
            call put_gtifilt(blist,elist,ngti,filtstr)
 
        }
        else{
            duration = QP_ONTIME(qphead)
        }
#  Minimum case - make sure old XS-FHIST string gets put in new file
        if( !skip_gti_code ){
                len=strlen(Memc[filtstr])
                if( qp_accessf(qp, filtkey) == NO ){
                    call qpx_addf (qp, filtkey, "c", len+SZ_LINE,
                                   "standard time filter", QPF_INHERIT)
                }
                call qp_pstr(qp, filtkey, Memc[filtstr])
        }
        call mfree(blist, TY_DOUBLE)
        call mfree(elist, TY_DOUBLE)
	return(duration)          
end

procedure strip_qpfilt(timespec,timsp,maxlen)
pointer	timespec	# i: pointer to input filter string (from QPPARSE)
pointer	timsp		# o: pointer to output filter string (for qpex...)
int	maxlen

int	n
int	strlen()

begin
#  The user filter string from QPPARSE needs to be massaged for use in QPEX
	Memc[timsp] = EOS
        # Strip off the leading and trailing []
        n = strlen(Memc[timespec])
        if( n >= 2 ){
            call strcpy( Memc[timespec+1],Memc[timsp], maxlen)
            Memc[timsp+n-1-1]=EOS
        }
	else
            call strcpy(Memc[timespec],Memc[timsp],n)
end

