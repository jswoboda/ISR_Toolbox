%% omtiscript
% Script used to retreive OMTI data from .abs files

% Change filepath based on where data is located on current system
omtidir = '/home/swoboj/DATA/20120220/omti';

omtiinfo = dir(fullfile(omtidir,'*.abs'));
allfiles = {omtiinfo(:).name};


for k = 1:1;
    outdata = readomti(fullfile(omtidir,allfiles{k}));
    htemp = figure;
    imagesc(outdata,[100,900]);
    fout(k)  = getframe(gcf);
%     close(htemp);
end