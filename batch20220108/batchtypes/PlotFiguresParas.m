function CellParas = ProcessTrialParas(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName','DataPath'};
label='SpectData.mat';
CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
eval(EvalStructureSelect);
if ~isempty(CellAll)
for cellnum=1:size(CellParas,1)


    
end
end
end