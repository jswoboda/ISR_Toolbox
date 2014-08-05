function hvec = plotOMTI(directory,filelist)
%plotOMTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description:
%Routine that plots the OMTI allsky image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SYNTAX:
%   hvec = plotOMTI(directory,filelist)
%
%INPUT:
%     directory   - the directory where the OMTI files are located 
%     filelist    - list of OMTI data file names that correspond to radar
%                   data
%OUTPUT:
%     hvec        - handle for OMTI image plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot OMTI image
%Find the optical data that corresponds to the current radar data

%Going through the list of OMTI imagers
hvec = zeros(1,length(filelist));
for ifile=1:length(filelist)

    file=fullfile(directory,filelist{ifile});            

    im = readomti(file);
    
    hvec(ifile) = figure();
    
    % Plot the OMTI image with grayscale and label
    colormap gray
    OMTIimage = pcolor(im);
    shading flat
    cbar_omti = colorbar;
    set(get(cbar_omti,'xlabel'),'String','I (R)');
    caxis([200,500])
    cblabel('I (R)')
    cbfreeze('on')
    axis([0 233 0 230])
    axis off
    set(gcf,'renderer','zbuffer')
    hold on
    h = text(550,130,'OMTI 630.0 nm (R)');
    set(h,'rotation',90)
 
end