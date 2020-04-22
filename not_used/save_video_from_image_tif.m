function [Area , PC] = save_video_from_image_tif(dataset_dir, L)
    
    writerObj = VideoWriter([dataset_dir ,'prediction.avi']);
    writerObj.FrameRate = 10;
    open(writerObj);
    
    PC = zeros(L,1);
    Area = cell(L,1);
    for index = 1:L
        if mod(index,5) == 0; disp(['Frame:',num2str(index)]), end
        
        im = read_image_per_index(index, dataset_dir);
        im = im(:,:,1);
        
        [prediction,im_enhanced] = segmentation(im);
        
        [Area{index}, PC{index}] = detect_Area_PC( prediction(40:end,40:end) );
        
        frame = im2frame(merge_prediction_image(im , im_enhanced , prediction));
        writeVideo(writerObj, frame);
    end
    close(writerObj);
end

function im = read_image_per_index(index, dataset_dir)
    
    name = ['Rec-000020 - Copy - test_',int2str(index),'.tif'];
    im = imread( [dataset_dir, name] );   
    
end