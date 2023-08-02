
function figure_degree_of_audiogram_asymmetry(bidsdir)

if nargin < 1 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

figure 
subplot(1,4,1:3)
dat = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));
f             = [125,250,500,1000,2000,3000,4000,6000,8000];
agram         = [];
for n = 1 : numel(f)
    agram(:,n,1) = dat.(['audiogram_left_ear_',num2str(f(n)),'Hz']);
    agram(:,n,2) = dat.(['audiogram_right_ear_',num2str(f(n)),'Hz']);
end

% compute the absolute difference between left/right ear
absolute_difference = abs(agram(:,:,1)-agram(:,:,2));

pta = squeeze(mean(agram(:,ismember(f,[500 1000 2000 4000]),:),2));
% show the differences
imagesc(absolute_difference,[0 max(absolute_difference(:))]);


% a few plotting considerations
Frequencies={'.125' '.25' '.5' '1' '2' '3' '4' '6' '8'};

set(gca,'xtick',1:numel(Frequencies))
set(gca,'xticklabel',Frequencies);
set(gca,'ytick',1:44)
set(gca,'yticklabel',dat.participant_id);
axis xy
xtickangle(50)

% let's specifically highlight subjects where the difference exceeds 15 dB
% HL
cmap(1,:) = [1,1,1];
cmap(2,:) = [1,1,1]-0.05;
cmap(3,:) = [1,1,1]-0.1;
cmap(4,:) = [1,1,1]-0.15;
cmap(5,:) = [0.9892    0.8136    0.1885];
cmap(6,:) = [0.9769    0.9839    0.0805];
    
colormap(cmap);
cbar = colorbar;

set(gca,'Fontsize',8)
xlabel('Center frequency (Hz)')
ylabel('Subject ID')
title('Absolute difference in audiogram between ears')
ylabel(cbar,'dB HL')

subplot(1,4,4)
plot(1:44,abs(pta(:,1)-pta(:,2)),'-k','LineWidth',2)
xlim([0.5 44.5])
set(gca,'xtick',1:44)
set(gca,'xticklabel',dat.participant_id);
ylabel('abs(PTA_{left} - PTA_{right})') 
camroll(90)
set(gca,'Fontsize',8)
box off

fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [1 1 14.3140 23.2833];

cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','dataset','figure_degree_of_audiogram_asymmetry','figure_degree_of_audiogram_asymmetry.png'),'-dpng','-r500')

end
