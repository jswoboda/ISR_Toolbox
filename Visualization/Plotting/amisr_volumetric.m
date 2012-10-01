function amisr_volumetric(varargin)
%
%amisr_volumetric  Creates a volumetric image of AMISR data, with multiple
%horizontal slices and one vertical slice, latitudinal and longitudinal lines and a map projected to 200 km
%altitude.
%
%   SYNTAX:
%           amisr_volumetric(Ne,Xi,Yi,Zi,utime,T1,T2,bco)
%           amisr_volumetric(Ne,Xi,Yi,Zi,utime,T1,T2,bco,'PFISR')
%
%   INPUT:
%
%          Ne,Xi,Yi,Zi,T1,T2,utime,bco that are given from either
%          interpAMISR or interpAMISRnocal
%          By specifying 'PFISR' as input argument, the map gets the right
%          coordinates for the PFISR location. Default is the location of RISR. 
%
%   OUTPUT:
% Volumetric image of Ne, with slices at different altitudes. 
%
%   DESCRIPTION:
%   Function that plots the electron density in a 3D image, with slices 
%   at 220, 250, 280, 310 and 340 km, as well as one vertical slice 
%
%An example on how this can be run:
%   StartTime = datenum(2009,12,11,22,13,00);
%   EndTime = datenum(2009,12,11,22,14,00);
%   file_name = 'C:/Users/hannad/Documents/RISR/20120122/20120122.001_lp_2min-Ne.h5';  
%   [Ne,Xi,Yi,Zi,utime,T1,T2,bco] = interpAMISRnocal(StartTime,EndTime,file_name);
%   amisr_volumetric(Ne,Xi,Yi,Zi,utime,T1,T2,bco)
%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check input, set default values if arguments are unspecified
    
%If no arguments are given
if nargin < 8 
    fprintf('Please provide the input arguments Ne, Xi, Yi, Zi, T1, T2, utime, bco\n'); 
    fprintf('which are provided by interpAMISR or interpAMISRnocal.\n'); 
    return
end

%if all arguments are given
if nargin >= 8 
        Ne = varargin{1};
    Xi = varargin{2};
    Yi = varargin{3};
    Zi = varargin{4};
    utime = varargin{5};    
    T1 = varargin{6};
    T2 = varargin{7};

    bco = varargin{8};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%

Xi=double(Xi);
Yi=double(Yi);
Zi=double(Zi);

l=size(utime);
mtime = zeros(l(1),l(2));

%%
%Converting the time from unix time to matlab time
for i1 = 1:l(1),
for i2 = 1:l(2),
mtime(i1,i2) = datenum([1970 1 1 0 0 double(utime(i1,i2))]); 
end
end

%%
%The pointing directions of the radar beams
    radar_az = -bco(2,:)+90;
    radar_el = 90-bco(3,:);
%
%Earth radius:
RE=6378;
      
%%

%if PFISR is set:
if sum(strcmp(varargin,'PFISR')) == 1
         lon0=-(147+25/60+48/3600);
    lat0=65+7/60+12/3600;
else
       lon0=-(94+54/60+16/3600);
    lat0=74+43/60+46/3600;
end

 %Initialize
raknare=1;
array=[1:101];  
%%
%Looping through the time steps, and plot:
for t = T1:T2,
    figure(raknare)
    clf
    hold on
  
 %%
 %    %Making all 0 NaNs 
   Ne(find(Ne == 0)) = NaN;
   

%%
 %Plot latitude lines  
    array=[1:101];
    zvekt=ones(1,101)*200;
    yRes = (90 - lat0).*cosd(lon0-lon0-180)*110;        
    geonorthx = 0;
    geonorthy = -yRes;

    for i3=10:2:50,
        r=i3*pi*RE/180;
        xxr=(r*sin(array./49.*pi)+geonorthx);
        yyr=(r*cos(array./49.*pi)+geonorthy);
        rightsize =  find( xxr < 380 & xxr > -90 & yyr < 520 & yyr > -32);
        plot3(xxr(rightsize),yyr(rightsize),200*ones(size(rightsize)),'k:')
    end
 
 %%
  %Plot longitude lines
 
    grid on
    for i4=0:2:180,     
     
       x_lonlat=geonorthx+(-1:0.0001:1)*13000*sind(i4);
       y_lonlat=geonorthy+(-1:0.0001:1)*13000*cosd(i4);
          
       rightsize =  find( x_lonlat < 380 & x_lonlat > -90 & y_lonlat < 520 & y_lonlat > -32);      
       plot3(x_lonlat(rightsize),y_lonlat(rightsize),200*ones(size(rightsize)),'k:'); 

    end

 %% Plotting a map onto the image
    zve = ones(1,8553)*200;
    load m_coasts
    map_lon=ncst(:,1);
    map_lat=ncst(:,2);
    ymap = (90 - map_lat).*cosd(map_lon-lon0-180)*110 - yRes;
    xmap = (90 - map_lat).*sind(map_lon-lon0)*110;
     
    %Making sure it is only plotting the part of the map that is within our X
    %and Y boundaries
    rightsize =  find( xmap < 400 & xmap > -100 & ymap < 550 & ymap > -82);
   
    %Need to take out the consequtive numbers to plot separately, since
    %matlab otherwise draws lines between islands
    %Check the difference in rightsize
    diff1 = diff(rightsize);
    %wherever the difference is greater than 1 we have a jump in
    %datapoints
    gg = find(diff1 > 1);
    gg=[gg;length(rightsize)];
    counter=0;
    %loop to create sub-arrays that will be plotted
    xny=NaN;
    yny=NaN;
    for i5=1:size(gg),
        c1 = counter;
        counter=counter+1;
       
        xmapp=xmap(rightsize(counter):rightsize(gg(i5)));
        ymapp=ymap(rightsize(counter):rightsize(gg(i5)));
        xny=[xny;xmapp;NaN];
        yny=[yny;ymapp;NaN];
        counter=gg(i5);
        plot3(xmapp,ymapp,200.0*ones(1,counter-c1),'-')
    end
%%   
%Plotting the slices with Ne data    

    axis([-90 380 -32 520 140 450])
  
    slice1 = slice(Xi,Yi,Zi,Ne(:,:,:,t-T1+1),[],[],340);
    set(slice1,'EdgeColor','none');
    
    slice2 = slice(Xi,Yi,Zi,Ne(:,:,:,t-T1+1),[],[],310);
    set(slice2,'EdgeColor','none');
    
    slice3 = slice(Xi,Yi,Zi,Ne(:,:,:,t-T1+1),[],[],280);
    set(slice3,'EdgeColor','none');

    slice4 = slice(Xi,Yi,Zi,Ne(:,:,:,t-T1+1),[],[],250);
    set(slice4,'EdgeColor','none');
    
    slice5 = slice(Xi,Yi,Zi,Ne(:,:,:,t-T1+1),[],[],220);
    set(slice5,'EdgeColor','none');
    
       %%% % Create rotated surface on which to plot rear slice.
    xmin = min(Xi(:));
    ymin = min(Yi(:));
    xmax = max(Xi(:));
    ymax = max(Yi(:));
   hslice = surf(linspace(xmin,xmax,100), linspace(ymin,ymax,100), 215*ones(100));
   rotate(hslice,[0,-1,0],75);
   rotate(hslice,[0,0,1],-35);
        xd = get(hslice,'XData')+5;
     yd = get(hslice,'YData');
   zd = get(hslice,'ZData')-50;
    delete(hslice);
      zdmanipulated=zd;
    for k1=1:38,
    zdmanipulated(:,k1)=zd(:,39);
    
    end
        sliceback = slice(Xi,Yi,Zi,Ne(:,:,:,t-T1+1),xd,yd,zdmanipulated);
     set(sliceback,'FaceColor','flat','EdgeColor','none');
%% 
%%Uncomment to plot the radar beams outlined
%plot3(positions(:,1),positions(:,2),positions(:,3),'.')


    %%Plotting the beam positions at altitudes of slices
    scale=0.76;  
    for imheight=220:30:340
        r=imheight*tand(scale*1.0);
        zzarr=ones(1,101).*imheight;
 
        for jj=1:42, 
            xr0=(imheight*tand(radar_el(jj)).*cosd(radar_az(jj)));
            yr0=(imheight*tand(radar_el(jj)).*sind(radar_az(jj)));    
            xxxr=(r*sin(array./49.*pi)+xr0);
            yyyr=(r*cos(array./49.*pi)+yr0);
      
            plot3(xxxr,yyyr,zzarr,'k')
        end
    end
     
    cbar_handle = colorbar;
    set(get(cbar_handle,'xlabel'),'String','Electron density (m^-^3)');
    caxis([0,1e11]);
    shading flat
    view(-80,16);
    daspect([1,1,1/3.5]);
    axis tight
    box on
    lighting none

    zlabel('Altitude (km)');
    xlabel('East (km)');
    ylabel('North (km)');
    axis([-90 380 -32 520 200 370])
   
    title(sprintf('%s -- %s UT',...
                  datestr(mtime(1,t),13),...
                  datestr(mtime(2,t),13) ));
      
    text(300,-40,330,'340 km',... 
     'HorizontalAlignment','right',...
     'FontSize',12)
 
    text(300,-40,300,'310 km',... 
     'HorizontalAlignment','right',...
     'FontSize',12)
 
    text(300,-40,270,'280 km',... 
     'HorizontalAlignment','right',...
     'FontSize',12)
 
    text(300,-40,240,'250 km',... 
     'HorizontalAlignment','right',...
     'FontSize',12)
 
    text(300,-40,210,'220 km',... 
     'HorizontalAlignment','right',...
     'FontSize',12)
    
 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    raknare=raknare+1;
    

end; 


    
    
warning on all