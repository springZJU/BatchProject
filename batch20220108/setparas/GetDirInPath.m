function nameFolds=GetDirInPath(path)
oldpath=pwd;
cd(path);
Files=dir(path);
isub = [Files(:).isdir]; %# returns logical vector
nameFolds = {Files(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

end
