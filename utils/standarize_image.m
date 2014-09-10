function [ imlist, options ] = standarize_image(imlist, options)

% Standarized image with various options
% Hang Su

% default: single precesion, gray-scale, height<=480
defaultOpts.valueClass = 'single';
defaultOpts.colorType = 'gray';
defaultOpts.rescaleDim = 'y';
defaultOpts.rescaleTarget = 480;
defaultOpts.reduceOnly = true;
defaultOpts.cropSquare = false;

% return default options when called w/o any arguments
if nargin==0,
    imlist = [];
    options = defaultOpts;
    return;
end

% populate the options not specified w/ default values
if nargin==1,
    options = defaultOpts;
else
    missingFields = setdiff(fieldnames(defaultOpts),fieldnames(options));
    for i=1:length(missingFields),
        options.(missingFields{i}) = defaultOpts.(missingFields{i});
    end
end

flag_cell = true;
if ~iscell(imlist), 
    imlist = {imlist}; 
    flag_cell = false;
end;

for ii = 1:length(imlist);
    im = imlist{ii};
    
    % image path is also accepted
    if ischar(im)
        try
            im = imread(im) ;
        catch
            error('Corrupted image %s', im) ;
        end
    end
    
    % convert color type
    switch options.colorType,
        case 'rgb',     if ismatrix(im), im = repmat(im,[1 1 3]); end;
        case 'gray',    if ~ismatrix(im), im = rgb2gray(im); end;
        case 'hsv',
            if ismatrix(im), im(:,:,3) = im; im(:,:,1:2) = 0;
            else im = rgb2hsv(im); end;
        case 'original', 
        otherwise,
            warning('Unknown colorType option: %s. No conversion was done.',...
                options.colorType);
    end
    
    % convert data type
    switch options.valueClass,
        case 'single',  im = im2single(im);
        case 'double',  im = im2double(im);
        case 'uint8',   im = im2uint8(im);
        case 'uint16',  im = im2uint16(im);
        case 'logical', im = im2single(im)>0.5;
        otherwise,
            warning('Unknown valueClass option: %s. %s was used instead.', ...
                options.valueClass, class(im));
    end
    
    % rescale
    switch options.rescaleDim,
        case 'y',       rescaleDim = 1;
        case 'x',       rescaleDim = 2;
        case 'longer',  rescaleDim = (size(im,2)>size(im,1))+1;
        case 'shorter', rescaleDim = (size(im,2)<size(im,1))+1;
        case 'none',    rescaleDim = 0;
        otherwise,
            warning('Unknown rescaleDim option: %s. %s was used instead.', ...
                options.valueClass, 'y');
            rescaleDim = 1;
    end
    if rescaleDim~=0,
        resizeScale = options.rescaleTarget/size(im,rescaleDim);
        if resizeScale<=1 || ~options.reduceOnly,
            im = imresize(im,resizeScale);
            if isfloat(im), im = max(min(im,1),0); end
        end
    end
    
    % crop center square
    if options.cropSquare && size(im,1)~=size(im,2), 
        if size(im,1)>size(im,2), 
            len = size(im,2);
            im = im(floor((size(im,1)-len)/2)+(1:len),:,:);
        else
            len = size(im,1);
            im = im(:,floor((size(im,2)-len)/2)+(1:len),:);
        end
    end
    
    imlist{ii} = im;
    
end

if ~flag_cell, imlist = imlist{1}; end

end