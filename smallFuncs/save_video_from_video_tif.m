function [Area , PC] = save_video_from_video_tif(dataset_dir, name)
    
    filename = [dataset_dir , name];
    
    writerObj = VideoWriter([dataset_dir ,'prediction.avi']);
    writerObj.FrameRate = 10;
    open(writerObj);
    
    L = length(imfinfo(filename));
    PC = zeros(L,1);
    Area = cell(L,1);
    for index = 1:L
        if mod(index,5) == 0; disp(['Frame:',num2str(index)]), end
        
        im = imread(filename, index);
        [prediction,im_enhanced] = segmentation(im);
       
        [Area{index}, PC(index)] = detect_Area_PC( prediction(40:end,40:end) );
        
        frame = im2frame(merge_prediction_image(im , im_enhanced , prediction));
        writeVideo(writerObj, frame);
    end
    close(writerObj);
end