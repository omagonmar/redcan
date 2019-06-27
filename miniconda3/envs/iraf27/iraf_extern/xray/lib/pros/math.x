include <math.h>

real procedure atan2d (a,b)
real	a,b
begin
	return (atan2(DEGTORAD(a),DEGTORAD(b)))
end


double procedure datan2d (a,b)
real	a,b
begin
	return (atan2(DEGTORAD(a),DEGTORAD(b)))
end


double procedure dcosd (a)
real	a
begin
	return (cos(DEGTORAD(a)))
end


real procedure cosd (a)
real	a
begin
	return (cos(DEGTORAD(a)))
end


real procedure dacosd (a)
real	a
begin
	return (acos(DEGTORAD(a)))
end


double procedure dsind (a)
real	a
begin
	return (sin(DEGTORAD(a)))
end


real procedure sind (a)
real	a
begin
	return (sin(DEGTORAD(a)))
end


real procedure acosd (a)
real	a
begin
	return (acos(DEGTORAD(a)))
end
