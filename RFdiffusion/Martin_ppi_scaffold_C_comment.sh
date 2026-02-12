#!/bin/bash
# Here, we're making a binder, and we're specifying the course-grained topology of the binder, from a set of processed inputs
# We tell RFdiffusion that we want to do "scaffoldguided" diffusion (i.e. we want to specify the fold of the protein)
# We tell RFdiffusion where on the (cropped) input protein we want to bind, in this case to residues 496, 498, 499, 500, 502, 520, 522, 523, 525, and 529 on the A chain
# We tell RFdiffusion that we're wanting to make a binder to a target, and provide the secondary structure and block adjacency input for these. This may not be necessary
# We then provide a path to a directory of different scaffolds (we've provided some for you to use, from Cao et al., 2022)
# We generate 2000 designs, and reduce the noise added during inference to 0 (which improves the quality of designs)

../scripts/run_inference.py scaffoldguided.target_path=input_pdbs/Martin.pdb inference.output_prefix=martin_outputs/martin_ppi_C scaffoldguided.scaffoldguided=True 'ppi.hotspot_res=[A496,A498,A499,A500,A502,A520,A522,A523,A525,A529]' scaffoldguided.target_pdb=True scaffoldguided.target_ss=target_folds/Martin_ss.pt scaffoldguided.target_adj=target_folds/Martin_adj.pt scaffoldguided.scaffold_dir=./ppi_scaffolds/ inference.num_designs=2000 denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0