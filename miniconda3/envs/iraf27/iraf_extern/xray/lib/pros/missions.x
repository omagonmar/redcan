#$Header: /home/pros/xray/lib/pros/RCS/missions.x,v 11.0 1997/11/06 16:20:38 prosb Exp $
#$Log: missions.x,v $
#Revision 11.0  1997/11/06 16:20:38  prosb
#General Release 2.5
#
#Revision 9.2  1996/02/13 15:33:58  prosb
#JCC - Add new cases for AXAF instruments in inst_ctoi and inst_itoc;
#      Add two new routines: tscope_ctoi and tscope_itoc.
#
#Revision 9.0  1995/11/16  18:27:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:52  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:38:21  mo
#MC	12/1/93		Update current missions and names
#
#Revision 6.0  93/05/24  15:45:02  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:58  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:00:50  wendy
#General
#
#Revision 2.0  91/03/07  00:07:08  pros
#General Release 1.0
#
#
#  MISSIONS.X -- routines to support specific missions
#

include <missions.h>  

#
#  MIS_ITOC -- convert mission ID to a string
#
procedure mis_itoc(mission, misstr, len)

int	mission				# i: mission id
char	misstr[ARB]			# o: mission name
int	len				# i: length of output string

begin
	# look for a match
	switch(mission){
	case EINSTEIN:
	    call strcpy("EINSTEIN", misstr, len)
	case ROSAT:
	    call strcpy("ROSAT", misstr, len)
	case ASTROD:
	    call strcpy("ASCA", misstr, len)
#	case ASTROD:
#	    call strcpy("ASTROD", misstr, len)
	case AXAF:
	    call strcpy("AXAF", misstr, len)
#	case SODART:
#	    call strcpy("SODART", misstr, len)
	case SRG:
	    call strcpy("SRG", misstr, len)
	default:
	    call strcpy("UNKNOWN", misstr, len)
	}
end

#
#  INST_ITOC -- convert inst ID to a string
#
procedure inst_itoc(inst, subinst, inststr, len)

int	inst				# i: instrument ID
int	subinst				# i: instrument sub-no
char	inststr[ARB]			# o: mission name
int	len				# i: length of output string

begin
	# look for a match
	switch(inst){
	case EINSTEIN_HRI:
	    call strcpy("HRI", inststr, len)
	case EINSTEIN_FPCS:
	    call strcpy("FPCS", inststr, len)
	case EINSTEIN_IPC:
	    call strcpy("IPC-1", inststr, len)
#	    call strcpy("IPC", inststr, len)
	case EINSTEIN_SSS:
	    call strcpy("SSS", inststr, len)
	case EINSTEIN_MPC:
	    call strcpy("MPC", inststr, len)
	case ROSAT_HRI:
	    if( subinst == 2 )
	        call strcpy("HRI-2", inststr, len)
	    else if( subinst == 3 )
	        call strcpy("HRI-3", inststr, len)
	    else 
	        call strcpy("HRI", inststr, len)
	case ROSAT_PSPC:
	    if( subinst == 1 )
	        call strcpy("PSPCC", inststr, len)
	    else if( subinst == 2 )
	        call strcpy("PSPCB", inststr, len)
	    else 
	        call strcpy("PSPC", inststr, len)
	case ROSAT_WFC:
	    call strcpy("WFC", inststr, len)
	case ASTROD_SIS:
	    call strcpy("SIS", inststr, len)
	case ASTROD_GIS:
	    call strcpy("GIS", inststr, len)
	case AXAF_HRC:
	    call strcpy("HRC", inststr, len)
	case SRG_HEPC1:
	    call strcpy("HEPC1", inststr, len)
	case SRG_HEPC2:
	    call strcpy("HEPC2", inststr, len)
	case SRG_LEPC1:
	    call strcpy("LEPC1", inststr, len)
	case SRG_LEPC2:
	    call strcpy("LEPC2", inststr, len)
#JCC- add new cases for AXAF instruments
        case AXAF_HRC_I:
            call strcpy("HRC-I", inststr, len)
        case AXAF_HRC_I_1:
            call strcpy("HRC-I-1", inststr, len)
        case AXAF_HRC_I_2:
            call strcpy("HRC-I-2", inststr, len)
        case AXAF_HRC_S:
            call strcpy("HRC-S", inststr, len)
        case AXAF_HRC_S_DB:
            call strcpy("HRC-S-DB", inststr, len)
        case AXAF_HRC_PST:
            call strcpy("HRC-PST", inststr, len)
        case AXAF_HETG:
            call strcpy("HETG", inststr, len)
        case AXAF_HETGS_AS:
            call strcpy("HETGS-AS", inststr, len)
        case AXAF_HETGS_AI:
            call strcpy("HETGS-AI", inststr, len)
        case AXAF_HETGS_HS:
            call strcpy("HETGS-HS", inststr, len)
        case AXAF_HETGS_HI:
            call strcpy("HETGS-HI", inststr, len)
        case AXAF_LETG:
            call strcpy("LETG", inststr, len)
        case AXAF_LETGS_AS:
            call strcpy("LETGS-AS", inststr, len)
        case AXAF_LETGS_AI:
            call strcpy("LETGS-AI", inststr, len)
        case AXAF_LETGS_HS:
            call strcpy("LETGS-HS", inststr, len)
        case AXAF_LETGS_HI:
            call strcpy("LETGS-HI", inststr, len)
        case AXAF_ACIS:
            call strcpy("ACIS", inststr, len)
        case AXAF_ACIS_I:
            call strcpy("ACIS-I", inststr, len)
        case AXAF_ACIS_S:
            call strcpy("ACIS-S", inststr, len)
        case AXAF_SSD:
            call strcpy("SSD", inststr, len)
        case AXAF_FPC:
            call strcpy("FPC", inststr, len)
#JCC - end of adding new cases for AXAF instruments
	default:
	    call strcpy("UNKNOWN", inststr, len)
	}
end

#
#  MIS_CTOI -- convert mission string to ID
#
procedure mis_ctoi(misstr, mission)

char	misstr[ARB]			# i: mission name
int	mission				# o: mission id
char	tbuf[SZ_LINE]			# l: temp char buffer
int	strdic()
string	m_names	"|EINSTEIN|ROSAT|ASTROD|ASCA|AXAF|SRG|"

begin
	# convert to upper case
	call strcpy(misstr, tbuf, SZ_LINE)
	call strupr(tbuf)
	# look for a match
	switch ( strdic( tbuf, tbuf, SZ_LINE, m_names ) ) {
	case 1:
	    mission = EINSTEIN
	case 2:
	    mission = ROSAT
	case 3:
	    mission = ASCA
	case 4:
	    mission = ASCA
	case 5:
	    mission = AXAF
	case 6:
	    mission = SRG
	default:
	    mission = 0
	}
end

#
#  INST_CTOI -- convert inst string to an id
#
procedure inst_ctoi(inststr, mission, inst, subinst)

char	inststr[ARB]			# i: instrument string
int	mission				# i: mission (for name resolution)
int	inst				# o: instrument id
int	subinst				# o: sub instrument id
char	tbuf[SZ_LINE]			# l: temp char buffer
int	strdic()
#JCC string	i_names	"|HRI|FPCS|IPC|SSS|PSPC|WFC|SIS1|SIS2|SIS3|GIS1|
#JCC GIS2|GIS3|MPC|HRC|PSPCB|PSPCC|HEPC1|HEPC2|LEPC1|LEPC2|IPC-1|HRI-2|HRI-3|"

#Add new string for AXAF instruments
string  i_names "|HRI|FPCS|IPC|SSS|PSPC|WFC|SIS1|SIS2|SIS3|GIS1|GIS2|GIS3|MPC|HRC|PSPCB|PSPCC|HEPC1|HEPC2|LEPC1|LEPC2|IPC-1|HRI-2|HRI-3|HRC-I|HRC-I-1|HRC-I-2|HRC-S|HRC-S-DB|HRC-PST|HETG|HETGS-AS|HETGS-AI|HETGS-HS|HETGS-HI|LETG|LETGS-AS|LETGS-AI|LETGS-HS|LETGS-HI|ACIS|ACIS-I|ACIS-S|SSD|FPC|"

begin
	# convert to upper case
	call strcpy(inststr, tbuf, SZ_LINE)
	call strupr(tbuf)
	# look for a match
	switch ( strdic( tbuf, tbuf, SZ_LINE, i_names ) ) {
	case 1:
	    switch(mission){
	    case EINSTEIN:
		inst = EINSTEIN_HRI
	    case ROSAT:
		inst = ROSAT_HRI
	    default:
		inst = 0
	    }
	case 2:
	    inst = EINSTEIN_FPCS
	case 3:
	    inst = EINSTEIN_IPC
	case 4:
	    inst = EINSTEIN_SSS
	case 5:
	    inst = ROSAT_PSPC
	case 6:
	    inst = ROSAT_WFC
	case 7:
	    inst = ASTROD_SIS
	    subinst = 1
	case 8:
	    inst = ASTROD_SIS
	    subinst = 2
	case 9:
	    inst = ASTROD_SIS
	    subinst = 3
	case 10:
	    inst = ASTROD_GIS
	    subinst = 1
	case 11:
	    inst = ASTROD_GIS
	    subinst = 2
	case 12:
	    inst = ASTROD_GIS
	    subinst = 3 
	case 13:
	    inst = EINSTEIN_MPC
	case 14:
	    inst = AXAF_HRC
	case 15:
	    inst = ROSAT_PSPC
	    subinst = 2
	case 16:
	    inst = ROSAT_PSPC
	    subinst = 1
	case 17:
	    inst = SRG_HEPC1
	    subinst = 1
	case 18:
	    inst = SRG_HEPC2
	    subinst = 2 
	case 19:
	    inst = SRG_LEPC1
	    subinst = 1
	case 20:
	    inst = SRG_LEPC2
	    subinst = 2 
	case 21:
	    inst = EINSTEIN_IPC
	    subinst = 1
	case 22:
	    inst = EINSTEIN_HRI
	    subinst = 2
	case 23:
	    inst = EINSTEIN_HRI
	    subinst = 3
#JCC- beginning of adding new instruments
        case 24:                         # HRC-I
            inst = AXAF_HRC_I
        case 25:                         # HRC-I-1
            inst = AXAF_HRC_I_1
        case 26:                         # HRC-I-2
            inst = AXAF_HRC_I_2
        case 27:                         # HRC-S
            inst = AXAF_HRC_S
        case 28:                         # HRC-S-DB
            inst = AXAF_HRC_S_DB
        case 29:                         # HRC-PST
            inst = AXAF_HRC_PST
        case 30:                         # HETG
            inst = AXAF_HETG
        case 31:                         # HETGS-AS
            inst = AXAF_HETGS_AS
        case 32:                         # HETGS-AI
            inst = AXAF_HETGS_AI
        case 33:                         # HETGS-HS
            inst = AXAF_HETGS_HS
        case 34:                         # HETGS-HI
            inst = AXAF_HETGS_HI
        case 35:                         # LETG
            inst = AXAF_LETG
        case 36:                         # LETGS-AS
            inst = AXAF_LETGS_AS
        case 37:                         # LETGS-AI
            inst = AXAF_LETGS_AI
        case 38:                         # LETGS-HS
            inst = AXAF_LETGS_HS
        case 39:                         # LETGS-HI
            inst = AXAF_LETGS_HI
        case 40:                         # ACIS
            inst = AXAF_ACIS
        case 41:                         # ACIS-I
            inst = AXAF_ACIS_I
        case 42:                         # ACIS-S
            inst = AXAF_ACIS_S
        case 43:                         # SSD
            inst = AXAF_SSD
        case 44:                         # FPC
            inst = AXAF_FPC
#JCC- end of adding new instruments
	default:
	    inst = 0
	}
end

#
#  TSCOPE_CTOI -- convert telescope string to ID
#  JCC - Added for AXAF telescope
#
procedure tscope_ctoi(tscopestr, tscope )

char    tscopestr[ARB]          # i: telescope name
int     tscope                       # o: telescope id
char    tbuf[SZ_LINE]                   # l: temp char buffer
int     strdic()

string m_names "|EINSTEIN|ROSAT|ASTROD|ASCA|SRG|AXAF|XRCF-HRMA|SAO_HRC|MIT_CCD|"

begin
        # convert to upper case
        call strcpy(tscopestr, tbuf, SZ_LINE)
        call strupr(tbuf)
        # look for a match
        switch ( strdic( tbuf, tbuf, SZ_LINE, m_names ) ) {
           case 1:
              tscope = EINSTEIN
           case 2:
              tscope = ROSAT
           case 3:
              tscope = ASCA
           case 4:
              tscope = ASCA
           case 5:
              tscope = SRG
           case 6:
              tscope = AXAF
           case 7:
              tscope = XRCF_HRMA
           case 8:
              tscope = SAO_HRC
           case 9:
              tscope = MIT_CCD
           default:
              tscope = 0
        }
end


#
#  TELE_ITOC -- convert telescope ID to a string
#  JCC - Added for AXAF telescope
#
procedure tscope_itoc(tscope, tscopestr, len)

int     tscope                          # i: telescope id
char    tscopestr[ARB]                  # o: telescopy name
int     len                             # i: length of output string

begin
        # look for a match
        switch(tscope){
        case EINSTEIN:
            call strcpy("EINSTEIN", tscopestr, len)
        case ROSAT:
            call strcpy("ROSAT", tscopestr, len)
        case ASTROD:
            call strcpy("ASCA", tscopestr, len)
        case SRG:
            call strcpy("SRG", tscopestr, len)
        case AXAF:
            call strcpy("AXAF", tscopestr, len)
        case XRCF_HRMA:
            call strcpy("XRCF-HRMA", tscopestr, len)
        case SAO_HRC:
            call strcpy("SAO_HRC", tscopestr, len)
        case MIT_CCD:
            call strcpy("MIT_CCD", tscopestr, len)
        default:
            call strcpy("UNKNOWN", tscopestr, len)
        }
end

