function physics_type=determine_physics_type(finfilename)

% function physics_type=determine_physics_type(finfilename)
% determines the physics type according to the file name extension
%
% input parameters
%    finfilename        : file name
%
% output parameters
%    physics_type       : magnetic/electric/thermal/electrokinetic
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ischar(finfilename)
  switch finfilename(end-3:end)
    case {'.fem','.ans'}
      physics_type='magnetic';
    case {'.fee','.res'}
      physics_type='electric';
    case {'.feh','.anh'}
      physics_type='thermal';
    case {'.fec','.anc'}
      physics_type='electrokinetic';
    otherwise
      error('unknown file extension ---%s---',finfilename(end-3:end));
  end
else
  warning('can not retrieve physics_type, depreciated use of read_femm, please change to "read_femm(filename)", assuming magnetic problem\n');
  physics_type='magnetic';
end
