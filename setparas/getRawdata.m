function [lfp,spike,sortdata,chs,FsNew] = getRawdata(datapath,params)
eval([GetStructStr(params) '=ReadStructValue(params);']);

load(datapath);
rawdata=double(data.lfp.data)*10^6;
FsRaw=data.lfp.fs;
buffer=rawdata;
chs = 1 : length(size(rawdata,1));
[P,Q] = rat(FsNew/FsRaw);
bufferResample = (resample(buffer',P,Q))';
bufferResample = iircombfilter(bufferResample,50,45,FsNew);
lfp.rawdata=bufferResample;
lfp.fs=FsNew;
lfp.T=(0:1:length(lfp.rawdata)-1)*1000/lfp.fs;
clear rawdata



if isfield(data,'sortdata')
    sortbuffer=data.sortdata;
    chs = unique(sortbuffer(:,2))+1;
    for ch = chs'
        sortdata{ch,1} = sortbuffer(sortbuffer(:,2) == ch-1 , 1);
    end
    spike=[];
else
    sortdata=[];
    if isfield(data,'spike')
        spikeBuffer = data.spike;
        for ch = 1:size(lfp.rawdata,1)
            spike{ch,1} = spikeBuffer(spikeBuffer(:,2) == ch-1 , 1);
        end
    else
        spike=[];
    end
    
end

end