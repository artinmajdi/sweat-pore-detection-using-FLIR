
if ~exist('Directory_output','var')
    addpath('smallFuncs')
    Directory_output = '';
    app_main()
    
    % writematrix(["Frame Number", "Area","Number of Pores","LED State"] , Directory_output)    
    % path = 'E:\Data7\FLIR\Dataset\Fine\Fine'; % pwd
    % dir = uigetdir(path,'Select Directory that you want to save the output');
    % name = inputdlg('write output name','Input',[1,35],{'prediction'});
    % Directory_output = fullfile(dir , '/' , [name{1},'.csv']); % 'H:\Datasets\FLIR Datasets\';  %  
    % Background = roipoly(rir_filter_input);
end

% Directory_output = fullfile( 'E:\Data7\FLIR\Dataset\Fine\Fine' , '/prediction.csv']);


% if rir_filter_reset
    % h = size(rir_filter_input, 1);
    % w = size(rir_filter_input, 2);
    % rir_filter_output = zeros(h, w, class(rir_filter_input));
% end


% Detecting LED
MAX = max(rir_filter_input(:));

% % Mitigating the Effect of LED When it's On
rir_filter_input = mitigating_Effect_of_LED(rir_filter_input, background);

% % Segmentation
frame = func_normalize(rir_filter_input,1);
prediction = segmentation2( struct('im',frame , 'binarization_threshold',binarization_threshold , 'ClipLimit',0.2) );

% Post Processing
prediction = Post_Processing( struct('prediction', prediction  ,  'background',background  ,  'max_obj_size',maxPore_size) );

% Overlaying Detected Spots Onto the Image
rir_filter_output = overlaying_prediction( struct('frame',frame , 'prediction', prediction) );

% Writing the outputs
writing_outputs( struct('Directory_output',Directory_output , 'prediction',prediction , 'FN',single(rir_filter_metadata_input.FrameNumber) , 'MAX',MAX) ) 


% rir_filter_output = rir_filter_input; % im2single(background, 'indexed');
