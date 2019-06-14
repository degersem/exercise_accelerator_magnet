function footer(varargin)

% function FOOTER(fid,str1)
% writes a standarised footer string to a file or to the screen or to a combination of both
%
% input parameters
%    fid            : file identifier (specify 1 for stdout; specify 2 for stderr; optional; default: 1), can also be an array of file identifiers
%
% output parameters
%    none
%
% see also REPORT, HEADER
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter control
width=80;
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

% B. Print footer
for k=1:length(fid)
  fprintf(fid(k),'%s\n',repmat('-',1,width));
end
