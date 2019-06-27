# MKMASK: 04OCT91 KMM
# MKMASK -- Replace all values inside a range with one value
#           and all values outside a range with another value

procedure mkmask (input, output, lower_lim, upper_lim)

string  input       {prompt="Input images"}
string  output      {prompt="Clipped output images"}
real    lower_lim   {prompt="Lower limit for in/exclusion"}
real    upper_lim   {prompt="Upper limit for in/exclusion"}
real    in_value    {1.0,prompt="Replacement value inside range"}
real    out_value   {0.0,prompt="Replacement value outside range"}

string  section     {"[]",prompt="Image section for replacement"}
string  trimlimits  {"[0:0,0:0]",prompt="trim limits around edge"}
#bool    outside     {yes,prompt="Revalue pixels outside/inside range"}
bool    verbose     {yes,prompt="Verbose output?"}
struct  *inlist, *outlist, *l_list

   begin

   # Assign positional parameters to local variables
      int    npos, nxhitrim, nxlotrim, nyhitrim, nylotrim, stat, ncols, nrows
      real   uplim,lolim
      string in, out, uniq, sname, sjunk
      file   infile, outfile, l_log

   # Assign positional parameters to local variables
      in          = input
      out         = output
      lolim       = lower_lim
      uplim       = upper_lim
      uniq        = mktemp ("_Timc")
      infile      = mktemp ("tmp$msk")
      outfile     = mktemp ("tmp$msk")
      l_log       = mktemp ("tmp$msk")
      nxlotrim = 0; nxhitrim = 0; nylotrim = 0; nyhitrim = 0
      print (trimlimits) | translit ("", "[:,]", "    ", >> l_log)
      l_list = l_log
      stat = (fscan(l_list,nxlotrim,nxhitrim,nylotrim,nyhitrim))
      sections (in,  option="root", >> infile)
      sections (out, option="root", >> outfile)
      imcopy (in, out, verbose=no)
      outlist  = outfile
      while (fscan (outlist, sname) != EOF) {
   # Strip off ".imh"
         npos  = strlen(sname)
         if (substr(sname,npos-3,npos) == ".imh")
            sname = substr(sname,1,npos-4)
         sname = sname // section
   # Get image size
         hedit(sname,"i_naxis1",".",>> l_log)
         stat = fscan(l_list, sjunk, sjunk, ncols)
         hedit(sname,"i_naxis2",".",>> l_log)
         stat = fscan(l_list, sjunk, sjunk, nrows)
   # Generate temporary data list for dark subtracted frames
   # inside range
         imreplace(sname,in_value,imaginary=0.0,lower=lolim,upper=uplim)
   # outside range
         if (lolim != INDEF)
            imreplace(sname,out_value,imaginary=0.0,lower=INDEF,upper=lolim)
         if (uplim != INDEF)
            imreplace(sname,out_value,imaginary=0.0,lower=uplim,upper=INDEF)
   # trim region
         if (nxlotrim !=0) {
            sjunk = sname//"[1:"//nxlotrim//",*]"
            imreplace(sjunk,out_value,imaginary=0.0,lower=INDEF,upper=INDEF)
         } 
         if (nxhitrim !=0) {
            sjunk = sname//"["//ncols-nxhitrim+1//":"//ncols//",*]"
            imreplace(sjunk,out_value,imaginary=0.0,lower=INDEF,upper=INDEF)
         } 
         if (nylotrim !=0) {
            sjunk = sname//"[*,1:"//nylotrim//"]"
            imreplace(sjunk,out_value,imaginary=0.0,lower=INDEF,upper=INDEF)
         } 
         if (nyhitrim !=0) {
            sjunk = sname//"[*,"//nrows-nyhitrim+1//":"//nrows//"]"
            imreplace(sjunk,out_value,imaginary=0.0,lower=INDEF,upper=INDEF)
         } 
             
      }
   # Finish up
      delete   (infile//","//outfile//","//l_log//","//uniq//"*", verify=no)

end
