%% allvids
% Script that translates Allsky/RISR co-visualization figures into a movie
% format.

%%
choices = {1,'Ne';1,'Ti';2,'Ne';2,'Ti';1,'Te';2,'Te';};
omtivec = {'C61',558;'C62',630;'C64',777};
plasmaAlt = 340; % in km
outdirbase = '/home/swoboj/DATA/20120220/omtiradarfusion';
S = struct('FrameRate',{5});
for ich = 1:size(choices,1);
    
    curomti = choices{ich,1};
    omtype = omtivec{curomti,1};%C61:558nm, C62:630nm, C64:777nm, 
    ...C66:Sodium
    omtiWL = omtivec{curomti,2};
    param =  choices{ich,2};
    % make the out directory
    outdir = fullfile(outdirbase,[param,omtype]);
    videoname = [param,omtype,num2str(plasmaAlt),'km.avi']
    figdir2movie(outdir,fullfile(outdir,videoname),S);
end