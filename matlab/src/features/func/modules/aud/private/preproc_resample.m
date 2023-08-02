%> @file  preproc_resample.m
%> @brief Resamples a 2d array, but first centers the array and afterwards
%> adds the mean to the output. The function outputs the resampled array and
%> a corresponding time vector is generated (relative to a pre-specified start time <ti>)
%> @param xx array (time x independent dimensions)
%> @param fsr sampling rate after resampling
%> @param fs original sampling rate
%> @param ti a number indicating the time of the first sample. the
%> corresponding generated time vector will be relative to this sample
%(rounded to the best matching 



%> history:
%> 2019/07/05 removed unncessary subfunctions 
%> 2019/08/05 made code slightly more readable (line 23-26) and defines time in a slightly different way (gives the same result)

% Note that Matlab's build-in function RESAMPLE assumes that time points
% before/after the end are equal to zero, which can cause strong edge
% effects. 

function [xr,tn]=preproc_resample(xx,fsr,fs,ti)

mu      = mean(xx);
xx      = bsxfun(@minus,xx,mu);

xr      = resample(xx,fsr,fs);


tn      = deftime(xr,fsr,ti);



xr      = bsxfun(@plus,xr,mu);

end













function t = deftime(xx,fs,ti)

% the more straightforward way:
% t = [0:1/fs:size(xx,1)/fs-1/fs]'+round(ti*fs)/fs;

t  = [0:1/fs:size(xx,1)/fs-1/fs]';


if ti<t(1) || ti>t(end) 
    error('Please consider using another resampling approach than <preproc_resample>')
end

[~,idb] = min(abs(t-ti));
t = t + t(idb);

end



