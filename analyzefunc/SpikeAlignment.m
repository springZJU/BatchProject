function TrialParas = SpikeAlignment(TrialParas,varargin)
tic 
TRIAL=1:size(TrialParas,1);
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
catch
end


for Paranum = TRIAL
    TrialBuffer = TrialParas(Paranum);
%% Different Alignments
ParaFields = fields(TrialParas);
AlignmentStr = {'Std1Onset','DevOnset','DevOffset','Pushtime'}; % maybe transportable via Para
for alignN = 1:length(AlignmentStr)
    switch AlignmentStr{alignN}
        case 'Std1Onset'
            if ~isempty(TrialBuffer.Spikesort)
            AlignmentSpikeSort.(AlignmentStr{alignN}) = (TrialBuffer.Spikesort - TrialBuffer.Std1Time)*1000;
            end
            AlignmentSpikeRaw.(AlignmentStr{alignN}) = (TrialBuffer.Spikeraw - TrialBuffer.Std1Time)*1000;    
        case 'DevOnset'
            if ~isempty(TrialBuffer.Spikesort)
            AlignmentSpikeSort.(AlignmentStr{alignN}) = (TrialBuffer.Spikesort - TrialBuffer.DevTime)*1000;
            end
            AlignmentSpikeRaw.(AlignmentStr{alignN}) = (TrialBuffer.Spikeraw - TrialBuffer.DevTime)*1000;    
        case 'DevOffset'
            DevOfftime = TrialBuffer.DevTime+TrialBuffer.DurBase*TrialBuffer.DurDiff/1000;
            if ~isempty(TrialBuffer.Spikesort)
            AlignmentSpikeSort.(AlignmentStr{alignN}) = (TrialBuffer.Spikesort - DevOfftime)*1000;
            end
            AlignmentSpikeRaw.(AlignmentStr{alignN}) = (TrialBuffer.Spikeraw - DevOfftime)*1000;
        case 'Pushtime'
            Pushtime = TrialBuffer.DevTime+TrialBuffer.PushTime/1000;
            if ~isempty(TrialBuffer.Spikesort)
            AlignmentSpikeSort.(AlignmentStr{alignN}) = (TrialBuffer.Spikesort - Pushtime)*1000;
            end
            AlignmentSpikeRaw.(AlignmentStr{alignN}) = (TrialBuffer.Spikeraw - Pushtime)*1000;
    end
end
TrialParas(Paranum).AlignmentSpikeRaw = AlignmentSpikeRaw;
try
TrialParas(Paranum).AlignmentSpikeSort = AlignmentSpikeSort;
catch
end
end 