function amisr_Nevertical(varargin)

%amisr_slice  Linear interpolation of calibrated AMISR data onto a
%cartesian grid
%
%   SYNTAX:
%           amisr_Nevertical(Ne,Zi,utime,T1,T2)
%   
%
%
%   OUTPUT:
%   Time history of altitude profile of electron density
%
%   DESCRIPTION:
%   Function that plots the electron density as a function of time and
%   altitude. 
%
%An example on how this can be run:
%   file_name = 'C:/Users/hannad/Documents/RISR/20120122/20120122.001_lp_2min-Ne.h5';
%   StartTime = datenum(2012,01,22,22,30,00);
%   EndTime = datenum(2012,01,22,22,34,00);
%   [Ne,Xi,Yi,Zi,utime,T1,T2,bco] = interpAMISRnocal(StartTime,EndTime,file_name);
%   amisr_Nevertical(Ne,Zi,utime,T1,T2);
%

Ne=varargin{1};
Alt=varargin{2};
utime=varargin{3};
T1 = varargin{4};
T2 = varargin{5};
for ver1=1:50
    for ver2=1:50
%ver1=12;
%ver2=20;

alt=reshape(Alt(ver1,ver2,:),1,size(Alt,3));

%Converting utime to mtime
 l=size(utime);
mtime = zeros(l(1),l(2));

%%
%Converting the time from unix time to matlab time
for i1 = 1:l(1),
for i2 = 1:l(2),
mtime(i1,i2) = datenum([1970 1 1 0 0 double(utime(i1,i2))]); 
end
end

length= size(Ne,4);
NeWithHoles = zeros(size(Ne,3),length);
ttt = zeros(1,length);   
a=1;
b=1;
for i1=1:length*2,
  
 
%%For the time intervals without data
    if mod(i1,2)== 0
        NeWithHoles(:,i1)=0;   
        ttt(i1) = mtime(2,b);
        b=b+1;
    else
  %%For the time intervals with data
  
    NeWithHoles(:,i1)=Ne(ver1,ver2,:,a);  
    ttt(i1) = mtime(1,a);
    a=a+1;
    end
end

%%Start time of the datafile
[Y, M, D, H, MN, S] = datevec(mtime(1,T1));
tt1=H+MN/60.+S/3600.;

%Creating time array for whole sequence (given in hours)
t=tt1+(ttt-ttt(1))*24.;

%Making all NaNs white in the plot
colordata = colormap;
colordata(1,:) = [1 1 1];
colormap(colordata);

figure(1)
clf
pcolor(t,alt,NeWithHoles)
set(gca,'YDir','normal')

colorbar  
shading flat
caxis([5E9 1E11]);
%axis([ts te 120 500]);
ylim([120 500]);
cbar_handle = colorbar;
set(get(cbar_handle,'xlabel'),'String','n_e (m^-3)');
xlabel('Time (UT)')
ylabel('Height (km)')
set_timeaxis()
title(sprintf('Electron density, Start Date %4d-%02d-%02d, position %2d, %2d',Y,M,D,ver1,ver2),...
    'fontsize',12);
           imfilename = fullfile('C:/Users/hannad/Documents/RISR/2012/'...
        ,sprintf('n_eVertical_x%2dy%2d_%s-%3s.pdf',ver1,ver2,datestr(mtime(1,T1),'HH.MM.SS'),datestr(mtime(1,T2),'HH.MM.SS')));
if sum(sum(NeWithHoles(:,:))) > 0
     print('-f1','-dpdf','-r100','-opengl',imfilename);
end
    end
end

    

