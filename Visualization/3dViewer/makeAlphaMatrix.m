% This function generates an alpha matrix from a given data matrix
% The input argument is a 1-256 length vector that specifies the alpha map
%   for the data range. The index maps to from the lowest value of the data
%   to the highest value, eg; linspace(min(data),max(data),256).
%  The values in this vector correspond to the alpha value we would like
%   that data value to have.
%  For Example; alphavec(1:128) = 0 alphavec(129:256) = 1
%   Maps data values between min(data) and 1/2*max(data) to be transparent
%   and those above 1/2*max(data) to be opaque.

function [AlphaMatrix] = makeAlphaMatrix(DataMatrix,alphavec)

% number of alpha levels - just in case the user didn't conform to our
% suggested 256 values.
nal = length(alphavec);

% Initalize matricies
AlphaMatrix = zeros(size(DataMatrix));
datavec = linspace(min(min(min(DataMatrix))),max(max(max(DataMatrix))),nal);

for j = 1:nal
    % Just find those values that are greater than the current datavec
    % value. No need to check for values less than the next one, because on
    % the next pass we'll find the matrix values greater than the next
    % datavec set, leaving those we just set on the last pass.
    AlphaMatrix(DataMatrix > datavec(j)) = alphavec(j);
end

end
