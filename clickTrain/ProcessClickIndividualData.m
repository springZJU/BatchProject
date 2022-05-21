function CellParas = ProcessClickIndividualData(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
if ~autoBatch % automatic batch or not
    [Filename,Path] = uigetfile();
    load([Path Filename]);
else
    Path = regexpi(IndividualDataPath,'.*\','match');
    Path = Path{1}(1:end-1);
    load(IndividualDataPath);
end


CellAll = IndividualData;
% EvalStructureSelect = EvalCellParaStr('CellAll');
% eval(EvalStructureSelect);
CellParas = CellAll;
params.IndividualSaveFold = check_mkdir_SPR(Path ,'IndividualResult');
params.Para = Para;
params.BufferData = CellParas;
params.BufferField = fields(params.BufferData)';

[~,params.ProtocolLogic] = structSelectViaKeyword(params.BufferField,ProtocolStr);
[~,params.RegionLogic] = structSelectViaKeyword(params.BufferData,RegionStr,'fieldName','Region');
params.StructLogic = cellfun(@isstruct,struct2cell(params.BufferData)');

%% 
% if toAnalyseLFP % analyse LFP data
% 
% end

%% Plot population spike analysis result
if toAnalyseSpike % analyse spike data
[popPlotData.spikeRes params] = ClickSpikeResPopulation('params',params);
end

%% population behavioral analysis
if toAnalyseBehavior % analyse behavior

%Decision variation in confused conditions, behavioral analysis
IndividualData = DecisionVariationAnalysis('params',params);
save([Path Filename],'IndividualData');
%other behavior analysis
[popPlotData.behavRes params] = behavResPopulation('params',params);

end

end


