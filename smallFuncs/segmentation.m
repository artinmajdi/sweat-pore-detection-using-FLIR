function [mask, im_enhanced] = segmentation(im, UserInfo)

    imN = func_normalize(im,1);
    [im_wo_Backrground, Background] = removeBackground(imN);
    [im_enhanced, im_texture_removed] = enhancement_filter(im_wo_Backrground);
    
    mask = ~imbinarize(im_texture_removed,'adaptive','ForegroundPolarity','dark','Sensitivity',0.2);
    mask(Background == 1) = 0;     

    mask = bwareafilt(mask,UserInfo.pore_size_range);
    mask(1:40,:) = 0;
    mask(:,1:40) = 0;
end
