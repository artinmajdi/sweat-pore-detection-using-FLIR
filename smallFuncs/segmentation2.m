function [mask, im_enhanced] = segmentation2(inputs)

% % inputs.im = filter2(ones(3,3)/9,inputs.im);
im_enhanced = adapthisteq(inputs.im,'NumTiles',[50,50],'ClipLimit',inputs.ClipLimit);
im_enhanced = medfilt2(im_enhanced,[3,3]);
mask = im_enhanced < inputs.binarization_threshold;

end