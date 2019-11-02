% app_designer_address: 'C:\Users\artin\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\App Designer - Image Processing'

clc
clear

dataset_dir = 'F:\RESEARCH\Data7\FLIR\Dataset\video sample\tif\';
index = 183;

im = read_image(index, dataset_dir, true);
[im, Background] = removeBackground(im);
%% enhancing the dots

[im_filtered, candidates1] = apply_filter(im,0.4);
[msk, im1 , im4] = apply_filter2(im, Background, "same");

ax(1) = subplot(131); imshow(im1)
ax(2) = subplot(132); imshow(candidates1)
ax(3) = subplot(133); imshow(msk) % , hold on , visboundaries(msk)
linkaxes(ax)
%%
% im5 = watershed(im4,4);
% candidates1_watershed = keeping_the_watershed_area(watershed_output, candidates1);

% myshow('joined','imshow', im4 , im5)

%%
function [msk, im1 , im4] = apply_filter2(im, Background, shape)
    % rescale(entropyfilt(im));
    % localcontrast(im, 0.2, 0.2);

    im1 = rescale(locallapfilt(im,0.2,0.2));

    im2 = rescale(filter2( fspecial('average',3) ,im1,shape));

    h = [-1,-1,-1;-1,8,-1;-1,-1,-1];
    im2b = rescale(filter2(h,im2,shape));

    im3 = imhmax(im2b,0.3);
    im4 = rescale(filter2( fspecial('average',3) ,im3,shape));
       
    msk = ~imbinarize(im4,'adaptive','ForegroundPolarity','dark','Sensitivity',0.2);

    msk = bwareafilt(msk , [1, 15] );
    msk(Background == 1) = 0; 
    
    % myshow('separate','imtool', im1 , msk)
    % myshow('joined','imshow', im1 , msk)
end

%%
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
    disp(name)
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