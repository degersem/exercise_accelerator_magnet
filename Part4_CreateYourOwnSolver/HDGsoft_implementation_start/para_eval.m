function HDG_value = para_eval(HDG_expr,varargin)
% function HDG_value = para_eval(HDG_expr,varargin)
%   evaluates an expression using one or more set of parameters
%
% Inputs
%     HDG_expr             : expression
%     varargin             : parameter sets

% Outputs
%     HDG_value            : result
%
% Note
%     (a) HDG_ added to prevent interference with defined parameters
%     (b) This implementation would be greatly simplified if it would be possible to define and store several own workspaces
%
% Author
%   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

for HDG_i=1:length(varargin)
  if ~isempty(varargin{HDG_i})
    HDG_nms=fieldnames(varargin{HDG_i});
    for HDG_p=1:length(HDG_nms)
      evalc(sprintf('%s=varargin{%d}.%s;',HDG_nms{HDG_p},HDG_i,HDG_nms{HDG_p}));
    end
  end
end
HDG_value=eval(HDG_expr);

end
