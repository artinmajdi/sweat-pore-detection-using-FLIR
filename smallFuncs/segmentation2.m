function [mask] = segmentation2(im)

im = func_normalize(im,1);
% im = filter2(ones(3,3)/9,im);
im3 = adapthisteq(im,'NumTiles',[50,50],'ClipLimit',0.9);
mask = medfilt2(im3,[3,3]) < 0.1;

end