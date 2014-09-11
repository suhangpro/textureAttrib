do_startup;

imDir = 'dtd-r1/images';
saveDir = 'data/feat';

load('dtd-r1/imdb/imdb.mat','images');
imPathCell = cellfun(@(s) fullfile(imDir,s), images.name, 'UniformOutput',false);

imConf.rescaleDim = 'shorter';
imConf.rescaleTarget = 256;
imConf.colorType = 'rgb';
imConf.cropSquare = true;

featType = 'DeCAF';

featMat = prep_feat(imPathCell,saveDir,imConf,featType);
save(fullfile(saveDir,'DeCAF.mat'),'featMat');
