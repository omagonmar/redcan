#$Header: /home/pros/xray/lib/regions/RCS/regcpu.x,v 11.0 1997/11/06 16:19:02 prosb Exp $
#$Log: regcpu.x,v $
#Revision 11.0  1997/11/06 16:19:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:16  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:30:34  mo
#MC	7/2/93		Correct boolean function return to remove == YES
#			and remove FUNCTION declaration of rg_cpu
#
#Revision 6.0  93/05/24  15:37:57  prosb
#General Release 2.2
#
#Revision 5.1  93/04/27  00:02:30  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:13:40  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:19:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:32:01  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:14:31  pros
#General Release 1.0
#
#
#	REGCPU.X - routines to:
#			append compiled instructions to the virtual CPU pgm;
#			save and recall deferred virtual CPU programs and 
#				multi region control structures (for EXCLUDE 
#				regions);
#			execute virtual CPU programs;
#			debug virtual CPU operations
#			
#

include <error.h>
include <time.h>

include <regparse.h>

#
# RG_COMPILE0 -- append an instruction with no arguments to the virtual CPU pgm
#
procedure rg_compile0(inst)

int inst				# i: instruction
include "regparse.com"

begin
	if( rg_nextinst >= MAX_INST )
	    call error(EA_FATAL, "too many instructions")
	INST(rg_nextinst) = inst
	rg_nextinst = rg_nextinst + 1
end

#
# RG_COMPILE1 -- append an instruction with 1 argument to the virtual CPU pgm
#
procedure rg_compile1(inst, a)

int inst				# i: instruction
pointer a				# i: arg 1
include "regparse.com"

begin
	if( rg_nextinst >= MAX_INST )
	    call error(EA_FATAL, "too many instructions")
	INST(rg_nextinst) = inst
	ARG1(rg_nextinst) = a
	rg_nextinst = rg_nextinst + 1
end

#
# RG_SAVECPU -- save the virtual CPU program and multi region control 
#               structures; it is an EXCLUDE region, to be done later
#
procedure rg_savecpu(exclfd)

int	exclfd			# i: file handle for EXCLUDE regions'
				#    (deferred) virtual CPU programs
int	ninsts			# l: number of instructions in program
include "regparse.com"

begin
	ninsts = rg_nextinst-1
	# save number of insts
	call write(exclfd, ninsts, SZ_INT)
	# save insts
	call write(exclfd, rg_metacode, ninsts*LEN_INST*SZ_INT)
	# save multiple annuli info
	call write(exclfd, Memi[rg_annuli], LEN_MULTI*SZ_INT)
	# save multiple slices info
	call write(exclfd, Memi[rg_slices], LEN_MULTI*SZ_INT)
end

#
# RG_RECALLCPU -- recall a saved virtual CPU program and its multi region 
#                 control structures; it's time to do this EXCLUDE region
#
int procedure rg_recallcpu(exclfd)

int	exclfd			# i: file handle for EXCLUDE regions'
				#    (deferred) virtual CPU programs
int	ninsts			# l: number of instructions in program
int	read()
include "regparse.com"

begin
	# read back number of insts
	if( read(exclfd, ninsts, SZ_INT) == EOF )
	    return(NO)
	# read back insts
	else if( read(exclfd, rg_metacode, ninsts*LEN_INST*SZ_INT) == EOF ){
	    call error(EA_FATAL, "unexpected EOF reading saved cpu")
	    return(NO)
	}
	# read back multiple annuli info
	else if( read(exclfd, Memi[rg_annuli], LEN_MULTI*SZ_INT) == EOF){
	    call error(EA_FATAL, "unexpected EOF reading saved cpu")
	    return(NO)
	}
	# read back multiple slices info
	else if( read(exclfd, Memi[rg_slices], LEN_MULTI*SZ_INT) == EOF){
	    call error(EA_FATAL, "unexpected EOF reading saved cpu")
	    return(NO)
	}
	else{
	    rg_nextinst = ninsts+1
	    return(YES)
	}
end

#
# RG_EXECUTE -- Under control of the multi region control structures, 
#               execute the virtual CPU program, once for each region 
#               defined by a combination of the multi parameters 
#               (once, if the region isn't a multi)
#
procedure rg_execute(parsing, debug)

pointer	parsing			# i: pointer to parsing control structure
int	debug			# i: debug level

int	i, j			# l: loop variables
include "regparse.com"

begin
	# If not supposed to be here, or had an error earlier, just return
	if( (!rg_executing) || (rg_eflag == YES) ) return

#	# If multi slices ...
#	if( M_INST(rg_slices) !=0 )
#	    # ... set slice argv to argv for 1st slice.
#	    # [Unnecessary; rg_region() already did it.]
#	    R_ARGV(ARG1(M_INST(rg_slices))) = M_BASE(rg_slices)

	# Execute the compiled code as many times as necessary.

	# For each slice, ...
	for(i=1; i<=M_ITER(rg_slices); i=i+1){

	    # ... if multi annuli ...
	    if( M_INST(rg_annuli) !=0 )
		# ... set annulus argv to argv for 1st annulus.
	        R_ARGV(ARG1(M_INST(rg_annuli))) = M_BASE(rg_annuli)

	    # For each annulus ...
	    for(j=1; j<=M_ITER(rg_annuli); j=j+1){

		# ... execute the program one time.
		call rg_exe1(parsing, debug)

		# If multi annuli ...
		if( M_INST(rg_annuli) !=0 ){
		    # ... set annulus argv to argv for next annulus.
		    R_ARGV(ARG1(M_INST(rg_annuli))) =
		    R_ARGV(ARG1(M_INST(rg_annuli))) + M_INC(rg_annuli)
		}
	    }
	    # If multi slices ...
	    if( M_INST(rg_slices) !=0 )
		# ... set slice argv to argv for next slice.
		R_ARGV(ARG1(M_INST(rg_slices))) =
		R_ARGV(ARG1(M_INST(rg_slices))) + M_INC(rg_slices)
	}
end

#
# RG_EXE1 -- execute the virtual CPU program one time
#
procedure rg_exe1(parsing, debug)

pointer	parsing		# i: pointer to parsing control structure
int	debug		# i: debug level

bool	making_note	# l: whether making a note structure for this region
pointer	note		# l: pointer to new note structure, filled with this 
			#    region's descriptor string (possibly truncated, 
			#    operator postfix notation, logical pixels), and 
			#    limits of annulus and/or pie slice
int	vpc		# l: virtual CPU program counter
int	i		# l: temp integer
char	op[2]		# l: temp buffer for boolean operator for note string

pointer	rg_alloc_note()	#  : alloc & init a new note structure

include "regparse.com"

begin
	# If not supposed to be here, or had an error earlier, just return
	if( (!rg_executing) || (rg_eflag == YES) )
	    return

	# return if there are no instructions
	if( rg_nextinst == 1 )
	    return

	# start timing
	call rg_time(debug, "start cpu")

	# display instructions
	if( debug !=0 )
	    call rg_cpu()

	# if we are making single-region notes and this is an include region, 
	#  allocate a new note structure, initialize it, and append it to 
	#  the list
	making_note = ( (rg_inclreg==YES) && 
				(RGPARSE_OPT(ONEREGNOTES, parsing) != NULL))
	if (making_note)
	    note = rg_alloc_note(parsing)

	# execute the machine, one instruction at a time
	vpc = 1
	while( INST(vpc) != OP_RTN ){

	    # check for error on previous instruction
	    if( rg_eflag == YES )
		return

	    if( debug >= 5 ){
		# display this instruction's opcode
		call printf("vpc=%d, INST=%d\n")
		call pargi(vpc)
		call pargi(INST(vpc))
		call flush(STDOUT)
	    }

	    # execute the instruction
	    switch( INST(vpc) ){

		case OP_NEW:
		    if (rg_making_mask)
			call rg_new(R_CODE(ARG1(vpc)), R_ARGC(ARG1(vpc)),
					Memr[R_ARGV(ARG1(vpc))])
		    if (making_note)
			call rg_note_new(parsing, R_CODE(ARG1(vpc)), 
						  R_ARGC(ARG1(vpc)), 
						  Memr[R_ARGV(ARG1(vpc))])
		case OP_UNSET:
		    if (rg_making_mask)
			call rg_not()
		    if (making_note)
			call strcat("! ", ORN_DESCBUF(note), SZ_ONEREGDESC)
		case OP_MERGE:
		    if (rg_making_mask)
			call rg_merge(ARG1(vpc))
		    if (making_note)  {
			switch (ARG1(vpc))  {
			    case OP_AND:  call strcpy("& ", op, 2)
			    case OP_OR:   call strcpy("| ", op, 2)
			    case OP_XOR:  call strcpy("^ ", op, 2)
			    default:
				call error(EA_FATAL, "unknown opcode\n")
			}
			call strcat(op, ORN_DESCBUF(note), SZ_ONEREGDESC)
		    }
		case OP_FLUSH:
		    if (rg_making_mask)  {
			# if it's not an exclude, use a real index
			if( rg_inclreg == YES ){
			    i = REGNUM(parsing)
			    REGNUM(parsing) = i + 1
			}
			# otherwise use a 0, which will unset the region
			else
			    i = 0
			call rg_flush(i, MASKPTR(rg_parsing))
		    }
		default:
		    call error(EA_FATAL, "unknown CPU instruction")
	    }
	    vpc = vpc + 1
	}

	# end timing
	call rg_time(debug, "end cpu")
end


#
# RG_TIME -- print out time for debugging
#
procedure rg_time(debug, str)

int	debug			# i: debug level
char	str[ARB]		# i: string to print out

char	timstr[SZ_TIME]		# l: output debug str
long	clktime()		# l: get time since 1-1-80
include "regparse.com"

begin
    if( debug >= 1 ){
	call cnvtime(clktime(long(0)), timstr, SZ_TIME)
	call printf("%s:\t%s\n")
	call pargstr(str)
	call pargstr(timstr)
    }
end

#
# RG_CPU - for debugging, list the virtual CPU program
#
#int procedure rg_cpu()
procedure rg_cpu()

int	vpc			# l: virtual CPU program counter

include "regparse.com"

begin
	for(vpc=1; vpc<rg_nextinst; vpc=vpc+1){
	    call printf("inst %d:\t%d:\t%d\n")
	    call pargi(vpc)
	    call pargi(INST(vpc))
	    call pargi(ARG1(vpc))
	}
	call printf("\n")
	call flush(STDOUT)
end
