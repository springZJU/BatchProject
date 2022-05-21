function savepath=check_mkdir_SPR(rootpath,newfolder)  %在rootpath中搜索newfolder，如果没有则建立，并返回newfolder的路径
narginchk(1,2);
if nargin == 2
    if ~exist(fullfile(rootpath,newfolder) ,'dir')
        mkdir(fullfile(rootpath,newfolder));
    end
    savepath=[rootpath '\' newfolder];
elseif nargin == 1
    if ~exist(rootpath ,'dir')
        mkdir(rootpath);
    end
    savepath=rootpath;
end

end