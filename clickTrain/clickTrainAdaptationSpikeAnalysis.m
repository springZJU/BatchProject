function varargout = clickTrainAdaptationSpikeAnalysis(rez,varargin)

for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

rezBuffer = struct2cell(rez.frate);
ICIFields = fields(rez.frate);

for num = 1:length(rezBuffer{1,1}) %% split trials into different groups accoring to soundNum
frateBuffer = cellfun(@(x) x{num},rezBuffer,'UniformOutput',false);
frateBuffer2{num} = cell2mat(cellfun(@(x) x{2},frateBuffer,'UniformOutput',false));
end
frate = mergeSameSizeDoubleTypeCell(frateBuffer2);
meanFrate = cellfun(@mean,frate);
stdFrate = cellfun(@std,frate)/sqrt(num);

%% restruct firing rate and SE for click train adaptation 
frateSE = cellfun(@(x) [mean(x) std(x)/sqrt(num)],frate,'UniformOutput',false);
rez.frate = easyStruct(ICIFields,frateSE');

%% restruct spike raster for click train adaptation
rasterBuffer = struct2cell(rez.raster)';
raster = cellfun(@(x) cell2mat(x'),rasterBuffer,'UniformOutput',false);
rez.raster = easyStruct(ICIFields,raster);

%% restruct psth for click train adaptation
psthBuffer = cellfun(@(x) calPsth(x(:,1),optPSTH,1000,'edge',[0 300]),raster,'UniformOutput',false);
rez.psth = easyStruct(ICIFields,psthBuffer);

%% calculate adaptation slope
for ch = 1:size(meanFrate,2)
    [slope(ch,1),~,~,~,~,p(ch,1)] = regress_perp(ICIs/1000,meanFrate(:,ch));
end

varargout{1} = easyStruct({'slope','p','mean','SE','rawdata'},[num2cell(slope), num2cell(p), array2VectorCell(meanFrate'), array2VectorCell(stdFrate'), mergeCellToOneCol(frate')]);