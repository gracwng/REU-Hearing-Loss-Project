function prob = may2011classifyGMM(featSpace,speaker,mask)



%% *********************  CHECK INPUT ARGUMENTS  ***********************
% 
% 
% Check for proper input arguments
%
%   Url: http://amtoolbox.sourceforge.net/doc/modelstages/may2011classifyGMM.php

% Copyright (C) 2009-2015 Piotr Majdak and Peter L. Søndergaard.
% This file is part of AMToolbox version 0.9.7
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
if nargin < 2 || nargin > 3
    help(mfilename);
    error('Wrong number of input arguments!');
end

% Check if missing data should be used
if nargin < 3 || isempty(mask); 
   bMissingData = false; 
else
   bMissingData = true;
end 

% Initialization
nClasses  = length(speaker);
prob      = zeros(size(featSpace,1),nClasses);


%% ***********************  PERFORM CLASSIFICATION  ***********************
% 
% 
if bMissingData
    % Loop over number of classes
    for jj = 1 : nClasses
        % Missing data classification
        prob(:,jj) = marginalize(featSpace,speaker(jj),mask);
    end
else
    % Loop over number of classes
    for jj = 1 : nClasses
        % Conventional recognition using the complete feature space
        prob(:,jj) = gmmprob(speaker(jj),featSpace);
    end
end


function a = gmmactiv(mix, x)
%GMMACTIV Computes the activations of a Gaussian mixture model.
%
%	Description
%	This function computes the activations A (i.e. the  probability
%	P(X|J) of the data conditioned on each component density)  for a
%	Gaussian mixture model.  For the PPCA model, each activation is the
%	conditional probability of X given that it is generated by the
%	component subspace. The data structure MIX defines the mixture model,
%	while the matrix X contains the data vectors.  Each row of X
%	represents a single vector.
%
%	See also
%	GMM, GMMPOST, GMMPROB
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check that inputs are consistent
errstring = consist(mix, 'gmm', x);
if ~isempty(errstring)
  error(errstring);
end

ndata = size(x, 1);
a = zeros(ndata, mix.ncentres);  % Preallocate matrix

switch mix.covar_type
  
case 'spherical'
  % Calculate squared norm matrix, of dimension (ndata, ncentres)
  n2 = dist2(x, mix.centres);
  
  % Calculate width factors
  wi2 = ones(ndata, 1) * (2 .* mix.covars);
  normal = (pi .* wi2) .^ (mix.nin/2);
  
  % Now compute the activations
  a = exp(-(n2./wi2))./ normal;
  
case 'diag'
  normal = (2*pi)^(mix.nin/2);
  s = prod(sqrt(mix.covars), 2);
  for j = 1:mix.ncentres
    diffs = x - (ones(ndata, 1) * mix.centres(j, :));
    a(:, j) = exp(-0.5*sum((diffs.*diffs)./(ones(ndata, 1) * ...
      mix.covars(j, :)), 2)) ./ (normal*s(j));
  end
  
case 'full'
  normal = (2*pi)^(mix.nin/2);
  for j = 1:mix.ncentres
    diffs = x - (ones(ndata, 1) * mix.centres(j, :));
    % Use Cholesky decomposition of covariance matrix to speed computation
    c = chol(mix.covars(:, :, j));
    temp = diffs/c;
    a(:, j) = exp(-0.5*sum(temp.*temp, 2))./(normal*prod(diag(c)));
  end
case 'ppca'
  log_normal = mix.nin*log(2*pi);
  d2 = zeros(ndata, mix.ncentres);
  logZ = zeros(1, mix.ncentres);
  for i = 1:mix.ncentres
    k = 1 - mix.covars(i)./mix.lambda(i, :);
    logZ(i) = log_normal + mix.nin*log(mix.covars(i)) - ...
      sum(log(1 - k));
    diffs = x - ones(ndata, 1)*mix.centres(i, :);
    proj = diffs*mix.U(:, :, i);
    d2(:,i) = (sum(diffs.*diffs, 2) - ...
      sum((proj.*(ones(ndata, 1)*k)).*proj, 2)) / ...
      mix.covars(i);
  end
  a = exp(-0.5*(d2 + ones(ndata, 1)*logZ));
otherwise
  error(['Unknown covariance type ', mix.covar_type]);
end
  


function prob = gmmprob(mix, x)
%GMMPROB Computes the data probability for a Gaussian mixture model.
%
%	Description
%	 This function computes the unconditional data density P(X) for a
%	Gaussian mixture model.  The data structure MIX defines the mixture
%	model, while the matrix X contains the data vectors.  Each row of X
%	represents a single vector.
%
%	See also
%	GMM, GMMPOST, GMMACTIV
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check that inputs are consistent
errstring = consist(mix, 'gmm', x);
if ~isempty(errstring)
  error(errstring);
end

% Compute activations
a = gmmactiv(mix, x);

% Form dot product with priors
prob = a * (mix.priors)';


function errstring = consist(model, type, inputs, outputs)
%CONSIST Check that arguments are consistent.
%
%	Description
%
%	ERRSTRING = CONSIST(NET, TYPE, INPUTS) takes a network data structure
%	NET together with a string TYPE containing the correct network type,
%	a matrix INPUTS of input vectors and checks that the data structure
%	is consistent with the other arguments.  An empty string is returned
%	if there is no error, otherwise the string contains the relevant
%	error message.  If the TYPE string is empty, then any type of network
%	is allowed.
%
%	ERRSTRING = CONSIST(NET, TYPE) takes a network data structure NET
%	together with a string TYPE containing the correct  network type, and
%	checks that the two types match.
%
%	ERRSTRING = CONSIST(NET, TYPE, INPUTS, OUTPUTS) also checks that the
%	network has the correct number of outputs, and that the number of
%	patterns in the INPUTS and OUTPUTS is the same.  The fields in NET
%	that are used are
%	  type
%	  nin
%	  nout
%
%	See also
%	MLPFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Assume that all is OK as default
errstring = '';

% If type string is not empty
if ~isempty(type)
  % First check that model has type field
  if ~isfield(model, 'type')
    errstring = 'Data structure does not contain type field';
    return
  end
  % Check that model has the correct type
  s = model.type;
  if ~strcmp(s, type)
    errstring = ['Model type ''', s, ''' does not match expected type ''',...
	type, ''''];
    return
  end
end

% If inputs are present, check that they have correct dimension
if nargin > 2
  if ~isfield(model, 'nin')
    errstring = 'Data structure does not contain nin field';
    return
  end

  data_nin = size(inputs, 2);
  if model.nin ~= data_nin
    errstring = ['Dimension of inputs ', num2str(data_nin), ...
	' does not match number of model inputs ', num2str(model.nin)];
    return
  end
end

% If outputs are present, check that they have correct dimension
if nargin > 3
  if ~isfield(model, 'nout')
    errstring = 'Data structure does not conatin nout field';
    return
  end
  data_nout = size(outputs, 2);
  if model.nout ~= data_nout
    errstring = ['Dimension of outputs ', num2str(data_nout), ...
	' does not match number of model outputs ', num2str(model.nout)];
    return
  end

% Also check that number of data points in inputs and outputs is the same
  num_in = size(inputs, 1);
  num_out = size(outputs, 1);
  if num_in ~= num_out
    errstring = ['Number of input patterns ', num2str(num_in), ...
	' does not match number of output patterns ', num2str(num_out)];
    return
  end
end

%   ***********************************************************************
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   ***********************************************************************
