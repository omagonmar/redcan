# ESOSETINST -- Run instrument setup script.

procedure esosetinst ()

file script = "esodb$esowfi.cl"		{prompt="Script to setup instrument"}

begin
    cl (< script)
end
