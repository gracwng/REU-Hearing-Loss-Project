% this function imports BIDs metadata and searches for CMS/DRL errors. the
% function outputs figures that illustrate what events that are contained
% in the EEG data alongside with CMS/DRL errors. Each horizontal line
% indicate when/where there is an event (e.g. presentation of an audio
% stimulus). Each type of event is shown in different colours.

%> history
%> 2019/08/07 updated figure name and folder name

function illustrate_bdf_events(sdir,bidsdir)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

tasks = {'selectiveattention','tonestimuli'};

for subid = 1 : 44
    
    for itask = 1 : numel(tasks)
        
        
        nrun = 1;
        ltask           = tasks{itask};
        if  subid == 24 && strcmp(ltask,'selectiveattention')
            nrun = 2;
        end
        
        for lrun = 1 : nrun
            
            fprintf('\n exporting data from subject %0.2i, task %s, run %i',subid,ltask,lrun)
            
            ldir            = fullfile(bidsdir,sprintf('sub-%0.3i',subid));
            if lrun == 1
                lfname          = fullfile(ldir,'eeg',sprintf('sub-%0.3i_task-%s',subid,ltask));
            else
                lfname          = fullfile(ldir,'eeg',sprintf('sub-%0.3i_task-%s_run-2',subid,ltask));
            end
            bids_events     = ioreadbidstsv([lfname,'_events.tsv']);
            
            
            if strcmp(ltask,'selectiveattention')
                illustrate_cms_drl_errors_task_attention(lfname,bids_events);
            end
            
            if strcmp(ltask,'tonestimuli')
                illustrate_cms_drl_errors_task_tonestimuli(lfname,bids_events);
            end
        end
        
    end
    
end

end

















function illustrate_cms_drl_errors_task_attention(lfname,dtab)

[~,ff] = fileparts(lfname);
close all
figure
leg_entry = 0;
for t = 1 : size(dtab,1)
    
    if strcmp(dtab.trigger_type(t),'targetonset') && strcmp(dtab.single_talker_two_talker(t),'singletalker')
        ha = line([dtab.onset(t) dtab.onset(t+1)],[1 1]);
        ha.LineWidth = 2;
        ha.Color = 'r';
    end
    
    if strcmp(dtab.trigger_type(t),'targetonset') && strcmp(dtab.single_talker_two_talker(t),'twotalker')
        hb = line([dtab.onset(t) dtab.onset(t+2)],[1 1]);
        hb.LineWidth = 2;
        hb.Color = 'b';
    end
    
    if strcmp(dtab.trigger_type(t),'maskeronset')
        hc = line([dtab.onset(t) dtab.onset(t+1)],[1 1]+0.1);
        hc.LineWidth = 2;
        hc.Color = 'g';
    end
    
    if strcmp(dtab.type(t),'CM_out_of_range')
        
        if strcmp(dtab.type(t+1),'CM_in_range') || strcmp(dtab.type(t+1),'CM_out_of_range')
            leg_entry = 1;
            hf = line([dtab.onset(t)-15 dtab.onset(t+1)+15],[1 1]+0.05);
            hf.LineWidth = 2;
            hf.Color = [0.8 0.8 0.8];
            hf.LineStyle = '-';
            
            hl = line([dtab.onset(t)-15 dtab.onset(t+1)+15],[1 1]+0.05);
            hl.LineWidth = 25;
            hl.Color = [0.8 0.8 0.8];
            hl.LineStyle = '--';
            
            
            
            hd = line([dtab.onset(t) dtab.onset(t+1)],[1 1]+0.05);
            hd.LineWidth = 2;
            hd.Color = 'k';
            
            hl = line([dtab.onset(t) dtab.onset(t+1)],[1 1]+0.05);
            hl.LineWidth = 50;
            hl.Color = 'k';
        end
    end
end
set(gca,'ytick',[])
ylim([0.9 1.2])
if leg_entry
    hleg = legend([ha hb hc hd hf],'Single-talker attended stimulus','Two-talker attended stimulus','Two-talker ignored stimulus','CMS/DRL errors','CMS/DRL errors (here artificially extended with 15 s on each side for visualization)');
else
    hleg = legend([ha hb hc],'Single-talker attended stimulus','Two-talker attended stimulus','Two-talker ignored stimulus');
end
hleg.Location = 'southoutside';
xlabel('Time (s)')
tit = ff;
tit(regexp(ff,'_'))=' ';
title(tit,'FontWeight','Normal')
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [1 10 23,8];


cd(fullfile(fileparts(which('initdir.m')),'reports','dataset','figure_illustrate_bdf_events'))
print(sprintf('figure-bdf_events-%s.png',ff),'-dpng','-r100')


end










function illustrate_cms_drl_errors_task_tonestimuli(lfname,dtab)

[~,ff] = fileparts(lfname);
close all
figure
leg_entry = 0;
err_entry = 0;
hold on
for t = 1 : size(dtab,1)
    
    if strcmp(dtab.trigger_type(t),'stimonset_delta_gamma')
        ha = line([dtab.onset(t) dtab.onset(t)+3],[1 1]);
        ha.LineWidth = 2;
        ha.Color = 'r';
        
        h = line([dtab.onset(t) dtab.onset(t)],[0.8 1]);
        h.Color = 'r';
    end
    
    
    
    if strcmp(dtab.trigger_type(t),'stimonset_gamma')
        hb = line([dtab.onset(t) dtab.onset(t)+3],[1 1]);
        hb.LineWidth = 2;
        hb.Color = 'b';
        
        h = line([dtab.onset(t) dtab.onset(t)],[0.8 1]);
        h.Color = 'b';
    end
    
    if strcmp(dtab.trigger_type(t),'stimonset_tone_beep')
        hc = line([dtab.onset(t) dtab.onset(t)+3],[1 1]);
        hc.LineWidth = 2;
        hc.Color = 'g';
        
        h = line([dtab.onset(t) dtab.onset(t)],[0.8 1]);
        h.Color = 'g';
    end
    
    if strcmp(dtab.trigger_type(t),'error_trigger')
        herr = line([dtab.onset(t) dtab.onset(t)+3],[1 1]);
        herr.LineWidth = 2;
        herr.Color = [0.85 0.85 0.85];
        
        h = line([dtab.onset(t) dtab.onset(t)],[0.8 1]);
        h.Color =  [0.85 0.85 0.85]';
        err_entry = 1;
    end
    
    if strcmp(dtab.type(t),'CM_out_of_range')
        
        if t == size(dtab.type,1)
            leg_entry = 1;
            hf = line([dtab.onset(t)-20 dtab.onset(t)+20],[1 1]+0.05);
            hf.LineWidth = 2;
            hf.Color = [0.8 0.8 0.8];
            hf.LineStyle = '-';
            
            hl = line([dtab.onset(t)-20 dtab.onset(t)+20],[1 1]+0.05);
            hl.LineWidth = 25;
            hl.Color = [0.8 0.8 0.8];
            hl.LineStyle = '--';
            
            
            
            hd = line([dtab.onset(t) dtab.onset(t)+20],[1 1]+0.05);
            hd.LineWidth = 2;
            hd.Color = 'k';
            
            hl = line([dtab.onset(t) dtab.onset(t)+20],[1 1]+0.05);
            hl.LineWidth = 50;
            hl.Color = 'k';
            
            
        elseif strcmp(dtab.type(t+1),'CM_in_range') || strcmp(dtab.type(t+1),'CM_out_of_range')
            leg_entry = 1;
            hf = line([dtab.onset(t)-20 dtab.onset(t+1)+20],[1 1]+0.05);
            hf.LineWidth = 2;
            hf.Color = [0.8 0.8 0.8];
            hf.LineStyle = '-';
            
            hl = line([dtab.onset(t)-20 dtab.onset(t+1)+20],[1 1]+0.05);
            hl.LineWidth = 25;
            hl.Color = [0.8 0.8 0.8];
            hl.LineStyle = '--';
            
            
            
            hd = line([dtab.onset(t) dtab.onset(t+1)],[1 1]+0.05);
            hd.LineWidth = 2;
            hd.Color = 'k';
            
            hl = line([dtab.onset(t) dtab.onset(t+1)],[1 1]+0.05);
            hl.LineWidth = 50;
            hl.Color = 'k';
        end
    end
end
set(gca,'ytick',[])
ylim([0.9 1.2])
if leg_entry
    if err_entry
        hleg = legend([ha hb hc hd hf herr],'Delta-gamma stimuli','Gamma stimuli','Tone beep stimuli','CMS/DRL errors','CMS/DRL errors (here artificially extended with 20 s on each side for visualization)','Error trigger (not included)');
    else
        hleg = legend([ha hb hc hd hf],'Delta-gamma stimuli','Gamma stimuli','Tone beep stimuli','CMS/DRL errors','CMS/DRL errors (here artificially extended with 20 s on each side for visualization)');
    end
else
    if err_entry
        hleg = legend([ha hb hc herr],'Delta-gamma stimuli','Gamma stimuli','Tone beep stimuli','Error trigger (not included)');
    else
        hleg = legend([ha hb hc],'Delta-gamma stimuli','Gamma stimuli','Tone beep stimuli');
    end
end
hleg.Location = 'southoutside';
xlabel('Time (s)')
ff(regexp(ff,'_'))=' ';
title(ff,'FontWeight','Normal')
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [1 10 23,8];

ff(regexp(ff,' '))='_';

cd(fullfile(fileparts(which('initdir.m')),'reports','dataset','figure_illustrate_bdf_events'))
print(sprintf('figure-bdf_events-%s.png',ff),'-dpng','-r100')
 

end














