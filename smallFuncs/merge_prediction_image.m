function msk = merge_prediction_image(im , im_enhanced , prediction)
    merged = 256*horzcat( im(40:end,40:end),im_enhanced(40:end,40:end) , single(prediction(40:end,40:end)) );
    msk = uint8(cat(3,merged,merged,merged));     
end