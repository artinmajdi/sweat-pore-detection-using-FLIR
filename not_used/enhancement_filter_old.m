function [im1d, im1d_binarize] = enhancement_filter1(im1_woBg,sensitivity)
    % local differentiation
    h = [-1,-1,-1;-1,8,-1;-1,-1,-1];
    im1c = filter2(h,im1_woBg,"valid");
    im1c = func_normalize(im1c, 1);
    
    % local average
    h = ones(3,3)/4;
    im1d = filter2(h,im1c,"valid");
    im1d = func_normalize(im1d, 1);
    
    im1d_binarize = ~imbinarize(im1d,'adaptive','ForegroundPolarity','dark','Sensitivity',sensitivity);
end