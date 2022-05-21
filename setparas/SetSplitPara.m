function varargout=SetSplitPara(varargin)
params.leftorright=1;
params.fre_int_reverse=0;
params.choicewin=[100 800];
params.TimeUpperLater=[-3 5];
params.FsNew=1200;
for i = 1:2:length(varargin)
    eval(['params.' varargin{i} ' = varargin{i+1};']);
end
varargout{1} = params;
end
