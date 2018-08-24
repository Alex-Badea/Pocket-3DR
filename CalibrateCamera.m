function [ K ] = CalibrateCamera( calibImgDir, plotResultFlag )
%CALIBRATECAMERA Summary of this function goes here
%   Detailed explanation goes here
ims = imageDatastore(calibImgDir);
[imPts, boardSz] = detectCheckerboardPoints(ims.Files);

sqSz = 24;
dummyPts = generateCheckerboardPoints(boardSz, sqSz);
cameraParameters = estimateCameraParameters(imPts, dummyPts);
K = cameraParameters.IntrinsicMatrix';

if size(ims.Files,1) ~= size(imPts,3)
    error('Error detecting checkerboard pattern in all images')
end

if exist('plotResultFlag', 'var')
    if strcmp(plotResultFlag, 'plotResult')
        for i = 1:size(ims.Files,1)
            figure, imshow(imread([char(64+i) '.jpg'])), hold on
            plot(imPts(:,1,i), imPts(:,2,i), 'ro');
        end
    else
        error('Invalid plotResultFlag')
    end
end
end

