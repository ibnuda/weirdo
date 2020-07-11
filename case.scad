use_2u_left = false;
use_2u_right = false;
bottom_thickness = 5;
function cave_thickness(use_2u) = use_2u ? 7 : 5;
function plate_thickness(use_2u) = use_2u ? 3 : 5;
function lower_thickness(use_2u) = bottom_thickness +
                                   cave_thickness(use_2u);
function sandwich_thickness(use_2u) = lower_thickness(use_2u) +
                                      plate_thickness(use_2u);

module sector(radius, angles, fn = 60)
{
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat(
        [[ 0, 0 ]],
        [for (a = [angles[0]:step:angles[1] - 360])[r * cos(a), r * sin(a)]],
        [[r * cos(angles[1]), r * sin(angles[1])]]);

    difference()
    {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

stagger = [ -44, -31, -29, -33, -35 ];

module alpha_holes(width = 14)
{
    for (j = [0:2]) {
        for (i = [0:4]) {
            translate([ (30 + i * 19), (stagger[i] - j * 19), 0 ])
            {
                square(size = [ width, width ], center = true);
            }
        }
    }
}

module
thumb_2u()
{
    translate([ 7, -6.3, 0 ])
    {
        rotate([ 0, 0, -30 ]) { import("2u-cutout.dxf"); }
    }
}

module
shape_of_promicro()
{
    translate([ -15, 0, 0 ]) square(size = [ 63, 20 ], center = true);
}

module
shape_of_rj45()
{
    translate([ -4, -39, 0 ]) square(size = [ 17, 44 ], center = false);
}

module
shape_of_pcb()
{
    union()
    {
        difference()
        {
            translate([ 78, -132, 0 ]) { sector(115, [ 70, 121 ]); }
            translate([ 78, -132, 0 ]) { sector(15, [ 69, 122 ]); }
        }
        polygon(points = [
            [ 18.81, -33.5 ],
            [ 18.81, -92.5 ],
            [ 32, -92.5 ],
            [ 67.82, -118.982 ],
            [ 117.24, -107 ],
            [ 117.24, -24 ]
        ]);
        translate([ 86, -86, 0 ]) { sector(37.68, [ 241, 326.1 ]); }
    }
}

module base_case(use_2u)
{
    difference()
    {
        minkowski()
        {
            translate([ 0, 0, 13 ]) sphere(r = 13);
            linear_extrude(height = 0.1) { shape_of_pcb(); }
        }
        translate([ 0, 0, bottom_thickness ])
            linear_extrude(height = cave_thickness(use_2u)) shape_of_pcb();
        translate([ 0, 0, lower_thickness(use_2u) ])
            linear_extrude(height = plate_thickness(use_2u)) alpha_holes(14);
        translate([ 0, 0, sandwich_thickness(use_2u) ]) linear_extrude(height = 18)
            alpha_holes(19.5);
        if (use_2u) {
            translate([ 93, -104, lower_thickness(use_2u) ]) rotate([ 0, 0, 323.4 ])
                linear_extrude(height = plate_thickness(use_2u)) thumb_2u();
            translate([ 93, -104, sandwich_thickness(use_2u) ]) rotate([ 0, 0, 323.4 ])
                linear_extrude(height = 18)
                    square(size = [ 19.5, 39 ], center = true);
        } else {
            translate([ 98.7, -96.3, lower_thickness(use_2u) ]) rotate([ 0, 0, 233.4 ])
                linear_extrude(height = plate_thickness(use_2u))
                    square(size = [ 14, 14 ], center = true);
            translate([ 98.7, -96.3, sandwich_thickness(use_2u) ])
                rotate([ 0, 0, 233.4 ]) linear_extrude(height = 18)
                    square(size = [ 19.5, 19.5 ], center = true);
        }
    }
}

module
left_case()
{
    difference()
    {
        base_case(use_2u_left);
        translate([ 72, -98, bottom_thickness ]) rotate([ 0, 0, 53.4 ])
            linear_extrude(height = 12) shape_of_promicro();
        translate([ 50.5, -86, bottom_thickness ]) rotate([ 0, 0, 323.4 ])
            linear_extrude(height = 22) shape_of_rj45();
    }
}

module
bottom_left_case()
{
    difference()
    {
        left_case();
        translate([ 0, -400, lower_thickness(use_2u_left) ])
            cube(size = [ 400, 400, 30 ], center = false);
    }
}

module
top_left_case()
{
    difference()
    {
        left_case();
        translate([ 0, -400, (0 - 30 + lower_thickness(use_2u_left)) ])
            cube(size = [ 400, 400, 30 ], center = false);
    }
}

module
right_case()
{
    difference()
    {
        translate([ 235, 0, 0 ]) mirror(v = [ 1, 0, 0 ])
            base_case(use_2u_right);
        translate([ 177, -91, bottom_thickness ]) rotate([ 0, 0, 36.6 ])
            linear_extrude(height = 22) shape_of_rj45();
    }
}

module
bottom_right_case()
{
    difference()
    {
        right_case();
        translate([ 77, -400, lower_thickness(use_2u_right) ])
            cube(size = [ 400, 400, 30 ], center = false);
    }
}

module
top_right_case()
{
    difference()
    {
        right_case();
        translate([ 77, -400, (0 - 30 + lower_thickness(use_2u_right)) ])
            cube(size = [ 400, 400, 30 ], center = false);
    }
}

module base_plate(use_2u)
{
    difference()
    {
        shape_of_pcb();
        alpha_holes(14);
        if (use_2u) {
            translate([ 93, -104, 0 ]) rotate([ 0, 0, 323.4 ]) thumb_2u();

        } else {
            translate([ 98.7, -96.3, 0 ]) rotate([ 0, 0, 233.4 ])
                square(size = [ 14, 14 ], center = true);
        }
    }
}

module
left_plate()
{
    difference()
    {
        base_plate(use_2u_left);
        translate([ 72, -98, 0 ]) rotate([ 0, 0, 53.4 ]) shape_of_promicro();
        translate([ 50.5, -86, 0 ]) rotate([ 0, 0, 323.4 ]) shape_of_rj45();
    }
}

module
right_plate()
{
    difference(use_2u_right)
    {
        translate([ 235, 0, 0 ]) mirror(v = [ 1, 0, 0 ]) base_plate();
        translate([ 177, -91, 0 ]) rotate([ 0, 0, 36.6 ]) shape_of_rj45();
    }
}

module
left_pcb()
{
    union()
    {
        color("navy") linear_extrude(height = 1.6) shape_of_pcb();
        color("pink") translate([ 50.5, -86, 1.7 ]) rotate([ 0, 0, 323.4 ]) linear_extrude(height = 14) shape_of_rj45();
        color("gray") translate([ 72, -98, 0 ]) rotate([ 0, 0, 53.4 ]) linear_extrude(height = 7) shape_of_promicro();
        color("aqua") linear_extrude(height = 16) alpha_holes();
    }
}


// left_case();
// right_case();

// bottom_right_case();
// translate([ -150, 0, -lower_thickness(use_2u_right) ]) top_right_case();

// bottom_left_case();
// translate([ 150, 0, -lower_thickness(use_2u_left) ]) top_left_case();

// left_plate();
// right_plate();