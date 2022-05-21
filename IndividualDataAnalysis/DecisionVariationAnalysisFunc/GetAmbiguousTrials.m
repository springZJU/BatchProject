function AmbiguousTrials = GetAmbiguousTrials(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

Diff = unique([TrialParas.Diff]);
CueType = unique({TrialParas.CueType});
DiffCueType = CueType(~strcmp(CueType,'control'));
typenums = length(DiffCueType);

if ~any([TrialParas.Ambiguous]==1)
    AmbiguousTrials = []; % no ambiguous trials
else
    AmbiguousTrials.All = TrialParas([TrialParas.Ambiguous]==1);
    for m = 1:typenums
        AmbiguousTrials.(DiffCueType{m}) = TrialParas(strcmp({TrialParas.CueType},DiffCueType{m})&[TrialParas.Ambiguous]==1);
    end
end
end


