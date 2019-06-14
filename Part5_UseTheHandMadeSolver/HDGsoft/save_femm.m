function save_femm(prb,foutfilename)

% function SAVE_FEMM(prb,foutfilename)
% saves a FE-prb structure into a FEMM-formatted .ans file
%
% input parameters
%     prb            : FE-problem structure
%     foutfilename   : file name or file pointer
%
% output parameters
%
% see also READ_FEMM
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Carry over all information
femmdata.Format='4.0';
femmdata.Frequency=sprintf('%f',prb.formulation.frequency);
femmdata.Precision='1e-008';
femmdata.MinAngle='30';
femmdata.Depth=prb.mesh.depth(1,1);
femmdata.LengthUnits=prb.mesh.original_unit;
femmdata.ProblemType=prb.mesh.symmetry_type;
switch femmdata.ProblemType
    case 'planar'
        femmdata.Coordinates='cartesian';
    case 'axisymmetric'
        femmdata.Coordinates='cylindrical';
    case 'radialsymmetric'
        femmdata.Coordinates='cylindrical';
end
femmdata.ACSolver='0';
femmdata.Comment='"written from save_femm"';
femmdata.PointProps=[]; % or '0'
femmdata.BdryProps=bdrycond_store_in_femmdata(prb.bdrycond,prb.mesh.depth(1,1),prb.formulation);
femmdata.BlockProps=material_store_in_femmdata(prb.material);
femmdata.CircuitProps=wire_store_in_femmdata(prb.wire,prb.formulation);
femmdata.points=prb.geometry.points(:,1:4);
femmdata.segments=prb.geometry.segments(:,1:6);
femmdata.arcsegments=prb.geometry.arcsegments(:,1:7);
femmdata.NumHoles='0';
femmdata.holes=zeros(0,3);
femmdata.blocklabels=prb.region(:,1:9);
femmdata.node=prb.mesh.node(:,1:3);
femmdata.elem=prb.mesh.elem(:,1:4);
femmdata.whatisthis=[ 1     1e-6 ];
femmdata=bdrycond_reconnect(prb.bdrycond,femmdata);

% B. Adapt solution

switch femmdata.ProblemType
    case 'planar'
        femmdata.Depth=prb.mesh.depth(1,1);
        lz=femmdata.Depth;
        rvis=1;
    case 'axisymmetric'
        lz=[-pi/2,pi/2];
        rvis=1;
    case 'radialsymmetric'
        rvis=prb.mesh.symmetry_info.rvis;
        lz=rvis;
        femmdata.ProblemType='planar';
        femmdata.Coordinates='cartesian';
end

if ~strcmp(femmdata.ProblemType,'axisymmetric')                            % FEMM stores Az in the case of cartesian or Ar in the case or radialsymmetric
    femmdata.node(:,3)=femmdata.node(:,3)./(femmdata.Depth);
else                                                                       % FEMM stores 2*pi*r*Atheta
  % do nothing
end

% C. Rescale lengths
switch femmdata.LengthUnits
  case 'meters'
    lfac=1;
  case 'centimeters'
    lfac=100;
  case 'millimeters'
    lfac=1000;
  otherwise
    error('unit %s not not known\n',femmdata.LengthUnits);
end
femmdata.points(:,1:2)=femmdata.points(:,1:2)*lfac;
femmdata.points(:,1)=femmdata.points(:,1)*rvis;                            % converting the perimetercoorditnates in to theta coordinates
femmdata.blocklabels(:,1:2)=femmdata.blocklabels(:,1:2)*lfac;
femmdata.blocklabels(:,1)=femmdata.blocklabels(:,1)*rvis;                  % converting the perimetercoorditnates in to theta coordinates
femmdata.blocklabels(:,6)=femmdata.blocklabels(:,6)*180/pi;                % conversion from degrees to radians (magnetisation angles)
femmdata.Depth=femmdata.Depth*lfac;
femmdata.node(:,1:2)=femmdata.node(:,1:2)*lfac;
femmdata.node(:,1)=femmdata.node(:,1)*rvis;                                % converting the perimetercoorditnates in to theta coordinates

% D. Readapt indices
%Explanation for adapting the indices: Matlab works from 1 to N, while C++
%works from 0 to N-1

femmdata.arcsegments(:,1:2)=femmdata.arcsegments(:,1:2)-1;
femmdata.segments(:,1:2)=femmdata.segments(:,1:2)-1;
femmdata.elem=femmdata.elem-1;

% E. Write info to file
save_femmdata(femmdata,foutfilename);
