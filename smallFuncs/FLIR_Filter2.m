
if ~exist('Directory_output')
    path = 'E:\Data7\FLIR\Dataset\Fine\Fine'; % pwd
    dir = uigetdir(path,'Select Directory that you want to save the output');
    name = inputdlg('write output name','Input',[1,35],{'prediction'});
    Directory_output = fullfile(dir , '/' , [name{1},'.csv']); % 'H:\Datasets\FLIR Datasets\';  %    
end

% dir = 'E:\Data7\FLIR\Dataset\Fine\Fine';
% name = {'prediction'};
% Directory_output = fullfile(dir , '/' , [name{1},'.csv']); % 'H:\Datasets\FLIR Datasets\';  %    


% if rir_filter_reset
    % h = size(rir_filter_input, 1);
    % w = size(rir_filter_input, 2);
    % rir_filter_output = zeros(h, w, class(rir_filter_input));
% end


% Detecting LED
MAX = max(rir_filter_input(:));

% % Mitigating the Effect of LED When it's On
rir_filter_input = mitigating_Effect_of_LED(rir_filter_input);

% % Segmentation
frame = func_normalize(rir_filter_input,1);
prediction = segmentation2( struct('im',frame , 'binarization_threshold',0.2 , 'ClipLimit',0.2) );

% Post Processing
[prediction, background] = Post_Processing( struct('im',frame , 'prediction', prediction ,  'background_thresh',0.2) );

% Overlaying Detected Spots Onto the Image
rir_filter_output = overlaying_prediction( struct('frame',frame , 'prediction', prediction) );

% Writing the outputs
writing_outputs( struct('Directory_output',Directory_output , 'prediction',prediction , 'FN',single(rir_filter_metadata_input.FrameNumber) , 'MAX',MAX) ) 

% background = frame < 0.4;
% background(200:end,:) = 0;
% background = rgb2gray( cat(3,background,background,frame) );
% rir_filter_output = rir_filter_input; % im2single(background, 'indexed');
