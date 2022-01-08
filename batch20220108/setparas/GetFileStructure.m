function varargout=GetFileStructure(varargin)

for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
try
try 
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
catch
end
path=uigetdir();
Chind=find(strcmp(FoldName,'Channel'));
if path
    Respath=[];
    Respath=FindFileCurrentPath(path,label,Respath,'Para',Para);
    for i=1:length(Respath)
        Respathsp{i,1}=erase(Respath{i},[path '\']);
        buffer=strsplit(Respathsp{i},{'\','_'});
        
        if contains(Respath{i},{'Ch'})
            Foldnames(i,:)=[{Respath{i}} {path} buffer];
        else
            Foldnames(i,:)=[{Respath{i}} {path} buffer(1:Chind-3) {''}  buffer(Chind-2:end)];
        end
        
    end
end
%%
evalstr=[StructName '=struct('];
for Paranum=1:min([length(FoldName) size(Foldnames,2)]);
    evalstr=[ evalstr '''' FoldName{Paranum} ''', Foldnames(:,' num2str(Paranum) ') ,'];
end
evalstr(end)=[')'];
evalstr=[evalstr ';'];
eval(evalstr);
varargout{1} = PathFolds;
catch
    disp('No Path Selected');
    varargout{1} = [];
end
end