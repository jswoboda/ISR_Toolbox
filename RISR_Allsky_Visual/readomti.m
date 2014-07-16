function outdata = readomti(filename)
%readomti.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description:
%Reads in data storing OMTI images in .abs format. Also formats OMTI image
%to be plotted.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SYNTAX:
%   outdata = readomti(filename)
%
% INPUTS:
%     filename   - file name of OMTI data file
%
% OUTPUT:
%     outdata     - formatted data read from OMTI .abs file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By John Swoboda
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read the .abs data
fid=fopen(filename, 'rb');
fseek(fid,8,'bof');% seek ahead to remove the header
% use uint16
curdata=fread(fid,[256,256],'uint16=>uint16'); 
fclose(fid);

% Do a bishift, can also be divide by 4 and a floor command if double.
curdata = bitshift(curdata,-2);

%% Format OMTI image data to be plotted
% Do a leftright flip and then a 270 deg rotation
outdata =imrotate(fliplr(double(curdata)),270);
