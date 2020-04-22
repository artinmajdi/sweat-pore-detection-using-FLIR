function Results = detecting_objects(prediction)

    objects  = regionprops(prediction , 'Area' , 'BoundingBox' , 'Centroid');
        
    Results.Area = cat(1,objects.Area);
    Results.PC   = length(objects);
    Results.centroids = cat(1,objects.Centroid);
    Results.bboxes = int32(cat(1,objects.BoundingBox));      

end

