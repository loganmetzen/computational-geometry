//Logan Metzen U7649553

import java.util.*;

//Holds every point we generate, points should still be drawn even if they are excluded from the convex hull
ArrayList<Point>    points      = new ArrayList<Point>(); 

//Holds every edge between initially sequential points in polar order.
//In this case however, edges will be removed from here and subsequently not drawn if a point is eliminated from the convex hull in phaseNum 3
ArrayList<Edge>     edges       = new ArrayList<Edge>();

//Only used when drawing the rudimentary hull when phaseNum = 2
ArrayList<Edge>     dottedEdges = new ArrayList<Edge>();

//The end product
Polygon             convexHull  = new Polygon();

//Current testing triangle, used when phaseNum = 4
Triangle            t;

//Used for incrementally constructing hull when phaseNum = 4.
Stack<Point> cHullTemp = new Stack<Point>();
Object[] pointsEdges = new Object[2];
Object[] newData = new Object[5]; //Used for incrementally processing convex hull -> should create a class that stores everything instead of this Object array

//Makes drawing the leftmost point every frame more convenient, also useful for drawing sweepline
Point leftmost;

//This is the other point in the sweepline that is drawn in phaseNum 0
Point rightSweep;

//Prefer to check flags, instead of checking if corresponding values are null.
boolean foundLeftmost = false; 

//For drawing sweepline.
boolean reachedTop = false; 
boolean sweepStarted = true;

//Used in phaseNum 3, during the first iteration of constructing the hull we should take the first two elements from points and push them to the stack to get the algorithm started.
boolean firstRun = true;
boolean pointsGenerated = false;


//Good starting point for number of points generated, can be adjusted with '+' or '-'
int numOfPoints = 10;

//Main variable for determing program's state
int phaseNum = 0; 

//Keeps track of index of points arraylist for easier access
int index = 1;

//Initial phase, changes with phaseNum
String phase = "Pre-Processing";

//Called when the user presses 'g' at the beginning of the program. Generates the number of random points set by the user
void generateRandomPoints(){
  //Ensures that points are not drawn completely over top of text that will be displayed on screen
  for( int i = 0; i < numOfPoints; i++){
    points.add( new Point( random(100,width-100), random(100,height-100) ) );
  }
}

//Walks user through convex hull
void calculateConvexHull(){
  switch(phaseNum){
    //I set the phaseNum to -1 to represent error cases when I was debugging/testing, not in use currently
    case -1:
      break;
    
    case 0:
      //phase = "Pre-Processing";
      leftmost = PreProcessing( points );
      rightSweep = new Point(leftmost.x(), 0);
      foundLeftmost = true;
      break;
    case 1:
      pointsEdges = RudimentaryHull(points, leftmost);
      //edges = (ArrayList)pointsEdges[1];
      break;
    case 2:
      //phase = "Rudimentary Hull";
      pointsEdges = RudimentaryHull(points, leftmost);
      edges = (ArrayList)pointsEdges[1];
      break;
    case 3:
      if(firstRun){
        cHullTemp.push(leftmost);
        cHullTemp.push(((ArrayList<Point>)pointsEdges[0]).get(0));
        
        Object[] data = new Object[5];
        data[0] = pointsEdges[0];
        data[1] = edges; //pointsEdges[1];
        data[2] = cHullTemp;
        data[4] = index;
        newData = IncrementalHull(data);
        firstRun = false;
      }
      else{
       StepThroughHull(); 
      }
      break;
      
    default:
      //phase = "Graham Scan";
      edges.clear();
      convexHull = ConvexHullGrahamScan( points );
      break;
  }
}

void StepThroughHull(){
  //ccw here is key here, it is very rare for 3 randomly generated points to be collinear, but still a possibility.
  //Including the middle collinear point is up to interpretation, I treat collinear the same as clockwise
  //I remove the middle collinear point, as I consider the line connecting the outer 2 collinear points to encapsulate the middle collinear point.
  //Breaks down to if(ccw), else(cw, collinear)
  if(((Triangle)newData[3]).ccw()){
    ((Stack<Point>)newData[2]).push(t.p1);
    ((Stack<Point>)newData[2]).push(t.p2);
  }
  else{
    //index will be incremented every time this function is called, this cancels that out, so that we go back and test the proper triangle
    index--;
    //remove edge from t0 to t1 and t1 to t2
    for(int i = 0; i < ((ArrayList<Edge>)newData[1]).size(); i++){
      Edge e = ((ArrayList<Edge>)newData[1]).get(i);
      if(e.p1 == t.p2 || e.p0 == t.p0){
        ((ArrayList<Edge>)newData[1]).remove(i);
        i--;//will never index out of bounds -> first triangle will ALWAYS be CCW 
        //If triangle was cw, then points would not be sorted by angle correctly, i.e., the 3rd point when sorted always forms a ccw triangle
      }  
    }
    
    //Does not recognize edge like intended, left in as a reminder
    //((ArrayList<Edge>)newData[1]).remove(new Edge(t.p0, t.p1));
    
    //Add edge from t0 to t2
    Edge e = new Edge(t.p0, t.p2);
    ((ArrayList<Edge>)newData[1]).add(e);
  }
  index++;
  if(index -2 == ((ArrayList<Point>)newData[1]).size()){
    phaseNum++;
    return;
  }
  newData[4] = index;
  newData = IncrementalHull(newData);
}

void setup(){
  size(1300,900,P3D);
  frameRate(30);
  surface.setTitle("Graham's Algorithm Tutorial");
}


void draw(){
  background(255);
  
  translate( 0, height, 0);
  scale( 1, -1, 1 );
  
  noFill();
  stroke(100);
  //Draw every edge
  for( Edge e : edges ){
    e.draw();
  }
  
  strokeWeight(3);
  //Draw every point
  for( Point p : points ){
    p.draw();
    if(phaseNum == 1){
      Edge e = new Edge(leftmost, p);
      dottedEdges.add(e);
      }
    }
    
  fill(0);
  //Draws the appropriate features for each phase
  switch(phaseNum){
    case 0:
      if(foundLeftmost){
        //Draw line through leftmost point -> don't extend line into text on screen 
        line(leftmost.x(), 30, leftmost.x(), height-130);
      }
      break;
    //Draws the rudimentary hull in a "connect the dots" style  
    case 1:
      for( Edge e : dottedEdges){ 
        //e.draw();
        //e.drawDotted(); 
      }
      for( Edge e : (ArrayList<Edge>)pointsEdges[1]){
        e.drawDotted();
      }
      textRHC("Connect each point to the next point in polar order" , 50, 10);
      break;
      
    case 2:
      textRHC("Push the leftmost point, and the next two points (in CCW order) onto the stack" , 50, 10);
      break;
    //Draws the in-progress hull as well as the testing triangle (which is green when t is ccw and red when t is cw or collinear)  
    case 3:
      edges = (ArrayList<Edge>)newData[1];
      cHullTemp = (Stack<Point>)newData[2];
      t = (Triangle)newData[3];
      t.draw();
      fill(0);
      if(!t.cw()){
        textRHC("Testing triangle is CCW, push all of the points back onto the stack and form a new triangle with the next point in polar order" , 50, 10);
      }
      else{
        textRHC("Testing triangle is CW, push the head and tail onto the stack, disconnect the middle point, form a new triangle with the previous tail" , 50, 10);
      }
      //Identify the head, middle, and tail of the testing triangle with H, M, and T respectively
      Point head = t.p2;
      Point middle = t.p1;
      Point tail = t.p0;
      
      //Drawn below and to the left of the corresponding point
      textSize(28);
      textRHC("H", head.x()-20, head.y()-40);
      textRHC("M", middle.x()-20, middle.y()-40);
      textRHC("T", tail.x()-20, tail.y()-40);
      break;
      
    case 4:
      textRHC("Our next testing triangle contains the leftmost point, which is our stopping point" , 50, 10);
      break;
      
    case 5:
      textRHC("We have finished constructing the convex hull! Press c to clear the window, then g to generate more points" , 50, 10);
      break;
  }
  
  //Program acted weird when checking if point was null after multiple successive runs through
  if(foundLeftmost) { 
    leftmost.drawLeft(); 
  }
  
  
  //Once convex hull is complete change color of edges from grey to black
  if( convexHull.ccw() ) stroke( 100, 200, 100 ); 
  convexHull.draw();
  
  //Phase descriptions displayed in upper left of screen
  switch(phaseNum){
    case 0:
      phase = "Pre-Processing";
      break;
    case 1: 
      phase = "Sort Points By Angle";
      break;
    case 2:
      phase = "Rudimentary Hull";
      break;
    case 3:
      phase = "In-Progress Hull";
      break;
    case 4:
      phase = "Graham Scan Finishes";
      break;
    case 5:
      phase = "Complete Convex Hull";
  }
  
  fill(0);
  stroke(0);
  textSize(18);
  
  //All of the controls in the upper left are placed here
  textRHC( "Controls", 10, height-40 );
  if(phaseNum == 0) {
    if(!sweepStarted){ testSweep(); }
    textRHC( "+/-: Increase/Decrease Number of Random Points Generated", 10, height-60 );
    textRHC( "g: Generate " + numOfPoints + " Random Point(s)", 10, height-80 );
    textRHC( "n: Next Step ", 10, height-100 );
    textRHC( "c: Clear Points", 10, height-120 );
    
    //Attempting to place the following line in case 0 of the switch statement in draw() causes the text to become blurry for an unknown reason
    //Only tell the user to press g if they haven't already
    if(!pointsGenerated){
      textRHC("Press g to generate points and begin!" , 50, 10);
    }
    else{
      textRHC("Sort the points by their angle with respect to the leftmost point (CCW)(polar order)" , 50, 10);
    }  
  }
  else{ 
    textRHC( "n: Next Step ", 10, height-60 );
    textRHC( "c: Clear Points", 10, height-80 );
  }
  
  //textSize(28);
  String phasePhrase = "Phase " + phaseNum + ": " + phase;
  textRHC(phasePhrase, 10, height-20);
  
  textSize(18);
  for( int i = 0; i < points.size(); i++ ){
    textRHC( i+1, points.get(i).p.x+5, points.get(i).p.y+15 );
  }
  
}


void keyPressed(){
  //Will come back and add potentially -> don't want to clutter screen with too many controls
  //if( key == 's' ) saveImage = true;
  if( key == '+' ){ numOfPoints++; calculateConvexHull(); }
  if( key == '-' ){ numOfPoints = max( numOfPoints-1, 4 ); calculateConvexHull(); }
  
  //The user can not generate points after they have started the demonstration (aka once they have pressed 'n' atleast once
  if( key == 'g' ){ 
    if(phaseNum == 0) { 
      generateRandomPoints(); 
      calculateConvexHull();
      pointsGenerated = true;
    } 
  }
  
  //Clear function resets every global variable to initial values and emptys arraylists
  if( key == 'c' ){ clear(); }
  
  //n is used not only for advancing phases, but also for advancing sub phases
  if( key == 'n' ){ 
    //if the user has not generated points, there is nothing for the algorithm to do yet
    if(!pointsGenerated){ return;}
    if(phaseNum == 0 && sweepStarted){   
      sweepStarted = false;
      return;
    }
    if(phaseNum != 3 && phaseNum < 5){phaseNum++;} 
      calculateConvexHull(); 
    }
  //if( key == 'w' ){ ccwSweep(); }
}


//Utility functions to use a right-handed coordinate system (processing uses a left-handed coordinate system by default)
void textRHC( String s, float x, float y ){
  pushMatrix();
  translate(x,y);
  scale(1,-1,1);
  text( s, 0, 0 );
  popMatrix();
}

//Convert int toString in here, makes code cleaner
void textRHC( int s, float x, float y ){
  textRHC( Integer.toString(s), x, y );
}

//Decided against allowing user to click and add points, and move points around
//Point sel = null;
void mousePressed(){
  /*int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  
  float dT = 6;
  for( Point p : points ){
    float d = dist( p.p.x, p.p.y, mouseXRHC, mouseYRHC );
    if( d < dT ){
      dT = d;
      sel = p;
    }
  }
  
  if( sel == null ){
    sel = new Point(mouseXRHC,mouseYRHC);
    points.add( sel );
    calculateConvexHull();
  }*/
}

void mouseDragged(){
  /*int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  if( sel != null ){
    sel.p.x = mouseXRHC;   
    sel.p.y = mouseYRHC;
    calculateConvexHull();
  }*/
}

void mouseReleased(){
  //sel = null;
}

//Emptys all arraylists, and resets variables to proper starting values, so that the demonstration may be repeated properly
//i.e., makes it so that nothing is drawn on the screen after you press 'c'
void clear(){
  points.clear();
  edges.clear();
  dottedEdges.clear();
  rightSweep = null;
  //leftmost = null;
  convexHull.p.clear();
  foundLeftmost = false;
  firstRun = true;
  pointsGenerated = false;
  sweepStarted = true;
  reachedTop = false;
  phaseNum = 0;
  index = 1;
  phase = "Pre-Processing";
}

//Never got the sweepline working by angle
/*void ccwSweep(){
  float angle = 270;
  float radius = width*2;
  float frequency = 2;
  float px, py;
  int count = 0;
  float startX = leftmost.x();
  Point point2 = new Point(startX, 0);
  
  while( point2.x() <= startX){
    //if(count % 1000 == 0){
      line(leftmost.x(), leftmost.y(), point2.x(), point2.y());
      point2.setX(point2.getX()+ cos(radians(angle))*(radius));
      point2.setY(point2.getY()+ sin(radians(angle))*(radius));
      angle -= frequency;
    //}
    //count++;
  }
  
}*/

//Workaround to being unable to draw the sweepline using angles, 
//essentially traces the boundary of the window in ccw order, but it is done by incrementing coordinates
void testSweep(){
  if(reachedTop) { 
    if(rightSweep.x() >= leftmost.x())  
      rightSweep.decrementX(); 
    }
    else{
      if(rightSweep.x() <= width){
        rightSweep.incrementX();
      }
      else if(rightSweep.y() <= height - 110){
        rightSweep.incrementY();
      }
      else{
        reachedTop = true;
      }
    }
   line(leftmost.x(), leftmost.y(), rightSweep.x(), rightSweep.y());
}
