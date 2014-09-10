function [ feat ] = compute_decaf( im, varargin )
% COMPUTE_DECAF get DeCAF feature for input image

if isempty(im), 
  % For demo purposes we will use the peppers image
  im = imread('peppers.png');
end

olddir = cd('dependencies/caffe/matlab/caffe/');

conf.use_gpu = false;
conf.blob_names = {'fc6','fc7'};
conf.center_only = true;
conf.verbose = false;
conf = vl_argparse(conf,varargin);

% init caffe network (spews logging info)
net = CaffeNet.instance;
if conf.use_gpu
    net.set_mode_gpu;
    if conf.verbose, fprintf('Done with set_mode_gpu\n'); end
else
    net.set_mode_cpu;
    if conf.verbose, fprintf('Done with set_mode_cpu\n');end
end

% put into test mode
net.set_phase_test;
if conf.verbose, fprintf('Done with set_phase_test\n');end 

% prepare oversampled input
% input_data is Height x Width x Channel x Num
tic;
input_data = {prepare_image(im)};
if conf.center_only, input_data = {input_data{1}(:,:,:,5)}; end
if conf.verbose, toc; end

% do forward pass to get scores
% scores are now Width x Height x Channels x Num
tic;
net.forward(input_data);
if conf.verbose, toc; end

blob_data = cellfun(@(s) squeeze(net.get_blob_data(s)), conf.blob_names, 'UniformOutput',false);
blob_data = cellfun(@(d) d(:,1:size(input_data{1},4)), blob_data, 'UniformOutput',false);
feat = cat(1,blob_data{:});

cd(olddir);


% ------------------------------------------------------------------------
function images = prepare_image(im)
% ------------------------------------------------------------------------
d = load('ilsvrc_2012_mean');
IMAGE_MEAN = d.image_mean;
IMAGE_DIM = 256;
CROPPED_DIM = 227;

% resize to fixed input size
im = single(im);
im = imresize(im, [IMAGE_DIM IMAGE_DIM], 'bilinear');
% permute from RGB to BGR (IMAGE_MEAN is already BGR)
im = im(:,:,[3 2 1]) - IMAGE_MEAN;

% oversample (4 corners, center, and their x-axis flips)
images = zeros(CROPPED_DIM, CROPPED_DIM, 3, 10, 'single');
indices = [0 IMAGE_DIM-CROPPED_DIM] + 1;
curr = 1;
for i = indices
  for j = indices
    images(:, :, :, curr) = ...
        permute(im(i:i+CROPPED_DIM-1, j:j+CROPPED_DIM-1, :), [2 1 3]);
    images(:, :, :, curr+5) = images(end:-1:1, :, :, curr);
    curr = curr + 1;
  end
end
center = floor(indices(2) / 2)+1;
images(:,:,:,5) = ...
    permute(im(center:center+CROPPED_DIM-1,center:center+CROPPED_DIM-1,:), ...
        [2 1 3]);
images(:,:,:,10) = images(end:-1:1, :, :, curr);
