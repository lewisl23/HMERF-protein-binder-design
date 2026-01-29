## Steps
1. AlphaFold2 used to predict wildtype titin Ig152 / Fn3 119
2. YASARA used to create mutated titin Ig152 / Fn3 119 by replacing Cystseine 102 
with Arginine and Proline 122with Leucine
3. RFdiffusion creates protein backbone aimed to bid to wildtype Ig152 / Fn3 119 domain
4. ProteinMPNN generates amino acids that are predicted to fold into the 3D backbone structure
5. Molecular Dynamic simulation

## Note: 
### 1. data_analysis_drug_53-244_173.R is for analysis off long simulation
### 2. data_analysis_drug_53-244.R is for superimposition on Ca backbone 53-244
### 3. data_analysis_drug_58-249.R is for superimposition on Ca backbone 53-249