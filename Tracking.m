%% Sweat Pore Detection
% The association of detections to the same object is based solely on
% motion. The motion of each track is estimated by a Kalman filter. The
% filter is used to predict the track's location in each frame, and
% determine the likelihood of each detection being assigned to each
% track.
%
% Track maintenance becomes an important aspect of this example. In any
% given frame, some detections may be assigned to tracks, while other
% detections and tracks may remain unassigned. The assigned tracks are
% updated using the corresponding detections. The unassigned tracks are
% marked invisible. An unassigned detection begins a new track.
%
% Each track keeps count of the number of consecutive frames, where it
% remained unassigned. If the count exceeds a specified threshold, the
% example assumes that the object left the field of view and it deletes the
% track.

function Tracking()  % modified MotionBasedMultiObjectTracking

    addpath(genpath('.'))
    UserInfo = init_directories();

    filename = [UserInfo.Directories.address , UserInfo.Directories.TIF_video];
    info = imfinfo(filename);
    L = length(info);

    obj = setupSystemObjects(); % Create System objects used for reading video, detecting moving objects, and displaying the results.

    tracks = initializeTracks(); % Create an empty array of tracks.
    nextId = 1; % ID of the next track


    % while ~isDone(obj.reader)   % Detect moving objects, and track them across video frames.
    for index = 1:L
        disp(['index',string(index)])
%         frame = reading_frame(index, UserInfo.inputMode);
        frame = imread(filename, index);
        [mask, frame] = segmentation(frame, UserInfo);

        Results = detecting_objects(mask);        
        bboxes = Results.bboxes;
        centroids = Results.centroids;
        
        predictNewLocationsOfTracks();
        [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment();

        updateAssignedTracks();
        updateUnassignedTracks();
        deleteLostTracks();
        createNewTracks();
        displayTrackingResults();
    end


    function UserInfo = init_directories()
        
%         if strcmp(OS,'linux_data7')
%             input_Hard_Drive = '\media\artin\HDD1\';
%         elseif strcmp(OS,'windows_data7')
%             input_Hard_Drive = 'H:\Datasets\';
%         end
% 
%         UserInfo.Directories.address   = [input_Hard_Drive, 'FLIR Datasets\Dataset\new_Jan2\'];
%         UserInfo.Directories.video     = 'Rec-000020 - Copy - test.wmv';
%         UserInfo.Directories.TIF_video = 'Rec-000020 - Copy - test.tif';
%         UserInfo.inputMode = 'reading_tif_video';
% 
%         if contains(OS,'linux')
%              UserInfo.Directories.address = strrep(UserInfo.Directories.address,'\','/');
%         end

        [name,path] = uigetfile('H:\Datasets\FLIR Datasets\sample\Rec-000020\','Select Input Video');
        UserInfo.Directories.address = path;
        UserInfo.Directories.TIF_video = name;
        
        a = strsplit(name,'.');
        UserInfo.Directories.video     = [a{1},'.wmv'];

        if strcmp(a{2},'tif')
            UserInfo.inputMode = 'reading_tif_video';
        else
            UserInfo.inputMode = 'reading_ats_video';
        end



        UserInfo.invisibleForTooLong = 20;
        UserInfo.ageThreshold = 8; 

        % Kalman Filter Parameters
        UserInfo.costOfNonAssignment = 20;
        UserInfo.MotionModel = 'ConstantVelocity';
        UserInfo.InitialEstimateError = [200, 50];
        UserInfo.MotionNoise = [100, 25];
        UserInfo.MeasurementNoise = 100;

        UserInfo.minVisibleCount = 8;
        
        Pore_Size = inputdlg({'Minimum','Maximum'},'Insert Pore Size',[1,40],{'1','15'});
        UserInfo.pore_size_range = [str2double(Pore_Size{1}) , str2double(Pore_Size{2}) ];
    end

    mask = segmentating_sweat_pores(frame);
        
    
    function im = reading_frame(index, mode)
        
        if strcmp(mode , 'read_from_individual_frames')
            name = ['Rec-000020 - Copy - test_',int2str(index),'.tif'];
            Dirr = [Directories.address, name];
            im = imread(Dirr);
        else
            im = imread(filename, index);
        end
        
        im = func_normalize(im,1);
        
        function im = func_normalize(im,type)
            im = single(im);
            mn = min(im(:));
            mx = max(im(:));
            if type == 16
                im = uint16(  (im-mn)*(2^16)/(mx-mn)  );
            elseif type == 8
                im = uint8(  (im-mn)*(2^8)/(mx-mn)  );
            elseif type == 1
                im = (im-mn)/(mx-mn);
            end
        end

    end

%% Create System Objects
% Create System objects used for reading the video frames, detecting
% foreground objects, and displaying results.

    function obj = setupSystemObjects()
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.
        
        % Create a video file reader.
        %         obj.reader = vision.VideoFileReader('atrium.mp4');
        obj.reader = vision.VideoFileReader([UserInfo.Directories.address , UserInfo.Directories.video]); % 'G:\FLIR Datasets\Dataset\new_Jan2\Rec-000020 - Copy - test.wmv');
        
        % Create two video players, one to display the video,
        % and one to display the foreground mask.
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
        
        % Create System objects for foreground detection and blob analysis
        
        % The foreground detector is used to segment moving objects from
        % the background. It outputs a binary mask, where the pixel value
        % of 1 corresponds to the foreground and the value of 0 corresponds
        % to the background.
        
        obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
        
        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis System object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.
        
        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400);
    end

%% Initialize Tracks
% The |initializeTracks| function creates an array of tracks, where each
% track is a structure representing a moving object in the video. The
% purpose of the structure is to maintain the state of a tracked object.
% The state consists of information used for detection to track assignment,
% track termination, and display.
%
% The structure contains the following fields:
%
% * |id| :                  the integer ID of the track
% * |bbox| :                the current bounding box of the object; used
%                           for display
% * |kalmanFilter| :        a Kalman filter object used for motion-based
%                           tracking
% * |age| :                 the number of frames since the track was first
%                           detected
% * |totalVisibleCount| :   the total number of frames in which the track
%                           was detected (visible)
% * |consecutiveInvisibleCount| : the number of consecutive frames for
%                                  which the track was not detected (invisible).
%
% Noisy detections tend to result in short-lived tracks. For this reason,
% the example only displays an object after it was tracked for some number
% of frames. This happens when |totalVisibleCount| exceeds a specified
% threshold.
%
% When no detections are associated with a track for several consecutive
% frames, the example assumes that the object has left the field of view
% and deletes the track. This happens when |consecutiveInvisibleCount|
% exceeds a specified threshold. A track may also get deleted as noise if
% it was tracked for a short time, and marked invisible for most of the
% frames.

    function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end

%% Read a Video Frame
% Read the next video frame from the video file.
    function frame = readFrame()
        frame = obj.reader.step();
    end


%% Predict New Locations of Existing Tracks
% Use the Kalman filter to predict the centroid of each track in the
% current frame, and update its bounding box accordingly.

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;
            
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);
            
            % Shift the bounding box so that its center is at
            % the predicted location.
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end

%% Assign Detections to Tracks
% Assigning object detections in the current frame to existing tracks is
% done by minimizing cost. The cost is defined as the negative
% log-likelihood of a detection corresponding to a track.
%
% The algorithm involves two steps:
%
% Step 1: Compute the cost of assigning every detection to each track using
% the |distance| method of the |vision.KalmanFilter| System object(TM). The
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

    function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment()
        
        nTracks = length(tracks);
        nDetections = size(centroids, 1);
        
        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end
        
        % Solve the assignment problem.
        costOfNonAssignment = UserInfo.costOfNonAssignment; %  20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

%% Update Assigned Tracks
% The |updateAssignedTracks| function updates each assigned track with the
% corresponding detection. It calls the |correct| method of
% |vision.KalmanFilter| to correct the location estimate. Next, it stores
% the new bounding box, and increases the age of the track and the total
% visible count by 1. Finally, the function sets the invisible count to 0.

    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);
            
            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);
            
            % Replace predicted bounding box with detected
            % bounding box.
            tracks(trackIdx).bbox = bbox;
            
            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;
            
            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end

%% Update Unassigned Tracks
% Mark each unassigned track as invisible, and increase its age by 1.

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    end

%% Delete Lost Tracks
% The |deleteLostTracks| function deletes tracks that have been invisible
% for too many consecutive frames. It also deletes recently created tracks
% that have been invisible for too many frames overall.

    function deleteLostTracks()
        if isempty(tracks)
            return;
        end
        
        invisibleForTooLong = UserInfo.invisibleForTooLong; % 20;
        ageThreshold = UserInfo.ageThreshold; %  8;
        
        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;
        
        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
        
        % Delete lost tracks.
        tracks = tracks(~lostInds);
    end

%% Create New Tracks
% Create new tracks from unassigned detections. Assume that any unassigned
% detection is a start of a new track. In practice, you can use other cues
% to eliminate noisy detections, such as size, location, or appearance.

    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);
        
        for i = 1:size(centroids, 1)
            
            centroid = centroids(i,:);
            bbox = bboxes(i, :);
            
            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter(UserInfo.MotionModel, centroid, UserInfo.InitialEstimateError, UserInfo.MotionNoise, UserInfo.MeasurementNoise);
                
            
            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);
            
            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;
            
            % Increment the next id.
            nextId = nextId + 1;
        end
    end

%% Display Tracking Results
% The |displayTrackingResults| function draws a bounding box and label ID
% for each track on the video frame and the foreground mask. It then
% displays the frame and the mask in their respective video players.

    function displayTrackingResults()
        % Convert the frame and the mask to uint8 RGB.
        frame = uint8(repmat(frame, [1, 1, 3]) .* 255); %im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;
        
        minVisibleCount = UserInfo.minVisibleCount; %8;
        if ~isempty(tracks)
            
            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);
            
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % Get bounding boxes.
                pore_ID = cat(1,tracks.id);
                Time_Pore_Stayed_Active = cat(1,tracks.totalVisibleCount);
                When_Pore_Appeared = cat(1,tracks.age);
                T = table(pore_ID, Time_Pore_Stayed_Active, When_Pore_Appeared);
                bboxes = cat(1, reliableTracks.bbox);
                
                % Get ids.
                ids = int32([reliableTracks(:).id]);
                
                % Create labels for objects indicating the ones for
                % which we display the predicted rather than the actual
                % location.
                labels = cellstr(int2str(ids'));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};
                labels = strcat(labels, isPredicted);
                
                % Draw the objects on the frame.
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);
                
                % Draw the objects on the mask.
%                 mask = insertObjectAnnotation(mask, 'rectangle', ...
%                     bboxes, labels);
            end
        end
        
        % Display the mask and the frame.
        obj.maskPlayer.step(mask);
        obj.videoPlayer.step(frame);
    end

%% Summary
% This example created a motion-based system for detecting and
% tracking multiple moving objects. Try using a different video to see if
% you are able to detect and track objects. Try modifying the parameters
% for the detection, assignment, and deletion steps.
%
% The tracking in this example was solely based on motion with the
% assumption that all objects move in a straight line with constant speed.
% When the motion of an object significantly deviates from this model, the
% example may produce tracking errors. Notice the mistake in tracking the
% person labeled #12, when he is occluded by the tree.
%
% The likelihood of tracking errors can be reduced by using a more complex
% motion model, such as constant acceleration, or by using multiple Kalman
% filters for every object. Also, you can incorporate other cues for
% associating detections over time, such as size, shape, and color.


end
