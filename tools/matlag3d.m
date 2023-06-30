%> @file matlag3d.m
%> @brief Creates a lagged (time-shifted) version of a 3d array. The array is time-shifted along the second dimension
%> @param xx input matrix of size (time x features x trials)
%> @param lags a vector or a value that contains the time-shifts of interest (in samples). Negative lags leads the xx matrix and positive lags the matrix.
%> @retval yy time-shifted array of size (time x features*lags x trials)

%> Please note that this function is not well-suited for fitting
%> multidimensional stimulus-response for certain types of regularization
%> that enforce smoothness along certain dimensions (e.g. Tikhonov
%> regularization or Gaussian Process Priors). Here, it is possible that
%> the model instead will put a constraint on the smoothness across
%> neighbouring channels (for decoding models) or peripheral bands (for
%> spectro-temporal receptive field models).


function yy = matlag3d(xx,lags)

yy = [];
for ii = 1 : size(xx,3)
    yy(:,:,ii) = matlag(xx(:,:,ii),lags);
end

end