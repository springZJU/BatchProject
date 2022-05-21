function ProcessClickTrainSSAIndividualData(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
if ~autoBatch % automatic batch or not
    [Filename,Path] = uigetfile();
    load([Path Filename]);
else
    Path = regexpi(IndividualDataPath,'.*\','match');
    Path = Path{1}(1:end-1);
    load(IndividualDataPath);
end

params.IndividualSaveFold = [Path '\IndividualResult'];

%% Plot population spike analysis result
if toAnalyseSpike % analyse spike data

% popRes = SpikeResPopulation(IndividualData);
ClickSpikeResPopulation
end

%% 不同细胞在主/被动行为下特定频谱区域能量的比较， one channel one figure
% if toAnalyseLFP % analyse LFP data
%     
% for Ch1=1:PlotCh:ChAll(end)
% plotpara=SetPlotPara('PlotType',3,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Cscale','auto_semiequalCLim','PlotWin',[-2 3.5],...
%                     'RootDisk','F:\','ylinepos',[0:0.5:3.5],'Diff',1,'savefold','F:\gym\batchres\IndividualData','ToPlot',1);
% PlotTFRegionInf('params',params,'plotpara',plotpara,'Para',Para);
% end
% end



%% population behavioral analysis
if toAnalyseBehavior % analyse behavior
%Decision variation in confused conditions, behavioral analysis
IndividualData = DecisionVariationAnalysis('params',params);
save([Path Filename],'IndividualData');
%other behavior analysis
[popPlotData.behavRes params] = behavResPopulation('params',params);
end

end


