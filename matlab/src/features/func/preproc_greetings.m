%> @file  preproc_greetings.m
%> @brief Greet the user and show information about available toolboxes and
%preprocessing pipelines

function preproc_greetings(subid,pipeline,bidsdir,sdir)

fprintf('\n ========================================================================')
fprintf('\n Using Matlab version %s', version)

try
fprintf('\n Using Fieldtrip version %s', ft_version)
catch
error('Fieldtrip not available');
end

try
fprintf('\n Using NoiseTools version %s', nt_version)
catch
error('NoiseTools not available');
end

fprintf('\n Preprocessing data using: %s', pipeline.sname)
fprintf('\n \n ')
fprintf('\n                                    %s',datetime)
fprintf('\n ========================================================================')
fprintf('\n Preprocessing data from sub-%0.3i',subid)
fprintf('\n Assuming that the derived BIDs directory is:')
fprintf('\n            "%s" ',bidsdir)
fprintf('\n The preprocessed data will be stored in the following path: ')
fprintf('\n            "%s" ',sdir)
fprintf('\n Please cite relevant work')
fprintf('\n ======================================================================== ')
fprintf('\n %i The following processing steps are considered: \n')
fprintf(1, '       %s \n', pipeline.pp{:})
fprintf('\n ======================================================================== \n \n \n')
end

