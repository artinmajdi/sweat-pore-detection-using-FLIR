%%  source: https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/51932/versions/3/previews/Demos_FLIR_FEX/d2_Object_Detection_Tracking/multiObjectTrackingFilter.m/index.html

%% Motion-Based Multiple Object Tracking
% FLIRЂ ResearchIR�?AgbLOs邽߂̃XNvg

% This example shows how to perform automatic detection and motion-based
% tracking of moving objects in a video from a stationary camera.
%
% This file si called from ResearchIR using the new connection with MATLAB
% through MATLAB Engine
%
% Copyright 2014 - 2015 The MathWorks, Inc. 

h = size(rir_filter_input, 1);
w = size(rir_filter_input, 2);

if rir_filter_reset
	rir_filter_output = zeros(h, w, class(rir_filter_input));
    
  
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {},...
            'trails',[],...
            'trails_corrected',[]);
    
    
    detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
        
    blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 200);


    nextId = 1; % ID of the next track
%     obj = setupSystemObjects()
%   
end


% Detect moving objects, and track them across video frames.

    frame = rir_filter_input;



%% Detect Objects
% The |detectObjects| function returns the centroids and the bounding boxes
% of the detected objects. It also returns the binary mask, which has the 
% same size as the input frame. Pixels with a value of 1 correspond to the
% foreground, and pixels with a value of 0 correspond to the background.   
%
% The function performs motion segmentation using the foreground detector. 
% It then performs morphological operations on the resulting binary mask to
% remove noisy pixels and to fill the holes in the remaining blobs.  


        % Detect foreground.
        mask = detector.step(frame);
        
        % Apply morphological operations to remove noise and fill in holes.
        mask = imopen(mask, strel('rectangle', [15,15]));
%         mask = imclose(mask, strel('rectangle', [15, 15])); 
         mask = imclose(mask, strel('rectangle', [15, 15])); 
        mask = imfill(mask, 'holes');
        
        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = blobAnalyser.step(mask);
%     end

%% Predict New Locations of Existing Tracks
% Use the Kalman filter to predict the centroid of each track in the
% current frame, and update its bounding box accordingly.

        for i = 1:length(tracks)
            bbox = tracks(i).bbox;
            
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);
            
            % Shift the bounding box so that its center is at 
            % the predicted location.
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
%     end

%% Assign Detections to Tracks
% Assigning object detections in the current frame to existing tracks is
% done by minimizing cost. The cost is defined as the negative
% log-likelihood of a detection corresponding to a track.  
%
% The algorithm involves two steps: 
%
% Step 1: Compute the cost of assigning every detection to each track using
% the |distance| method of the |vision.KalmanFilter| System object. The 
% cost takes into account the Euclidean distance between the predicted
% centroid of the track and the centroid of the detection. It also includes
% the confidence of the prediction, which is maintained by the Kalman
% filter. The results are stored in an MxN matrix, where M is the number of
% tracks, and N is the number of detections.   
%
% Step 2: Solve the assignment problem represented by the cost matrix using
% the |assignDetectionsToTracks| function. The function takes the cost 
% matrix and the cost of not assigning any detections to a track.  
%
% The value for the cost of not assigning a detection to a track depends on
% the range of values returned by the |distance| method of the 
% |vision.KalmanFilter|. This value must be tuned experimentally. Setting 
% it too low increases the likelihood of creating a new track, and may
% result in track fragmentation. Setting it too high may result in a single 
% track corresponding to a series of separate moving objects.   
%
% The |assignDetectionsToTracks| function uses the Munkres' version of the
% Hungarian algorithm to compute an assignment which minimizes the total
% cost. It returns an M x 2 matrix containing the corresponding indices of
% assigned tracks and detections in its two columns. It also returns the
% indices of tracks and detections that remained unassigned. 

        
        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end
        
        % Solve the assignment problem.
        costOfNonAssignment = 50;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
%     end

%% Update Assigned Tracks
% The |updateAssignedTracks| function updates each assigned track with the
% corresponding detection. It calls the |correct| method of
% |vision.KalmanFilter| to correct the location estimate. Next, it stores
% the new bounding box, and increases the age of the track and the total
% visible count by 1. Finally, the function sets the invisible count to 0. 

  
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);
            
            tracks(trackIdx).trails{end+1} = centroid;
            % Correct the estimate of the object's location
            % using the new detection.
            c2 = correct(tracks(trackIdx).kalmanFilter, centroid);
            
            tracks(trackIdx).trails_corrected{end+1} = c2;
            
            % Replace predicted bounding box with detected
            % bounding box.
     
            if length( tracks(trackIdx).trails) > 30
                tracks(trackIdx).trails(1) = [];
            end
            if length( tracks(trackIdx).trails_corrected) > 30
                tracks(trackIdx).trails_corrected(1) = [];
            end
            tracks(trackIdx).bbox = bbox;
            
            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;
            
            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
%     end

%% Update Unassigned Tracks
% Mark each unassigned track as invisible, and increase its age by 1.

        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
      
            c2 = predict(tracks(ind).kalmanFilter);
            
            tracks(ind).trails_corrected{end+1} = c2;
            
            % Replace predicted bounding box with detected
            % bounding box.
     
            if length( tracks(ind).trails_corrected) > 30
                tracks(ind).trails_corrected(1) = [];
            end
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    

%% Delete Lost Tracks
% The |deleteLostTracks| function deletes tracks that have been invisible
% for too many consecutive frames. It also deletes recently created tracks
% that have been invisible for too many frames overall. 

%         if isempty(tracks)
%             return;
%         end
        invisibleForTooLong = 30;
        ageThreshold = 30;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
    

%% Create New Tracks
% Create new tracks from unassigned detections. Assume that any unassigned
% detection is a start of a new track. In practice, you can use other cues
% to eliminate noisy detections, such as size, location, or appearance.

        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);
        
        for i = 1:size(centroids, 1)
            
            centroid = centroids(i,:);
            bbox = bboxes(i, :);
            
            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);
            
            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0,...
                'trails',{{}},...
                'trails_corrected',{{}});
            newTrack.trails{1} = centroid;
            newTrack.trails_corrected{1} = centroid;
            
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            
            % Increment the next id.
            nextId = nextId + 1;
        end
    

%% Display Tracking Results
% The |displayTrackingResults| function draws a bounding box and label ID 
% for each track on the video frame and the foreground mask. It then 
% displays the frame and the mask in their respective video players. 

    
%        Convert the frame and the mask to uint8 RGB.
        frame = im2uint8(frame, 'indexed');
     
        
        minVisibleCount = 8;
        
    
        for i = 1:length(tracks)
            loc = tracks(i).trails{size(tracks(i).trails)};
            x1 = round(loc(1));
            y1 = round(loc(2));
            label = frame(x1, y1);
            
            if tracks(i).totalVisibleCount > minVisibleCount
                % Draw the objects on the frame.
%                 label = cellstr(int2str(tracks(i).id));
                
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    tracks(i).bbox, label, 'TextBoxOpacity', 1);
                
                
                p = cat(1,tracks(i).trails{:});
                
                frame = insertMarker(frame, p, 'x', 'size', 5);
                
                pc = cat(1,tracks(i).trails_corrected{:});
                
                frame = insertMarker(frame, pc, 'o', 'size', 5);
                
                z = 1;
                
            end
            if tracks(i).consecutiveInvisibleCount > 0
%                label = cellstr(int2str(tracks(i).id));
               
               frame = insertObjectAnnotation(frame, 'rectangle', ...
                    tracks(i).bbox, strcat('Predicted-',label), 'TextBoxOpacity', 1);
                   p = cat(1,tracks(i).trails{:});
                
                frame = insertMarker(frame, p, 'x', 'size', 5);
                
                pc = cat(1,tracks(i).trails_corrected{:});
                
                frame = insertMarker(frame, pc, 'o', 'size', 5);
                
                y = 2;
            end
 

        
        end

frame = imfuse(frame, rir_filter_input);
frame = rgb2gray(frame);
rir_filter_output = im2single(frame, 'indexed');
