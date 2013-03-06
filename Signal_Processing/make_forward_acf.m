function acf = make_forward_acf(rawbeam,N)
% make_forward_acf.m
% by John Swoboda
% acf = make_forward_acf(rawbeam,N)
% This function will make Forward acfs for the long pulse experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% rawbeam - An RGxP array that will hold the raw data.  This array is
% complex.
% N - A scalar that tells the program how large the acfs will be.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% acf_cent - A (RG-N)xN array of the forward acfs acfs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[RGs,Pul] = size(rawbeam);
% Set up what parts will be kept
sp = 1;
ep = RGs-N;
N = 16;
acf = zeros(ep-sp+1,N);
%% Loop that makes the acf
for irng = sp:ep
    % Determine what values go into the acf
    rng_ar = (0:N-1)+irng;
    sub_arr = rawbeam(rng_ar,:);
    ar1 = sub_arr(1,:);
    % Do each acf index speratly and integrate across pulses
    % Note: this shouldn't be a for loop.
    for iacf = 1:N
        ar2 = sub_arr(iacf,:);
        acf(irng,iacf) = sum(ar1.*conj(ar2),2);
    end
end