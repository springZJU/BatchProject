function varargout = clickTrianSpikeThroughICI(rez,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

rezBuffer = struct2cell(rez.frate);

switch protocolName
    case 'ClickTrain'
        numAll = 1;
    case 'ClickTrainAdaptation'
        numAll = length(rezBuffer{1});
end
for num = 1:numAll%% split trials into different groups accoring to soundNum
    % if frateBuffer{1,1} is still cell type, that means clickTrainAdaptation protocol
    if iscell(rezBuffer{1}{1})
        frateBuffer = cellfun(@(x) x{num},rezBuffer,'UniformOutput',false);
    else
        frateBuffer = rezBuffer;
    end
    %% spearman rank correlation coefficience

    fRate = cellfun(@(x) x{2},frateBuffer,'UniformOutput',false);

    % add click rate for each frate
    for iciN = 1:size(frateBuffer,1)
        spearmanBuffer(iciN,:) = cellfun(@(x) [x' ones(length(x),1)*round(1000/ICIs(iciN))],fRate(iciN,:),'UniformOutput',false);
    end

    % integrate into each channel and calculate spearman rank correlation coefficience
    for ch = 1:size(spearmanBuffer,2)
        spearman{ch,num} = cell2mat(spearmanBuffer(:,ch));
        [coeff(ch,num),p(ch,num)] = corr(spearman{ch,num}(:,1),spearman{ch,num}(:,2),'type','Spearman');
    end

    %% frate slope

    meanFrate = cellfun(@(x) x{1}(1),frateBuffer,'UniformOutput',false);

    % add click rate for each mean frate
    for iciN = 1:size(frateBuffer,1)
        slopeDataBuffer(iciN,:) = cellfun(@(x) [x' ones(length(x),1)*round(1000/ICIs(iciN))],meanFrate(iciN,:),'UniformOutput',false);
    end

    % integrate into each channel
    for ch = 1:size(slopeDataBuffer,2)
        slopeData{ch,1} = cell2mat(slopeDataBuffer(:,ch));
    end

    % linear interpolation
    repeatRate = round(1000./ICIs);
    xInterp = [min(repeatRate):1:max(repeatRate)]';
    interpData = [cellfun(@(x) [interp1(x(:,2),x(:,1),xInterp,'linear') xInterp],slopeData,'UniformOutput',false) ] ;
    [fitSlope(:,num), ~, ~, ~, ~, fitPvalue(:,num)] = cellfun(@(x) regress_perp(x(:,2),x(:,1)),interpData,'UniformOutput',false);

end

%% integrate spearman rank correlation coefficience and linear interpolation slope
spearmanRes = easyStruct({'coeff';'p';'rawdata'},[array2VectorCell(coeff), array2VectorCell(p), mergeCellToOneCol(spearman)]);
slopeRes = easyStruct({'slope','p'},[mergeCellToOneCol(fitSlope), mergeCellToOneCol(fitPvalue)]);

%% set output
varargout{1} = spearmanRes;
varargout{2} = slopeRes;
