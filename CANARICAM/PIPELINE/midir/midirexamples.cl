# Copyright(c) 2003-2006 Association of Universities for Research in Astronomy, Inc.

procedure midirexamples (example)

char    example {enum="im_mich|im_trecs|sp_mich|spectroscopy|polarimetry", prompt="Example to print"}

begin

    char    l_example
    
    l_example=example

    if (l_example == "im_mich")
        page ("midir$doc/GN-CAL20031109_im_michelle_example.cl")
    else if (l_example == "im_trecs")
        page ("midir$doc/GS-2003B-SV-101-eng_im_trecs_example.cl")
    else if (l_example == "sp_mich")
        page ("midir$doc/GN-ENG-MICHELLE_sp_midir_example.cl")
    else if (l_example == "spectroscopy")
        page ("midir$doc/GN-spectro_example.cl")
    else if (l_example == "polarimetry")
        page ("midir$doc/GN-michpol_example.cl")
    else
        printf ("MIDIREXAMPLES - ERROR  Invalid example ID\n")

end
