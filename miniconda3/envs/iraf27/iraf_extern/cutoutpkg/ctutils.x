include <ctotok.h>
include <ctype.h>


# CT_IMROOT -- Get the image name minus the directory specification.

procedure ct_imroot (image, root, maxch)

char    image[ARB]              #I input image name
char    root[ARB]               #O output image name minus the directory spec
int     maxch                   #I maximum number of characters

pointer sp, imroot, kernel, section, str
int     clindex, clsize, nchars
int     fnldir()

begin
        call smark (sp)
        call salloc (imroot, SZ_PATHNAME, TY_CHAR)
        call salloc (kernel, SZ_FNAME, TY_CHAR)
        call salloc (section, SZ_FNAME, TY_CHAR)
        call salloc (str, SZ_PATHNAME, TY_CHAR)

        call imparse (image, Memc[imroot], SZ_PATHNAME, Memc[kernel], SZ_FNAME,
            Memc[section], SZ_FNAME, clindex, clsize)
        nchars = fnldir (Memc[imroot], Memc[str], SZ_PATHNAME)
        if (clindex >= 0) {
            call sprintf (root, maxch, "%s[%d]%s%s")
                call pargstr (Memc[imroot+nchars])
                call pargi (clindex)
                call pargstr (Memc[kernel])
                call pargstr (Memc[section])
        } else {
            call sprintf (root, maxch, "%s%s%s")
                call pargstr (Memc[imroot+nchars])
                call pargstr (Memc[kernel])
                call pargstr (Memc[section])
        }

        call sfree (sp)
end


# CT_OIMNAME -- Procedure to construct an output image name. If output is null
# or a directory a name is constructed from the root of the image name and the
# extension. The disk is searched to avoid name collisions.
#
# Note that for now I have disabled version number checking. This can be
# restored should it proved necessary.

procedure ct_oimname (image, output, ext, name, maxch)

char    image[ARB]              # image name
char    output[ARB]             # output directory or name
char    ext[ARB]                # extension
char    name[ARB]               # output name
int     maxch                   # maximum size of name

int     ndir, nimdir, clindex, clsize
pointer sp, root, str
int     fnldir(), strlen()

begin
        call smark (sp)
        call salloc (root, SZ_FNAME, TY_CHAR)
        call salloc (str, SZ_FNAME, TY_CHAR)

        ndir = fnldir (output, name, maxch)
        if (strlen (output) == ndir) {
            call imparse (image, Memc[root], SZ_FNAME, Memc[str], SZ_FNAME,
                Memc[str], SZ_FNAME, clindex, clsize)
            nimdir = fnldir (Memc[root], Memc[str], SZ_FNAME)
            if (clindex >= 0) {
                if (ext[1] == EOS) {
                    #call sprintf (name[ndir+1], maxch, "%s%d.*")
                    call sprintf (name[ndir+1], maxch, "%s%d")
                        call pargstr (Memc[root+nimdir])
                        call pargi (clindex)
                } else {
                    #call sprintf (name[ndir+1], maxch, "%s%d.%s.*")
                    call sprintf (name[ndir+1], maxch, "%s%d.%s")
                        call pargstr (Memc[root+nimdir])
                        call pargi (clindex)
                        call pargstr (ext)
                }
            } else {
                if (ext[1] == EOS) {
                    #call sprintf (name[ndir+1], maxch, "%s.*")
                    call sprintf (name[ndir+1], maxch, "%s")
                        call pargstr (Memc[root+nimdir])
                } else {
                    #call sprintf (name[ndir+1], maxch, "%s.%s.*")
                    call sprintf (name[ndir+1], maxch, "%s.%s")
                        call pargstr (Memc[root+nimdir])
                        call pargstr (ext)
                }
            }
            #call ct_oimversion (name, name, maxch)
        } else
            call strcpy (output, name, maxch)

        call sfree (sp)
end


# CT_OIMVERSION -- Routine to compute the next available version number of
# a given file name template and output the new files name.

procedure ct_oimversion (template, filename, maxch)

char    template[ARB]                   # name template
char    filename[ARB]                   # output name
int     maxch                           # maximum number of characters

char    period
int     newversion, version, len
pointer sp, list, name
int     imtopen(), imtgetim(), strldx(), ctoi()

begin
        # Allocate temporary space
        call smark (sp)
        call salloc (name, maxch, TY_CHAR)
        period = '.'
        list = imtopen (template)

        # Loop over the names in the list searchng for the highest version.
        newversion = 0
        while (imtgetim (list, Memc[name], maxch) != EOF) {
            len = strldx (period, Memc[name])
            Memc[name+len-1] = EOS
            len = strldx (period, Memc[name])
            len = len + 1
            if (ctoi (Memc[name], len, version) <= 0)
                next
            newversion = max (newversion, version)
        }

        # Make new output file name.
        len = strldx (period, template)
        call strcpy (template, filename, len)
        call sprintf (filename[len+1], maxch, "%d")
            call pargi (newversion + 1)

        call imtclose (list)
        call sfree (sp)
end


# CT_MKDIC -- Reformat the string so that it is a suitable string dictionary
# for the STRDIC routine.

int procedure ct_mkdic (instr, outstr, maxch)

char    instr[ARB]          	# input list of items
char    outstr[ARB]             # output item dictionary
int     maxch  	                # maximum length of the output dictionary

int     ip, nitems
pointer sp, str
int     ct_getitem()

begin
        call smark (sp)
        call salloc (str, maxch, TY_CHAR)

        ip = 1
        nitems = 0
        outstr[1] = EOS
        while (ct_getitem (instr, ip, Memc[str], maxch) != EOF) {
            call strcat (",", outstr, maxch)
            call strcat (Memc[str], outstr, maxch)
            nitems = nitems + 1
        }

        call sfree (sp)

        return (nitems)
end


# CT_GETITEM -- Get the next item from a list.

int procedure ct_getitem (list, ip, item, maxch)

char    list[ARB]               # list of items
int     ip                      # pointer in to the list of items
char    item[ARB]               # the output item
int     maxch                   # maximum length of an item

int     op, token
int     ctotok(), strlen()

begin
        # Decode the list.
        op = 1
        while (list[ip] != EOS) {

            token = ctotok (list, ip, item[op], maxch)
            if (item[op] == EOS)
                next
            if ((token == TOK_UNKNOWN) || (token == TOK_CHARCON))
                break
            if ((token == TOK_PUNCTUATION) && (item[op] == ',')) {
                if (op == 1)
                    next
                else
                    break
            }

            op = op + strlen (item[op])
            if (IS_WHITE(list[ip]))
                break
        }

        item[op] = EOS
        if ((list[ip] == EOS) && (op == 1))
            return (EOF)
        else
            return (op - 1)
end


define  LOGPTR          20                      # log2(maxpts) (1e6)


# CT_QSORTD -- Vector Quicksort. In this version the index array is
# sorted.

procedure ct_qsortd (data, a, b, npix)

double  data[ARB]               # data array
int     a[ARB], b[ARB]          # index array
int     npix                    # number of pixels

int     i, j, lv[LOGPTR], p, uv[LOGPTR], temp
double  pivot

begin
        # Initialize the indices for an inplace sort.
        do i = 1, npix
            a[i] = i
        call amovi (a, b, npix)

        p = 1
        lv[1] = 1
        uv[1] = npix
        while (p > 0) {

            # If only one elem in subset pop stack otherwise pivot line.
            if (lv[p] >= uv[p])
                p = p - 1
            else {
                i = lv[p] - 1
                j = uv[p]
                pivot = data[b[j]]

                while (i < j) {
                    for (i=i+1;  data[b[i]] < pivot;  i=i+1)
                        ;
                    for (j=j-1;  j > i;  j=j-1)
                        if (data[b[j]] <= pivot)
                            break
                    if (i < j) {                # out of order pair
                        temp = b[j]             # interchange elements
                        b[j] = b[i]
                        b[i] = temp
                    }
                }
                j = uv[p]                       # move pivot to position i
                temp = b[j]                     # interchange elements
                b[j] = b[i]
                b[i] = temp

                if (i-lv[p] < uv[p] - i) {      # stack so shorter done first
                    lv[p+1] = lv[p]
                    uv[p+1] = i - 1
                    lv[p] = i + 1
                } else {
                    lv[p+1] = i + 1
                    uv[p+1] = uv[p]
                    uv[p] = i - 1
                }

                p = p + 1                       # push onto stack
            }
        }
end

