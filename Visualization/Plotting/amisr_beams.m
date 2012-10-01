function amisr_beams(varargin)
%Function that plots the beam grid in polar coordinates. 
%By adding 'numbers' as input argument, the beams are numbered.
%
%   SYNTAX:
%           amisr_beams(datafile)
%           amisr_beams(datafile,'numbers')
%  
%   INPUT:
%     datafile   - h5 file with data, e.g.  
%                   'E:/20120122.001_lp_2min-Ne.h5'
%   OUTPUT:
%     Plot of beam grid 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1 
   fprintf('Please give a data file as input argument\n')
   fprintf('e.g. amisr_beams(''20120122.001_lp_2min-Ne.h5'')\n')
   return
end

if strcmp(varargin{1},'numbers')
     fprintf('Please give a data file as first input argument\n')
     return
end
file_name=varargin{1};
    
%% Load radar file.
%%Reading the data from the h5 file

bco   = hdf5read(file_name,'BeamCodes');

%%
%% Azimuth and elevation in degrees
az = bco(2,:)*pi/180;  
el = bco(3,:); 
[x,y] = pol2cart(az,el);

%%

figure
clf
theta = linspace(0,2*pi,100);
r10 = 70*ones(1,100);
[xx1,yy1] = pol2cart(theta,r10);
fill(xx1,yy1,'w')
hold on

axis off 
axis equal
hold on

%plotting the radar beams
[xx,yy]=pol2cart(-az+pi/2,90-el);
plot(xx,yy,'o','MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',10)


%Plotting the cardinal directions
lin1x=linspace(-70,70,700);
lin1y=linspace(0,0,700);
plot(lin1x,lin1y,':k')
lin1x=linspace(0,0,700);
lin1y=linspace(-70,70,700);
plot(lin1x,lin1y,':k')
lin1x=linspace(-70*sind(45),70*sind(45),700);
lin1y=linspace(-70*cosd(45),70*cosd(45),700);
plot(lin1x,lin1y,':k')
lin1x=linspace(-70*sind(45),70*sind(45),700);
lin1y=linspace(70*cosd(45),-70*cosd(45),700);
plot(lin1x,lin1y,':k')
text(73,0,'E')
text(73*cosd(45),73*sind(45),'NE')
text(-1,73,'N')
text(-76,0,'W')
text(-81*cosd(45),76*sind(45),'NW')
text(-1,-73,'S')
text(-81*cosd(45),-76*sind(45),'SW')
text(73*cosd(45),-73*sind(45),'SE')

%plotting elevation rings
elev=[10,20,30,40,50,60];
theta = linspace(0,2*pi,100);
r20 = elev'*ones(1,100);
for i=1:length(elev)
[x,y] = pol2cart(theta,r20(i,:));
plot(x,y,':k')
text(elev(i)*sind(22.5),-elev(i)*cosd(22.5)-2,sprintf('%d',90-elev(i)))
end

axis off

if nargin > 1
    if strcmp(varargin{2},'numbers')
       for i=1:1:length(xx)
   text(xx(i)+2,yy(i)+2,sprintf('%d',i))     
       end       
        
    end 
end


