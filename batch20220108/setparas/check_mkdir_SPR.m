function savepath=check_mkdir_SPR(rootpath,newfolder)  %��rootpath������newfolder�����û��������������newfolder��·��
    oldpath=pwd;
    cd(rootpath)
    if ~exist(newfolder ,'dir')
        cd(rootpath)
        mkdir(newfolder);
    end
    savepath=[rootpath '\' newfolder];
    cd(oldpath);
end