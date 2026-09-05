function [opticDiscMask, centerX, centerY, radius] = locateOpticDisc(imagePath)
% locateOpticDisc
% Detects a bright circular candidate region corresponding to
% the optic disc in a retinal fundus image.
%
% Input:
%   imagePath - path to retinal image
%
% Outputs:
%   opticDiscMask - binary optic disc candidate mask
%   centerX      - estimated X coordinate
%   centerY      - estimated Y coordinate
%   radius       - estimated radius

%% Read image
img = imread(imagePath);

if size(img,3) == 1
    img = repmat(img,[1 1 3]);
end

img = im2double(img);

%% Resize
img = imresize(img,[512 512]);

%% Extract channels
red = img(:,:,1);
green = img(:,:,2);

%% Create brightness image
brightness = 0.6 * red + 0.4 * green;

brightness = mat2gray(brightness);

%% Improve contrast
brightness = adapthisteq(brightness, ...
    'ClipLimit',0.01, ...
    'Distribution','rayleigh');

%% Threshold very bright regions
threshold = graythresh(brightness);

brightMask = imbinarize(brightness,threshold);

%% Remove small regions
brightMask = bwareaopen(brightMask,200);

%% Keep reasonably sized regions
brightMask = bwareafilt(brightMask,[200 10000]);

%% Find connected components
CC = bwconncomp(brightMask);

opticDiscMask = false(size(brightMask));

centerX = NaN;
centerY = NaN;
radius = NaN;

if CC.NumObjects > 0

    stats = regionprops(CC, ...
        'Area', ...
        'Centroid', ...
        'EquivDiameter');

    %% Select the brightest/largest candidate
    areas = [stats.Area];

    [~,idx] = max(areas);

    candidate = CC.PixelIdxList{idx};

    opticDiscMask(candidate) = true;

    centerX = stats(idx).Centroid(1);
    centerY = stats(idx).Centroid(2);

    radius = stats(idx).EquivDiameter / 2;

end

end