function CellParas = RenameItems(Para)
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName','Folder1','Folder2'};
OldName = 'Ch1.jpg';
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
switch RenameType
    case 'File'
        CellAll = GetFileStructure('FoldName',FoldName, 'label',OldName,'StructName','PathFolds','Para',Para);
    case 'Folder'
        CellAll = GetFoldStructure('FoldName',FoldName, 'label',OldName,'StructName','PathFolds','Para',Para);
end
% eval(EvalStructureSelect);
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','ProtocolName');
if ~isempty(CellAll)
    hh = waitbar(0,'please wait');
    for cellnum = 1:size(CellParas,1)
        str=['Renaming Selected Items, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
        waitbar(cellnum/size(CellParas,1),hh,str)
        NewName = CellParas(cellnum).SitePos;
        try
            switch RenameType
                case 'File'
                    oldpath = pwd;
                    path = erase(CellParas(cellnum).FilePath,['\' OldName]);
                    cd(path);
                    eval(['!rename,' OldName ',' NewName OldName  ]);
                    cd(oldpath);
                case 'Folder'
                    oldpath = pwd;
                    path = CellParas(cellnum).FilePath;
                    cd(path);
                    eval(['!rename,' OldName ',' NewName ]);
                    cd(oldpath);
            end
        catch
        end

    end
    delete(hh);
end
end


