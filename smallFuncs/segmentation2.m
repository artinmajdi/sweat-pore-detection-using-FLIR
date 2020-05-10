function mask = segmentation2(inputs)

% % inputs.im = filter2(ones(3,3)/9,inputs.im);
im3 = adapthisteq(inputs.im,'NumTiles',[50,50],'ClipLimit',inputs.ClipLimit);
im3 = medfilt2(im3,[3,3]);
mask = im3 < inputs.binarization_threshold;

end