function TrialParas = SelectArtifacts(TrialParas,varargin)
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
    eval([GetStructStr(params) '=ReadStructValue(params);']);
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
catch
end

try
    ArtifactScale = 4;
    %% Find artifact based on trial itself
    for Paranum = 1:size(TrialParas,1)
        bufferlfp = TrialParas(Paranum).Lfpdata(end,:);
        CurlfpSTD = std(bufferlfp);
        bufferOverSTD = find(abs(bufferlfp)>(mean(bufferlfp)+ArtifactScale*CurlfpSTD));
        if length(bufferOverSTD)>=50
            TrialParas(Paranum).IsArtifact = 1;
        else
            TrialParas(Paranum).IsArtifact = 0;
        end
    end

    %% Find artifact based on baseline——whole period FRA
    FRALfp = load(datampath);
    rawdata=double(FRALfp.data.lfp.data)*10^6;
    FsRaw = FRALfp.data.lfp.fs;
    FsNew = 1200;
    [P,Q] = rat(FsNew/FsRaw);
    bufferResample = (resample(rawdata',P,Q))';


    for Paranum = 1:size(TrialParas,1)
        bufferPE = TrialParas(Paranum).Lfpdata;
        SDFRA = std(bufferResample(end,:));
        SDPE = std(bufferPE(end,:));
        if SDPE > ArtifactScale*SDFRA
            TrialParas(Paranum).IsArtifact = TrialParas(Paranum).IsArtifact+2;
        else
            TrialParas(Paranum).IsArtifact = TrialParas(Paranum).IsArtifact+0;
        end
    end
catch
    for Paranum = 1:size(TrialParas,1)
            TrialParas(Paranum).IsArtifact = TrialParas(Paranum).IsArtifact+0;
    end
end
end