# EXPANDNIM: 07APR90 KMM
# EXPANDNIM: 03OCT90 KMM
# EXPANDNIM epand range of numbers to a list of image numbers

procedure expandnim (nimrange)

string nimrange    {prompt="Range of image numbers"}
int    ref_nim     {-1,prompt="Prepended image number (<0 == none)"}
int    max_nim     {100,prompt="Maximum image number"}
struct  *list1

begin

int    ncomp,lo,hi
string key,image_nims,sjunk
file   tmp1,tmp2,nimlist

     image_nims  = nimrange  
     ncomp       = max_nim
     tmp1        = mktemp ("tmp$exn")
     tmp2        = mktemp ("tmp$exn")
     nimlist     = mktemp ("tmp$exn")
     # Expand the range of mosaic images
     if (image_nims == "all" || image_nims == "*")
        image_nims = "1-"//ncomp
     print (image_nims, ",") | translit ("", "^-,0-9", del+) |
        translit ("", "-", "!", del-) | tokens (new-) |
        translit ("", "\n,", " \n", del-, > tmp1)
     list1 = tmp1
     while (fscan (list1, lo, key, hi, sjunk) != EOF) {
        if (nscan() == 0)
           next
        else if (nscan() == 1 && lo >= 1)
           print (lo, >> tmp2)
        else if (nscan() == 3) {
           lo = min (max (lo, 1), ncomp); hi = min (max (hi, 1), ncomp)
        for (i = lo; i <= hi; i += 1)
            print (i, >> tmp2)
        }
     }
   # Prepend reference image to list
     if (ref_nim >= 0) print (ref_nim,> nimlist)
     sort (tmp2, col=0, ign+, num+, rev-) | unique (>> nimlist)
     type (nimlist)

     list1 = ""
     delete (tmp1//","//tmp2//","//nimlist, ver-, >& "dev$null")


end
