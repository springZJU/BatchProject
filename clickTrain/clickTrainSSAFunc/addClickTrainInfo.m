function addClickTrainInfo(dataPath)
oldPath = pwd;
savePath = erase(dataPath,'\data.mat');
cd(savePath)
if ~exist('clickTrainInfo.mat','file')
load(dataPath);
clickTrainInfo.TrainDur = input('Input click train duration (ms) :');
clickTrainInfo.clickICI = input('Input click train ICI (ms) :');
devNum = max(data.epocs.num0.data);

if contains(dataPath,'Control')
    std1Idx = find(data.epocs.num0.data == 1);
    devIdx = [std1Idx(2:end) - 1; length(data.epocs.num0.data)];
    SSApairBuffer = unique([data.epocs.ordr.data(std1Idx) data.epocs.ordr.data(devIdx)],'rows');
else
SSApairBuffer = unique([data.epocs.ordr.data(data.epocs.num0.data == 1) data.epocs.ordr.data(data.epocs.num0.data == devNum)],'rows');
end
SSApairBuffer(:,3) = SSApairBuffer(:,2) - SSApairBuffer(:,1);
if contains(dataPath,'LongTerm')
clickTrainInfo.SSApairs = SSApairBuffer(SSApairBuffer(:,3) >= 0,1);
clickTrainInfo.S1Duration = input('Input first sound duration (ms) :');
if contains(dataPath,'ICIThr')
    clickTrainInfo.ICIThr = input('Input click train ICIs from low to high (ms) :');
end
if contains(dataPath,'Var')
    clickTrainInfo.sd = input('Input normalized SD of click trains  :');
end
else
    clickTrainInfo.SSApairs = SSApairBuffer(SSApairBuffer(:,3) >= 0,[1 2]);
end
save('clickTrainInfo.mat','clickTrainInfo');
end
cd(oldPath)
end