function varargout=SetUserPara(varargin)
if nargin >= 2
for i = 1:2:length(varargin)
    eval(['params.' varargin{i} ' = varargin{i+1};']);
end
varargout{1} = params;
else
    varargout{1} = [];
end
