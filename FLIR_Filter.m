
h = size(rir_filter_input, 1);
w = size(rir_filter_input, 2);

if rir_filter_reset
	rir_filter_output = zeros(h, w, class(rir_filter_input));
end


% Detect moving objects, and track them across video frames.

frame = rir_filter_input;
[prediction, frame_enhanced] = segmentation(frame);

prediction = im2single(prediction, 'indexed');
% msk = msk*max(rir_filter_input);

frame = imfuse(prediction, frame_enhanced);
frame = rgb2gray(frame);
rir_filter_output = im2single(frame, 'indexed');
% rir_filter_output = msk;
