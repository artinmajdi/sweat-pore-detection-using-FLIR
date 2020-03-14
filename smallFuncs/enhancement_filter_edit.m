function [msk, im1 , im4] = enhancement_filter_edit(im, Background, shape)


    % imA = rescale(imbilatfilt(im,0.5));
    % imB = rescale(locallapfilt(im,0.2,0.2));
    % imC = rescale(imdiffusefilt(im));  % ,Name,Value 
    % imD = rescale(imnlmfilt(im , 'ComparisonWindowSize' , 3 , 'SearchWindowSize' , 11));  % ,Name,Value 
    % imE = rescale(filter2( fspecial('average',3) ,im,"same"));
    % myshow('joined','imshow', imE , imEc , im2c)

    % rescale(entropyfilt(im));
    % localcontrast(im, 0.2, 0.2);

    im1 = rescale(locallapfilt(im,0.2,0.2));
    im2 = rescale(filter2( fspecial('average',3) ,im1,shape));
    % im2 = rescale(imnlmfilt(im1));

    h = [-1,-1,-1;-1,8,-1;-1,-1,-1];
    im2b = rescale(filter2(h,im2,shape));
    % myshow('joined','imshow', im , im2 , im2b)  
    
    im3 = rescale(imhmax(im2b,0.3));
    im4 = rescale(filter2( fspecial('average',3) ,im3,shape));       
    
    mskO = ~imbinarize(im4,'adaptive','ForegroundPolarity','dark','Sensitivity',0.2);
    msk2 = bwareafilt(mskO , [1, 15] );    
    msk = msk2;
    msk(Background == 1) = 0; 
    
    
%     ax(1) = subplot(141); imshow(im)  ; title('Original Image', 'FontSize',14)
%     ax(2) = subplot(142); imshow(im1) ; title('Local Laplacian Filter', 'FontSize',14) 
%     ax(3) = subplot(143); imshow(4*im2b) ; title('Manual Filter: Remove Background Texture', 'FontSize',14)
%     ax(4) = subplot(144); imshow(4*im4) ; title('H-Maxima -> Average Filter', 'FontSize',14)
%     linkaxes(ax) 
    
%     ax(1) = subplot(2,3,[1,2,4,5]); imshow(im(40:end,40:end))  ; title('Original Image', 'FontSize',18)% , hold on , visboundaries(msk)
%     ax(2) = subplot(233); imshow(im4(40:end,40:end)) ; title('Fitlered Image', 'FontSize',18) % , hold on , visboundaries(msk)
%     ax(3) = subplot(236); imshow(im(40:end,40:end)) ; title('Image With Detected pores', 'FontSize',18), hold on , visboundaries(msk(40:end,40:end))
%     linkaxes(ax)
    
end