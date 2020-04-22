
if ~exist('Directory_output')
    dir = uigetdir(pwd,'Select Directory that you want to save the output');
    name = inputdlg('write output name e.g. prediction');
    Directory_output = fullfile(dir , '/' , name{1},'csv'); % 'H:\Datasets\FLIR Datasets\';  %    
end
% Directory_output = 'H:\Datasets\FLIR Datasets\';  %uigetdir; %  

% h = size(rir_filter_input, 1);
% w = size(rir_filter_input, 2);

% if rir_filter_reset
% 	rir_filter_output = zeros(h, w, class(rir_filter_input));
% end

% rir_filter_metadata_output.Average = mean(rir_filter_input,'double');
% rir_filter_metadata_output.Max = max(max(rir_filter_input));
% rir_filter_metadata_output.Min = min(min(rir_filter_input));


frame = func_normalize(rir_filter_input,1);


UserInfo.pore_size_range = [1,15];
[prediction, frame_enhanced] = segmentation(frame, UserInfo);


% method 1: showing them as white spots
frame = cat(3,prediction,frame,frame);
frame = rgb2gray(frame);


% % method 2: showing them as black spots
% frame(prediction == 1) = 0;

rir_filter_output = im2single(frame, 'indexed');


Results = detecting_objects(prediction);        
Area = mean(Results.Area);
PC   = Results.PC;
FN   = single(rir_filter_metadata_input.FrameNumber);
dlmwrite( Directory_output ,[FN, Area,PC],'delimiter',',','precision',5,'-append') ; % [Directory_output, '\output_table.csv']
