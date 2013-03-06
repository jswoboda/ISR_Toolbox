function acf_cent = make_cent_acf(rawbeam,N)
% make_cent_acf.m
% by John Swoboda
% acf_cent = make_cent_acf(rawbeam,N)
% This function will make centered acfs for the long pulse exeperiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% rawbeam - An RGxP array that will hold the raw data.  This array is
% complex.
% N - A scalar that tells the program how large the acfs will be.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% acf_cent - A (RG-N)xN array of the centered acfs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note
% This was tested against ACFs from SRI and they matched perfectly with the
% example that was used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up array to to take needed samples
arex = 0:.5:(N/2 -.5);
arback = -floor(arex);
arfor = ceil(arex);
% figure out how much range space will be kept
sp = max(abs(arback))+1;
ep = size(rawbeam,1)- max(arfor);
rng_ar_all = sp:ep;
acf_cent = zeros(ep-sp,N);
%% Main array for creating the ACFS
for irng = 1:ep-sp % loop over range
    % figure out what ranges are need for each acf
    rng_ar1 = rng_ar_all(irng)+arback;
    rng_ar2 = rng_ar_all(irng)+arfor;
    % get all of the acfs across pulses
    acf_tmp = conj(rawbeam(rng_ar1,:)).*rawbeam(rng_ar2,:);
    % sum along the pulses
    acf_ave = sum(acf_tmp,2);
    acf_cent(irng,:) = acf_ave.';
end