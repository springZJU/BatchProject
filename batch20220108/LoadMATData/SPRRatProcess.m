function SPRRatProcess(varargin)
if nargin>=2
    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    try
        eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    catch
    end
end
load(datapath);
%% down samplerate
rawdata = double(data.lfp.data)*10^6;
FsRaw = data.lfp.fs;
buffer=rawdata;
[P,Q] = rat(FsNew/FsRaw);
bufferResample = (resample(buffer',P,Q))';
bufferResample = iircombfilter(bufferResample,50,45,FsNew);
TrialParas.Lfpdata=bufferResample;
TrialParas.FsRaw = FsNew;

TrialParas.Spikeraw = data.spike;
TrialParas.SoundTime = data.epocs.Swep.onset;
savepath = erase(datapath,'data.mat');
Para.savepath = savepath;

RatSPRLfpAnalyze(TrialParas,'Para',Para);
% TrialParas = RatSPRSpikeAnalyze(TrialParas,'Para',Para,'NeuWin',[0 100]);
save([savepath '\TrialParas.mat'],'TrialParas');
end
