function TrialParas=PEOdd139LabelStr(TrialParas,varargin)

if nargin>1
    for i = 1:2:length(varargin)
        val([ varargin{i} '=varargin{i+1};']);
    end
    eval([GetStructStr(params) '=ReadStructValue(params);']);
end

for Paranum = 1:size(TrialParas,1)
    TrialParas(Paranum).Diff = max([TrialParas(Paranum).FreqDiff TrialParas(Paranum).IntDiff TrialParas(Paranum).DurDiff]);
end


G1Index=find([TrialParas.CueDiff]'==12);
for ind=1:length(G1Index)
TrialParas(G1Index(ind)).CueType='group12';
end

G2Index=find([TrialParas.CueDiff]'==34);
for ind=1:length(G2Index)
TrialParas(G2Index(ind)).CueType='group34';
end

G3Index=find([TrialParas.CueDiff]'==56);
for ind=1:length(G3Index)
TrialParas(G3Index(ind)).CueType='group56';
end

G4Index=find([TrialParas.CueDiff]'==789);
for ind=1:length(G4Index)
TrialParas(G4Index(ind)).CueType='group789';
end


ControlLogic = [TrialParas.FreqDiff]'==1&[TrialParas.IntDiff]'==1&[TrialParas.DurDiff]'==1;
ControlIndex=find(ControlLogic);
for ind=1:length(ControlIndex)
TrialParas(ControlIndex(ind)).CueType='control';
end


PushLogic = [TrialParas.PushTime]'>0;
PushIndex=find(PushLogic);
for ind=1:length(PushIndex)
TrialParas(PushIndex(ind)).Behav='Push';
end


NoPushLogic = [TrialParas.PushTime]'==0;
NoPushIndex=find(NoPushLogic);
for ind=1:length(NoPushIndex)
TrialParas(NoPushIndex(ind)).Behav='NoPush';
end

CorrectLogic = (ControlLogic & NoPushLogic) |((~ControlLogic)&PushLogic);
CorrectIndex = find(CorrectLogic);
for ind=1:length(CorrectIndex)
TrialParas(CorrectIndex(ind)).CorrectWrong='Correct';
end

WrongLogic = ~CorrectLogic;
WrongIndex = find(WrongLogic);
for ind=1:length(WrongIndex)
TrialParas(WrongIndex(ind)).CorrectWrong='Wrong';
end

end