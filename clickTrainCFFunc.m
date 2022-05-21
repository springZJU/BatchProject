function varargout = clickTrainCFFunc(params,datapath,varargin)
if nargin<2
    disp('Please input datapath information')
    return
else
    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    eval([GetStructStr(params) '=ReadStructValue(params);']);
    
    FRA(datapath); % plot CF
end
end

