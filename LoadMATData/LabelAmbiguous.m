function TrialParas = LabelAmbiguous(TrialParas,method,varargin)
range = [0.4 0.6];
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
try
    eval([GetStructStr(params) '=ReadStructValue(params);']);
    range = PushRateRange;
catch
end
try
Diff = unique([TrialParas.Diff]);
catch
    Diff = unique([TrialParas.Diffnum]);
end
CueType = unique({TrialParas.CueType});
DiffCueType = CueType(~strcmp(CueType,'control'));
typenums = length(DiffCueType);

for m = 1:typenums
% get Pushrate
    for n = Diff
        if n == 1
            Ind{n} = find([TrialParas.Diff]==n);
        else
            Ind{n} = find(strcmp({TrialParas.CueType},DiffCueType{m})&[TrialParas.Diff]==n);
        end
        Stim = TrialParas(Ind{n});
        Push = Stim(strcmp({Stim.Behav},'Push'));
        PushRate(m,n) = size(Push,1)/size(Stim,1);
    end
% select ambiguous trials according to pushraterange(null res is permitted)
    switch method
        case 'PushRateRange'
            for n = Diff
                if PushRate(m,n)>range(1) & PushRate(m,n)<range(2)
                    for i = 1:length(Ind{n})
                        TrialParas(Ind{n}(i)).Ambiguous = 1;
                    end
                else
                    for i = 1:length(Ind{n})
                        TrialParas(Ind{n}(i)).Ambiguous = 0;
                    end
                end
            end
% always return the most ambiguous condition 
        case 'Closest'
            [~,n]   = min(abs(PushRate(m,:)-0.5));
            for i = 1:size(TrialParas,1)
                TrialParas(i).Ambiguous = 0;
            end
            Ind1 = find([TrialParas.Diff] == n);
            for i = 1:length(Ind1)
                TrialParas(Ind1(i)).Ambiguous = 1;
            end
    end
end



end


