# $Header: /home/pros/xray/xraytasks/RCS/xapropos.cl,v 11.0 1997/11/06 16:46:34 prosb Exp $
# $Log: xapropos.cl,v $
# Revision 11.0  1997/11/06 16:46:34  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:37:14  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:29  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:03:18  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:51  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:44:11  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/24  14:25:48  mo
#MC	4/24/92		Remove the STSDAS data base
#
#Revision 1.1  92/04/23  15:40:06  mo
#Initial revision
#
procedure xapropos(topic)
  string   topic      {prompt="topic requested",mode="a"}
  bool     ignorecase {yes,prompt="ignore case in subject string?",mode="h"}
  string dbname	      {"xray$lib/xray.db,xray$lib/iraf.db,xray$lib/tables.db,xray$lib/noao.db",prompt="data base names",mode="h"}
  bool     verbose       {no,prompt="print database filenames when searching?" ,mode="h"}

begin
  string top
  bool ign
  bool verb
  string dbn

  if( !deftask("ctio") ){
    error (1,"requires ctio package to be installed")
  }
  ;
  
  if( !deftask("apropos") ){
    error (1,"requires ctio package to be loaded" )
  }
  ;

  top = topic
  ign = ignorecase
  verb = verbose
  dbn = dbname

apropos (top,ignore_case=ign,aproposdb=dbn,verbose=verb)


end
