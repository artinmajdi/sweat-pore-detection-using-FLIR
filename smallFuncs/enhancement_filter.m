function [im_enhanced, im_texture_removed] = enhancement_filter(im)

    % rescale(entropyfilt(im));
    % localcontrast(im, 0.2, 0.2);

    im_enhanced = rescale(locallapfilt(im,0.2,0.2));
    im2 = rescale(filter2( fspecial('average',3) ,im_enhanced,"same"));
    % im2 = rescale(imnlmfilt(im1));

    h = [-1,-1,-1;-1,8,-1;-1,-1,-1];
    im2b = rescale(filter2(h,im2,"same"));
    % myshow('joined', 'imshow', im , im2 , im2b)  

    im3 = rescale(imhmax(im2b,0.3));
    im_texture_removed = rescale(filter2( fspecial('average',3) ,im3,"same"));       

    % msk = ~imbinarize(im_enhanced,'adaptive','ForegroundPolarity','dark','Sensitivity',0.2);
    % msk = bwareafilt(msk , [1, 15] );
    % msk(Background == 1) = 0; 
end
    
% prompt = {'Enter matrix size:','Enter colormap name:'};
% dlgtitle = 'Input';
% dims = [1 35];
% definput = {'20','hsv'};
% answer = inputdlg(prompt,dlgtitle,dims,definput)