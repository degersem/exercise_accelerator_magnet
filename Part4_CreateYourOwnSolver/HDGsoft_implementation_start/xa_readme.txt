% xa_readme.txt

Functions with prescripts "xa_", "xi_" and "xo_" wrap functions of OctaveFEMM.
    "xa_"    : wrap general functions
    "xi_"    : wrap functions of the preprocessor
    "xe_"    : intended to define solving procedures (e.g. inductance_matrix)
    "xo_"    : wrap functions of the postprocessor

Why wrapping the OctaveFEMM functions and not directly using them?
    1. there exists still the possibility to use the OctaveFEMM functions
       directly, even together with wrapped functions.
    2. FEMM forces the user to repeat the modelling when another formulation
       is needed. The wrapped functions are invoked by
             xi_functionname(arg1,arg2,arg3,prp0,prp1,prp2,prp3)
       and replace
             mi_functionname(arg1,arg2,arg3);
             ei_functionname(arg1,arg2,arg3);
             hi_functionname(arg1,arg2,arg3);
             ci_functionname(arg1,arg2,arg3);
       and some additional routines for selecting and setting properties.
       The arguments arg1-arg3 are shared by all formulations (there
       typically contain only topological and geometrical information).
       The properties depend on the formulation.
             prp0 (optional) are formulation-independent properties
             prp1 (optional) are properties for formulation 1
             prp2 (optional) are properties for formulation 2 and so on.
       The applied formulation is specified by 
             xa_newdocument(problemtype,propertyset);
                 problemtype    : 'magnetic','electric','thermal','electrokinetic'
                 propertyset    : number of the property set to be used
       e.g. to build a magnetic model using prp0 and prp1 to specify
       properties: xa_newdocument('magnetic',1);
       try to use 1,2,3,4 for magnetic, electric, thermal, electrokinetic
       formulations, respectively, as much as possible
    3. All information about the formulation is gathered in the global
       variable xa_formulation.
       default: xa_formulation=struct('problemtype','magnetic');
    4. The wrappers allow to become independent of syntax changes
       occurring in FEMM from one version to the following.
    5. The wrappers introduce common names for similar parameters, which
       is sometimes not the case in FEMM.
