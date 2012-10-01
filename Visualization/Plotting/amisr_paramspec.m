%
function amisr_paramspec(varargin)
%Function that plots the plasma parameters for a specific beam, as a 
%function of time and altitude
%
%   SYNTAX:
%           amisr_paramspec(datafile,starttime,stoptime,beam)
%  
%   INPUT:
%     datafile   - h5 file with data, e.g.  
%                   'E:/20120122.001_lp_2min-Ne.h5'
%     starttime  - as returned by datenum, for example 
%                  datenum(2009,12,11,18,00,00);
%     stoptime   - as returned by datenum, for example 
%                  datenum(2009,12,12,18,00,00);
%     beam       - beam number to plot
%
%
%   OUTPUT:
%     Plots of electron density, electron temperature, ion temperature and 
%           Te/Ti for the specified beam
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin ~= 4
    fprintf('please provide 4 arguments: datafile, starttime, stoptime and beam number.\n ')
   return 
end

file_name = varargin{1}; 
StartTime = varargin{2}; 
EndTime   = varargin{3}; 
beam = varargin{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[Y1, M1, D1, H1, MN1, S1] = datevec(StartTime);
[Y2, M2, D2, H2, MN2, S2] = datevec(EndTime);

% Specify approximate start- and end-points on height axis
h1 = 120;
h2 = 500;


%% Load radar file.
%%Reading the data from the h5 file

Ne = hdf5read(file_name,'/FittedParams/Ne');
Altitude = hdf5read(file_name,'/FittedParams/Altitude')/1000.;
Fits = hdf5read(file_name,'/FittedParams/Fits');
utime = hdf5read(file_name,'/Time/UnixTime');
bco   = hdf5read(file_name,'BeamCodes');

if beam > size(Ne,2) 
   fprintf('No such beam, maximum beam number is %2d\n',size(Ne,2))
   return
end
    
%%

l=size(utime);
mtime = zeros(l(1),l(2));

%%
%Converting the time from unix time to matlab time
for i1 = 1:l(1),
for i2 = 1:l(2),
mtime(i1,i2) = datenum([1970 1 1 0 0 double(utime(i1,i2))]); 
end
end


%Pick out the data for the specified beam    
NeBeam=Ne(:,beam,:);
NeBeam=reshape(NeBeam,size(Ne,1),size(Ne,3));
AltBeam=Altitude(:,beam);
TeBeam=Fits(2,2,:,beam,:);
TeBeam=reshape(TeBeam,size(Ne,1),size(Ne,3));
TiBeam=Fits(2,1,:,beam,:);
TiBeam=reshape(TiBeam,size(Ne,1),size(Ne,3));

times=mtime(1,:);
ttt = zeros(1,7132);
NeWithHoles = zeros(size(Ne,1),size(Ne,3)*2);
TeWithHoles = zeros(size(Ne,1),size(Ne,3)*2);
TiWithHoles = zeros(size(Ne,1),size(Ne,3)*2);
a=1;
b=1;
for i1=1:size(Ne,3)*2
    

    if mod(i1,2)== 0
        NeWithHoles(:,i1)=0;
        TeWithHoles(:,i1)=0;
        TiWithHoles(:,i1)=0;       
        ttt(i1) = utime(2,b);
        b=b+1;
    else
  
    NeWithHoles(:,i1)=NeBeam(:,a);
    TeWithHoles(:,i1)=TeBeam(:,a);   
    TiWithHoles(:,i1)=TiBeam(:,a);    
    ttt(i1) = utime(1,a);
    a=a+1;
    end

end

%%Start time of the datafile
[Y, M, D, H, MN, S] = datevec(mtime(1,1));
tt1=H+MN/60.+S/3600.;

%Creating time array for whole sequence
t=tt1+(ttt-ttt(1))/3600.;

%Plotting limits
t1=H1+MN1/60.+S1/3600. + 24.*(D1-D);
t2=H2+MN2/60.+S2/3600.+ 24.*(D2-D);

%Making all NaNs white in the plot
colordata = colormap;
colordata(1,:) = [1 1 1];
colormap(colordata);

%%
%Time to plot!
figure
clf

%Electron density
subplot(411)
pcolor(t,AltBeam,NeWithHoles)
set(gca,'YDir','normal')
emin=5e7;
emax=1e11;
colorbar  
shading flat
caxis([emin emax]);
axis([t1 t2 h1 h2]);
cbar_handle = colorbar;
set(get(cbar_handle,'xlabel'),'String','n_e (m^-3)');
xlabel('Time (UT)')
ylabel('Height (km)')
set_timeaxis()

%Electron temperature
subplot(412)
pcolor(t,AltBeam,TeWithHoles)
set(gca,'YDir','normal')
Temin=300;
Temax=2000;
colorbar  
shading flat
caxis([Temin Temax]); 
axis([t1 t2 h1 h2]);
set_timeaxis()
cbar_handle = colorbar;
set(get(cbar_handle,'xlabel'),'String','T_e (K)');
xlabel('Time (UT)')
ylabel('Height (km)')
 
%Ion temperature  
subplot(413)
pcolor(t,AltBeam,TiWithHoles)
set(gca,'YDir','normal')
Timin=300;
Timax=2000;
colorbar  
shading flat
caxis([Timin Timax]);
axis([t1 t2 h1 h2]);
cbar_handle = colorbar;
set(get(cbar_handle,'xlabel'),'String','T_i (K)');
set_timeaxis()
xlabel('Time (UT)')
ylabel('Height (km)')
  
%Te/Ti plot  
subplot(414)
ratio=TeWithHoles./TiWithHoles;
ratio(isnan(ratio))=0;
pcolor(t,AltBeam,ratio)
set(gca,'YDir','normal')
Rmin=0;
Rmax=4;
colorbar  
shading flat
caxis([Rmin Rmax]);
axis([t1 t2 h1 h2]);
cbar_handle = colorbar;
set(get(cbar_handle,'xlabel'),'String','T_e/T_i');
set_timeaxis()
xlabel('Time (UT)')
ylabel('Height (km)')
  
%Adding titles to the plots
p=mtit(sprintf('Beam %2d, Start Date %4d-%2d-%2d',beam,Y1,M1,D1),...
    'fontsize',12,'color',[0 0 0],...
	'xoff',-.05,'yoff',.010);
     
  
p=mtit(sprintf('electron density'),...
    'fontsize',10,'color',[0 0 0],...
	'xoff',-.05,'yoff',-.005);
     
p=mtit(sprintf('electron temperature'),...
	'fontsize',10,'color',[0 0 0],...
	'xoff',-.05,'yoff',-.275);
 
p=mtit(sprintf('ion temperature'),...
	'fontsize',10,'color',[0 0 0],...
	'xoff',-.05,'yoff',-.545);
     
p=mtit(sprintf('T_e/T_i'),...
	'fontsize',10,'color',[0 0 0],...
	'xoff',-.05,'yoff',-.818);
     

 

    
  


