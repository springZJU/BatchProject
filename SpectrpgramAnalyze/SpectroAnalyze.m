function [TrialParas Spect ]=SpectroAnalyze(TrialParas,FsRaw,SpectroMethod,FsNew,varargin)
tic
TRIAL=1:size(TrialParas,1);
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
catch
end

Ymin=[];

for Paranum=TRIAL
for chs=1:ChAll
buffer=TrialParas(Paranum).Lfpdata;
[P,Q] = rat(FsNew/FsRaw);
bufferResample = (resample(buffer',P,Q))';
switch SpectroMethod
    case 'morse'
    [wt,f,coi] =cwt(bufferResample(chs,:),'morse',FsNew);
    case 'morlet'
    [wt,f,coi] =cwt(bufferResample(chs,:),'amor',FsNew);
    case 'bump'
    [wt,f,coi] =cwt(bufferResample(chs,:),'bump',FsNew);   
    case 'STFT'
        spectrogram
end

Spectbuffer.YData = f;
Spectbuffer.XData = (1:size(bufferResample,2))/FsNew;
Spectbuffer.CData = abs(wt);
Spectbuffer.Coi=coi;

Spectbuffer = downsampleSpect(Spectbuffer,'FsNew',DownSampleRate);

Spect.FsScale=Spectbuffer.YData;
Spect.CData{chs}=Spectbuffer.CData;
Spect.Timescale=Spectbuffer.XData;
Spect.Coi=Spectbuffer.Coi;

end

TrialParas(Paranum).Spectrum.Coi=Spect.Coi;
TrialParas(Paranum).Spectrum.XData=Spect.Timescale;
TrialParas(Paranum).Spectrum.YData=Spect.FsScale;
TrialParas(Paranum).Spectrum.CData=Spect.CData;


TrialParas(Paranum).SpecYlength=length(Spect.FsScale);
end
toc
end
