function elAzPlot = PlotElAz(varargin) 
%PlotElAz.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% Function plots axis for el az plots as well as plasma parameter at each
% specific el az coordinate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNTAX:
% elAzPlot = PlotElAz(az, el, Val) 
% 
% INPUT: 
%       az              - contains satellite azimuth angles. It is a 2D 
%                       matrix. One line contains data of one satellite. 
%                       The columns are the calculated azimuth values. 
%       el              - contains satellite elevation angles. It is a 2D 
%                       matrix. One line contains data of one satellite. 
%                       The columns are the calculated elevations. 
%       Val             - contains radar beam data of each specific beam in
%                       the el az coordinate system. This data may be a
%                       variety of plasma parameters.
%       param           - Plasma parameter
%                      
% OUTPUT: 
%       elAzPlot               - handle to the plot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check arguments and sort them ========================================== 
[hAxis, args, nargs] = axescheck(varargin{:}); 
if nargs ~= 4
    error('Requires 4 data arguments.') 
elseif nargs == 4 
    [az, el, Val, param]   = deal(args{1:4}); 
end 
 
if ischar(az) || ischar(el) || ischar(Val) 
    error('AZ and EL and Val must be numeric.'); 
end 
 
if ~isequal(size(az), size(el)) 
    error('AZ and EL must be same size.'); 
end 

%% Prepare axis =========================================================== 
axisLimits = [0 256 0 256];
verticalMid = 115;
horizontalMid = 116.5;
hAxis = newplot(hAxis);
set(hAxis,'xcolor','white')
%--- Get x-axis text color so grid is in same color ----------------------- 
tc = get(hAxis, 'xcolor');
hold(hAxis, 'on');
axis([0 233 0 230])

%% Plot spokes ============================================================ 
 
%--- Find spoke angles ---------------------------------------------------- 
% Only 6 lines are needed to divide circle into 12 parts 
th = (1:6) * 2*pi / 12; 
 
%--- Convert spoke end point coordinate to Cartesian system --------------- 
cst = cos(th); snt = sin(th); 
cs = [cst; -cst]; 
sn = [snt; -snt]; 
 
%--- Plot the spoke lines ------------------------------------------------- 
line(horizontalMid*sn+horizontalMid, verticalMid*cs+verticalMid, ...
    'linestyle', ':', 'color', tc, 'linewidth', 0.5, ... 
    'handlevisibility', 'off');
%% Annotate spokes in degrees ============================================= 
rt = 1.05*115; 
for i = 1:max(size(th)) 
 
    %--- Write text in the first half of the plot ------------------------- 
    text(rt*snt(i)+horizontalMid, rt*cst(i)+verticalMid, int2str(i*30), ... 
        'horizontalalignment', 'center', 'handlevisibility', 'off',...
        'color', 'w','fontweight','bold'); 
 
    if i == max(size(th)) 
        loc = int2str(0); 
    else 
        loc = int2str(180 + i*30); 
    end 
 
    %--- Write text in the opposite half of the plot ---------------------- 
    text(-rt*snt(i)+horizontalMid, -rt*cst(i)+verticalMid, loc, ... 
        'handlevisibility', 'off', 'horizontalalignment', 'center',...
        'color', 'w','fontweight','bold'); 
end 
 
%% Plot elevation grid ==================================================== 
 
%--- Define a "unit" radius circle ---------------------------------------- 
th = 0 : pi/50 : 2*pi; 
xunit = cos(th); 
yunit = sin(th); 
 
%--- Plot elevation grid lines and tick text ------------------------------ 
for elevation = 0 : 15 : 90 
    elevationSpherical = 115 * cos((pi/180) * elevation); 
 
    line(yunit * elevationSpherical + 115, xunit * elevationSpherical...
        + 115, 'lineStyle', ':', 'color', tc, 'linewidth', 0.5, ... 
        'handlevisibility', 'off'); 
 
    text(0 + 115, elevationSpherical + 115, num2str(elevation), ... 
        'horizontalalignment','center', 'color', 'w',... 
        'handlevisibility', 'off','fontweight','bold'); 
end 

%--- Cut-off Noise Outside Camera Image -----------------------------------
fillout(xunit * horizontalMid + horizontalMid,yunit * ...
    verticalMid + verticalMid,axisLimits,'black');

%--- Set view to 2-D ------------------------------------------------------ 
view(0, 90);
 
%% Transform elevation angle to a distance to the center of the plot ------ 
elSpherical = 90*cos(el * pi/180); 
 
%--- Transform data to Cartesian coordinates ------------------------------ 
yy = elSpherical .* cos(az * pi/180)+115; 
xx = elSpherical .* sin(az * pi/180)+116.5; 
 
%% Plot radar data on top of the grid ===================================== 
colormap(jet)
elAzPlot = scatter(hAxis, xx', yy', 300, Val,'.');

cbarhandle = colorbar('location','WestOutside');
% Label color axis based on parameter
if (strcmp(param,'Ti'))
    set(get(cbarhandle,'xlabel'),'String','Ti (K)');
    caxis([0,3000])
elseif (strcmp(param,'Te'))
    set(get(cbarhandle,'xlabel'),'String','Te (K)');
    caxis([0,3000])
elseif (strcmp(param,'dTi'))
    set(get(cbarhandle,'xlabel'),'String','dTi (K)');
    caxis([0,3000])
elseif (strcmp(param,'dTe'))
    set(get(cbarhandle,'xlabel'),'String','dTe (K)');
    caxis([0,3000])
elseif (strcmp(param,'Ne'))
    set(get(cbarhandle,'xlabel'),'String','Ne (m^-3)');
    caxis([1e10,1e12])
elseif (strcmp(param,'dNe'))
    set(get(cbarhandle,'xlabel'),'String','dNe (m^-3)');   
    caxis([1e10,1e12])
end

 

%--- Make sure both axis have the same data aspect ratio ------------------ 
axis(hAxis, 'equal'); 
 
%--- Switch off the standard Cartesian axis ------------------------------- 
axis(hAxis, 'off'); 