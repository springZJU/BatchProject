function CellParas = DelelteItems(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName','Folder1','Folder2'};
switch DeleteType
    case 'File'
        CellAll = GetFileStructure('FoldName',FoldName, 'label',DeleteName,'StructName','PathFolds','Para',Para);
    case 'Folder'
        CellAll = GetFoldStructure('FoldName',FoldName, 'label',DeleteName,'StructName','PathFolds','Para',Para);
end
% eval(EvalStructureSelect);
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','FilePath');
if ~isempty(CellAll)
hh = waitbar(0,'please wait');
for cellnum = 1:size(CellParas,1)
    str=['Deleting Selected Items, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
    waitbar(cellnum/size(CellParas,1),hh,str)
%     try
    switch DeleteType
        case 'File'
            delete(CellParas(cellnum).FilePath);
        case 'Folder'
            rmdir(CellParas(cellnum).FilePath,'s');
    end
%     catch
%     end

end
delete(hh);
end
end