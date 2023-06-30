function definput=arg_auditoryfilterbank(definput)
 
  definput.keyvals.flow=80;
  definput.keyvals.fhigh=8000;
  definput.keyvals.basef=[];
  definput.keyvals.bwmul=1;

  definput.groups.gtf_dau = {'basef',1000};


%
%   Url: http://amtoolbox.sourceforge.net/doc/arg/arg_auditoryfilterbank.php

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

