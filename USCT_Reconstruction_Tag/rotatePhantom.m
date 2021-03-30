function new_p = rotatePhantom(p, Angle, Center)
% p: n by 3 -- n * [px, py, pz]
% angle is row vector: 1 by #angles
% center is row vector: 1 by 3 -- [x, y, z]
% modify to multiple points phantom

size_phantom = size(p,1);
size_angle = size(Angle,2);
Angle = deg2rad(Angle);
new_p = zeros(size_phantom,3,size_angle);

for n = 1:size_angle
    for m = 1:size_phantom
        old_position = p(m,:);
        vec = (old_position - Center);
        new_position = roty(vec, Angle(n)) + Center.';
        new_p(m,:,n) = new_position.';
    end
end


end