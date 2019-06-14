function v3=savedivide(v1,v2,default_value)

% function v3=SAVEDIVIDE(v1,v2,default_value)
% performs a save division, replacing infinity by a specified default value
%
% input parameters
%     v1            : first operand
%     v2            : second operand
%     default_value : default value inserted instead of infinity (optional, default=0)
%
% output parameters
%     v3            : result
%
% see also NULLINV
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if nargin<3
  default_value=0;
end
if sum(size(v1)~=size(v2))
  error('savedivide: sizes do not match');
end
idx1=find(v2);
idx2=find(v2==0);
v3=v1;
v3(idx1)=v1(idx1)./v2(idx1);
v3(idx2)=default_value*ones(size(idx2));
