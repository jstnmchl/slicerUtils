function []=writeMarkupsFiducial(points,filename)
%Pre-Conditions: Filename includes file extension. 'Points' is Nx3

%%Export points to file

[~,~,ext] = fileparts(filename);

if ~strcmp(lower(ext),'.fcsv')
    error(['Incompatible filename extension. Extension must be .fcsv (case insensitive). Extension given was ' ext ])
end

%Open file 
fid=fopen(filename, 'w+');

%write header
fprintf(fid, '# Markups fiducial file version = 4.4\r\n');
fprintf(fid, '# CoordinateSystem = 0\r\n');
fprintf(fid, '# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID\r\n');

%Write data
for j=1:size(points,1) %write each row on new line; elements seperated by spaces
    fprintf(fid, 'vtkMRMLMarkupsFiducialNode_%d,%f,%f,%f,0,0,0,1,1,1,0,F-%d,,vtkMRMLScalarVolumeNode1\r\n',j-1,points(j,1),points(j,2),points(j,3),j);
end

fclose(fid);

end