function CellParas = GenerateTrialParas(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
label='data.mat';
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName'};
CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','ProtocolName');
if ~isempty(CellAll)
hh = waitbar(0,'please wait');
for cellnum = 1:size(CellParas,1)
    str=['Generating TrialParas, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
    waitbar(cellnum/size(CellParas,1),hh,str)
    params = SetSplitPara('choicewin',choicewin,'TimeUpperLater',[-1 9],'FsNew',1200, ...
        'MinusBaseline',[-1 0],'ProtocolName',CellParas(cellnum).ProtocolName,'PushRateRange',Para.PushRateRange,'AmMethod',Para.AmMethod);
    path = erase(CellParas(cellnum).FilePath,'data.mat');
    cd(path);
    if exist('TrialParas.mat','file')
        continue
    else
    FHCGenerateTrialParas('datapath',CellParas(cellnum).FilePath,'params',params,'Para',Para);
    end
end
delete(hh);
end
end