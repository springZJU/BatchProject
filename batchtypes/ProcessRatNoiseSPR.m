function CellParas = ProcessRatNoiseSPR(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
label='data.mat';
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName','Folder1','Folder2'};
CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
% eval(EvalStructureSelect);
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','ProtocolName');
if ~isempty(CellAll)
hh = waitbar(0,'please wait');
for cellnum = 1:size(CellParas,1)
    str=['Processing SPR Rat Noise, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
    waitbar(cellnum/size(CellParas,1),hh,str)
    Para.ProtocolName = CellParas(cellnum).ProtocolName;
    Para.datapath = CellParas(cellnum).FilePath;

    SPRRatProcess('Para',Para);

end
delete(hh);
end
end