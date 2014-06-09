function Patout = AMISR_Pattern(AZ,EL,Az0,El0)
% AMISR_Pattern 
% by John Swoboda
% This function will create an idealized antenna pattern for the AMISR
% array. The pattern is not normalized. 
% The antenna is assumed to made of a grid of ideal cross dipole 
% elements. In the array every other column is shifted by 1/2 dy. The
% parameters are taken from the AMISR spec and the method for calculating
% the field is derived from a report by Adam R. Wichman.
% The inputs for the az and el coordinates can be either an array or
% scalar. If both are arrays they must be the same shape.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% Az - An array or scalar holding the azimuth coordinates in radians.
% EL - An array or scalar holding the elevation coordinates in radians.
%   Also vertical is at zero radians.
% Az0 - A scalar that determines the azimuth pointing angle of the antenna.
% El0 - A scalar that determines the elevation pointing angle of the
% antenna.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% Patout - The normalized radiation density.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0=299792458; % speed of light m/s
f0=440e6;% frequency of AMISR in Hz
lam0=c0/f0; % wavelength in m
k0=2*pi/lam0; % wavenumber in rad/m

dx=0.4343; % x spacing[m]
dy=0.4958; % y spacing[m]
% element pattern from an ideal cross dipole array.
elementpower=(1/2)*(1+(cos(EL)).^2);

m=8;% number of pannels in the x direction
mtot = 8*m;% number of elements times panels in x direction

n = 16;% number of pannels in the y direction
ntot = n*4;% number of elements times panels in y direction
% relative phase between the x elements
phix = k0*dx*(sin(EL).*cos(AZ)-sin(El0).*cos(Az0));
% relative phase between the y elements
phiy = k0*dy.*(sin(EL).*sin(AZ)-sin(El0).*sin(Az0));
%AF = 0;% array factor
% for mm =-mtot/2:2:mtot/2-1
%     for nn = -ntot/2:ntot/2-1
%         % for columns not shifted
%         ea1 = exp(1i*mm*phix+1i*nn*phiy);
%         % for columns that are shifted
%         ea2 = exp(1i*(mm+1)*phix+1i*(nn+1/2)*phiy);
%         AF = ea1+ea2+AF;
%     end
% end

AF = (1/2)*(1+exp(1i*((1/2)*phiy+phix))).*diric(2*phix,mtot/2).*diric(phiy,ntot);
arrayfac = abs(AF).^2;
Patout = elementpower.*arrayfac;