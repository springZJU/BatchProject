function [MeanRes ResX  FinalInd WaveSingle]=CalMeanWaveRes(TrialParas,cue,diff,Push,ResType,PlotWin,varargin)
CType=' ';
MMN=0;
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

TimeUpperLater(1)=TrialParas(1).StdSelect-TrialParas(1).Std1Time;




if diff==1
    cue='control';
end
switch Push
    case 'Push'
        PushInd=find([TrialParas.PushTime]'>0);
    case 'NoPush'
        PushInd=find([TrialParas.PushTime]'==0);
    case 'All'
        PushInd=find([TrialParas.PushTime]'>=0);
end
cuetypes={TrialParas.CueType}';
if find(strcmp(cuetypes,cue))
    CueInd=find(strcmp(cuetypes,cue));
else
    CueInd=1:length(cuetypes);
end
% DiffInd=find([TrialParas.FreqDiff]'==diff|[TrialParas.IntDiff]'==diff);
DiffInd=find(ismember([TrialParas.FreqDiff]',diff)|ismember([TrialParas.IntDiff]',diff));
IndBuffer=intersect(PushInd,CueInd);
FinalInd=intersect(IndBuffer,DiffInd);
%取spectrum平均

if ~isempty(FinalInd)
    for chs=1:ChAll
        trialcount=0;
        for Trialnum=1:length(FinalInd)
            trialcount = trialcount+1;
            switch ResType
                case 'Align2Std1Onset'
                    Tmove=TimeUpperLater(1); %std onset对齐
                case 'Align2DevOnset'
                    Tmove=TimeUpperLater(1)-TrialParas(FinalInd(Trialnum)).DevTime+TrialParas(FinalInd(Trialnum)).Std1Time; %dev onset对齐
                case 'Align2Push'
                    Tmove=TimeUpperLater(1)-TrialParas(FinalInd(Trialnum)).DevTime+TrialParas(FinalInd(Trialnum)).Std1Time-TrialParas(FinalInd(Trialnum)).PushTime/1000; %push对齐
            end
                
                if ChAll ==1
                    Databuffer=TrialParas(FinalInd(Trialnum)).Lfpdata;
                else
                Databuffer=TrialParas(FinalInd(Trialnum)).Lfpdata(chs,:);
                end
                
                if MMN==1
%                     Tmove_Std1=TimeUpperLater(1); %std onset对齐
%                     Tmove_Dev=TimeUpperLater(1)-TrialParas(FinalInd(Trialnum)).DevTime+TrialParas(FinalInd(Trialnum)).Std1Time; %dev onset对齐
                    TLfp = (1:size(Databuffer,2))/TrialParas(FinalInd(Trialnum)).FsRaw;
                    Timescale=TLfp+Tmove;
                    [DataResDev ResXDev IndexDev]=GetAlignRes(Databuffer,PlotWin,Timescale);
                    SoundTime = TrialParas(FinalInd(Trialnum)).SoundTime;
                    ISI = SoundTime(end) - SoundTime(end-1);
                    [DataResStd0 ResXStd0 IndexStd0]=GetAlignRes(Databuffer,PlotWin-ISI,Timescale);
                    try
                    DataRes=DataResDev-DataResStd0;
                    ResX=ResXDev;
                    WaveSingle{Trialnum,chs}=DataRes;

                    catch
                        DataRes=[];
                    end
                else
                    TLfp = (1:size(Databuffer,2))/TrialParas(1).FsRaw;
                    Timescale=TLfp+Tmove;
                    [DataRes ResX Index]=GetAlignRes(Databuffer,PlotWin,Timescale);
                    WaveSingle{Trialnum,chs}=DataRes;

                end
                    
                    
            if Trialnum==1|trialcount==1
                try
                WaveBuffer=DataRes;
                catch
                    trialcount=trialcount-1;
                end
            else
                try
                WaveBuffer=WaveBuffer+DataRes;
                catch
                    trialcount=trialcount-1;
                end
            end
        end
        
        

        MeanRes{chs}=WaveBuffer/trialcount;
    end
else
    MeanRes=[];
    FinalInd=[];
    ResX=[];

    
end

end

