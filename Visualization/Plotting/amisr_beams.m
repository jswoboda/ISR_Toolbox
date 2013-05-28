function amisr_beams(varargin)
% amisr_beams.m
% amisr_beams(filename))
% amisr_beams(az,el)
% Function that plots the beam grid in polar coordinates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% filename - A string that holds the h5 filename.
% az - The azimuthal coordinates of the beams in degrees.
% el - The elevation of the beams in degrees
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% A plot of the beam positions.  The handle will not be returned as an
% output.  Do a gcf after the function is run if you want the handle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input
if nargin == 1
    file_name=varargin{1};
    h5file_info = h5info(file_name);
   
    str_data1 = {h5file_info.Datasets(:).Name};
    str_data2 = {h5file_info.Groups(:).Name};
     % for poker flat set up
    if any(strcmp('BeamCodes',str_data1))
        bco   = hdf5read(file_name,'BeamCodes');
        az = bco(2,:)*pi/180;  
        el = bco(3,:); 
     % for madrigal data
    else any(strcmp('Data',str_data2));
        all_data = h5read(file_name,'/Data/Table Layout');
        [~,ids,~] = unique(all_data.beamid);
        az = all_data.azm(ids) *pi/180;
        el = all_data.elm(ids);
    end
elseif nargin ==2
    az = varargin{1}*pi/180;
    el = varargin{2};
end

az = az*pi/180;

%% Azimuth and elevation in degrees

[x,y] = pol2cart(az,el);

%% Plotting

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


