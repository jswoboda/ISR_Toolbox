function S_out = ionocontinterp(S_in,interover)
% ionocontinterp.m
% by John Swoboda 4/20/2014
% This function will take the structured matfiles from the ionocontainer
% python class and interpolate over it using natural neighbors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ouput
% S_out - A struct that mirrors the set up of the Ionocontainer matfile.
% 
% paramnums.
% Input
% S_in - A struct that mirrors the set up of the Ionocontainer matfile.
% interover - The coordinates that the parameters will be interpolated over
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
%% Check strucs
if ischar(S_in)
    S_in = load(S_in);
end

%% Interp over

% create the mesh grid that we will interpoalted over
Cart_Coords =S_in.Cart_Coords;
[X,Y,Z] = meshgrid(interover{1},interover{2},interover{3});
numlocs = numel(X);
numtimes = length(S_in.Time_Vector);
% Interpolate over each time point.
if ndims(S_in.Param_List)==2
    S_out = struct('Param_List',{zeros(numlocs,numtimes)},'Cart_Coords',{[X(:),Y(:),Z(:)]},'Time_Vector',...
        {S_in.Time_Vector},'x',{interover{1}},'y',{interover{2}},'z',{interover{3}});
    for itime = 1:size(S_in.Param_List,2)
        disp(['Time ',num2str(itime), ' of ',num2str(size(S_in.Param_List,2))])
        F = scatteredInterpolant(Cart_Coords(:,1),Cart_Coords(:,2),Cart_Coords(:,3),S_in.Param_List(:,itime),...
            'natural','none');
        S_out.Param_List(:,itime) = F(X(:),Y(:),Z(:));
        
    end
else
    numparams = size(S_in.Param_List,3);
    S_out = struct('Param_List',{zeros(numlocs,numtimes,numparams)},'Cart_Coords',{[X(:),Y(:),Z(:)]},'Time_Vector',...
        {S_in.Time_Vector},'x',{interover{1}},'y',{interover{2}},'z',{interover{3}});
    for iparam = 1:numparams
        
        for itime = 1:size(S_in.Param_List,2)
            F = scatteredInterpolant(Cart_Coords(:,1),Cart_Coords(:,2),Cart_Coords(:,3),S_in.Param_List(:,itime),...
                'natural','none');
           S_out.Param_List(:,itime,iparam) =F(X(:),Y(:),Z(:));
           fprintf(['\tTime ',num2str(itime), ' of ',num2str(size(S_in.Param_List,2)),'\n'])
        end
    end
end