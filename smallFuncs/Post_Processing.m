function prediction = Post_Processing(inputs)
  
    prediction = bwareafilt(inputs.prediction,[1,inputs.max_obj_size]);
%     sz = size(prediction);
%     prediction(sz(1)-100:end,:) = 0;
%     prediction(:,sz(2)-20:end)  = 0;

    prediction(inputs.background==1) = 0;

end