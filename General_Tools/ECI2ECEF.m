function ECEFCOORDS = ECI2ECEF(ECICOORDS,UT)
% ECI2ECEF.m
% ECEFCOORDS = ECI2ECEF(ECICOORDS,UT)
% by John Swoboda
% This function will convert ECI inertial coordinates into ECEF coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% ECICOORDS - A 3xN array that will hold the ECI coordinates that will be
% changed to ECEF.
% UT - A 1xN array that holds the unix time that the coordinates were
% taken.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% ECEFCOORDS - A 3xN array that holds the ECEF coordinates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References
% Parts of this code were taken from the matlab central site:
% http://www.mathworks.com/matlabcentral/fileexchange/28233-convert-eci-to-ecef-coordinates
% This code references the following documents:
% http://www.cdeagle.com/ccnum/pdf/demogast.pdf
% http://www.cdeagle.com/omnum/pdf/csystems.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the Sidreal Time
% Get the Julian Date
JD = unix2julian(UT);

T = (JD - 2451545)/36525;
% Average Greenwich sidreal time in degrees
GMST = 100.46061837+36000.770053608*T+0.000387933*T.^2-T.^3/38710000;

EPSILONm = 23.439291-0.0130111.*T - 1.64E-07.*(T.^2) + 5.04E-07.*(T.^3);

L = 280.4665 + 36000.7698.*T;
dL = 218.3165 + 481267.8813.*T;
OMEGA = 125.04452 - 1934.136261.*T;

deltpsi = -17.2*sind(OMEGA) - 1.32*sind(2*L) - 0.23*sind(2*dL) + 0.21*sind(2*OMEGA);

delteps = 9.20*cosd(OMEGA) + 0.57*cosd(2*L)+ 0.1*cosd(2*dL) - 0.09*cosd(2*OMEGA);
% This is in degrees
GMAT = GMST + deltpsi.*cosd(EPSILONm.*delteps);

%% Apply Transform
ECEFCOORDS = zeros(size(ECICOORDS));
x_eci = ECICOORDS(1,:);
y_eci = ECICOORDS(2,:);
z_eci = ECICOORDS(3,:);

ECEFCOORDS(1,:) = cosd(GMAT).*x_eci + sind(GMAT).*y_eci;
ECEFCOORDS(2,:) = -sind(GMAT).*x_eci + cosd(GMAT).*y_eci;
ECEFCOORDS(3,:) = z_eci;
