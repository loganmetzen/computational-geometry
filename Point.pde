//Logan Metzen U7649553

class Point {
  
   public PVector p;
   boolean found = false;
   public Point( float x, float y ){
     p = new PVector(x,y);
   }

   public Point(PVector _p0 ){
     p = _p0;
   }
   
   public void draw(){
     fill(165);
     stroke(0);
     ellipse( p.x,p.y, 30, 30);
   }
   
   public void drawLeft(){
     fill(217, 15 , 30);
     ellipse ( p.x, p.y, 30, 30 );
     //nofill(); Look up the other thing that makes/clears presets or make your own
     }
   float getX(){ return p.x; }
   float getY(){ return p.y; }
   
   void setX(float x){ p.x = x; }
   void setY(float y){ p.y = y; }
   
   void incrementX(){
     p.x = p.x + 7;
   }
   
   void incrementY(){
     p.y = p.y + 7;
   }
   
   void decrementX(){
     p.x = p.x - 7;
   }
   float x(){ return p.x; }
   float y(){ return p.y; }
   float angle;
   
   public float distance( Point o ){
     return PVector.dist( p, o.p );
   }
   
   public String toString(){
     return p.toString();
   }
   
   
}

class SortByAngle implements Comparator<Point>{
  
  public int compare(Point a, Point b){
    if(a.angle - b.angle > 0){
      return 1;
    }
    else if(a.angle - b.angle < 0){
      return -1;
    }
    else{
      return 0;
    }
  }
  
}
