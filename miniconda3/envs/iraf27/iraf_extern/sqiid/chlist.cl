# CHLIST 21FEB94 KMM
# CHLIST produces list of images of form id### 
#    where id is an alphanumeric base id and ### is an  integers:
#    starting at first_image, increments of delta, number images in final list
#    e.g.  deltalist dat001 3 delta=3 produces
#        dat001
#        dat004
#        dat007
# CHLIST: 09SEP93 KMM incorporates id_color indicator to all additional
#                        choices for color naming conventions

procedure chlist (first_image,number)

string  first_image {prompt="First image in sequentially numbered images"}
int     number      {prompt="Number of images in output list"}
int     delta       {4,prompt=""}
string  id_color    {"end",
                      prompt="Location of color indicator? (end|predot|seq)",
                        enum="end|predot|sequence" }
#   "predot ==     FIRE mode: root || [jhkl] || .number
#   "   end == WILDFIRE mode: root || (.) number || [jhkl]
#   "          sequence mode: root || number; number incerments between colors

   begin

      int    nim,i,max,off
      string first,name,name0,color,snim
      file   tmp1

      first = first_image
      max = number
   # get rid of ".imh" extension
      i = strlen(first)
      if (substr(first,i-3,i) == ".imh")
         first = substr(first,1,i-4)
      i = strlen(first)
      
      if (id_color == "end") {
         color = substr(first,i,i)
         first = substr(first,1,(i-1))	# drop [jhkl]
         for (nim=1; nim <= max; nim += 1) {
             name = first + (nim-1)*delta
             print (name//color//".imh")
         }
      } else {
         for (nim=1; nim <= max; nim += 1) {
             name = first + (nim-1)*delta
             print (name//".imh")
         }
      }

  end
