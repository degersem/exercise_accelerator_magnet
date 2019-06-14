function bdrycond = bdrycond_create_rectangle(mesh)

xmin = min(mesh.node(:,1));   xmax = max(mesh.node(:,1));
ymin = min(mesh.node(:,2));   ymax = max(mesh.node(:,2));
idxbottom = find(abs(mesh.node(:,2)-ymin)/(ymax-ymin)<1e-3);
idxright  = find(abs(mesh.node(:,1)-xmax)/(xmax-xmin)<1e-3);
idxtop    = find(abs(mesh.node(:,2)-ymax)/(ymax-ymin)<1e-3);
idxleft   = find(abs(mesh.node(:,1)-xmin)/(xmax-xmin)<1e-3);
idxcorner = [
  intersect(idxbottom,idxright) ;
  intersect(idxright,idxtop)    ;
  intersect(idxtop,idxleft)     ;
  intersect(idxleft,idxbottom)  ;
  ];
idxbottom = setdiff(idxbottom,idxcorner);
idxright  = setdiff(idxright, idxcorner);
idxtop    = setdiff(idxtop,   idxcorner);
idxleft   = setdiff(idxleft,  idxcorner);
[~,i] = sort(mesh.node(idxbottom,1));    idxbottom = idxbottom(i);
[~,i] = sort(mesh.node(idxright,1));     idxright  = idxright(i);
[~,i] = sort(mesh.node(idxtop,1));       idxtop    = idxtop(i);
[~,i] = sort(mesh.node(idxleft,1));      idxleft   = idxleft(i);
idxslvmst = [
  idxbottom      idxtop                   ;
  idxleft        idxright                 ;
  idxcorner(2:4) repmat(idxcorner(1),3,1)
  ];
bdrycond.type = 'periodic';
bdrycond.name = '"ALL"';
bdrycond.value = [];
bdrycond.expression = [];
bdrycond.X = 1;
bdrycond.mirror = [];
bdrycond.idxnode = idxslvmst;
bdrycond.idx = idxslvmst;
bdrycond.idxedge = [];
bdrycond.data = [];


