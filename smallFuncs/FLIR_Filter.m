

Directory_output = 'G:\Google Drive\RESEARCH - UofA Account\Data7\FLIR\';

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
dlmwrite( [Directory_output, 'output_table.csv'] ,[FN, Area,PC],'delimiter',',','precision',5,'-append')
