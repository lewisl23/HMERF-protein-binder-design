# The effect of AI designed de novo protein binders on the stability of HMERF mutated Titin domain Fn3-119

This is the BSc Biochemistry dissertation repository that uses RF diffusion/Protein MPNN-designed protein binders to stabilise mutated titin Fn3-119 domain movement in Hereditary myopathy with early respiratory failure (HMERF) patients. 

For this project, molecular dynamics (MD) simulations were run on wildtype and mutant titin Ig-152 / Fn3-119 domains with Principal Component Analysis (PCA) to identify domain bending movement in the mutant. RF diffusion was used to design 2000 protein backbone scaffolds with interface hotspot residues on the titin domains for the protein binders to target. Protein MPNN creates 2 amino acid sequences for each protein backbone, resulting in a total of 4000 amino acid sequences. Using AlphaFold multimer and PAE scoring, 6 protein structures are chosen to bind onto the wildtype and mutant protein domain, resulting in 12 protein complexes. 10 runs of 1µs MD simulations are set for each complex, and the RMSD and hinge bending angles are analysed from the simulation.

## Methods

### 1. Identification of bending movements in mutant titin Ig-152 / Fn3-119
- AlphaFold2 was used to predict wildtype titin Ig-152 / Fn3-119 structure using amino acid sequences
- YASARA was used to create mutation on the wildtype structure, resulting in the mutant
- PCA analysis of the MD simulations identified domain bending movements in the mutant when compared with wildtype.


### 2. Protein binder design using RFdiffusion and Protein MPNN
- RFdiffusion creates 2000 protein backbone aimed to bind to wildtype Ig-152 / Fn3-119 domain
- ProteinMPNN generates 2 amino acids that are predicted to fold into each of the 3D backbones (4000 in total)
- 6 protein binder candidates are chosen using the PAE score
- AlphaFold multimer used to predict protein complexes with the 6 protein binders binds onto the wildtype and mutant Ig-152 / Fn3-119 domain

### 3. Selection of most suitable protein binder candidate
- 10 1 microsecond MD simulations was run on each of the 12 protein complexes
- Analysis on RMSD and bending angles from the MD simulations to select most suitable protein binder
that can stabilise the mutant structure

## Results
- Protein binder reduces the RMSD and bending movement of the mutant Ig-152 / Fn3-119 domain, allowing the mutant to behave close to the wildtype.
