function vec_out = roty(vec_in, angle)
mat = [cos(angle), 0, sin(angle); 0 1 0; -sin(angle), 0, cos(angle)];
vec_out = mat*vec_in.';
end

