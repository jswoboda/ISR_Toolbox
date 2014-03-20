function varargout = ionocontvideo(input,paramnums,paramnames)
% ionocontvideo
% by John Swoboda 3/20/2014
% This function will take the structured matfiles from the ionocontainer
% python class and create a video out of them.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ouput
% Vid1,Vid2... - Videos in structs.  The number is dependent on the
% paramnums.
% Input
% input - If a string must be a structured matfile (see below) or a struct
%       with the format below.
% paramnums - A array of numbers from 1-Np, the number of params. 
% paramnames - A cell array of strings that has the names of the parameters
%              choosen.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Struct format, the matfile also has to have variables of this format.
% S_in = 
% 
%        Param_List: [NcxNtxNp double]
%       Cart_Coords: [Ncx3 double]
%       Time_Vector: [1xNt double]
%                 y: [1xNy double]
%                 x: [1xNx double]
%                 z: [1xNz double]
%     Sphere_Coords: [Ncx3 double]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(input)
    S_in = load(input);
elseif isa(input,'struct')
    S_in =input;
end

times = S_in.Time_Vector;
Nt = length(times);
axlabels = {'x km','y km','z km'};
Nx = length(S_in.x);
Ny = length(S_in.y);
Nz = length(S_in.z);
videos = cell(1,length(paramnums));

for l = 1:length(paramnums)
    v = reshape(squeeze(S_in.Param_List(:,:,paramnums(l))),[Ny,Nx,Nz,Nt]);
    titlecell= cell(1,length(times));
    for k = 1:length(times)
        titlecell{k} = [paramnames{l},' at t= ',num2str(times(k)), ' s'];
    end
    

    videos{l} = slicevideo( S_in.x,S_in.y,S_in.z,v,{[0],[0],[]},'TitleStrings',titlecell,...
    'AxisLabels',axlabels );

end   
varargout = videos;