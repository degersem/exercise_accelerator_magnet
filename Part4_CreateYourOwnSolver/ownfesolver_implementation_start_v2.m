%% Own finite-element solver
% Herbert De Gersem, Technische Universitaet Darmstadt
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

%addpath('HDGsoft_implementation_start');
%plotflag = 0;    % no plots at all
plotflag = 1;    % some plots, no mesh and field plots
%plotflag = 2;    % all plots, including mesh and field plots

%% A. Reading the FEMM model and own post-processing
% A.1. Problem
modelname = 'sis100';                                                      %        : model name
prb = read_femm([modelname '.ans'],1,0);                                   %        : read the FEMM .ans data file
header(1,'Problem data structure');
prb
footer;

% A.2. Geometry
if plotflag
  figure(1); clf; geometry_plot(prb.geometry);
end
header(1,'Geometry');
prb.geometry
footer;

% A.3. Mesh
header(1,'Mesh');
prb.mesh
numnode = size(prb.mesh.node,1);                                           % [#]    : number of nodes
numelem = size(prb.mesh.elem,1);                                           % [#]    : number of elements
footer
x = prb.mesh.node(:,1);                 % [m]   : x-coordinates
y = prb.mesh.node(:,2);                 % [m]   : y-coordinates
if plotflag>=2
  figure(2); clf; mesh_plot(prb.mesh); hold on; geometry_plot(prb.geometry,[],'b');
  % A.3.a. Plot elements 1 3 5 7 9
  idxelem = [1 3 5 7 9];
  figure(3); clf; trimesh(prb.mesh.elem(idxelem,1:3),x,y); axis equal; axis off; title('elements 1, 3, 5, 7 and 9');
  % A.3.b. Plot all elements belonging to region 1
  idxelem = find(prb.mesh.elem(:,4)==1);
  figure(4); clf; trimesh(prb.mesh.elem(idxelem,1:3),x,y); axis equal; axis off; title('elements belonging to region 1');
end

% A.4. Material
header(1,'Material');
prb.material(3)
footer
nuelem = prb_mate2elem(prb,'nu');                                          % [m/H]  : element-wise reluctivities
if plotflag>=2
  figure(5); clf; viewprop(prb,nuelem(:,1)); title('element-wise reluctivities'); hold on; geometry_plot(prb.geometry,[],'y');
end

% A.5. Boundary conditions
header(1,'Boundary conditions');
prb.bdrycond(1)
footer
[prb.bdrycond,idxdof,numunknown] = bdrycond_update_mesh(prb.bdrycond,prb.mesh,prb.geometry,'node',0);
if plotflag
  figure(6); clf; geometry_plot(prb.geometry); hold on;
  colour='brgcmyb'; legtxt = {};
  for bc=1:length(prb.bdrycond)
    idx = prb.bdrycond(bc).idxnode;
    if ~isempty(idx)
      xbc = prb.mesh.node(idx,1);
      ybc = prb.mesh.node(idx,2);
      plot(xbc,ybc,[colour(rem(bc-1,length(colour))+1) 'x']);
      legtxt = {legtxt{:},sprintf('boundary condition %d',bc)};
    end
  end
  legend(legtxt{:});
end

% A.6. Conductors
header(1,'Conductors');
%prb.wire(1)
footer
if plotflag>=2
  figure(7); clf; mesh_plot(prb.mesh,[],struct('elem',prb.wire(1).k));
  hold on; geometry_plot(prb.geometry,[],'b'); title('elements belonging to conductor 1');
end

% A.7. Regions
header(1,'Regions');
prb.region
for rg=1:size(prb.region,1)
  fprintf('Region %d\n',rg);
  fprintf('    prb.region(:,1:2)   : coordinate               : (%13.6e,%13.6e) m\n',prb.region(rg,1),prb.region(rg,2));
  fprintf('    prb.region(:,3)     : material identifier      : %d\n',prb.region(rg,3));
  fprintf('    prb.region(:,5)     : conductor identifier     : %d\n',prb.region(rg,5));
  fprintf('    prb.region(:,8)     : number of turns          : %d\n',prb.region(rg,8));
end
footer
if plotflag>=2
  figure(8); clf; colour='kbrgymc';
  for rg=1:size(prb.region,1)
    idxelem = find(prb.mesh.elem(:,4)==rg);                                % identifiers of the elements belonging to this region
    mesh_plot(prb.mesh,[],struct('elem',idxelem),colour(rem(rg-1,length(colour))+1)); hold on;
  end
  geometry_plot(prb.geometry,[],'b'); title('regions');
end

% A.8. FEMM solution for the line-integrated magnetic vector potential
az = prb.mesh.node(:,3);                                                   % [Wb]   : line-integrated magnetic vector potential (one value per node)
azelem = prj_nd2el(prb,az);                                                % [Wb]   : line-integrated magnetic vector potential (one value per element)
if plotflag>=2
  figure(9);  clf; viewequi(prb,az,24); title('magnetic flux lines (FEMM solution)'); hold on; geometry_plot(prb.geometry);
  figure(10); clf; viewprop(prb,azelem); title('magnetic vector potential (FEMM solution)'); hold on; geometry_plot(prb.geometry);
end

% A.9. Post-process for the magnetic flux density
% ---------------------- START IMPLEMENTATION TASK 1 ----------------------
% calculate the magnetic flux density from the FEMM solution
Bxy;                                                                       % [T]    : magnetic flux density
Bm;                                                                        % [T]    : magnitude of the magnetic flux density
if plotflag>=2
  figure(11); clf; viewprop(prb,Bm); title('magnetic flux density (FEMM solution)'); hold on; geometry_plot(prb.geometry,[],'y');
end
% ----------------------- END IMPLEMENTATION TASK 1 -----------------------

% A.10. Post-process for the magnetic energy
% ---------------------- START IMPLEMENTATION TASK 2 ----------------------
% calculate the magnetic energy
Wmagn_ownpost;                                                             % [J]     : magnetic energy
report('Magnetic energy',Wmagn_ownpost','J (FEMM)');
% ----------------------- END IMPLEMENTATION TASK 2 -----------------------

% B. Own 2D FE solver
% B.1. Prepare boundary conditions (do not care about this, only do it)
[prb.bdrycond,idxdof,numunknown] = bdrycond_update_mesh(prb.bdrycond,prb.mesh,prb.geometry,'node',0);
prb.bdrycond = bdrycond_update_time(prb.bdrycond,prb.para,0,0,0);

% B.2. Calculate system matrices and righthandside
% ---------------------- START IMPLEMENTATION TASK 3 ----------------------
% calculate and assemble the curl-reluctance-curl matrix and the winding matrix
Knu;                                                                       % [1/H]   : FE reluctance matrix (xy-direction)
Wmagn_femm_alt;                                                            % [J]     : alternative method for calculating the magnetic energy (combining FEMM solution and Matlab matrix)
report('Magnetic energy',Wmagn_femm_alt','J (FEMM+Matlab)');
Pstr;                                                                      % []      : winding-function coupling matrix
report('Number of turns (check of the partition-of-unity property)',full(sum(Pstr,1)),'A');
gstr = zeros(numunknown,1);                                                % [A]     : righthandside (for inserting nonhomogeneous Dirichlet boundary conditions)
if plotflag
  figure(12); spy(Knu); title('Knu');
end
% ----------------------- END IMPLEMENTATION TASK 3 -----------------------

% B.3. Shrink the system matrices according to the boundary conditions
[Kbcs,gbcs] = bdrycond_shrink(prb.bdrycond,idxdof,Knu,gstr);               %         : shrink the system matrix for the boundary conditions
[dummy,Pbcs] = bdrycond_shrink(prb.bdrycond,idxdof,[],Pstr,0);             %         : shrink the coupling matrix for the boundary conditions

% B.4. Solve the system of equations
% ---------------------- START IMPLEMENTATION TASK 4 ----------------------
% solve the system of equations
Iapp = 6000;                                                               % [A]    : applied current
ubcs;                                                                      % [Wb]    : solve for the line-integrated magnetic vector potentials
% ----------------------- END IMPLEMENTATION TASK 4 -----------------------

% B.5. Inflate the solution
u = bdrycond_inflate(prb.bdrycond,ubcs,numunknown,idxdof);                 % [Wb]    : insert the boundary conditions
if plotflag>=2
  figure(13); clf; viewequi(prb,u,24); title('magnetic flux lines (own solution)'); hold on; geometry_plot(prb.geometry);
end

% B.6. Post-process for the magnetic flux density
% ---------------------- START IMPLEMENTATION TASK 5 ----------------------
% calculate the magnetic flux density from the FEMM solution
Bxy;                                                                       % [T]     : magnetic flux density
Bm;                                                                        % [T]    : magnitude of the magnetic flux density
if plotflag>=2
  figure(14); clf; viewprop(prb,Bm); title('magnetic flux density (own solution)'); hold on; geometry_plot(prb.geometry,[],'y');
end
% ----------------------- END IMPLEMENTATION TASK 5 -----------------------

% B.7. Post-process for the magnetic energy
% ---------------------- START IMPLEMENTATION TASK 6 ----------------------
% calculate the magnetic energy
Wmagn_ownfe;                                                               % [J]     : magnetic energy (from own FE solution)
Wmagn_ownfe_alt;                                                           % [J]     : alternative method for calculating the magnetic energy
report('Magnetic energy',Wmagn_ownfe','J (Matlab)');
report('Magnetic energy (alternative)',Wmagn_ownfe_alt','J (Matlab)');
% ----------------------- END IMPLEMENTATION TASK 6 -----------------------

% B.8. Save the solution in FEMM format
prb.mesh.node(:,3) = real(u);
save_femm(prb,[modelname '_own.ans']);
fprintf('Check the solution in %s_own.ans\n',modelname);

%% C. Verify the homogeneity of the aperture field
rref = 25e-3;                                                              % [m]    : radius of the aperture field
tol = 1e-3;                                                                % []     : relative tolerance for detecting nodes at the reference circle
% ---------------------- START IMPLEMENTATION TASK 7 ----------------------
% find the nodes at the reference circle, extract the field
% and compute the harmonic components and the skew harmonic components
[Brcff,lambda]=aperture_fieldquality(prb.mesh,u,rref,tol,plotflag);
% ----------------------- END IMPLEMENTATION TASK 7 -----------------------

%% D. Nonlinear material properties
% D.1. Identify elements in the nonlinear region
rgFE = findlab({prb.material.label},'FE');                                 % []     : index of the nonlinear region
elemregi = prb.region(prb.mesh.elem(:,4),3);                               % []     : element-2-region identifiers
idxnlinelem = find(elemregi==rgFE);                                        % []     : indices of the elements in the nonlinear region
if plotflag>=2                                                             %        : plot the mesh
  figure(15); clf; trimesh(prb.mesh.elem(idxnlinelem,1:3),prb.mesh.node(:,1),prb.mesh.node(:,2),'Color','k');
  axis equal; axis off; title('nonlinear region');
end

% D.2. Initialise nonlinear characteristic (given Hchar and Bchar)
load BH.txt; Bchar = BH(:,1); Hchar = BH(:,2);                             % [T,A/m]: load the B-H characteristic from file
nlin = nlin_initialise(Bchar,Hchar);                                       % []     : initialise the data structure for use when evaluating the B-H characteristic
if plotflag
  B = [0:0.1:3]';                                                          % [T]    : exemplary magnetic flux densities (sorted)
  [H,nu,nud,dnudB2] = nlin_evaluate(nlin,B);                               % [--]   : evaluate the characteristic
  figure(16); clf; subplot(131); hold on; plot(pyth(H),pyth(B),'x-'); xlabel('H (A/m)'); ylabel('B (T)');
  subplot(132); hold on; plot(pyth(B),nu,'x-');  xlabel('B (T)'); ylabel('nu (A/mT)');
  subplot(133); hold on; plot(pyth(B),nud,'x-'); xlabel('B (T)'); ylabel('dnudB2 (A/mT)');
end

%% E. Successive substitution
ufem = zeros(numnode,1);                                                   % [Wb]   : initial solution
nuelem = prb_mate2elem(prb,'nu');                                          % [m/H]  : element-wise reluctivities
relerrnlin = 1;                                                            % []     : relative nonlinear error
epsnlin = 1e-3;                                                            % []     : tolerance for the nonlinear iteration
maxiter = 20;                                                              % [#]    : maximum number of nonlinear iterations
alpha = 0.2;                                                               % []     : relaxation factor
it = 0;                                                                    % [#]    : iteration number
succsubst_cvg = 1;                                                         % []     : relative nonlinear error as measure for convergence
while (it<maxiter) & (relerrnlin>epsnlin)
  it = it+1;
  % ---------------------- START IMPLEMENTATION TASK 8 --------------------
  % implement the successive-substitution approach
  fprintf('Successive-substitution step %3d        : relative nonlinear error %13.6e\n',it,relerrnlin);
  succsubst_cvg = [succsubst_cvg relerrnlin];                              % []     : relative nonlinear error as measure for convergence
  % ---------------------- END IMPLEMENTATION TASK 8 ----------------------
end
% E.5. Report convergence
if (it==maxiter) & (relerrnlin>epsnlin)
  fprintf('No convergences after %3d steps         : relative nonlinear error %13.6e\n',it,relerrnlin);
else
  fprintf('Convergence in %3d succ-subst steps     : relative nonlinear error %13.6e\n',it,relerrnlin);
end
if plotflag
  figure(17); clf; semilogy([0:length(succsubst_cvg)-1],succsubst_cvg);
  xlabel('number of nonlinear iteration steps'); ylabel('relative nonlinear error');
end
% E.6. Save the solution
prb.mesh.node(:,3)=ufem;                                                   % [Tm]   : save the magnetic vector potential as third column in the node array
save_femm(prb,[modelname '_succsubb.ans']);                                %        : save a FEMM .ans data file

%% F. Newton
ufem = zeros(numnode,1);                                                   % [Wb]   : initial solution
nuelem = prb_mate2elem(prb,'nu');                                          % [m/H]  : element-wise reluctivities
dnudB2 = zeros(numelem,1);                                                 % [A/mT^3]: derivative of the reluctivity with respect to the square of the magnetic flux density
Hc = zeros(numelem,2);                                                     % [A/m]  : element-wise coercitive field strengths
relerrnlin = 1;                                                            % []     : relative nonlinear error
epsnlin = 1e-3;                                                            % []     : tolerance for the nonlinear iteration
maxiter = 20;                                                              % [#]    : maximum number of nonlinear iterations
alpha = 1.0;                                                               % []     : relaxation factor
it = 0;                                                                    % [#]    : iteration number
newton_cvg = 1;                                                            % []     : relative nonlinear error as measure for convergence
while (it<maxiter) & (relerrnlin>epsnlin)
  it = it+1;
  % ---------------------- START IMPLEMENTATION TASK 9 --------------------
  % implement the Newton approach
  fprintf('Newton step %3d                         : relative nonlinear error %13.6e\n',it,relerrnlin);
  newton_cvg = [newton_cvg relerrnlin];                                    % []     : relative nonlinear error as measure for convergence
  % ---------------------- END IMPLEMENTATION TASK 9 ----------------------
end
% F.5. Report convergence
if (it==maxiter) & (relerrnlin>epsnlin)
  fprintf('No convergences after %3d Newton steps  : relative nonlinear error %13.6e\n',it,relerrnlin);
else
  fprintf('Convergence in %3d Newton steps         : relative nonlinear error %13.6e\n',it,relerrnlin);
end
if plotflag
  figure(17); hold on; semilogy([0:length(newton_cvg)-1],newton_cvg,'r');
  xlabel('number of nonlinear iteration steps'); ylabel('relative nonlinear error'); legend('successive substitution','newton');
end
% F.6. Save the solution
prb.mesh.node(:,3)=ufem;                                                   % [Tm]   : save the magnetic vector potential as third column in the node array
save_femm(prb,[modelname '_newton.ans']);                                  %        : save a FEMM .ans data file

%% G. Verify the homogeneity of the aperture field
[Brcff2,lambda2]=aperture_fieldquality(prb.mesh,ufem,rref,tol,plotflag);
if plotflag
  report('Aperture field (linear solution)',2*imag(Brcff(2)),'T');         %        : FACTOR 2 BECAUSE OF DOUBLE-SIDED SPECTRUM
  report('Aperture field (nonlinear solution)',2*imag(Brcff2(2)),'T');     %        : FACTOR 2 BECAUSE OF DOUBLE-SIDED SPECTRUM
  maxlambda = 7;                                                           % [@]    : maximal harmonic to be plotted
  range = find(abs(lambda)<=maxlambda);                                    % [@]    : indices of the harmonic orders to be plotted
  Brall = [ Brcff Brcff2 ];                                                % [T]    : gather the components for both the linear and nonlinear solution
  Brall([ 2 size(Brall,1) ],:) = 0;                                        % [T]    : omit the main field component
  figure(18); clf;
  subplot(211); bar(lambda(range),real(Brall(range,:))); xlabel('harmonic order'); ylabel('Br (T)'); title('normal components'); legend('linear','nonlinear');
  subplot(212); bar(lambda(range),imag(Brall(range,:))); xlabel('harmonic order'); ylabel('Br (T)'); title('skew components');   legend('linear','nonlinear');
end
