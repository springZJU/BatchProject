function CellParas = ProcessIndividualData(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
[Filename,Path] = uigetfile();
load([Path Filename]);
CellAll = IndividualData;
EvalStructureSelect = EvalCellParaStr('CellAll');
eval(EvalStructureSelect);
params.cuetype = 'dur';
params.PushRateRange = PushRateRange;
params.AmMethod = AmMethod;
params.BufferData = CellParas;
params.BufferField = fields(params.BufferData);
params.ProtocolLogic = contains(params.BufferField',ProtocolStr);
params.StructLogic = cellfun(@isstruct,struct2cell(params.BufferData)');
params.BasicYpos = 0.98;
params.BasicXposSpect = 0.02; params.BasicXposHistogram = 0.4; params.BasicXposScatter = 0.88; params.BasicXposSpike = 0.9;
params.WidthSpect = 0.18; params.WidthHistogram = 0.09; params.WidthScatter = 0.11; params.WidthSpike = 0.11;
% %% 不同细胞在主/被动行为下特定频谱区域能量的比较， one channel one figure
% for Ch1=1:PlotCh:ChAll(end)
% plotpara=SetPlotPara('PlotType',3,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Cscale','auto_semiequalCLim','PlotWin',[-2 3.5],...
%                     'RootDisk','F:\','ylinepos',[0:0.5:3.5],'Diff',1,'savefold','F:\gym\batchres\IndividualData','ToPlot',1);
% PlotTFRegionInf('params',params,'plotpara',plotpara,'Para',Para);
% end

%% Decision variation in confused conditions
IndividualData = DecisionVariationAnalysis('params',params);
save([Path Filename],'IndividualData');

end


