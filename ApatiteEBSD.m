% This script calculates the angles between an EPMA or EDS traverse and the crystal
% directions of an apatite crystal determined by EBSD. 

% You must download and install the MTEX toolbox for this script to work.
% http://mtex-toolbox.github.io/pt.

% The Imaging Processing Toolbox is also required.

%% Import the EBSD Data

disp('Choose the .ctf file with the EBSD data.');
[file_name,pname] = uigetfile('*.ctf','Choose the .ctf file with the EBSD data.');
if isequal(file_name,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(pname,file_name)]);
end
fname = [pname file_name];


%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = {... 
  'notIndexed',...
  crystalSymmetry('6/m', [9.5 9.5 6.9], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Apatite', 'color', [0.53 0.81 0.98])};

% plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

%% Import the Data

% create an EBSD variable containing the data
ebsd = EBSD.load(fname,CS,'interface','ctf',...
  'convertSpatial2EulerReferenceFrame');

%% Clean Up EBSD Data

% Eliminate measurements with high MAD values
figure('Name',fname)
histogram(ebsd('Apatite').mad)
prompt1 = 'What is the maximum acceptable MAD value? (usually 1)';
MadMax = input(prompt1);
ebsd_corrected = ebsd(ebsd.mad<MadMax);

% Smooth data using a mean filter (eliminates psuedosymmetry reflectors)
F = meanFilter;
ebsd_smoothed = smooth(ebsd_corrected,F);

%% Calculate the Orientation Density Function (ODF)

odf = calcDensity(ebsd_corrected('Apatite').orientations);

% Calculate the mean of the ODF
m = mean(odf);


%% Calculate the Rotation Matrix of the ODF mean

RotMat = matrix(m);

%% Open and Display Electron Image

disp(['Choose the electron image that corresponds to ', (file_name)]);

[img_name,img_path] = uigetfile({'*.tif';'*.png';'*.jpg'},['Choose the electron image that corresponds to ', (file_name)]);
if isequal(img_name,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(img_path,img_name)]);
end

img_file = [img_path img_name];
figure('Name',img_name);
ElecImage = imread(img_file);
imshow(ElecImage);

%% Traverse Orientation

% Ask the user to draw the traverse line on the electron image
disp('Draw the traverse on the electron image.');
line = drawline(SelectedColor="yellow");
prompt2 = 'Move the line or its endpoints if necessary. When satisfied with the position, press Enter.';
EnterToContinue = input(prompt2);
pos = line.Position;

% Calculate the x and y components and trend of the traverse unit vector
x1 = pos(1,1);
x2 = pos(2,1);
y1 = pos(2,2);
y2 = pos(1,2);
dx = x2-x1;
dy = y2-y1;
TrendOfTrav = atan(dx/dy);
TravX = sin(TrendOfTrav);
TravY = cos(TrendOfTrav);

%% Make Direction Cosines of Crystal Directions and the Traverse

DirCosine1010 = [RotMat(1,1) RotMat(2,1) RotMat(3,1)];
DirCosine0110 = [RotMat(1,2) RotMat(2,2) RotMat(3,2)];
DirCosine0001 = [RotMat(1,3) RotMat(2,3) RotMat(3,3)];
DirCosineTrav = [TravX TravY 0];

%% Calculate the Angles (theta) Between Crystal Directions and Traverse 

Theta1010Trav = acos(dot(DirCosine1010,DirCosineTrav)) / degree;
Theta0110Trav = acos(dot(DirCosine0110,DirCosineTrav)) / degree;
Theta0001Trav = acos(dot(DirCosine0001,DirCosineTrav)) / degree;

%% Produce the Results Matrix

TravEuler = orientation.byEuler(TrendOfTrav, 0, 0, CS{1,2});  % converts TrendOfTrav to orientation matrix
TravAzimuth = (TravEuler.phi1) / degree;  % extracts phi1 from the TravEuler matrix
TravVector = vector3d(DirCosineTrav); % puts the direction cosine of the traverse into a vector for plotting

if Theta1010Trav < 90
    Theta1010Trav = Theta1010Trav;
elseif (Theta1010Trav >= 90) && (Theta1010Trav < 180)
    Theta1010Trav = 180-Theta1010Trav;
elseif (Theta1010Trav >= 180) && (Theta1010Trav < 270)
    Theta1010Trav = Theta1010Trav-180;
elseif (Theta1010Trav >= 270) && (Theta1010Trav > 360)
    Theta1010Trav = 360-Theta1010Trav;
elseif Theta1010Trav == 360
    Theta1010Trav = 0;
end


if Theta0110Trav < 90
    Theta0110Trav = Theta0110Trav;
elseif (Theta0110Trav >= 90) && (Theta0110Trav < 180)
    Theta0110Trav = 180-Theta0110Trav;
elseif (Theta0110Trav >= 180) && (Theta0110Trav < 270)
    Theta0110Trav = Theta0110Trav-180;
elseif (Theta0110Trav >= 270) && (Theta0110Trav > 360)
    Theta0110Trav = 360-Theta0110Trav;
elseif Theta0110Trav == 360
    Theta0110Trav = 0;
end


if Theta0001Trav < 90
    Theta0001Trav = Theta0001Trav;
elseif (Theta0001Trav >= 90) && (Theta0001Trav < 180)
    Theta0001Trav = 180-Theta0001Trav;
elseif (Theta0001Trav >= 180) && (Theta0001Trav < 270)
    Theta0001Trav = Theta0001Trav-180;
elseif (Theta0001Trav >= 270) && (Theta0001Trav > 360)
    Theta0001Trav = 360-Theta0001Trav;
elseif Theta0001Trav == 360
    Theta0001Trav = 0;
end



Results = [Theta1010Trav Theta0110Trav Theta0001Trav TravAzimuth];

display_txt = sprintf(['Theta(1010) = %d' char(176)  '  Theta(0110) = %d' char(176)  '  Theta(0001) = %d' char(176) ...
    '  TravAzimuth = %d' char(176)], round(Theta1010Trav), round(Theta0110Trav), round(Theta0001Trav), round(TravAzimuth));
disp('Results:');
disp(display_txt);

%% Output the Results to a .csv File

% Write the text strings for the headers
HdrTxt1=sprintf('%s\t',file_name);
hdr2 = {'TravAzimuth','Theta(1010)','Theta(0110)','Theta(0001)'};

ResultsFile = fullfile(pname, 'ApatiteEBSD_Results.csv'); % Sets the save location to the folder where the EBSD data is located.
writematrix(HdrTxt1, ResultsFile, 'WriteMode', 'append', "Delimiter",","); % Adds header 1 text to the results file
writecell(hdr2, ResultsFile,'WriteMode', 'append', "Delimiter",","); % Adds header 2 text (results column names) to the results file
writematrix(round(Results,2), ResultsFile, 'WriteMode', 'append', "Delimiter",",");  % Adds the results to the results file

disp(['These results were added to the ApatiteEBSD_results.csv file in ' (pname)]);

%% Plot Pole Figures

% define the Miller indices
PFmiller = [Miller(1,0,0,odf.CS),Miller(0,1,0,odf.CS),Miller(0,0,1,odf.CS)];

% Plot pole figure and add the traverse orientation and mean of ODF
figure('Name',fname) % create a blank figure
plotPDF(odf,PFmiller) % plot a pole figure of the data
annotate(m,'label',{'mean'},'MarkerSize',15,'MarkerEdgeColor','black',...
   'MarkerFaceColor','none') % add the mean of the data to the plot
annotate(TravVector, 'label', {'traverse'}, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red') % add the traverse orientation to the plot
annotate(-TravVector, 'label', {'traverse'}, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red') % add the supplementary traverse orientation to the plot
