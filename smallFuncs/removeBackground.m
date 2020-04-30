function [im_wo_background, Background] = removeBackground(im)

    thresh = 0.2;
    Background = im*0;
    Background(im < thresh) = 1;
    Background = imclose(Background,strel('disk',20));
    
    im_wo_background = im;
    im_wo_background(Background==1) = 0;
    
    im_wo_background = rescale(im_wo_background - thresh);
    
end