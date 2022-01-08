function CellParas = GenerateTrialParas(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
label='data.mat';
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName'};
CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
eval(EvalStructureSelect);
if ~isempty(CellAll)
hh = waitbar(0,'please wait');
for cellnum = 1:size(CellParas,1)
% for cellnum = 21
    str=['Generating TrialParas, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
    waitbar(cellnum/size(CellParas,1),hh,str)
    params = SetSplitPara('choicewin',[100 600],'TimeUpperLater',[-3 10],'FsNew',1200, ...
        'MinusBaseline',[-1 0],'ProtocolName',CellParas(cellnum).ProtocolName,'PushRateRange',Para.PushRateRange,'AmMethod',Para.AmMethod);
    FHCGenerateTrialParas('datapath',CellParas(cellnum).FilePath,'params',params,'Para',Para);
end
delete(hh);
end
end