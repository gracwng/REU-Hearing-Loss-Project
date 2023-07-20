%> @file  export_summaries.m
%> @brief Function used for exporting data summaries and figures
%> @param sdir directory in which the features and model results are stored
%> @param bidsdir the root of the BIDs directory
%> @param do_plot a flag (0/1) indicating if relevant figures should be
%> exported (1) or not (0)
%> @param cameq specify if results should be exported with- or without 
%> CamEQ. this can be 'wa' (with CamEQ), 'woa' (without CamEQ; extracted
%> using inverse filtering) or 'woacontrol' (without CamEQ; exactly the 
%> same audio extraction method for NH and HI listeners)
%> @param savesummary should the data summary be stored in ds-nhhi>reports?
%> 1 = yes, 0 = no

%> history
%> 2019/08/07 added do_plot and cameq variables rather than hardcode
%> 2019/28/10 added the opportunity to not save data

function dtab = export_summaries(sdir,bidsdir,do_plot,cameq,savesummary)

if nargin < 1 || isempty(sdir);     sdir = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(do_plot);  do_plot = 1; end
if nargin < 4 || isempty(cameq);    cameq = 'woa'; end
if nargin < 5 || isempty(savesummary); savesummary = 1; end

initdir
workflows_paper

dtab_erp    = extract_all_erp(sdir,bidsdir,pipeline_erp,do_plot);
% dtab_erp    = extract_component_erp(sdir,bidsdir,pipeline_erp,do_plot);
% dtab_erp    = extract_erp(sdir,bidsdir,pipeline_erp,do_plot);

dtab = dtab_erp;

if savesummary
cd(fullfile(fileparts(which('initdir.m')),'reports','paper'))
save('data_summary.mat','dtab');
writetable(dtab,'data_summary.csv','Delimiter',' ')  
end

end


