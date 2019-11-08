clc
clear

dataset_dir = 'F:\RESEARCH\Data7\FLIR\Dataset\video sample\tif\';
index = 160;

imO = read_image(index, dataset_dir, true);
[im, Background] = removeBackground(imO);

%% enhancing the dots

% [im_filtered, candidates1] = apply_filter_V1(im,0.4);
[msk, im1 , im4] = apply_filter_V2(im, Background, "same");

%% watershed segmentation
% im5 = watershed(im4,4);
% candidates1_watershed = keeping_the_watershed_area(watershed_output, candidates1);

%% write as a video
L = 1000;
T = linspace(1,33.3,1000);
[Area , PC] = save_video(dataset_dir, L);

%%  extras for presentation
% show_the_manual_filter(3, 11)

   
%% functions
function [im1d, im1d_binarize] = apply_filter_V1(im1_woBg,sensitivity)
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

function [msk, im1 , im4] = apply_filter_V2(im, Background, shape)


    % imA = rescale(imbilatfilt(im,0.5));
    % imB = rescale(locallapfilt(im,0.2,0.2));
    % imC = rescale(imdiffusefilt(im));  % ,Name,Value 
    % imD = rescale(imnlmfilt(im , 'ComparisonWindowSize' , 3 , 'SearchWindowSize' , 11));  % ,Name,Value 
    % imE = rescale(filter2( fspecial('average',3) ,im,"same"));
    % myshow('joined','imshow', imE , imEc , im2c)

    % ax(1) = subplot(231); imshow(im)  ; title('Original Image', 'FontSize',18)
    % ax(2) = subplot(232); imshow(imA) ; title('Bilateral Fitler', 'FontSize',18) 
    % ax(3) = subplot(233); imshow(imE) ; title('3x3 Average Filter', 'FontSize',18)
    % ax(4) = subplot(234); imshow(imC) ; title('Anisotropic Diffusion Filter', 'FontSize',18)
    % ax(5) = subplot(235); imshow(imD) ; title('Non-Local Means Filter', 'FontSize',18)
    % ax(6) = subplot(236); imshow(imB) ; title('Local Laplacian Filter', 'FontSize',18)
    % linkaxes(ax)


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

function myshow(separate_joined,mode,varargin)
    for x = 1:length(varargin)
        
        if strcmp(separate_joined,'joined')
            if strcmp(mode,'imshow')
                ax(x) = subplot(1,length(varargin),x); imshow(varargin{x});
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

function [Area , PC] = save_video(dataset_dir, L)
    
    writerObj = VideoWriter([dataset_dir ,'myVideo1.avi']);
    writerObj.FrameRate = 10;

    secsPerImage = 1;
    open(writerObj);
    
    PC = zeros(L,1);
    Area = cell(L,1);
    for index = 1:L
        if mod(index,5) == 0 disp(['Frame:',num2str(index)]), end
        
        im = read_image(index, dataset_dir, true);
        [im, Background] = removeBackground(im);

        [prediction, im1 , im4] = apply_filter_V2(im, Background, "same");
        
        obj = regionprops(prediction(40:end,40:end) , 'Area');
        Area{index} = cat(1,obj.Area);
        PC(index) = length(obj);
        
        msk = post_process(im , im1 , prediction);

        frame = im2frame(msk);
%         a = vision.PointTracker(frame);
        writeVideo(writerObj, frame);
    end
    close(writerObj);
    
    function msk = post_process(im , imFiltered , prediction)
        merged = 256*horzcat( im(40:end,40:end),imFiltered(40:end,40:end) , single(prediction(40:end,40:end)) );
        msk = uint8(cat(3,merged,merged,merged));     
    end
end

function show_the_manual_filter(L, L2)
%     L = 3;
    d = floor(L/3);
    h1 = -(L^2-8*(d^2))*ones(L,L);

    l = (L - d)/2;
    h1(l+1:end-l,l+1:end-l) = 8;
    [X1,Y1] = meshgrid(1:L , 1:L);


    h2 = ones(L,L)/(L^2);    
    h12 = conv2(h2, h1);   

%     L2 = 11;
    [X3,Y3] = meshgrid(1:L2 , 1:L2);
    h3 = zeros(L2,L2);

    l = (L2 - (2*L-1))/2;
    h3(l+1:end-l,l+1:end-l) = h12;


    [fitresult, gof] = createFit1(X3, Y3, h3)

end

%%
% app_designer_address: 'C:\Users\artin\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\App Designer - Image Processing'