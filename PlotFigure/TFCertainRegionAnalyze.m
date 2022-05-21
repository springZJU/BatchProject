function varargout = TFCertainRegionAnalyze(TrialParas,varargin)
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
catch
end

TrialParas([TrialParas.IsArtifact]>0)=[]; % use trials without artifact

CorrectIndex = find(strcmp({TrialParas.CorrectWrong},'Correct'));
WrongIndex = find(strcmp({TrialParas.CorrectWrong},'Wrong'));
PushIndex = find(strcmp({TrialParas.Behav},'Push')&~strcmp({TrialParas.CueType},'control'));
NoPushIndex = find(strcmp({TrialParas.Behav},'NoPush')&~strcmp({TrialParas.CueType},'control'));

PreCorrectIndex = CorrectIndex(CorrectIndex<size(TrialParas,1))+1;
PreWrongIndex = WrongIndex(WrongIndex<size(TrialParas,1))+1;

LowDiffPushIndex = find(strcmp({TrialParas.Behav},'Push')&~strcmp({TrialParas.CueType},'control')&ismember([TrialParas.Diff],[2 3]));
LowDiffNoPushIndex = find(strcmp({TrialParas.Behav},'NoPush')&~strcmp({TrialParas.CueType},'control')&ismember([TrialParas.Diff],[2 3]));
TFcertainZscore = [TrialParas.TFCertainZscore];

for ch=1:ChAll
bufferData = TFcertainZscore(ch,:);
ZscoreSpace = max(bufferData)-min(bufferData);
buffer.trial{ch}.Push = bufferData(PushIndex);
buffer.trial{ch}.NoPush = bufferData(NoPushIndex);
buffer.trial{ch}.PreCorrect = bufferData(PreCorrectIndex);
buffer.trial{ch}.PreWrong = bufferData(PreWrongIndex);
buffer.trial{ch}.Early = bufferData(1:floor(end/2));
buffer.trial{ch}.Late = bufferData(floor(end/2)+1:end);
buffer.trial{ch}.LowDiffPush = bufferData(LowDiffPushIndex);
buffer.trial{ch}.LowDiffNoPush = bufferData(LowDiffNoPushIndex);

if ToPlot ==1
h = figure
set(gcf,'outerposition',get(0,'screensize'));
end
bufferField = fields(buffer.trial{ch});
figorder = [1 5 2 6 3 7 4 8];
for fieldnum = 1:length(bufferField)
if ToPlot ==1
    subplot(2,4,figorder(fieldnum))
    histogram(buffer.trial{ch}.(bufferField{fieldnum}),'BinEdges',[min(bufferData):ZscoreSpace/20:max(bufferData)]); hold on
    Ax = gca;
    plot(ones(2,1)*mean(buffer.trial{ch}.(bufferField{fieldnum})), Ax.YLim,'r-','LineWidth',2);
end
    buffer.mean{ch}.(bufferField{fieldnum}) = mean(buffer.trial{ch}.(bufferField{fieldnum}));
    if mod(fieldnum,2)>0

        panova(fieldnum) = anova1([buffer.trial{ch}.(bufferField{fieldnum}) buffer.trial{ch}.(bufferField{fieldnum+1})],[ones(1,length(buffer.trial{ch}.(bufferField{fieldnum}))) 2*ones(1,length(buffer.trial{ch}.(bufferField{fieldnum+1})))],'off');
        [~,p(fieldnum)] = ttest2(buffer.trial{ch}.(bufferField{fieldnum}),buffer.trial{ch}.(bufferField{fieldnum+1}));
        if ToPlot ==1
        title([bufferField{fieldnum},' n=' num2str(length(buffer.trial{ch}.(bufferField{fieldnum}))),' ttest,p=' num2str(roundn(p(fieldnum),-4)),' anova,p=' num2str(roundn(panova(fieldnum),-4))] );
        xlabel('Zscore ')
        end
    else
        panova(fieldnum) = panova(fieldnum-1);
        p(fieldnum) = p(fieldnum-1);
        if ToPlot ==1
        title([bufferField{fieldnum},' n=' num2str(length(buffer.trial{ch}.(bufferField{fieldnum}))),' ttest,p=' num2str(roundn(p(fieldnum-1),-4)),' anova,p=' num2str(roundn(panova(fieldnum-1),-4))]);
        xlabel('Zscore ')
        end
        buffer.p{ch}.([bufferField{fieldnum} 'vs' bufferField{fieldnum-1}]) = p(fieldnum);
        buffer.panova{ch}.([bufferField{fieldnum} 'vs' bufferField{fieldnum-1}]) = panova(fieldnum);
    end
    



end
if ToPlot == 1
newpath=[savefold '\Timescale' num2str(TimeFrequencyRegion(1,1)) '~' num2str(TimeFrequencyRegion(1,2)) 'Frequency' num2str(TimeFrequencyRegion(2,1)) '~' num2str(TimeFrequencyRegion(2,2))];
figsavepath=check_mkdir_SPR(Savepath,newpath);
saveas(h,[figsavepath  '\' SitePos ' Ch'  num2str(ch) '.jpg']);
close;
end
end
TFcertainZDistribution = buffer;

varargout{1} = TFcertainZDistribution;

