function [ResStruct,ResCellParas]= SelectStructField(CellParas,varargin)
CopyField = {'SitePos','Date','AnimalCode','Region','RecordingTech'};
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
CellBuffer = {CellParas.(SelectField)}';
CellUnique = unique(CellBuffer);
for Uniquenum = 1:length(CellUnique)
    IndBuffer = find(strcmp(CellBuffer,CellUnique{Uniquenum}));
    ResInd(Uniquenum) = IndBuffer(end);
end
ResStruct = ResStruct(ResInd);
ResCellParas = CellParas(ResInd);
catch
end

end