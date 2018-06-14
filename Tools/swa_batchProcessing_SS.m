function [output, Info] = swa_batchProcessing(dir_name, pattern, save_ext)
% function to batch process several files with a given extension (e.g.
% _pp.set) using one command.

% inputs
%   dir_name: full path of the directory to search for pattern matches
%   pattern:  string indicating the file names to be processed
%   save_ext: string to add to the file name when saving
%
% outputs
%   output:   if save_output is true, output will be list of summary stats 

if nargin < 3
    save_ext = '';
end

% option to save the file or not (0: no, 1:yes);
save_file = 1; 

% option to save the summary measure outputs
save_output = 1;

% a list of files
fileList = swa_getFiles(dir_name, pattern);

% pre-allocate output structure 
if save_output
    % pre-allocate the output variable
    output = struct(...
        'wave_density',        [], ...
        'amplitude',           [], ...
        'globality',           []);
else
    output = [];  
end

% loop for each file in the list
for n = 1:length(fileList)

    % split the path and name
    [filePath, fileName, ext] = fileparts(fileList{n});
    [Data, Info] = swa_convertFromEEGLAB([fileName, ext], filePath);

    % get the default parameters
   % Info = swa_getInfoDefaults(Info, 'SW', 'envelope');
    Info = swa_getInfoDefaults(Info, 'SS', 'envelope');

    % change the defaults % why this exactly?
 %   [Data, Info] = swa_changeReference(Data, Info);
 %   Info.Parameters.Ref_Method = 'envelope';
        Info.Parameters.Filter_band = [11, 16];
    %  Info.Parameters.Channels_Method = 'wavelet'; % wavelet or power (FFT) method
       Info.Parameters.Ref_AmplitudeCriteria = 'absolute'; % relative/absolute

                
   % Info.Parameters.Ref_AmplitudeRelative = 4; %changed  

    % find the waves
    [Data.SSRef, Info]  = swa_CalculateReference (Data.Raw, Info);
    [Data, Info, SS]    = swa_FindSSRef (Data, Info);
    [Data, Info, SS]    = swa_FindSSChannels (Data, Info, SS);
   % [Info, SS]          = swa_FindSWTravelling (Info, SS, [], 0);

    % check whether any waves were found/left 
    if length(SS) < 1
        continue;
    elseif length(SS) < 2
        if isempty(SS.Ref_Region)
            continue;
        end
    end

    if save_file
        % save the results
        saveFile = ['SSFile_', fileName, '.mat'];
        swa_saveOutput(Data, Info, SS, saveFile, 1, 0)
    end

    if save_output & ~isempty(SS) 
        % wave density (waves per minute)
        output(n).wave_density = length(SS)/(Info.Recording.dataDim(2)/Info.Recording.sRate/60);
        output(n).number = length(SS)';
        output(n).recdur= (Info.Recording.dataDim(2)/Info.Recording.sRate/60)
        
        % mean peak freq
        temp_data = extractfield(SS,'Ref_PeakFreq')' 
        output(n).meanpeakfreq = mean(temp_data);
        output(n).stdpeakfreq = std(temp_data);

        % mean amplitude
        temp_data = extractfield(SS,'Ref_Peak2Peak')'; % field 8 
        output(n).medianamplitude = median(temp_data);
        output(n).stdamplitude = std(temp_data);
        output(n).maxamplitude = max(temp_data);
        
        % mean wave globality
        temp_data = extractfield(SS,'Channels_Globality')'; % field 13
        output(n).meanglobality = mean(temp_data);
        output(n).stdglobality = std(temp_data);

           % mean duration
        temp_data = extractfield(SS,'Ref_Length')'; % field 9
        output(n).medianduration = median(temp_data);
        output(n).meanduration = std(temp_data);
        output(n).maxduration = max(temp_data);
        
       
        % mean travelling angle (need circular means)
      %  temp_data = swa_wave_summary(SS, Info, 'anglemap') * pi / 180;
            % compute weighted sum of cos and sin of angles
      %  sum_of_angles = sum(exp(1i*temp_data));
      %  output(n).travel_angle(1) = angle(sum_of_angles) / pi * 180;

        % angle dispersion
     %   angle_length = abs(sum_of_angles) / length(temp_data);
     %   output(n).travel_angle(2) = sqrt(2 * (1 - angle_length)) / pi * 180;
    
        % mean and max slope
     %   temp_data=(abs([SS.Ref_PeakAmp])'./([SS.Ref_PeakInd]'-[SS.Ref_DownInd]'))
      %  output(n).slope(1) = mean([SS.Ref_NegSlope]); %max slope
      %  output(n).slope(2) = mean(temp_data); % mean average slope
      %  output(n).slope(3) = std(temp_data); % std 
        
    end
save('output_SSdetection.mat','output');
end

