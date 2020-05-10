function frame = overlaying_prediction(inputs)
    frame = rgb2gray( cat(3,inputs.prediction,inputs.frame,inputs.frame) );
    frame = im2single(frame, 'indexed');
end