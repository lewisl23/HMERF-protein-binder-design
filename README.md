# The effect of AI designed de novo protein binders on the stability of HMERF mutated Titin domain Fn3-119

This is the BSc Biochemistry dissertation repository that uses RF diffusion / 
Protein MPNN designed protein binders aimed to stabalise mutated titin Fn3-119 
domain movement in Hereditary myopathy with early respiratory failure (HMERF) patient.
For this project, molecular dynamic (MD) simulation was run on wildtype and mutant
titin Ig-152 / Fn3-119 domain with Principal component analysis (PCA) to identify 
domain bending movement in mutant. RF diffusion was used to design 2000 protein backbones
scaffolds with interface hotspot residues for the protein binders to target. Protein MPNN
creates 2 amino acid seqeuences for each protein backbone that resulted in a total of 4000
amino acid sequences. Using AlphaFold multimer and PAE scoring, 6 protein structures are
chosen to bound onto the wildtype and mutant protein domain that results in 12 protein complexes.
10 runs of 1µs MD simulations are set for each complex and the RMSD and hinge bending
angles are analysed from the simulation.


## Steps of the project

### 1. AlphaFold2 used to predict wildtype titin Ig152 / Fn3 119
### 2. YASARA used to create mutated titin Ig152 / Fn3 119 by replacing Cystseine 102 with Arginine and Proline 122with Leucine
### 3. RFdiffusion creates protein backbone aimed to bid to wildtype Ig152 / Fn3 119 domain
### 4. ProteinMPNN generates amino acids that are predicted to fold into the 3D backbone structure
### 5. Molecular Dynamic simulation

## Note: 
### 1. data_analysis_drug_53-244_173.R is for analysis of long simulation
### 2. data_analysis_drug_53-244.R is for superimposition on Ca backbone 53-244
### 3. data_analysis_drug_58-249.R is for superimposition on Ca backbone 53-249
### 4. file_convert_frame100.sh converts the MD simualtion from nc to xtc and dcd file type for easier storage and access

In MD

1. leap.in tells what s included in the system including force field (ff14SB, TIP3P water, phosphorylated amino acids (phosaa14SB), and ion parameter) Also add ion to neutralise and reaches specific salt concentration
2. md-vac-prep.sh is used to debug force field and verify protonation state before official run with md-wat-prep.sh