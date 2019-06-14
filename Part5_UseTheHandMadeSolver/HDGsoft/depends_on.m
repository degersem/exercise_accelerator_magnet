function flag = depends_on(expression,variable)

    % function flag = depends_on(expression,variable)
    %   returns 1 when the expression depends on the specified variable
    %
    % Inputs
    %    expression            : algebraic expression (string)
    %    variable              : variable name (string)
    %
    % Outputs
    %    flag                  : [1/0]
    %
    % Author
    %   Steven Vandekerckhove
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    flag=~isempty(expression) && any(strcmp(regexp(expression,'\w+','match'),variable));
end
