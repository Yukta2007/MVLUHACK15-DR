function microaneurysmMask = detectMicroaneurysms(imagePath)
% detectMicroaneurysms
% Detects candidate microaneurysms in a retinal fundus image.
%
% Input:
%   imagePath - path to retinal image
%
% Output:
%   microaneurysmMask - binary candidate mask

%% Read image
img = imread(imagePath);

% Convert grayscale to RGB
if size(img,3) == 1
    img = repmat(img,[1 1 3]);
end

% Convert to double
img = im2double(img);

% Resize
img = imresize(img,[512 512]);

%% Extract green channel
green = img(:,:,2);

%% Improve contrast
green = adapthisteq(green, ...
    'ClipLimit',0.01, ...
    'Distribution','rayleigh');

%% Detect small dark structures
smallKernel = strel('disk',4);

darkStructures = imbothat(green,smallKernel);

darkStructures = mat2gray(darkStructures);

%% Threshold
threshold = graythresh(darkStructures);

microaneurysmMask = imbinarize( ...
    darkStructures,threshold);

%% Remove very small noise
microaneurysmMask = bwareaopen( ...
    microaneurysmMask,3);

%% Remove very large regions
microaneurysmMask = ...
    bwareafilt(microaneurysmMask,[3 80]);

%% Morphological cleanup
microaneurysmMask = imopen( ...
    microaneurysmMask,strel('disk',1));

end