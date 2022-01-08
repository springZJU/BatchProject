function [MeanRes ResX FsScale Coi FinalInd  SpectSingle ]=CalMeanSpecRes(TrialParas,cue,diff,Push,ResType,Ymin,PlotWin,varargin)
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
                if strcmp({'dB'},CType)
                Databuffer=20*log10(TrialParas(FinalInd(Trialnum)).Spectrum.CData{chs});
                else
                Databuffer=TrialParas(FinalInd(Trialnum)).Spectrum.CData{chs};
                end
                if MMN==1
%                     Tmove_Std1=TimeUpperLater(1); %std onset对齐
%                     Tmove_Dev=TimeUpperLater(1)-TrialParas(FinalInd(Trialnum)).DevTime+TrialParas(FinalInd(Trialnum)).Std1Time; %dev onset对齐
                    Timescale=TrialParas(FinalInd(Trialnum)).Spectrum.XData+Tmove;
                    [DataResDev ResXDev IndexDev]=GetAlignRes(Databuffer,PlotWin,Timescale);
                    SoundTime = TrialParas(FinalInd(Trialnum)).SoundTime;
                    ISI = SoundTime(end) - SoundTime(end-1);
                    [DataResStd0 ResXStd0 IndexStd0]=GetAlignRes(Databuffer,PlotWin-ISI,Timescale);
                    Coi=TrialParas(FinalInd(Trialnum)).Spectrum.Coi(IndexDev);
                    try
                    DataRes=DataResDev-DataResStd0;
                    ResX=ResXDev;
                    SpectSingle{Trialnum,chs}=DataRes(end-Ymin+1:end,:);
                    catch
                        DataRes=[];
                    end
                else
                    Timescale=TrialParas(FinalInd(Trialnum)).Spectrum.XData+Tmove;
                    [DataRes ResX Index]=GetAlignRes(Databuffer,PlotWin,Timescale);
                    Coi=TrialParas(FinalInd(Trialnum)).Spectrum.Coi(Index);
                    SpectSingle{Trialnum,chs}=DataRes(end-Ymin+1:end,:);
                end
                    
                    
            if Trialnum==1|trialcount==1
                try
                SpecBuffer=DataRes(end-Ymin+1:end,:);
                FsScale=TrialParas(FinalInd(Trialnum)).Spectrum.YData(end-Ymin+1:end);
                catch
                    trialcount=trialcount-1;
                end
            else
                try
                SpecBuffer=SpecBuffer+DataRes(end-Ymin+1:end,:);
                FsScale=TrialParas(FinalInd(Trialnum)).Spectrum.YData(end-Ymin+1:end);
                catch
                    trialcount=trialcount-1;
                end
            end
        end
        
        

        MeanRes{chs}=SpecBuffer/trialcount;
    end
else
    MeanRes=[];
    FinalInd=[];
    ResX=[];
    FsScale=[];
    Coi=[];
    SpectSingle=[];
    
end

end

