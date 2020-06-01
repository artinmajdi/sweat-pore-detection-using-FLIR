
if ~exist('Directory_output','var')
    addpath('smallFuncs')
    Directory_output = '';
    app_main()
end


% if rir_filter_reset
%     clear all
% %     h = size(rir_filter_input, 1);
% %     w = size(rir_filter_input, 2);
% %     rir_filter_output = zeros(h, w, class(rir_filter_input));
% end

disp(rir_filter_reset)

% Detecting LED
Light_Bulb = detect_light_bulb( rir_filter_input , lightBulb_detection_mode , lightBulb_area );

% Mitigating the Effect of LED When it's On
frame = mitigating_Effect_of_LED(rir_filter_input, background);

% % Segmentation
frame = func_normalize(frame,1);
prediction = segmentation2( struct('im',frame , 'binarization_threshold',binarization_threshold , 'ClipLimit',0.2) );

% Post Processing
prediction = Post_Processing( struct('prediction', prediction  ,  'background',background  ,  'max_obj_size',maxPore_size) );

% Overlaying Detected Spots Onto the Image
rir_filter_output = overlaying_prediction( struct('frame',frame , 'prediction', prediction) );

% Writing the outputs
out_data = struct('Directory_output',Directory_output , 'prediction',prediction , 'FN',single(rir_filter_metadata_input.FrameNumber), 'Light_Bulb', Light_Bulb, 'Foreground_Area', sum(~background(:)),'TimeStamp',rir_filter_metadata_input.Time );

% Writing the output in CSV
writing_outputs( out_data ) 
% rir_filter_output = rir_filter_input; % im2single(background, 'indexed');
