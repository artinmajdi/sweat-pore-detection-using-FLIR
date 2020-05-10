function [prediction, background] = Post_Processing(inputs)
  
    prediction = bwareafilt(inputs.prediction,[1,40]);
    sz = size(prediction);
    prediction(sz(1)-100:end,:) = 0;
    prediction(:,sz(2)-20:end)  = 0;

    
%     background = imclose(inputs.im < inputs.background_thresh ,strel('disk',20));
%     background = bwareafilt(background,[500,1e8]);
%     background(300:end,:) = 0;
%     prediction(background==1) = 0;
    background = 0;

end