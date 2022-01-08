function CellParas = OrganiseFiguresParas(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos',...
    'ProtocolName','Channel','DataPath','AnalyzeTech','Folder1','Folder2'};
label={'Ch1'};
CellAll = GetFoldStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);

eval(EvalStructureSelect);
if ~isempty(CellAll)
    hh = waitbar(0,'please wait');
    for cellnum = 1:size(CellParas,1)
        str=['Copy Figures to Newfolds, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
        waitbar(cellnum/size(CellParas,1),hh,str)
        PathRaw = CellParas(cellnum).FilePath;
        PathNew = [CopyRootPath '\' CellParas(cellnum).AnalyzeTech '\' CellParas(cellnum).ProtocolName ...
            '\' CellParas(cellnum).Region '_' CellParas(cellnum).SitePos '_' CellParas(cellnum).Date];
%         PathNew = [CopyRootPath '\' CellParas(cellnum).AnalyzeTech '\' CellParas(cellnum).ProtocolName];
        copyfile (PathRaw,PathNew);
    end
    delete(hh);
end
end