function write_femm_geometry(fout,prb,point,line_segment,arc_segment,region,boundary)

% function WRITE_FEMM_GEOMETRY(fout,prb,point,line_segment,arc_segment,region,boundary)
% writes a temporary .fem file containing the geometry of a model
% which then can be further completed in FEMM
%
% input parameters
%    fout            : output file identifier
%    prb             : problem data structure
%    point           : geometry points (numpoint-by-2 vector containing the point coordinates)
%    line_segment    : line segments (numlinesegment-by-2 vector containing two point indices per line segment)
%    arc_segment     : arc segments (numarcsegment-by-3 vector containing two point indices and one radius per arc segment)
%    region          : regions (numregion-by-3 vector containing the region position and the region identifier)
%    boundary        : boundary conditions (optional)
%
% output parameters
%
% see also

if nargin<7
  boundary=[];
end

% A. General
fprintf(fout,'[Format]      =  4.0\n');
fprintf(fout,'[Frequency]   =  0\n');
fprintf(fout,'[Precision]   =  1e-008\n');
fprintf(fout,'[MinAngle]    =  30\n');
fprintf(fout,'[Depth]       =  %f\n',prb.Depth);
fprintf(fout,'[LengthUnits] =  %s\n',prb.LengthUnits);
fprintf(fout,'[ProblemType] =  planar\n');
fprintf(fout,'[Coordinates] =  cartesian\n');
fprintf(fout,'[Comment]     =  "Add comments here."\n');
fprintf(fout,'[PointProps]  = 0\n');

% A. Boundary properties
fprintf(fout,'[BdryProps]   = %d\n',length(boundary));
for bc=1:length(boundary)
  fprintf(fout,'  <BeginBdry>\n');
  fprintf(fout,'    <BdryName> = "%s"\n',boundary(bc).label);
    fprintf(fout,'    <BdryType> = 0\n');
    fprintf(fout,'    <A_0> = %13.6e\n',boundary(bc).value);
    fprintf(fout,'    <A_1> = 0\n');
    fprintf(fout,'    <A_2> = 0\n');
    fprintf(fout,'    <Phi> = 0\n');
    fprintf(fout,'    <c0> = 0\n');
    fprintf(fout,'    <c0i> = 0\n');
    fprintf(fout,'    <c1> = 0\n');
    fprintf(fout,'    <c1i> = 0\n');
    fprintf(fout,'    <Mu_ssd> = 0\n');
    fprintf(fout,'    <Sigma_ssd> = 0\n');
  fprintf(fout,'    <EndBdry>\n');
end

% A. Region/material properties
[regilab,dummy,reginum]=unique({region.label});
fprintf(fout,'[BlockProps]  = %d\n',length(regilab));
for rg=1:length(regilab)
  fprintf(fout,'  <BeginBlock>\n');
  fprintf(fout,'    <BlockName> = "%s"\n',regilab{rg});
  fprintf(fout,'    <Mu_x> = 1\n');
  fprintf(fout,'    <Mu_y> = 1\n');
  fprintf(fout,'    <H_c> = 0\n');
  fprintf(fout,'    <H_cAngle> = 0\n');
  fprintf(fout,'    <J_re> = 0\n');
  fprintf(fout,'    <J_im> = 0\n');
  fprintf(fout,'    <Sigma> = 0\n');
  fprintf(fout,'    <d_lam> = 0\n');
  fprintf(fout,'    <Phi_h> = 0\n');
  fprintf(fout,'    <Phi_hx> = 0\n');
  fprintf(fout,'    <Phi_hy> = 0\n');
  fprintf(fout,'    <LamType> = 0\n');
  fprintf(fout,'    <LamFill> = 1\n');
  fprintf(fout,'    <NStrands> = 0\n');
  fprintf(fout,'    <WireD> = 0\n');
  fprintf(fout,'    <BHPoints> = 0\n');
  fprintf(fout,'  <EndBlock>\n');
end

% B. Circuit properties
fprintf(fout,'[CircuitProps]  = 0\n');

% C. Geometry points
fprintf(fout,'[NumPoints] = %d\n',size(point,1));
for i=1:size(point,1)
  fprintf(fout,'%g\t%g\t%d\t%d\n',point(i,1),point(i,2),0,0);
end

% D. Geometry line segments
[nrw,ncl]=size(line_segment);
if ncl<2
  error('Too few columns in line_segment');
elseif ncl<3
  line_segment=[line_segment zeros(nrw,1)];
end
fprintf(fout,'[NumSegments] = %d\n',length(line_segment));
for i=1:size(line_segment,1)
  fprintf(fout,'%d\t%d\t%d\t%d\t%d\t%d\n',line_segment(i,1)-1,line_segment(i,2)-1,-1,line_segment(i,3),0,0);
end

% E. Geometry arc segments
[nrw,ncl]=size(arc_segment);
if ncl<3
  error('Too few columns in arc_segment');
elseif ncl<4
  arc_segment=[arc_segment 30*ones(nrw,1) zeros(nrw,3)];
else
  arc_segment=[arc_segment zeros(nrw,max(0,7-ncl))];
end
fprintf(fout,'[NumArcSegments] = %d\n',nrw);
for i=1:size(arc_segment,1)
  fprintf(fout,'%d\t%d\t%13.6e\t%d\t%d\t%d\t%d\n',arc_segment(i,1)-1,arc_segment(i,2)-1,arc_segment(i,3),arc_segment(i,4),arc_segment(i,5),arc_segment(i,6),arc_segment(i,7));
end

% F. Geometry holes
fprintf(fout,'[NumHoles] = 0\n');

% G. Geometry block labels
fprintf(fout,'[NumBlockLabels] = %d\n',length(reginum));
for rg=1:length(region)
  fprintf(fout,'%f\t%f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',region(rg).x,region(rg).y,reginum(rg),-1,0,0,0,1,0);
end
