function [res,resLogic] = structSelectViaKeyword(data,keyword,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
if exist('fieldName','var')
    str = {data.(fieldName)}'; %获取CellAll中字段.(fieldName)下所有字符串
else
    str = data;
end
pat = '.*'; %初始化正则表达式
for keyN = 1:length(keyword) %根据keyword的长度设置循环次数
    pat = [pat keyword{keyN} '.*']; % 获得完整的正则表达式
end
% 这里先调用regexpi（不分大小写）函数匹配表达式，然后调用cellfun批量处理CellArray中的Cell，
% 通过isempty找出不符要求字符串的索引，再通过~获得符合要求的索引
resLogic = ~cellfun(@isempty,regexp(str,pat,'match'));
if size(resLogic,2) ~= size(str,2)
    resLogic = resLogic';
end
res = data(resLogic);%返回符合要求的字符串索引对应的所有信息
end
