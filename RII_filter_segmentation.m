%% Motion-Based Multiple Object Tracking
% This example shows how to perform automatic detection and motion-based
% tracking of moving objects in a video from a stationary camera.
%
% This file si called from ResearchIR using the new connection with MATLAB
% through MATLAB Engine
%
% Copyright 2014 - 2015 The MathWorks, Inc. 

h = size(rir_filter_input, 1);
w = size(rir_filter_input, 2);

if rir_filter_reset
	rir_filter_output = zeros(h, w, class(rir_filter_input));
  
end


% Detect moving objects, and track them across video frames.

frame = rir_filter_input;
[msk, frame_enhanced] = segmentation(frame);

msk = im2single(msk, 'indexed');
% msk = msk*max(rir_filter_input);

frame = imfuse(msk, frame_enhanced);
frame = rgb2gray(frame);
rir_filter_output = im2single(frame, 'indexed');
% rir_filter_output = msk;
