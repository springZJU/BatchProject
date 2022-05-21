function [ResStruct,ResCellParas]= SelectStructField(CellParas,CopyField,varargin)
% input
% CopyField = {'SitePos','Date','AnimalCode','Region','RecordingTech'};
if ~iscell(CopyField)
    CopyField = cellstr(CopyField);
end
SelectField = 'SitePos';
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
for copyfieldnum = 1:length(CopyField)
    ResBuffer.(CopyField{copyfieldnum}) = {CellParas.(CopyField{copyfieldnum})}';
end

evalstr=['ResStruct=struct('];
for copyfieldnum = 1:length(CopyField)
    evalstr=[ evalstr '''' CopyField{copyfieldnum} ''',ResBuffer.' CopyField{copyfieldnum} ','];
end
evalstr(end)=[')'];
evalstr=[evalstr ';'];
eval(evalstr);
try
    if ~iscell(SelectField)
        SelectField = {SelectField};
    end
CellBuffer = mergeSameSizeCell(cellfun(@(x) {CellParas.(x)}',SelectField,'uni',false));
[~,Idx] = unique(cell2table(CellBuffer));

ResStruct = ResStruct(Idx);
ResCellParas = CellParas(ResInd);
catch
end
end