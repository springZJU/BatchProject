function varargout=PlotTypes(TrialParas,varargin)
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
catch
end
try
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
catch
end



switch PlotType
    case 1
        [varargout{1}  varargout{2} varargout{3}]=ChannelDiffInFigureSpect(TrialParas,plotpara,Savepath);
    case 2
        varargout{1}=SingleTrialPlotSpect(TrialParas,plotpara,Savepath);
    case 3
        [varargout{1} varargout{2}]=StandardAverageSpect(TrialParas,plotpara,Savepath);
    case 4
        [varargout{1}  varargout{2} varargout{3}]=CalculateMMNSpect(TrialParas,plotpara,Savepath);
    case 5
        [varargout{1}] = TFCertainRegionAnalyze(TrialParas,'Para',Para,'plotpara',plotpara,'Savepath',Savepath);
    case 6
        RawDataResultByTrial(TrialParas,'Para',Para,'plotpara',plotpara,'Savepath',Savepath);
    case 13
        [varargout{1} varargout{2}] = StandardAverageWave(TrialParas,plotpara,Savepath);
    case 1000
        [varargout{1} varargout{2}]=RatSPRNoiseSpect(TrialParas,plotpara,Savepath);
    case 1001
        [varargout{1} varargout{2}]=RatSPRNoiseWave(TrialParas,plotpara,Savepath);
    case 1002
        RatSPRNoiseSpike(TrialParas,plotpara,Savepath);

end
end
