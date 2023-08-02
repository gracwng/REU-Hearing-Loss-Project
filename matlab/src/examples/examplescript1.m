%> @file  examplescript1.m
%> @brief An example script that demonstrates how one can preprocess
%> audio/EEG data and perform a stimulus-response analysis (including an
%> encoding analaysis, a stimulus reconstruction analysis and a 
%> classification analysis).


%% Define where the BIDs data is located and which subject you are interested in
initdir
% bidsdir     = '/home/sorenaf/datasets/bids/ds-eeg-nhhi';
bidsdir = '/Users/student/Downloads/ds-eeg-snhl 2/ds-eeg-snhl';

subid       = 1;    % you may e.g. want to loop over subjects 1-44

rng('default'); parcreaterandstream(44, randi(10000)+subid)

%% Audio preprocessing

paud        = struct;
paud.task   = 'selectiveattention';
paud.sname  = ''; 
paud.pp     =       {'pp_aud_average',... 
                     'pp_aud_lowpass6000_44100',... 
                     'pp_aud_resample12000_44100',... 
                     'pp_aud_gammatone',... 
                     'pp_aud_fullwave_rectify',...
                     'pp_aud_powerlaw03',... 
                     'pp_aud_average',...
                     'pp_aud_lowpass256_12000',...
                     'pp_aud_resample512_12000',...
                     'pp_aud_lowpass30_512',...
                     'pp_aud_resample64_512',...
                     'pp_aud_highpass1_64',...
                     'pp_aud_lowpass9_64',...
                     'pp_aud_toi_attention'};
                                  
try                 
audfeat     = build_aud_features(subid,paud,bidsdir,[],'woa');
catch
 
% Note that the BIDs directory also contains derived envelope features 
% (Specifically, univariate envlope features at a sampling rate of 512 Hz).
% We can use these features to extract similar representations using the
% following function. This can be useful as the raw audio unfortunately
% cannot be uploaded to Zenodo (due to copyrights), but needs to be
% forwarded upon request.
pp       =      {'pp_aud_lowpass30_512',...
                 'pp_aud_resample64_512',...
                 'pp_aud_highpass1_64',...
                 'pp_aud_lowpass9_64',...
                 'pp_aud_toi_attention'};
audfeat = build_aud_features_from_derivatives(subid,pp,bidsdir,'woa');
end

%% EEG preprocessing

peeg        = struct;
peeg.task   = 'selectiveattention';
peeg.sname  = ''; 
peeg.pp     =       {'pp_ft_reref_mastoids',... 
                     'pp_ft_lowpass30_fs512',... 
                     'pp_ft_resample64',... 
                     'pp_ft_highpass05_fs64_attention',... 
                     'pp_ft_reref_bipolareog',... 
                     'pp_ft_segmenttrials_attention',...
                     'pp_ft_appenddatafromsessions_attention',...
                     'pp_ft_eogdenoise',...
                     'pp_ft_highpass1_fs64_attention',...
                     'pp_ft_lowpass9_fs64_attention',...
                     'pp_ft_toi_attention'};
                 
eegfeat    = build_eeg_features(subid,peeg,bidsdir,[]);
                
%% Prepare a struct that contains the audio and EEG features in the format [time x feature dimensions x trials] for single-talker and two-talker data

id_st = ismember(cat(1,audfeat.single_talker_two_talker{:}),'singletalker');
id_tt = ismember(cat(1,audfeat.single_talker_two_talker{:}),'twotalker');

srdat                       = struct;
srdat.aud_feature.target_st = cat(3,audfeat.target{id_st});
srdat.aud_feature.target_tt = cat(3,audfeat.target{id_tt});
srdat.aud_feature.masker_tt = cat(3,audfeat.masker{id_tt});
srdat.eeg_feature.eeg_st    = permute(cat(3,eegfeat.trial{id_st}),[2 1 3]);
srdat.eeg_feature.eeg_tt    = permute(cat(3,eegfeat.trial{id_tt}),[2 1 3]);



%% Perform the stimulus-response analysis

opts                        = struct;
opts.kinner                 = 5;
opts.kouter                 = 10;
opts.lambda                 = logspace(-3,6,50);
opts.znormd                 = 1; 
opts.storew                 = 0; 
opts.gof                    = 'estcorr';
opts.phaserand.nperm        = 1000;

%% Encoding analysis
rng('default'); parcreaterandstream(44, randi(10000)+subid)

% Example 1: encoding analysis on single-talker data
lagoi                       = 0:32;
xx                          = srdat.aud_feature.target_st;
yy                          = srdat.eeg_feature.eeg_st;

[vlog_encoding_st]         = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Example 2: encoding analysis on two-talker data (attended speech)
xx                          = srdat.aud_feature.target_tt;
yy                          = srdat.eeg_feature.eeg_tt;

[vlog_encoding_att]        = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Example 3: encoding analysis on two-talker data (ignored speech)
xx                          = srdat.aud_feature.masker_tt;
yy                          = srdat.eeg_feature.eeg_tt;

[vlog_encoding_itt]        = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);




%% Reconstruction analysis
rng('default'); parcreaterandstream(44, randi(10000)+subid)

% Example 4: stimulus reconstruction analysis on single-talker data
lagoi                       = -32:0;
xx                          = srdat.eeg_feature.eeg_st; 
yy                          = srdat.aud_feature.target_st;

[vlog_reconstruction_st]    = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Example 5: stimulus reconstruction analysis on two-talker data (attended speech)
xx                          = srdat.eeg_feature.eeg_tt; 
yy                          = srdat.aud_feature.target_tt;

[vlog_reconstruction_att]   = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Example 6: stimulus reconstruction analysis on two-talker data (ignored speech)
xx                          = srdat.eeg_feature.eeg_tt; 
yy                          = srdat.aud_feature.masker_tt;

[vlog_reconstruction_itt]   = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);



%% Classification analysis
rng('default'); parcreaterandstream(44, randi(10000)+subid)

% Please note that this example uses denoising filters trained on the
% entire dataset unlike the reported analysis. The following code trains
% stimulus reconstruction filters on EEG/audio data from the single-talker
% condition and uses these models to reconstruct estimates of the envelope
% of the attended speech stream. The classification decision is here based
% on correlation coefficients between neural reconstruction and the
% envelopes/features of the two competing speech streams
cd(fullfile(fileparts(which('initdir.m')),'src','paper','private'))


opts_classification         = struct;
opts_classification.tdur    = 9.5;  % 10 s minus kernel length 
opts_classification.tshift  = 5;    % the decoding segments are nonoverlapping and shifted with opts_classification.tdur + opts_classification.tshift (here 14.5 s)
opts_classification.lambda  = logspace(-3,6,50);
opts_classification.znormd  = 1;        
opts_classification.lagoi   = -32:0; 
opts_classification.gof     = 'estcorr';
opts_classification.fs      = 64;


vlog_classification_st      = sr_classificationanalysis(opts_classification,srdat);
