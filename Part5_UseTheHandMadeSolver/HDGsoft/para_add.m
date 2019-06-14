function para = para_add(para,varargin)
% function para = para_add(para,vargin)
%   adds an arbitrary number of variables of the caller workspace to the parameter structure
%
% Inputs
%     para         : parameters
%     varargin     : parameter values
%
% Outputs
%     para         : parameters
%
% Author
%   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    for i=1:length(varargin)
      para.(inputname(i+1))=varargin{i};
    end

end