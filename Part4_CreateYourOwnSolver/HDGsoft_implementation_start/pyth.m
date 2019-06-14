function [Bm,Bangle]=pyth(B)

% function Bm=PYTH(B)
% returns the magnitude of the vector/coordinate B
%
% input parameters
%     B           : vector/coordinate (size: num-by-dim where dim stands for the dimension)
%
% output parameters
%     Bm           : vector/coordinate magnitude
%     Bangle       : vector/coordinate angles
%
% see also POL2CART, CART2POL
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

Bm=sqrt(sum(B.*conj(B),2));
if nargout>1
  Bangle=B;
  idx=find(Bm);
  Bangle(idx,:)=Bangle(idx,:)./(Bm(idx,:)*ones(1,size(B,2)));
end
