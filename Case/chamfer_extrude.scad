module chamfer_extrude(height = 2, angle = 10, center = false) {
    /*
       chamfer_extrude - OpenSCAD operator module to approximate
        chamfered/tapered extrusion of a 2D path
    
       (C) 2019-02, Stewart Russell (scruss) - CC-BY-SA
    
       NOTE: generates _lots_ of facets, as many as
    
            6 * path_points + 4 * $fn - 4
    
       Consequently, use with care or lots of memory.
    
       Example:

            chamfer_extrude(height=5,angle=15,$fn=8)square(10);
    
       generates a 3D object 5 units high with top surface a
        10 x 10 square with sides flaring down and out at 15
        degrees with roughly rounded corners.
    
       Usage:
       
        chamfer_extrude (
            height  =   object height: should be positive
                            for reliable results               ,
            
            angle   =   chamfer angle: degrees                 ,
            
            center  =   false|true: centres object on z-axis [ ,
            
            $fn     =   smoothness of chamfer: higher => smoother
            ]
        ) ... 2D path(s) to extrude ... ;
        
       $fn in the argument list should be set between 6 .. 16:
            <  6 can result in striking/unwanted results
            > 12 is likely a waste of resources.
            
       Lower values of $fn can result in steeper sides than expected.
        
       Extrusion is not truly trapezoidal, but has a very thin
        (0.001 unit) parallel section at the base. This is a 
        limitation of OpenSCAD operators available at the time.
        
    */
    
    // shift base of 3d object to origin or
    //  centre at half height if center == true
    translate([ 0, 
                0, 
                (center == false) ? (height - 0.001) :
                                    (height - 0.002) / 2 ]) {
        minkowski() {
            // convert 2D path to very thin 3D extrusion
            linear_extrude(height = 0.001) {
                children();
            }
            // generate $fn-sided pyramid with apex at origin,
            // rotated "point-up" along the y-axis
            rotate(270) {
                rotate_extrude() {
                    polygon([
                        [ 0,                    0.001 - height  ],
                        [ height * tan(angle),  0.001 - height  ],
                        [ 0,                    0               ]
                    ]);
                }
            }
        }
    }
}
