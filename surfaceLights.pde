float screenSizeX = 1024.0;                        //
float screenSizeY = 768.0;                          //
ArrayList<PVector> points;
int col;
int counter;
void setup() {
  background(0);
  size(int(screenSizeX), int(screenSizeY), P3D);
  points = new ArrayList();
  smooth();
  colorMode(HSB, 100);
}

void draw() {
  counter ++;
  if (counter > 100) counter = 0;
  int i = 0;
  while(i<points.size()-3){
     col = (counter + int(points.get(i).x * points.get(i+3).y))%100;//counter-(floor(counter/100))*100;
     println(col);
      stroke(col,255,255);
      fill(col,255,255);
      strokeWeight(2);
    quad( int(points.get(i).x), int(points.get(i).y),int(points.get(i+1).x), int(points.get(i+1).y),int(points.get(i+2).x), int(points.get(i+2).y),int(points.get(i+3).x), int(points.get(i+3).y));
    i +=4;
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    points.add(new PVector(mouseX, mouseY));
  } 
  else if (mouseButton == RIGHT) {
    if (points.size()>0)points.remove(points.size()-1);
  } 
  else {
  }
}

