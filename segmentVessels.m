function vesselMask = segmentVessels(imagePath)
% segmentVessels
% Detects blood-vessel candidates from a retinal fundus image.
%
% Input:
%   imagePath - path to retinal image
%
% Output:
%   vesselMask - binary vessel candidate image

% Read image
img = imread(imagePath);

% Convert grayscale to RGB if necessary
if size(img,3) == 1
    img = repmat(img,[1 1 3]);
end

% Convert to double
img = im2double(img);

% Resize
img = imresize(img,[512 512]);

% Green channel gives strong vessel contrast
green = img(:,:,2);

% Improve contrast
green = adapthisteq(green, ...
    'ClipLimit',0.01, ...
    'Distribution','rayleigh');

% Enhance dark vessel structures
kernel = strel('disk',7);

blackhat = imbothat(green,kernel);

% Normalize
blackhat = mat2gray(blackhat);

% Threshold automatically
threshold = graythresh(blackhat);

vesselMask = imbinarize(blackhat,threshold);

% Remove very small objects
vesselMask = bwareaopen(vesselMask,20);

% Small morphological cleanup
vesselMask = imopen(vesselMask,strel('disk',1));

end