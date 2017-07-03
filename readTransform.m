function [ transform ] = readTransform( filename )
%loadTransformFromSlcier import affine transform saved from slicer (.mat)
%as a 4x4 matrix (pre-multiplication/column vector notation). 
%   Note that function was written for linear transforms only.

T_itkConventions = loadTransformFromFile(filename);
T_slicerConventions = convertTransfromFromItkToSlicer(T_itkConventions);

transform = T_slicerConventions;
end

function [T_itkConventions] = loadTransformFromFile(filename)

[~,~,ext] = fileparts(filename);

if strcmp(ext,'.mat')
    fileContents = load(filename);
    fieldName = 'AffineTransform_double_3_3';
    try
        transformVector = fileContents.(fieldName); %getfield(fileContents, fieldName);
    catch
        error(['Field ' fieldName ' not found in data loaded from ' filename])
    end
elseif strcmp(ext, '.h5')
    groupName = '/TransformGroup/0/TranformParameters'; %sic - transform intentionally misspelled (tranform)
    try
        transformVector = h5read(filename,groupName);
    catch
        error('"h5read" failed. Check that filename is correct/file folder is in MATLAB path')
    end
else
    error(['File extension "' ext '" not recognized'])
end

if ~isequal(size(transformVector),[12 1])
    error('Unexpected behaviour. Data loaded from file was incorrect size. Ensure that transform being loaded is linear.')
end

T_itkConventions = eye(4);
T_itkConventions(1:3,:) = reshape(transformVector,3,4);
end

function [T_slicer] = convertTransfromFromItkToSlicer(T_itk)
%Converts transform to be as displayed in 3D Slicer's 'transforms' node
%using method described here: https://www.slicer.org/wiki/Documentation/Nightly/Modules/Transforms#Transform_files

%Briefly, Slicer uses the RAS coordinate system and displays transforms
%from moving to fixed coordinate systems, however they are saved according
%to ITK conventions which use LPS and transforms from fixed to moving.

lps2ras = eye(4);
lps2ras(1,1) = -1;
lps2ras(2,2) = -1;

ras2lps = lps2ras; %diagonal matrixes, therefore same as inverse (M = M^-1)
T_slicer = inv( lps2ras*T_itk*ras2lps);
end