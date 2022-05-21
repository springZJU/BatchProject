function CellParas = ProcessOddIndividualData(Para)
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
params.IndividualSaveFold = [Path '\IndividualResult'];
params.Para = Para;
params.cuetype = 'freq';
params.PushRateRange = PushRateRange;
params.AmMethod = AmMethod;
params.BufferData = CellParas;
params.BufferField = fields(params.BufferData)';


[~,params.ProtocolLogic] = structSelectViaKeyword(params.BufferField,ProtocolStr);
[~,params.RegionLogic] = structSelectViaKeyword(params.BufferData,RegionStr,'fieldName','Region');
params.StructLogic = cellfun(@isstruct,mstruct2cell(params.BufferData));
params.BasicYpos = 0.98;
params.BasicXposSpect = 0.02; params.BasicXposHistogram = 0.4; params.BasicXposScatter = 0.88; params.BasicXposSpike = 0.9;
params.WidthSpect = 0.18; params.WidthHistogram = 0.09; params.WidthScatter = 0.11; params.WidthSpike = 0.11;
%% 不同细胞在主/被动行为下特定频谱区域能量的比较， one channel one figure
if toAnalyseLFP % analyse LFP data
    
for Ch1=1:PlotCh:ChAll(end)
plotpara=SetPlotPara('PlotType',3,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Cscale','auto_semiequalCLim','PlotWin',[-2 3.5],...
                    'RootDisk','F:\','ylinepos',[0:0.5:3.5],'Diff',1,'savefold','F:\gym\batchres\IndividualData','ToPlot',1);
PlotTFRegionInf('params',params,'plotpara',plotpara,'Para',Para);
end
end

%% Plot population spike analysis result
if toAnalyseSpike % analyse spike data
[popPlotData.spikeRes params] = SpikeResPopulation('params',params);
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


