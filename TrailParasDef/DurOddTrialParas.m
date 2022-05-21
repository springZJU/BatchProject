function TrialParas = DurOddTrialParas(params,sound_all,lfp)
eval([GetStructStr(params) '=ReadStructValue(params);']);
TrialParaName={'Std1Time','DevTime','SoundTime','StdSelect','DevSelect','StdNum','FreqBase','IntBase','DurBase',...
    'FreqDev','IntDev','DurDev','FreqDiff','IntDiff','DurDiff','CueDiff','PushTime','OffPushTime','StrType','FsRaw'};
%% set TrialParaValues
StrType.Alignments={'Align2Std1Onset','Align2DevOnset','Align2Push'};
StrType.cue_types={'dura'};
StrType.sound_types={'std','dev'};
StrType.right_wrong_types={'std_right','std_wrong','dev_right','dev_wrong','all'};
StrType.diff_colors={'#000000','#77AC30','#0072BD','#7E2F8E','#FF0000','#AAAAAA'};
StrType.dev_behav_types={'freq_right','freq_wrong','int_right','int_wrong'};
Std1Time=num2cell(sound_all(sound_all(:,4)==1,1));
DevTime=num2cell(sound_all(sound_all(:,15)==0,1));
StdInd=find(sound_all(:,4)==1);
DevInd=find(sound_all(:,15)==0);
for Trialnum=1:length(DevInd)
    SoundTime{Trialnum,1} = sound_all([StdInd(Trialnum):DevInd(Trialnum)],1);
end
StdSelect=num2cell(sound_all(StdInd,1)+TimeUpperLater(1)); %从std1前2s开始取
DevSelect=num2cell(sound_all(StdInd,1)+TimeUpperLater(2));%取到std1后10s
StdNum=num2cell(sound_all(sound_all(:,15)==1,4));
FreqBase=num2cell(sound_all(DevInd,5));
IntBase=num2cell(sound_all(DevInd,7));
DurBase=num2cell(sound_all(DevInd,9));
FreqDev=num2cell(sound_all(DevInd,12));
IntDev=num2cell(sound_all(DevInd,13));
DurDev=num2cell(sound_all(DevInd,14));
FreqDiff=num2cell(sound_all(DevInd,16));
IntDiff=num2cell(sound_all(DevInd,17));
DurDiff=num2cell(sound_all(DevInd,18));
try
CueDiff=num2cell(sound_all(DevInd,19));
catch
CueDiff=num2cell(ones(length(DevInd),1));
end
PushTime=num2cell((sound_all(DevInd,11)-sound_all(DevInd,1))*1000);
PushInd = find(cell2mat(PushTime)==0);
OffPushTime = (sound_all(DevInd,11)-sound_all(DevInd,1))*1000-sound_all(DevInd,10);
OffPushTime(PushInd) = 0;
OffPushTime = num2cell(OffPushTime);
FsRaw=lfp.fs;
%%
evalstr=['TrialParas=struct('];
evaldelete=['clear '];
for Paranum=1:length(TrialParaName)
    evalstr=[ evalstr '''' TrialParaName{Paranum} ''',' TrialParaName{Paranum} ','];
    evaldelete=[evaldelete TrialParaName{Paranum} ' '];
end
evalstr(end)=[')'];
evalstr=[evalstr ';'];
evaldelete=[evaldelete ';'];
eval(evalstr);
eval(evaldelete);