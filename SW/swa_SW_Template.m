%% -- Workflow and Plots for Slow Wave Analysis -- %%

% read the preprocessed data or another swa file

% for eeglab files
[Data, Info] = swa_convertFromEEGLAB();
% or if you have previously analysed some data
%[Data, Info, SW] = swa_load_previous();


%% -- Template for envelope method -- %%

% get the default parameters
Info = swa_getInfoDefaults(Info, 'SW', 'envelope');

% change parameters here
% e.g. Info.Parameters.Ref_AmplitudeCriteria = 'relative';
% e.g. [Data, Info] = swa_changeReference(Data, Info);
% e.g. Info.Parameters.Ref_UseStages = [2, 3];

% run through the 4 wave detection steps
[Data.SWRef, Info]  = swa_CalculateReference (Data.Raw, Info);
[Data, Info, SW]    = swa_FindSWRef (Data, Info);
[Data, Info, SW]    = swa_FindSWChannels (Data, Info, SW);
[Info, SW]          = swa_FindSWTravelling (Info, SW);

% save the data
swa_saveOutput(Data, Info, SW, [], 1, 0)

%% -- Plot the Reference Wave -- %%

% define a random time window of specified length
window_length = 15;
random_sample = randi(Info.Recording.dataDim(2), 1);
sample_range = random_sample : random_sample + window_length * Info.Recording.sRate - 1;
time_range = [1:size(sample_range, 2)] / Info.Recording.sRate;

% find the pure positive and negative envelopes
maximum_line = max(Data.Raw(:, sample_range), [], 1);
minimum_line = min(Data.Raw(:, sample_range), [], 1);

% create the figure
figure('color', 'w');
axes('nextplot', 'add');

% butterfly plot as a single patch object
patch([time_range, fliplr(time_range)], [maximum_line, fliplr(minimum_line)],...
    [0.8, 0.8, 0.8],...
    'edgeColor', [0.5, 0.5, 0.5]);
% reference wave
plot(time_range, Data.SWRef(1, sample_range), ...
    'color', [0.1, 0.1, 0.1], ...
    'lineWidth', 2);
    
title_name=[Info.Recording.dataFile(1:10) 'SW variables'];

title(title_name);
jpegoutname=[title_name]; % this saves the fig as jpeg
print('-djpeg','-r200',jpegoutname)


% store interesting variables per participant;
max_slope=mean([SW.Ref_NegSlope]')
ave_slope=mean(abs([SW.Ref_PeakAmp])'./([SW.Ref_PeakInd]'-[SW.Ref_DownInd]'))
total_num_SW=length(SW)
duration_recording=Info.Recording.dataDim(1,2)/12000;
num_SW_permin=total_num_SW/duration_recording
   
save ([title_name, '.mat'], 'max_slope', 'ave_slope','total_num_SW','num_SW_permin', '-mat')


swa_Explorer
