
RGB = imread('image.jpg');
method = 'circle'; %'adaptive-thresh'; % 

% finding_circles_func(RGB, method);
[BW2,coloredLabelsImage, obj, numberOfBlobs]  = read_masks_funcs(RGB, method);

disp(numberOfBlobs)
ax(1) = subplot(131); imshow(RGB)
ax(2) = subplot(132); imshow(BW2)
ax(3) = subplot(133); imshow(coloredLabelsImage)

linkaxes(ax)
%%
function finding_circles_func(RGB, method)

    if strcmp(method,'circle')
        
        % Find circles
        [centers,radii,~] = imfindcircles(RGB,[1 225],'ObjectPolarity','dark','Sensitivity',0.82);
        BW = false(size(RGB,1),size(RGB,2));
        [Xgrid,Ygrid] = meshgrid(1:size(BW,2),1:size(BW,1));
        for n = 1:1602
            BW = BW | (hypot(Xgrid-centers(n,1),Ygrid-centers(n,2)) <= radii(n));
        end
        

    elseif strcmp(method,'adaptive-thresh')
        
        % Adjust data to span data range.
        image = single(rgb2gray(RGB))/255;

        % Threshold image - adaptive threshold
        BW = imbinarize(image, 'adaptive', 'Sensitivity', 0.90000, 'ForegroundPolarity', 'bright'); 
    end
    
    BW = bwareafilt(BW,[5,350]);
    imwrite(BW, [method,'/BW_',method,'.jpg'])
   
end


function [BW2,coloredLabelsImage, obj, numberOfBlobs] = read_masks_funcs(RGB, method)

    % Convert RGB image into L*a*b* color space.
    image = single(rgb2gray(RGB))/255;
    BW = imread( [method,'/BW_',method,'.jpg'] ) > 100;
    [BW2,maskedImage, obj] = extracting_objects(image, BW);    
    
    BW2 = bwareafilt(BW2,[5,350]);

    [labeledImage, numberOfBlobs] = bwlabel(BW2, 8);
    coloredLabelsImage = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); 

    imwrite(~coloredLabelsImage, [method,'/coloredLabelsImage_',method,'.jpg'])
    imwrite(BW2, [method,'/BW_',method,'.jpg'])
end


function [BW2,image, obj] = extracting_objects(image, BW)

    % Cropping the top area
    BW2 = BW; 
    BW2(1:400,:) = 0;
    obj = regionprops(BW2,'Area', 'Centroid', 'ConvexImage', 'FilledImage', 'Image', 'PixelIdxList'	, 'PixelList');

    % Create masked image.
    image(BW2) = 1;

end


