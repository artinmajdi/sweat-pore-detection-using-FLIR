%%  extras for presentation
%     clc
%     clear
%     h = [-1,-1,-1;-1,8,-1;-1,-1,-1];

%     L = 7;
%     h1 = -1.8*ones(L,L);
%     h1(3:5,3:5) = 8;
%     
%     h2 = ones(L,L)/(L^2);    
%     h3 = conv2(h1,h2);    

    L = 3;
    h1 = -1*ones(L,L);
    h1(2,2) = 8;
    
    h2 = ones(L,L)/(L^2);    
    h3 = conv2(h1,h2);    

    [X,Y] = meshgrid(1:2*L-1 , 1:2*L-1);
    surf(fittedmodel(X,Y),h3)
    
%     L2 = 50;
%     x1 = ceil( (L2-(2*L-1))/2 );
%     H = zeros(L2,L2);
%     H(x1:x1+2*L-2,x1:x1+2*L-2) = h3;
% %     [X,Y] = meshgrid(1:L2 , 1:L2);
% %     surf(fittedmodel(X,Y),H)
% 
%     [X,Y] = meshgrid(1:2*L-1 , 1:2*L-1);
%     surf(fittedmodel(X,Y),h3)

%%
% app_designer_address: 'C:\Users\artin\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\App Designer - Image Processing'

clc
clear

dataset_dir = 'F:\RESEARCH\Data7\FLIR\Dataset\video sample\tif\';
index = 160;

imO = read_image(index, dataset_dir, true);
[im, Background] = removeBackground(imO);

% myshow('joine','imtool', imO , im , Background)
%% enhancing the dots

% [im_filtered, candidates1] = apply_filter(im,0.4);
[msk, im1 , im4] = apply_filter2(im, Background, "same");

% im5 = watershed(im4,4);
% candidates1_watershed = keeping_the_watershed_area(watershed_output, candidates1);
%% write the video
L = 5950;
save_video(dataset_dir, L)

%%
function [msk, im1 , im4] = apply_filter2(im, Background, shape)
    % rescale(entropyfilt(im));
    % localcontrast(im, 0.2, 0.2);

    im1 = rescale(locallapfilt(im,0.2,0.2));
    im2 = rescale(filter2( fspecial('average',3) ,im1,shape));

    h = [-1,-1,-1;-1,8,-1;-1,-1,-1];
    im2b = rescale(filter2(h,im2,shape));

    im3 = rescale(imhmax(im2b,0.3));
    im4 = rescale(filter2( fspecial('average',3) ,im3,shape));   
    
    mskO = ~imbinarize(im4,'adaptive','ForegroundPolarity','dark','Sensitivity',0.2);
    msk2 = bwareafilt(mskO , [1, 15] );    
    msk = msk2;
    msk(Background == 1) = 0; 
    
%     ax(1) = subplot(131); imshow(im)  ; title('Original Image', 'FontSize',18)% , hold on , visboundaries(msk)
%     ax(2) = subplot(132); imshow(im4) ; title('Fitlered Image', 'FontSize',18) % , hold on , visboundaries(msk)
%     ax(3) = subplot(133); imshow(im4) ; title('Fitlered Image With Detected pores', 'FontSize',18), hold on , visboundaries(msk)
% %     ax(3) = subplot(143); imshow(mskO); title('Binary Mask', 'FontSize',18)
% %     ax(4) = subplot(144); imshow(msk); title('Removing Background & Big Objects', 'fontsize',18)
%     linkaxes(ax)
    
%     figure,
%     ax(1) = subplot(121); imshow(mskO(330:370,160:200));title('Binary Mask', 'FontSize',18)
%     ax(2) = subplot(122); imshow(msk2(330:370,160:200)); title('Removing Background & Big Objects', 'fontsize',18)
%     linkaxes(ax)
end

function myshow(separate_joined,mode,varargin)
    for x = 1:length(varargin)
        
        if strcmp(separate_joined,'joined')
            if strcmp(mode,'imshow')
                ax(x) = subplot(1,length(varargin),x); imshow(varargin{x},[]);
            elseif strcmp(mode,'imtool')
                ax(x) = subplot(1,length(varargin),x); imtool(varargin{x},[]);
            end
        else
%                        
            if strcmp(mode,'imshow')
                ax(x) = figure;
                imshow(varargin{x},[]);
            elseif strcmp(mode,'imtool')
                ax(x) = imtool(varargin{x},[]);
            end      
            
        end

    end
    linkaxes(ax)

end

function [im2, msk] = removeBackground(im)

    thresh = 0.1;
    msk = im*0;
    msk(im < thresh) = 1;
    msk = imclose(msk,strel('disk',20));
    
    im2 = im;
    im2(msk==1) = 0;
    
    im2 = rescale(im2 - thresh);
    
end

function im = read_image(index, dataset_dir, normalize)
    
    % dir = 'F:\Datasets\FLIR\video sample\tif\';
    name = ['Rec-000020 - Copy - test_',int2str(index),'.tif'];
%     disp(name)
    Dirr = [dataset_dir, name];
    im = imread(Dirr);
    
    if normalize
        im = func_normalize(im,1);
    end

end

function im = func_normalize(im,type)
    mn = min(im(:));
    mx = max(im(:));
    if type == 16
        im = uint16(  (im-mn)*(2^16)/(mx-mn)  );
    elseif type == 8
        im = uint8(  (im-mn)*(2^8)/(mx-mn)  );
    elseif type == 1
        im = (im-mn)/(mx-mn);        
    end
    
    % im1c = histeq(im1_woBg,50);
    % im2 = adaptthresh(im1,'NeighborhoodSize',[3,3], 'ForegroundPolarity','dark', 'Statistic','median');
    
end

function [im1d, im1d_binarize] = apply_filter(im1_woBg,sensitivity)
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

function mask = keeping_the_watershed_area(watershed_output, binary_mask)
    mskk = watershed_output;
    mskk(binary_mask == 0) = 0;
    c = unique(mskk(:));
    c(c == 0) = [];
    
    obj = regionprops(watershed_output,'Area','PixelIdxList');
    
    mask = watershed_output*0;
    for i = 1:length(c)
        mask(obj(c(i)).PixelIdxList) = c(i);
    end
end

function save_video(dataset_dir, L)
    
    writerObj = VideoWriter([dataset_dir ,'myVideo1.avi']);
    writerObj.FrameRate = 5;

    secsPerImage = 1;
    open(writerObj);
    
    for index = 1:L
        if mod(index,5) == 0 disp(['Frame:',num2str(index)]), end
        
        im = read_image(index, dataset_dir, true);
        [im, Background] = removeBackground(im);

        [prediction, im1 , im4] = apply_filter2(im, Background, "same");
        msk = post_process(im , im1 , prediction);

        frame = im2frame(msk);
        writeVideo(writerObj, frame);
    end
    close(writerObj);
    
    function msk = post_process(im , imFiltered , prediction)
        merged = 256*horzcat( im(40:end,40:end),imFiltered(40:end,40:end) , single(prediction(40:end,40:end)) );
        msk = uint8(cat(3,merged,merged,merged));     
    end
end
