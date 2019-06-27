# SETCFH12K -- Run instrument setup script.

procedure setcfh12k ()

file script = "cfh12k$lib/db/setcfh12k.cl" {prompt="Script to setup instrument"}

begin
    echo = yes
    cl (< script)
    echo = no
end
