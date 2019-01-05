X = CX{1};
C = CC{1};
[~,inInd] = pcdenoise(pointCloud(X'), 'NumNeighbors', 50, 'Threshold', 0.1);
inInd = ismember(1:size(X,2), inInd);
X = X(:,inInd);
C = C(:,inInd);

NotNanInd = ~isnan(D);
NotNanAndNotNoiseInd = zeros(size(D));
NotNanAndNotNoiseInd(NotNanInd==true) = inInd;
figure,imshow(NotNanInd)
figure,imshow(NotNanAndNotNoiseInd)