function varargout = SelectPushAverageSpectThr(TrialParas,varargin)
if ~isfield(TrialParas,'Spectrum')
    disp('TrialParas does not include field ''Spectrum''');
    return
end
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);

catch
end
TimeUpperLater(1)=TrialParas(1).StdSelect-TrialParas(1).Std1Time;
Tmove=TimeUpperLater(1); %std onset

%% Mean power of selected field



for Paranum = 1:size(TrialParas,1)

    for chs=1:ChAll
    CData = TrialParas(Paranum).Spectrum.CData{chs};
    XData = TrialParas(Paranum).Spectrum.XData+Tmove;
    YData = TrialParas(Paranum).Spectrum.YData;

    Coi = TrialParas(Paranum).Spectrum.Coi;
    for Xnum = 1:length(Coi)
    ReliableInd(:,Xnum) = YData>Coi(Xnum);
    end
    double(ReliableInd);
    CData = CData.*ReliableInd;
    XInd = find(XData>=TimeFrequencyRegion(1,1)&XData<=TimeFrequencyRegion(1,2));
    YInd = find(YData>=TimeFrequencyRegion(2,1)&YData<=TimeFrequencyRegion(2,2));
    XBackInd = find(XData>=BackgroundRegion(1,1)&XData<=BackgroundRegion(1,2));
    CBackground = CData(:,XBackInd);
    CBuffer = CData(YInd,XInd);
    CMean = mean(mean(CBuffer));
    TrialParas(Paranum).TFCertainRegion(chs,1) = CMean;
    TrialParas(Paranum).TFCertainVisibility(chs,1) = CMean/max(max(CBackground));
    end

end


%% Zscore of TFCertain
bufferRaw = [TrialParas.TFCertainRegion];
bufferMean = mean(bufferRaw,2);
bufferStd = std(bufferRaw,1,2);
for chs = 1:ChAll
bufferZscore = (bufferRaw(chs,:)-bufferMean(chs))/bufferStd(chs);
for Paranum = 1:size(TrialParas,1)
TrialParas(Paranum).TFCertainZscore(chs,1) = bufferZscore(Paranum);
TrialParas(Paranum).TFRegionSelect = TimeFrequencyRegion;
end



varargout{1} = TrialParas;
end

