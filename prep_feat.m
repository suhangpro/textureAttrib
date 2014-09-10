function featMat = prep_feat(imPathCell, featDir, imConf, featType, featOpts)

if ~isempty(featDir) && ~exist(featDir,'dir'), vl_xmkdir(featDir); end
if ~exist('imConf','var'), imConf = struct(); end

switch featType,
    case 'DeCAF',
        if exist('featOpts','var') && isfield(featOpts,'conf'),
            aux_data = struct('imConf',imConf,'featConf',featOpts.conf);
            featExtractFn = eval_fn_without_vars(...
                '@(im) compute_decaf(standarize_image(im,imConf),featConf)',...
                aux_data);
        else
            aux_data = struct('imConf',imConf);
            featExtractFn = eval_fn_without_vars(...
                '@(im) compute_decaf(standarize_image(im,imConf))',...
                aux_data);
        end
    otherwise,
        error('Feature type: %s not supported.',featType);
end

featCell = cell(1,length(imPathCell));
for ii = 1:length(imPathCell), 
    fprintf('.');
    if mod(ii,50)==0, fprintf(' %d/%d\n',ii,length(imPathCell)); end;
    
    if ~isempty(featDir),
        [~,imName] = fileparts(imPathCell{ii});
        featFilePath = fullfile(featDir,[imName '.mat']);
        if exist(featFilePath,'file'), 
            existingFeatTypes = whos('-file',featFilePath);
            if ismember(featType,{existingFeatTypes.name}), 
                feat = load(featFilePath,featType);
                featCell{ii} = feat.(featType).desc;
                continue;
            end
        end
    end

    desc = featExtractFn(imPathCell{ii});
    desc = desc(:);
    featCell{ii} = desc;
    
    if ~isempty(featDir), 
        [~,imName] = fileparts(imPathCell{ii});
        featFilePath = fullfile(featDir,[imName '.mat']);
        feat = struct();
        feat.desc = desc;
        feat.imConf = imConf;
        if exist('featOpts','var'), feat.featOpts = featOpts; end;
        featWrap.(featType) = feat;
        if exist(featFilePath,'file'), 
            save(featFilePath,'-struct','featWrap','-append');
        else
            save(featFilePath,'-struct','featWrap');
        end
    end
    
    
end

fprintf(' %d/%d \n',length(imPathCell),length(imPathCell));

featMat = cat(2,featCell{:});


function fn = eval_fn_without_vars(fn_str,aux_data)

% unwrap workspace
fields = fieldnames(aux_data);
for i=1:length(fields), 
    eval([fields{i} '= aux_data.' fields{i} ';']);
end
clear aux_data fields i
eval(['fn = ' fn_str ';']);
