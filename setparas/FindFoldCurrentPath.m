function Respath=FindFoldCurrentPath(path,label,Respath,varargin)
for i=1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};'])
end
try 
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
catch
end

oldpath=pwd;
buffer=[];
Foldnames=GetDirInPath(path);



foldernum=size(Foldnames,1);
for i=1:foldernum
    Childpath=[path,'\',Foldnames{i}];
    try 
        if ~matches(Foldnames{i},CertainPath) & any(matches(CertainPath,Foldnames))
            continue
        end
    catch
    end
if contains(Foldnames{i},label)
        buffer=[buffer;{Childpath}];
end
if ~isempty(GetDirInPath(Childpath))
    if exist('Para','var')
    buffer2=FindFoldCurrentPath(Childpath,label,buffer,'Para',Para);
    else
        buffer2=FindFoldCurrentPath(Childpath,label,buffer);
    end

    buffer=[buffer;buffer2]; 
end
end

if isempty(Respath)
Respath=[Respath;buffer];
else
    Respath=buffer;
end

cd(oldpath);
end