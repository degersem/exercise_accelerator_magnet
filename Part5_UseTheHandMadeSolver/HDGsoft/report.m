function report(varargin)

% function REPORT(fid,str1,str2)
% writes information to a file or to the screen or to a combination of both
% the information is formatted such that a column appears at a fixed position
% both strings are located left and right from the column
%
% input parameters
%    fid            : file identifier (specify 1 for stdout; specify 2 for stderr; optional; default: 1), can also be an array of file identifiers
%    str1           : string to be put at the lefthandside
%    str2           : string to be put at the righthandside
%
% output parameters
%    none
%
% see also FPRINTF, SPRINTF
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter control
numspace=60;
if nargin==0
  fid=1;
  i=0;
elseif ischar(varargin{1})
  fid=1;
  i=1;
else
  fid=varargin{1};
  i=2;
end
if i<=nargin
  str1=varargin{i};
  i=i+1;
end
str2=[];
while i<=nargin
  switch class(varargin{i})
    case {'int8','uint8','int16','uint16','int32','uint32','int64','uint64'}
      str2=[str2 sprintf('%d',varargin{i})];
    case {'double','float','single'}
      str2=[str2 sprintf('%13.5e',varargin{i})];
    otherwise
      str2=[str2 ' ' varargin{i}];
  end
  i=i+1;
end

% B. Report
for k=1:length(fid)
  fprintf(fid(k),'%s %s: %s\n',str1,repmat(' ',1,max(0,numspace-1-length(str1))),str2);
end
