function [ optimalHypothesis, inliersSet, outliersSet, optimHypGenSamples,...
    elapsedSteps] = RANSAC( inputSet, hypothesisGeneratorFcn, minSampleSize,...
    errorFcn, threshold )
%RANSAC Computes an optimal hypothesis based on the hypothesis generator on
%the outlier-polluted input set
%   This method runs RANSAC adaptively by providing, with each iteration, a
%   random probe of minSampleSize samples from inputSet to the
%   hypothesisGeneratorFcn. It then tests this hypothesis against the
%   entire inputSet by computing a distance using distanceFcn and checking
%   whether this distance lies under the threshold, in which case it is
%   added to the inliersSet.
%   Input arguments:
%   - inputSet: A CELL ARRAY consisting of the input set;
%   - hypothesisGeneratorFcn: a function handle that receives A CELL ARRAY
%   of samples and returns A CELL ARRAY OF HYPOTHESES! (Even if the
%   function naturally returns a single output hypothesis)
%   - minSampleSize: the minimum size of a sample in order to generate a
%   hypothesis;
%   - errorFcn: a function handle that receives a hypothesis and the
%   inputSet and returns A ROW VECTOR OF NUMERICAL VALUES corresponding to
%   each member of the inputSet and representing its error;
%   threshold - the maximum permited error value under which a sample is
%   considered to be an inlier.
if ~iscell(inputSet)
    error('inputSet must be of cell type')
end
inputSize = length(inputSet);
maxSteps = inf;
bestSize = 0;
bestHypothesis = [];
bestInliersSet = {};
bestOutliersSet = {};
bestOptimHypGenSamples = [];

step = 1;
while step <= maxSteps
    crtSampleInd = randperm(inputSize, minSampleSize);
    crtSampleSet = inputSet(crtSampleInd);
    crtHypotheses = hypothesisGeneratorFcn(crtSampleSet);
    if isempty(crtHypotheses), continue, end
    for i = 1:length(crtHypotheses)
        crtHypothesis = crtHypotheses{i};
        crtErrors = errorFcn(crtHypothesis, inputSet);
        if ~all(abs(errorFcn(crtHypothesis, crtSampleSet) - crtErrors(crtSampleInd)) < 1e-4)
            warning('There might be something wrong with errorFcn')
        end
        if ~isequal(size(crtErrors), [1 inputSize])
            error('errorFcn must return a column vector of length equal to that of the input')
        end
        crtInliersInd = crtErrors < threshold;
        crtSize = sum(crtInliersInd);
        if crtSize > bestSize
            bestSize = crtSize;
            bestHypothesis = crtHypothesis;
            bestInliersSet = inputSet(crtInliersInd);
            bestOutliersSet = inputSet(~crtInliersInd);
            bestOptimHypGenSamples = crtSampleSet;
        end
    end
    e = 1 - crtSize/inputSize;
    maxSteps = abs(log(1-0.9999999999999999) / log(1-(1-e)^6));
    step = step + 1;
end

optimalHypothesis = bestHypothesis;
inliersSet = bestInliersSet;
outliersSet = bestOutliersSet;
optimHypGenSamples = bestOptimHypGenSamples;
elapsedSteps = step;
end

