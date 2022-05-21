function CellParas = OrganiseFiguresParas(Para)
copyLabel='Waveform';
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName'};
switch CopyType
    case 'File'
        CellAll = GetFileStructure('FoldName',FoldName, 'label',copyLabel,'StructName','PathFolds','Para',Para);
    case 'Folder'
        CellAll = GetFoldStructure('FoldName',FoldName, 'label',copyLabel,'StructName','PathFolds','Para',Para);
end
% CellAll(cellfun(@isempty , {CellAll.FilePath})) = [];
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','FilePath');

if ~isempty(CellAll)
    hh = waitbar(0,'please wait');
    for cellnum = 1:size(CellParas,1)
        str=['Copy Figures to Newfolds, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
        waitbar(cellnum/size(CellParas,1),hh,str)
        PathRaw = CellParas(cellnum).FilePath;
        fieldNames = fields(CellParas);
        Idx = find(contains(struct2cell(CellParas(1)),copyLabel));
        %         PathNew = erase(strrep(CellParas(cellnum).FilePath,CellParas(cellnum).RootPath,CopyRootPath),['\' CellParas(cellnum).(fieldNames{Idx(end)})]);
        % '\' CellParas(cellnum).(fieldNames{Idx(end)})
        switch CopyType
            case 'File'
                PathNew = [CopyRootPath '\' CellParas(cellnum).AnimalCode  '\'  CellParas(cellnum).Date '\' CellParas(cellnum).SitePos '\' CellParas(cellnum).ProtocolName ];
            case 'Folder'
                PathNew = [CopyRootPath '\' CellParas(cellnum).AnimalCode  '\'  CellParas(cellnum).Date '\' CellParas(cellnum).SitePos '\' CellParas(cellnum).ProtocolName '\' copyLabel ];
        end
        check_mkdir_SPR(PathNew) ;
        copyfile (PathRaw,PathNew);
    end
    delete(hh);
end
end