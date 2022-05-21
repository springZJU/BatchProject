function Spect = clickTrainSpectroAnalyze(lfpData,FsRaw,SpectroMethod,FsNew,varargin)
% example: clickTrainSpectroAnalyze(lfpData,2000,'morlet',300);
% imagesc('XData',Spect.Timescale*1000,'YData',Spect.FsScale,'CData',Spect.CDataMean);hold on;
% plot(Spect.Timescale*1000,Spect.Coi,'w--','LineWidth',1); hold on;
% tic

nTrials = size(lfpData,1);
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end


for trialN = 1 : nTrials

buffer=lfpData(trialN,:); % lfp waveform of certain trial
[P,Q] = rat(FsNew/FsRaw);
bufferResample = (resample(buffer',P,Q))';
switch SpectroMethod
    case 'morse'
    [wt,f,coi] =cwt(bufferResample,'morse',FsNew);
    case 'morlet'
    [wt,f,coi] =cwt(bufferResample,'amor',FsNew);
    case 'bump'
    [wt,f,coi] =cwt(bufferResample,'bump',FsNew);   
    case 'STFT'
        spectrogram
end

Spectbuffer.YData = f;
Spectbuffer.XData = (1:size(bufferResample,2))/FsNew;
Spectbuffer.CData = abs(wt);
Spectbuffer.Coi=coi;
DownSampleRate = 30;
Spectbuffer = downsampleSpect(Spectbuffer,'FsNew',DownSampleRate);

Spect.FsScale=Spectbuffer.YData;
Spect.CData{trialN}=Spectbuffer.CData;
Spect.Timescale=Spectbuffer.XData;
Spect.Coi=Spectbuffer.Coi;

end

Spect.CDataMean = cell2mat(cellSum(Spect.CData))/nTrials;

% toc
end


function Spect = downsampleSpect(Spect,varargin)
FsNew = 30;
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
CData = Spect.CData;
Coi = Spect.Coi;
XData = Spect.XData;

FsRaw = 1/(XData(2)-XData(1));
[P,Q] = rat(FsNew/FsRaw);

Spect.CData = (resample(CData',P,Q))';

if size(Coi,1)==1
    Coi = Coi';
end
Spect.Coi = resample(Coi,P,Q);

if size(XData,1)==1
    XData = XData';
end
Spect.XData = resample(XData,P,Q);
end

function res = cellSum(data,varargin)
    [m , n] = size(data);
    if n == 1
        direction = 1; % 1: m*n to 1*n | 2: m*n to m*1
    else
        direction = 2; % 1: m*n to 1*n | 2: m*n to m*1
    end

    for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
    end
    
    
    switch direction
        case 1
            for i = 1 : n
                res{1 , i} = zeros(size(data{1}));
                for j = 1 : m
                    res{1 , i} = res{1 , i} + data{i , j};
                end
            end
        case 2
            for i = 1 : m
                res{i , 1} = zeros(size(data{1}));
                for j = 1 : n
                    res{i , 1} = res{i , 1} + data{i , j};
                end
            end
        case 0
            res{1 , 1} = zeros(size(data{1}));
            for i = 1 : m
                for j = 1 : n
                    res{1 , 1} = data{i , j};
                end
            end
    end
end
                
    
    
    


