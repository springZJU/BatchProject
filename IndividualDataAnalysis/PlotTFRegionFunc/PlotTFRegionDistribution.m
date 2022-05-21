function PlotTFRegionDistribution(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
eval([GetStructStr(params) '=ReadStructValue(params);']);
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
for protypes = 1:length(ActiveProtocolTypes)
    PlotDataPath = strrep(BufferData(cellnum).(ActiveProtocolTypes{protypes}).PlotDataPath,'F:\',RootDisk);
    TFPlot{1} = load(PlotDataPath);
    TrialParasPath = strrep(BufferData(cellnum).(ActiveProtocolTypes{protypes}).TrialParasPath,'F:\',RootDisk);
    load(TrialParasPath);
    TFcertainRegion = [TrialParas.TFCertainRegion];
    bufferRawData = TFcertainRegion(ch,:);
    TFcertainZscore = [TrialParas.TFCertainZscore];
    bufferData = TFcertainZscore(ch,:);
    ZscoreSpace = max(bufferData)-min(bufferData);
    try
        Distribution = TFPlot{1}.PlotData.TFcertainZDistribution;
        DisFields = fields(Distribution.trial{ch});
        CompareType = [DisFields(1:2:end) DisFields(2:2:end)];
    catch
        continue
    end
    for TFnum = 1:size(CompareType,1)
        for Behavnum = 1:2
            subplot('Position',[BasicXposHistogram+(TFnum-1)*(WidthHistogram+0.005) BasicYpos-((protypes-1)*2+Behavnum)*(HeightHistogram+0.04) WidthHistogram HeightHistogram])
            AxHistrogram{(protypes-1)*2+Behavnum,TFnum}=gca;
            histogram(Distribution.trial{ch}.(CompareType{TFnum,Behavnum}),'BinEdges',[min(bufferData):ZscoreSpace/10:max(bufferData)]); hold on
            Ax = gca;
            plot(ones(2,1)*Distribution.mean{ch}.(CompareType{TFnum,Behavnum}), Ax.YLim,'r-','LineWidth',2);

            pfields = fields(Distribution.p{ch});
            %           title([CompareType{TFnum,Behavnum},' n=' num2str(length(Distribution.trial{ch}.(bufferField{fieldnum}))),' ttest,p=' num2str(roundn(p(fieldnum-1),-4)),' anova,p=' num2str(roundn(panova(fieldnum-1),-4))]);
            title([CompareType{TFnum,Behavnum},' n=' num2str(length(Distribution.trial{ch}.(CompareType{TFnum,Behavnum}))),' p=' num2str(roundn(Distribution.p{ch}.(pfields{TFnum}),-4))]);
%             if ~(protypes==length(ActiveProtocolTypes) & Behavnum==2)
%                 set(gca,'XTickLabel','');
%             end
        end
    end
    %     try
    Active = {'Active','Passive'};
    TrialParasPath2 = strrep(BufferData(cellnum).(PassiveProtocolTypes{protypes}).TrialParasPath,'F:\',RootDisk);
    TrialParas2 = load(TrialParasPath2);
    TrialParas2 = TrialParas2.TrialParas;
    TFcertainRegion2 = [TrialParas2.TFCertainRegion];
    bufferRawData2 = TFcertainRegion2(ch,:);
    TFcertainZscore2 = [TrialParas2.TFCertainZscore];
    bufferData2 = TFcertainZscore2(ch,:);
    bufferRawData1 = bufferRawData(strcmp({TrialParas.Behav},'NoPush'));
    bufferAll = [bufferRawData1 bufferRawData2];
    bufferZAll = (bufferAll-mean(bufferAll))/std(bufferAll);
    bufferZData{1} = (bufferRawData1-mean(bufferAll))/std(bufferAll);
    bufferZData{2} = (bufferRawData2-mean(bufferAll))/std(bufferAll);
    ZscoreSpace = max(bufferZAll)-min(bufferZAll);
    [~,p] = ttest2(bufferZData{1},bufferZData{2});
    for Behavnum = 1:2
        subplot('Position',[BasicXposHistogram+(TFnum)*(WidthHistogram+0.005) BasicYpos-((protypes-1)*2+Behavnum)*(HeightHistogram+0.04) WidthHistogram HeightHistogram])
        histogram(bufferZData{Behavnum},'BinEdges',[min(bufferZAll):ZscoreSpace/10:max(bufferZAll)]); hold on
        Ax = gca;
        plot(ones(2,1)*mean(bufferZData{Behavnum}), Ax.YLim,'r-','LineWidth',2);
        title([Active{Behavnum},' n=' num2str(length(bufferZData{Behavnum})),' p=' num2str(roundn(p,-4))]);
%         if ~(protypes==length(ActiveProtocolTypes) & Behavnum==2)
%             set(gca,'XTickLabel','');
%         end
    end
end




