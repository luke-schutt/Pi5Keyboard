include <chamfer_extrude.scad>;
$fn = 30;

// Thickness of the PCB.
$pcb_thickness = 7;
// Tolerance for fitting the PCB within the bezel.
$pcb_tolerance = 0.75;
// Width for the PCB lip.
$pcb_lip = 1.75;

// Desired cavity depth, excluding PCB.
$cavity_depth = 2.25;
// Case bottom thickness.
$bottom_thickness = 2;
// Case wall thickness above the PCB lip, at the thickest point.
$wall_thickness = 4;
// Full cavity depth.
cavity_well = $cavity_depth + $pcb_thickness;
// Full case height.
case_height = cavity_well + $bottom_thickness;

// If the top-outer edge should be chamfered.
$chamfer = true;
// The size of the chamfer.
$chamfer_size = 2.5;

// Mounting nut size.
$nut_size = 4.15;
// Mounting nut height.
$nut_height = 1.6;
// Mounting post radius.
$post_radius = 3.5;
// Mounting post hole radius.
$post_hole = 1.25;
// Mounting nut radius.
nut_radius = ($nut_size / 2) / cos(180 / 6);
// Vertical adjustment with the SVG Y inversion.
y_height = 8.5 * 25.4;
// Mounting post locations.
mounting_points = [
    // Pi Pico mounting holes.
    [136.8, y_height - 75.5],
    [148.2, y_height - 75.5],
    [136.8, y_height - 122.5],
    [148.2, y_height - 122.5],
    // Main mounting holes.
    [49.429641, y_height - 81.604177],
    [44.141063, y_height - 119.234364],
    [235.569953, y_height - 81.603467],
    [240.85853, y_height - 119.233654],
    // V0 mounting holes.
    [127.5, y_height - 131],
    [157.5, y_height - 131]
];
// Foot width.
foot_width = 12;
// Foot height.
foot_height = 1.75;
// Foot thickness.
foot_thickness = 1.25;
// Feet locations.
foot_positions = [
    [142.5, y_height - 118.5, 90],
    [114, y_height - 137.5, 90],
    [171, y_height - 137.5, 90],
    [41.5, y_height - 71, 0],
    [33.3, y_height - 128, 0],
    [243.5, y_height - 71, 0],
    [251.7, y_height - 128, 0]
];

// Import the PCB outline.
module pi5_pcb() {
    import(file = "pcb.svg");
}

// Mounting post negative.
module mounting_drill() {
    union() {
        // Post bolt hole.
        cylinder(h = cavity_well, r = $post_hole);
        // Post nut recess.
        translate([0, 0, (case_height - $pcb_thickness - $nut_height - 0.001)])
            cylinder(h = $nut_height + 0.002, r = nut_radius, $fn = 6);
    }
}

// Create a mounting positive.
module mounting_post() {
    cylinder(h = case_height - $pcb_thickness, r = $post_radius);
}

// Loop throguh mounting post positions.
module post_positions() {
    for (index = [0 : len(mounting_points) - 1]) {
        point = mounting_points[index];
        translate([point[0], point[1], 0])
            children();
    }
}

module foot_disc_recess() {
    cylinder(h = foot_thickness, r = 3.1, center = true);
}

union() {
    // Main case positive.
    difference() {
        // Main case shape.
        linear_extrude(height = case_height)
            offset(delta = $wall_thickness + $pcb_tolerance)
            pi5_pcb();
        // Case to subtract above the PCB lip.
        translate([0, 0, (case_height - $pcb_thickness)])
            linear_extrude(height = case_height)
            offset(delta = $pcb_tolerance)
            pi5_pcb();
        // Case to subtract making up the PCB lip.
        translate([0, 0, $bottom_thickness])
            linear_extrude(height = case_height)
            offset(delta = (0 - $pcb_lip))
            pi5_pcb();
        // Mounting post cutouts.
        post_positions()
            mounting_drill();
        // Add the chamfer.
        if ($chamfer) {
            translate([0, 0, (case_height - $chamfer_size + 0.001)])
                difference() {
                    linear_extrude(height = $chamfer_size)
                        offset(delta = $wall_thickness + $pcb_tolerance)
                        pi5_pcb();
                    chamfer_extrude(height = $chamfer_size, angle = 45, $fn = 10)
                        offset(delta = ($wall_thickness + $pcb_tolerance - $chamfer_size + 0.001))
                        pi5_pcb();
            }
        }
        // Subtract the area for USB.
        translate([142.5, 144, $bottom_thickness + $cavity_depth + 3.5])
            cube([8.5, 5, 3.5], center = true);
        translate([142.5, 147.5, $bottom_thickness + $cavity_depth + 3.5])
            cube([12.5, 5, 7.5], center = true);
        // Subtract positions for feet.
        for (index = [0 : len(foot_positions) - 1]) {
            foot_data = foot_positions[index];
            translate([foot_data[0], foot_data[1], 0])
                rotate([0, 0, foot_data[2]])
                cube([foot_width, foot_height, foot_thickness], center = true);
        }
        translate([33.411372, y_height - 127.319766, 0])
            foot_disc_recess();
        translate([251.588221, y_height - 127.319056, 0])
            foot_disc_recess();
        translate([41.344239, y_height - 70.874486, 0])
            foot_disc_recess();
        translate([243.655355, y_height - 70.873776, 0])
            foot_disc_recess();
    }
    // Mounting post positives.
    difference() {
        post_positions()
            mounting_post();
        post_positions()
            mounting_drill();
    }
}