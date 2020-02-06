//Logan Metzen

import java.util.*; 

Polygon ConvexHullGrahamScan( ArrayList<Point> points ){
  Polygon cHull = new Polygon();
  //Check that there are enough points to make a polygon
  if (points.size() >= 3) {
    
    //If size is 3, simply add all of the points
    if(points.size() == 3) {
      for(Point point : points){
      cHull.addPoint(point);
      }
    }
    
    //Find leftmost point (starting point) //Preprocessing: O(n)
    Point leftmost = points.get(0);
    for(Point point : points){
      if(point.x() < leftmost.x()){
        leftmost = point;
      }
    }
  
    //Create a copy of arraylist to be manipulated
    ArrayList<Point> pointsCopy = new ArrayList<Point>();
    
    //Create a PVector based on the leftmost point (for angle comparisons)
    PVector base = new PVector(leftmost.x(), leftmost.y());
    
    //for every point get the angle between that point and the leftmost point
    for(Point point : points){
      if(point == leftmost){ continue;}
      float angle = atan2(point.y() - base.y, point.x() - base.x);
      point.angle = angle;
      pointsCopy.add(point);
    }
    
    //Use our comparator defined by angle and the 
    Collections.sort(pointsCopy, new SortByAngle());
    pointsCopy.add(leftmost);
    //Create stack and pop first element of arraylist (should be leftmost point unless I messed up)
    Stack<Point> stack = new Stack<Point>();
  
    stack.push(leftmost);
    stack.push(pointsCopy.get(0));
    stack.push(pointsCopy.get(1));
    
    for(int j = 2; j < pointsCopy.size(); j++){
      
      Point head = pointsCopy.get(j);
      Point middle = stack.pop();
      Point tail = stack.peek();
      
      Triangle t = new Triangle(tail, middle, head);
      
      if(!t.cw()){
        stack.push(middle);
        stack.push(head);
      }
      else{
        j--;
      }
    } 
    while(!stack.empty()){
      cHull.addPoint(stack.pop());
    }
  }
  return cHull;
}

Point PreProcessing( ArrayList<Point> points ){
  
  Point leftmost = points.get(0);
  
  if (points.size() >= 4) {
    
    //If size is 3, simply add all of the points
    if(points.size() == 3) {
      for(Point point : points){
      }
    }
    
    //Find leftmost point (starting point) //Preprocessing: O(n)
    leftmost = points.get(0);
    for(Point point : points){
      if(point.x() < leftmost.x()){
        leftmost = point;
      }
    }
  }
  
  return leftmost;
}

Object[] RudimentaryHull(ArrayList<Point> points, Point leftmost) {
  //Create a copy of arraylist to be manipulated
    ArrayList<Point> pointsCopy = new ArrayList<Point>();
    
    //Create a PVector based on the leftmost point (for angle comparisons)
    PVector base = new PVector(leftmost.x(), leftmost.y());
    for(Point point : points){
      if(point == leftmost){ continue;}
      float angle = atan2(point.y() - base.y, point.x() - base.x);
      point.angle = angle;
      pointsCopy.add(point);
    }
    
  Collections.sort(pointsCopy, new SortByAngle());
  pointsCopy.add(leftmost);
    
  ArrayList<Edge> edges = new ArrayList<Edge>();
  for(int i = 0; i < pointsCopy.size() -1; i++){
      Edge e = new Edge(pointsCopy.get(i), pointsCopy.get(i+1));
      edges.add(e);
  }
  
  Edge e = new Edge(pointsCopy.get(pointsCopy.size() - 1), pointsCopy.get(0));
  edges.add(e);
  Object[] data = new Object[2];
  data[0] = pointsCopy;
  data[1] = edges;
  return data;
}

Object[] IncrementalHull(Object[] data){
  
  //data[0] = points; point arraylist
  //data[1] = edges; edge arraylist
  //data[2] = cHullTemp; stack<Point>
  //data[3] = triangle; 
  //data[4] = position in point arraylist
  
  ArrayList<Point> pointsCopy = (ArrayList<Point>)data[0];
  ArrayList<Edge>  edgesCopy  = (ArrayList<Edge>)data[1];
  Stack<Point>     stackCopy  = (Stack<Point>)data[2];
  int              index      = (int)data[4];
  
  Point head = pointsCopy.get(index);
  Point middle = stackCopy.pop();
  Point tail = stackCopy.peek();
     
  Triangle t = new Triangle(tail, middle, head);
  
  data[3] = t;
  return data;
  }
