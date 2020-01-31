//Logan Metzen U7649553

class Triangle {
  
   Point p0,p1,p2;
     
   Triangle(Point _p0, Point _p1, Point _p2 ){
     p0 = _p0; p1 = _p1; p2 = _p2;
   }
   
   void draw(){
     if( cw() ) {
      //color red
      fill(255, 0 ,0);
    }
    else{
      //color green
      fill(0, 255, 0);
    }
    triangle(  p0.p.x, p0.p.y, 
               p1.p.x, p1.p.y,
               p2.p.x, p2.p.y );   

   }
   
   boolean ccw(){
     PVector v1 = PVector.sub( p1.p, p0.p );
     PVector v2 = PVector.sub( p2.p, p0.p );
     float z = v1.cross(v2).z;
     return z > 0;
   }
   
   boolean cw(){
     PVector v1 = PVector.sub( p1.p, p0.p );
     PVector v2 = PVector.sub( p2.p, p0.p );
     float z = v1.cross(v2).z;
     return z < 0;
   }
   
   
}
