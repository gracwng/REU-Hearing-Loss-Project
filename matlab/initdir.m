%> @file  initdir.m
%> @brief run this function to add subfolders to path. Note that several of
%> the functions that exports data summaries searches for <initdir.m>

function initdir()

global hash_cmd
[~, hash_cmd] = unix(['git rev-parse HEAD']);

rootdir = fileparts(mfilename('fullpath')); 
addpath(genpath(rootdir))

try 
    ft_defaults
    global ft_default
    ft_default.showcallinfo = 'no';
end

rng('default')


fprintf('\n========================================================================')
fprintf('\n Intialized project                          %s \n', date)
fprintf('======================================================================== \n')
fprintf('\n Random state generator reset. \n')
fprintf('\n Please acknowledge work by citing relevant papers. \n')


return;

