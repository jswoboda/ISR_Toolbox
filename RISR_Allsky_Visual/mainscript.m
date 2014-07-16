%% mainscript
% Script that controls the co-visualization process of All Sky Camera (OMTI
% Images) and the RISR Data (Plasma Parameter Radar Data).

%% Location of data/Setting up filepath of data

% Change filepath based on where data is located on current system
omtidir = '/home/swoboj/DATA/20120220/omti';

% Change filepath based on where data is located on current system
radardir = '/home/swoboj/Documents/MATLAB/RISR.Allsky.Analysis/MATLABCode';

% Name of specific radar file
radarfile = '20120219.001_lp_2min.h5';
%20120219.001_lp_5min.h5

radarfilename = fullfile(radardir,radarfile);

%Filepath for output plots, figures, movies
outdirbase = '/home/swoboj/DATA/20120220/omtiradarfusion';
%% Set Parameters

% % Define start and end times
% User input defines start and end times from command line
% starttime = input('Please specify the desired starting time of experiment\nFormat: year month day hour minute second \n(e.g. 2012 01 24 12 30 00)\nStart date and time: ','s');
% starttime = str2num(starttime);
% StartTime = datenum(starttime(1),starttime(2),starttime(3),starttime(4),starttime(5),starttime(6));
% endtime = input('Please specify the desired ending time of experiment\nFormat: year month day hour minute second \n(e.g. 2012 01 24 12 30 00)\nEnd date and time: ','s');
% endtime = str2num(endtime);
% EndTime = datenum(endtime(1),endtime(2),endtime(3),endtime(4),endtime(5),endtime(6));

% Hard coded start and end times 
starttime = [2012,02,20,00,00,00];
StartTime = datenum(starttime);
endtime = [2012,02,20,08,00,00];
EndTime = datenum(endtime);

%% Choose Altitude

% % User input defines altitude from command line
% fprintf('Choose the specific altitude for the plasma parameter(s) (in km)');
% plasmaAlt = input(': ');

% Hard coded altitude
plasmaAlt = 340; % in km


%% Choose Plasma Parameter

% Vector of choices for plasma parameters
choices = {1,'Ne';1,'Ti';2,'Ne';2,'Ti';1,'Te';2,'Te';};

% Vector of choices for wavelengths (nm)
omtivec = {'C61',558;'C62',630;'C64',777};


for ich = 1:size(choices,1);
    
    % Pick wavelength
    curomti = choices{ich,1};
    omtype = omtivec{curomti,1};%C61: 558nm, C62:630nm, C64:777nm,C66: Sodium
    omtiWL = omtivec{curomti,2};
    omtilist = dir(fullfile(omtidir,['*',omtype,'*.abs']));
    omtitimes = zeros(1,length(omtilist));

    for iomti = 1:length(omtilist)
        omtitimes(iomti) = datenum(omtilist(iomti).name(5:16),'yymmddHHMMSS');
    end


    % Pick parameter
    param =  choices{ich,2};
    
    % make the out directory
    outdir = fullfile(outdirbase,[param,omtype]);
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
   
    %% Get radar data
    
    [rData, Az, El, Alt, Range, T1, T2, mtime, utime, timefortitle] = loadData(StartTime,EndTime,radarfilename,param);
    [numAlt,numBeam] = size(Alt);
    altInd = zeros(1,numBeam);
    
    % Find indeces of radar data that are closest to plasma altitude for
    % each beam
    for i = 1:numBeam
        [~,altInd(1,i)] = min(abs(minus(Alt(:,i),plasmaAlt)));
    end
    
    rDataNew = zeros(1,numBeam);
    datetime30s = 1/2880;

    
    %% main loop
    for iradar=(T1:T2)  
        % Find OMTI images that correspond to radar times and plot OMTI
        rDataIndex = iradar-(T1-1);    
        timelog = (omtitimes>=mtime(1,iradar))&(omtitimes<mtime(2,iradar));
        listcell = {omtilist(timelog).name};
        omtimesred = omtitimes(timelog);
        hvec = plotOMTI(omtidir,listcell);

        for ivec = 1:length(hvec)
            figure(hvec(ivec));
            freezeColors
            
            % Label used for OMTI image
            [~,curomtiname,~] = fileparts(listcell{ivec});
            curtime = datestr(omtimesred(ivec),'yymmddHHMMSS');
            curtimestr = datestr(omtimesred(ivec),'HH:MM:SS');
            curtimeend = datestr(omtimesred(ivec)+datetime30s,'HH:MM:SS');
            
            % Select radar data from specific altitude and time
            for i = 1:numBeam
                rDataNew(i) = rData(altInd(i),i,rDataIndex);
            end
            
            % Plot El Az plot of plasma parameter
            ElAzPlot = PlotElAz(Az,El,rDataNew,param);
            axis([0 233 0 230])
            
            % Label used for RISR data
            stimeHour = num2str(floor(timefortitle(1,iradar)));
            stimeMinute = num2str((floor(((timefortitle(1,iradar))-(floor(timefortitle(1,iradar))))*60)));
            if (str2num(stimeMinute)<10)
                stimeMinute = ['0' stimeMinute];
            end
            etimeHour = num2str(floor(timefortitle(2,iradar)));
            etimeMinute = num2str((floor(((timefortitle(2,iradar))-(floor(timefortitle(2,iradar))))*60)));
            if (str2num(etimeMinute)<10)
                etimeMinute = ['0' etimeMinute];
            end
            
            % Figure title and labels
            title({['OMTI w/ RISR Radar Points -- Plasma Parameter: ',...
                param ' @ ' num2str(plasmaAlt) ' km'];...
                ['Date:' num2str(starttime(2)) '/' num2str(starttime(3)) ...
                '/' num2str(starttime(1)) ' - Radar: ' stimeHour ':' ...
                stimeMinute ' - ' etimeHour ':' etimeMinute,' OMTI: ',curtimestr,' - ',...
                curtimeend];[]},'fontsize',10,'fontweight','bold');
            ylim=get(gca,'YLim');
            xlim=get(gca,'XLim');
            textb = text(xlim(2)*.5,.05*ylim(2),['OMTI ' num2str(omtiWL) ' nm (R)'],'fontsize',12,'HorizontalAlignment','center','VerticalAlignment','bottom','fontweight','light','color','w'); 
            figtitle = [param,omtype,num2str(plasmaAlt),'km',curtime];
            set(hvec(ivec),'Position',[520   666   800   600],'Color',[1,1,1])

            % Save figures as both .fig and png files
            saveas(hvec(ivec),fullfile(outdir,figtitle),'fig');
            saveas(hvec(ivec),fullfile(outdir,figtitle),'png');
            close(hvec(ivec))
        end

    end
    
    % Convert plots into a movie
    videoname = [param,omtype,num2str(plasmaAlt),'km.avi'];
    figdir2movie(outdir,videoname);
end