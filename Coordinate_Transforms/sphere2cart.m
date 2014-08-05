function [x,y,z] = sphere2cart(range,az,el)

kx = sin(az) .* cos(el);
ky = cos(az) .* cos(el);
kz = sin(el);

x = range.*kx;
y = range.*ky;
z = range.*kz;