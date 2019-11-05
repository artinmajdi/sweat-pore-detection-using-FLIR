clc
clear

%%
dataset_dir = 'F:\RESEARCH\Data7\FLIR\Dataset\video sample\tif\';

index = 183;
[im1, candidates1, candidates2] = detect_sweat_pores(dataset_dir, index);
[msk1,msk2] = main(dataset_dir, index);

% imshow(msk1,[])
myshow('imshow',im1, candidates2)

%%
obj = regionprops(candidates1,'Area','PixelIdxList');

%%
function [msk1, msk2] = main(dataset_dir, index)
    [im1, candidates1, candidates2] = detect_sweat_pores(dataset_dir, index);

    msk1 = post_process(im1, candidates1);
    msk2 = post_process(im1, candidates2);
    
    function msk1 = post_process(im1, candidates1)
%         candidates1 = remove_extra_areas(candidates1);
        candidates1f = 256*[im1(2:509,2:637),single(candidates1)];

        msk1 = zeros(508,1272,3);
        for i = 1:3
            msk1(:,:,i) = candidates1f;
        end
        msk1 = uint8(msk1);       
    end
    
end

function [im1, candidates1, candidates2] = detect_sweat_pores(dataset_dir, index)

    im1 = read_image(dataset_dir, index,true);
    im1_woBg = removeBackground(im1);

    sensitivity = 0.4;
    [im_filtered, candidates1] = apply_filter(im1_woBg,0.4);
    im_filtered_suppressed = imhmax(im_filtered,0.4);
    candidates2 = ~imbinarize(im_filtered_suppressed,'adaptive','ForegroundPolarity','dark','Sensitivity',sensitivity);

    candidates1 = remove_extra_areas(candidates1);
    candidates2 = remove_extra_areas(candidates2);
    
    function im = read_image(dataset_dir, index, normalize)

        % dir = 'F:\Datasets\FLIR\video sample\tif\';
        name = ['Rec-000020 - Copy - test_',int2str(index),'.tif'];
    %     disp(name)
        Dirr = [dataset_dir, name];
        im = imread(Dirr);

        if normalize
            im = func_normalize(im,1);
        end
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

    function im1_woBg = removeBackground(im1)
        im1b = im1*0;
        im1b(im1 < 0.1) = 1;
        im1b = imclose(im1b,strel('disk',20));

        im1_woBg = im1;
        im1_woBg(im1b==1) = 0;

        im1_woBg = func_normalize(im1_woBg - 0.1, 1);

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

    function msk = remove_extra_areas(msk)
        msk = bwareafilt(msk,[1,10]);
        msk(450:end,:)=0;
    end  

end

function myshow(mode,varargin)
    for x = 1:length(varargin)
        if strcmp(mode,'imshow')
            ax(x) = subplot(1,length(varargin),x); imshow(varargin{x},[]);% title('im1')
        elseif strcmp(mode,'imtool')
            ax(x) = subplot(1,length(varargin),x); imtool(varargin{x},[]);% title('im1')
        end
    end
    linkaxes(ax)

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

function save_video()

    L = 5400;
    
    
    writerObj1 = VideoWriter([dataset_dir ,'myVideo1.avi']);
    writerObj2 = VideoWriter([dataset_dir ,'myVideo2.avi']);
    writerObj1.FrameRate = 1;
    writerObj2.FrameRate = 1;

    secsPerImage = 1;
    open(writerObj1);
    open(writerObj2);
    
    % write the frames to the video
    for u=1:L
        % convert the image to a frame

        [msk1,msk2] = main(dataset_dir, index);

        frame1 = im2frame(uint8(msk1));
        frame2 = im2frame(uint8(msk2));
        writeVideo(writerObj1, frame1);
        writeVideo(writerObj2, frame1);
    end
    % close the writer object
    close(writerObj1);
    close(writerObj2);
end