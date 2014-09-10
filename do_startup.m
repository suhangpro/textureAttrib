
%% Caffe
if exist('dependencies/caffe/matlab/caffe','dir')
  addpath('dependencies/caffe/matlab/caffe');
else
  warning('Please install Caffe in ./dependencies/caffe');
end

%% VLFeat
if exist('dependencies/vlfeat','dir')
  addpath('dependencies/vlfeat');
  run('./dependencies/vlfeat/toolbox/vl_setup.m');
else
  warning('Please install VLFeat in ./dependencies/vlfeat');
end

%% Utils
addpath(genpath('utils'));

%% matlab pool
if matlabpool('SIZE')==0, 
    matlabpool;
end

%% Done
fprintf('startup done. \n');
