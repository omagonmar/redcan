# COLORLIST: 21FEB94 KMM
# COLORLIST: 02DEC91 KMM 10APR92
# COLORLIST produces list of images for given color from Jlist
#    where id is an alphanumeric base id and ### is an  integers:
#    starting at first_image, increments of 0-3 based on color
# COLORLIST: 09SEP93 KMM incorporates id_color indicator to all additional
#                        choices for color naming conventions

procedure colorlist (first_image,color_image)

   string  first_image {prompt="Image list"}
   string  color_image {prompt="Image color: |j|h|k|l|1|2|3|4",
                          enum="j|h|k|l|1|2|3|4"}
   string  id_color  {"end",
                       prompt="Location of color indicator? (end|predot|seq)",
                         enum="end|predot|sequence" }
#   "predot ==     FIRE mode: root || [jhkl] || .number
#   "   end == WILDFIRE mode: root || (.) number || [jhkl]
#   "          sequence mode: root || number; number incerments between colors
#   bool    fire_mode   {yes,prompt="FIRE mode (root || [jhkl] || .number) "}
   string  section     {"",prompt="Image subsection [xmin:xmax,ymin:ymax]"}
   struct  *ilist

   begin

      int    nim,i,max,off
      string first,name,name0,color,snim
      file   tmp1

      tmp1 = mktemp("tmp$col")

      first = first_image
      color = color_image
   # get rid of ".imh" extension
      if (color == "J" || color == "j" || color == "1") {
         color = "j"
         off = 0
      } else if (color == "H" || color == "h" || color == "2") {
         color = "h"
         off = 1
      } else if (color == "K" || color == "k" || color == "3") {
         color = "k"
         off = 2
      } else if (color == "L" || color == "l" || color == "4") {
         color = "l"
         off = 3
      } else {
         print ("Undefined color offset: ",color)
         goto skip
      }

   # expand file template
      sections(first,option="root",> tmp1)
      ilist = tmp1
      while (fscan(ilist,name0) != EOF) {
         i = strlen(name0)
         if (substr(name0,i-3,i) == ".imh") name0 = substr(name0,1,i-4)
         i = strlen(name0)
         if (id_color == "predot") {
            off = stridx(".",name0)
            snim = substr(name0,off,i)
            name0 = substr(name0,1,(off - 2))	# drop [jhkl]
            name = name0 //color//snim
         } else if (id_color == "end") {
            name0 = substr(name0,1,(i-1))	# drop [jhkl]
            name = name0 // color
         } else {
            name = name0 + off
         }
         print (name//".imh"//section)
      }

      skip:
       
      delete (tmp1, verify-,>& "dev$null")

  end
