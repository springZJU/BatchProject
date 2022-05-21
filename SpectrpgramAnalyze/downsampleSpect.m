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



