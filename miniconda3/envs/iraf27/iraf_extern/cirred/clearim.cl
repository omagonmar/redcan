procedure clearim ( input_name )

#
# 25 may 99. RDB. 
#

string input_name

begin
	string image

	show imtype | scan image

	if (image=="imh") {
	  if ( access ( input_name//".imh" ))
	  imdel ( input_name//".imh" , v- )
	} else if (image=="fits") {
	  if ( access ( input_name//".imh" ))
	  imdel ( input_name//".imh" , v- )
	  if ( access ( input_name//".fits" ))
	  imdel ( input_name//".fits" , v- )
        }
	if ( access ( input_name ))
		del ( input_name )
end
