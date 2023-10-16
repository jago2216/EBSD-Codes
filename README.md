# README file for ApatiteEBSD.m, OlivineEBSD.m, and OrthopyroxeneEBSD.m
## Matlab codes used for determining angles between crystallographic axes and orientations of microanaltyical traverses

### Introduction
These Matlab scripts are designed to calculate the angles between the orientations of the crystallographic axes (measured by EBSD) and the orientation of an analytical traverse across a crystal, utilizing the MTEX toolbox. After importing the EBSD data, the traverse orientation is drawn by the user on an electron image that was collected in the same orientation as the EBSD data.
These codes are intended to be used for diffusion chronometry when diffusivity is anisotropic. 

### Dependencies
- MTEX toolbox for working with EBSD data in Matlab (https://mtex-toolbox.github.io/index)
- Matlab's Image Processing Toolbox

### Input Files
- A channel text file (.ctf) exported from Oxford's Aztec software containing the EBSD data (Euler angles)
- An electron image of the crystal collected with the same orientation as the EBSD data

### Usage
- After installing the dependencies, the .m files can be run in Matlab by following the prompts that appear in the Command Window:
- The user will be asked to import a .ctf file containing the EBSD data.
- An MTEX EBSD class containing the data will be created.
- Data cleanup involves the user selecting the largest acceptable mean angular deviation (MAD) value. This is to remove outliers or points accidently obtained from nearby crystals.
- The user then be prompted to select an electron image corresponding to the EBSD data.
- The user then is prompted to draw a line along the microanalytical traverse.
- After the calculations have been performed the results (i.e., angles between the drawn traverse and crystallographic axes) will be displayed and exported into a .csv file in the same directory as the .ctf file that was imported.
- A pole figure showing the orientations of the crystallographic axes and the microanalytical traverse will also be displayed and can be saved by the user.

### Example Data
A data file (OpxTestData.ctf) and corresponding electron image (OpxTestImage.png) for an orthopyroxene crystal can be used to try the orthopyroxene code (OrthopyroxeneEBSD.m). The codes for the other minerals work in the same way.

### Other Uses
The codes can be modified and used for other purposes. 
In order to adapt this code for other minerals,  the crystal system variable (CS) must be changed. The CS for other minerals can be generated using the Import EBSD data function of MTEX. 

This program is free software, and it can be redistributed and/or modified under the terms of the MIT License. No warranties are given.

### Testing
The codes have been verified to work with Matlab R2023b and MTEX v. 5.8.2.
