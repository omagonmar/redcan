procedure cleanup()

# bool  tmp_include  {yes, prompt="Include all tmp$ files?"}

begin
      string dname= "_T*"
      imdelete (dname//".imh", verify-)
      delete (dname, verify-)
end
