function savepath=check_mkdir_SPR(rootpath,newfolder)  %在rootpath中搜索newfolder，如果没有则建立，并返回newfolder的路径
    oldpath=pwd;
    cd(rootpath)
    if ~exist(newfolder ,'dir')
        cd(rootpath)
        mkdir(newfolder);
    end
    savepath=[rootpath '\' newfolder];
    cd(oldpath);
end