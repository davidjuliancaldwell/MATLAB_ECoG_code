#!/bin/bash

## Job  name

#SBATCH --job-name=phase_calculation

## Allocation definition

#SBATCH --account=gridlab
#SBATCH --partition=gridlab

## Resources
## Nodes
#SBATCH --nodes=1

## Walltime 

#SBATCH --time=80:00:00

## memory per node

#SBATCH --mem=100G

## working directory for this job

#SBATCH --workdir=/gscratch/gridlab/djcald/MATLAB_ECoG_Code/BetaTriggeredStim/phaseVisualizations

## turn on e mail
#SBATCH --mail-type=ALL
#SBATCH --mail-user=djcald@uw.edu

export TZ="America/Los_Angeles"

module load matlab_2018a
matlab -nosplash -nodisplay -r B_ExctractNeuralDataDJC_phaseCalc_allChans_processed
