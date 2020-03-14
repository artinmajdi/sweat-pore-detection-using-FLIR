function [Area , PC] = save_video_from_video_wmv(dataset_dir, name)
    
    videoFReader  = vision.VideoFileReader([dataset_dir , name]);

    writerObj = VideoWriter([dataset_dir ,'prediction.avi']);
    writerObj.FrameRate = 10;
    open(writerObj);
    
    index = 1;
    while ~isDone(videoFReader)
        if mod(index,5) == 0; disp(['Frame:',num2str(index)]), end
        
        videoFrame = videoFReader();
        im = rgb2gray(videoFrame);                
        [prediction,im_enhanced] = segmentation(im);
        
        [Area{index}, PC(index)] = detect_Area_PC( prediction(40:end,40:end) );
        
        frame = im2frame(merge_prediction_image(im , im_enhanced , prediction));
        writeVideo(writerObj, frame);
        
        index = index + 1;
    end
    close(writerObj); 
end