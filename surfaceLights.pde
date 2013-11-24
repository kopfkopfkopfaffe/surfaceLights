/* surfaceLights, 2013 KopfKopfKopfAffe
 *
 * This is how it works:
 * == Creating Shapes ==
 * You can draw shapes by defining their outer points. 
 * Left click adds the current mouse position to the list of points.
 * Middle click ends a shape. Left click starts next one.
 * Right click removes the last point.
 * All points are stored in the ArrayList vertices.
 * The ArrayList metaInformations defines how to create the shapes
 * from the list of points. Each element of the metaInformations list
 * defines one shape. The x value defines the number of points in
 * that shape. The y value represents the effects group the shape belongs to.
 * This allows you to render groups of shapes in a different way.
 * The z value is not used currently.
 * If the mouse cursor is activated, a line is drawn from the last 
 * point to the cursor to help keeping track of the mapping.
 * The number of the current group is dispayed next to the cursor.
 *
 * == Rendering Shapes ==
 * The render module creates each shape by the instructions
 * provided in the metaInformations ArrayList. Depending of the
 * group and global parameters, the shapes are rendered in a 
 * different way. 
 * Points that belong to a non-finished shape are displayed as
 * little white dots.
 *
 * == Usage and External Controls ==
 * Shapes can be drawn and the group that they will be applied to
 * when you end the shape can be altered with the mouse wheel.
 * The sketch can run on external clock or internal clock 
 * (selected by boolean externalClock). If on external clock (beat),
 * a custom timer is used. It gets increased by a certain value each draw cycle. 
 * That increaser decreases over time, so it cools down, and the 
 * effects get slower. On each beat, this cooldown is reset so the 
 * effects pulse with the beat. The beat comes from GMF via OSC.
 * 
 * In order to apply effects to a certain shape, you can use slider one
 * and two on the GMF to select shape (0) and group (1). Then press 
 * 'a' on the keyboard to apply the shape to the effect/group.
 *
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
// set screen size manually
float screenSizeX = 1026.0;
float screenSizeY = 770.0;      
// contains ALL the vertices
ArrayList<PVector> vertices;
// contains informations of what to do with the vertices
ArrayList<PVector> metaInformations;
// ALL the shaders
ArrayList<PShader> shaders;
// indexes for both arrays
int vertexIndex = -1;
int metaIndex = 0;
// temporary counter for vertices in current shape
int vertexCounter = 0;
// are we in the middle of a shape?
boolean shapeEnded = true;
// are we in edit mode?
boolean editMode = true;
// are we in debug mode?
boolean debug = false;
// this is the group your shape will belong to if you end it
int currentGroup = 0;
// are we using the external clock from GMF?
boolean externalClock = false;
// cool down time of internal timer
float timeCoolDown = 0.95;
// internal timer is increased by this
int milliIncreaser = 80;
// internal timer
int myMillis = 0;
// used during the render loop
int tempVertexCounter = 0;
// selections for external control
float selectedShape = 0;
float selectedGroup = 0;
// font for group display
PFont font;
// obsolete variables
int col;
int counter;

void setup() {
  oscP5 = new OscP5(this, 5555);
  background(0);
  size(int(screenSizeX), int(screenSizeY), P2D);
  font = createFont("Georgia", 30);
  textSize(32);
  // pack all shaders in one arraylist
  shaders = new ArrayList();
  //shaders.add(loadShader("nebula.glsl"));
  shaders.add(loadShader("monjori.glsl"));
  //shaders.add(loadShader("stars.glsl"));
  shaders.add(loadShader("myshader.glsl"));
  shaders.add(loadShader("caustics.glsl"));
  shaders.add(loadShader("boxWarp.glsl"));
  //////shaders.add(loadShader("colorPool.glsl"));
  //shaders.add(loadShader("colorWobble.glsl"));
  shaders.add(loadShader("crazyCarpet.glsl"));
  shaders.add(loadShader("futureTunnel.glsl"));
  shaders.add(loadShader("laserShow.glsl"));
  //shaders.add(loadShader("machineBrain.glsl"));
  shaders.add(loadShader("nineties.glsl"));
  shaders.add(loadShader("persianRotor.glsl"));
  shaders.add(loadShader("psychoCircus.glsl"));
  shaders.add(loadShader("spaceHipster.glsl"));
  shaders.add(loadShader("stemCells.glsl"));
  shaders.add(loadShader("summerTime.glsl"));
  // set resolution of all shaders
  for (int shader = 0;shader < shaders.size();shader++) {
    shaders.get(shader).set("resolution", float(width), float(height));
  }
  // lists for points and shape informations
  vertices = new ArrayList();
  metaInformations = new ArrayList();
  smooth();
  colorMode(HSB, 100);
}

void draw() {
  // increase timer for external clock timing
  milliIncreaser *= timeCoolDown;
  myMillis += milliIncreaser;
  // draw background
  background(0);
  // move all effects
  animateEffects();
  // iterate over all shapes
  tempVertexCounter = 0;
  for (int shapes = 0; shapes < metaIndex; shapes++) {
    if (debug) println("Rendering shape "+str(shapes));
    applyEffect(metaInformations.get(shapes).y);
    beginShape();
    for (int points = 0;points < metaInformations.get(shapes).x;points ++) {
      vertex(vertices.get(tempVertexCounter).x, vertices.get(tempVertexCounter).y);
      tempVertexCounter ++;
    }
    endShape(CLOSE);
  }
  // if in edit mode, draw points of unfinished shape, draw line from
  // most recent point to cursor, display group number next to cursor.
  if (editMode) {
    resetShader();
    stroke(100, 0, 100);
    fill(100, 0, 100);
    strokeWeight(2);
    while (tempVertexCounter <= vertexIndex) {
      point(vertices.get(tempVertexCounter).x, vertices.get(tempVertexCounter).y);
      tempVertexCounter ++;
    }
    if (vertexIndex > -1) {
      line(vertices.get(tempVertexCounter-1).x, vertices.get(tempVertexCounter-1).y, mouseX, mouseY);
      text(currentGroup, mouseX+5, mouseY);
    }
    stroke(100, 0, 0);
  }
}

void animateEffects() {
  // Classic color blocks
  counter ++;
  if (counter > 100) counter = 0;
  // Shaders
  for (int shader = 0;shader < shaders.size();shader++) {
    if (externalClock) {
      // move shader effects by external clock
      shaders.get(shader).set("time", myMillis / 500.0);
    }
    else {
      // move shader effects by internal timing
      shaders.get(shader).set("time", millis() / 500.0);
    }
  }
}

void applyEffect(float group) {
  // Apply effect to shade depending on group setting
  // This is called once for each shape in each frame.
  int groupSelect =  (int(floor(group))); 
  if (groupSelect > -1 && groupSelect < shaders.size()) {
    shader(shaders.get(groupSelect));
  }
  else if (groupSelect == shaders.size()) {
    resetShader();  
    fill((counter + int(vertices.get(tempVertexCounter).x * vertices.get(tempVertexCounter).y))%100, 255, 255);
  }
  // if group is larger than the number of effects, do not render shape
  else {
    resetShader();  
    fill(0);
    // do not render anything
  }
}

void mouseWheel(MouseEvent event) {
  // Mouse wheel is used for group selection
  float e = event.getAmount();
  currentGroup += e;
  if (currentGroup<0) currentGroup = 0;
  println(str(currentGroup));
}

void mousePressed() {
  if (mouseButton == LEFT) {
    // starting a new shape
    if (shapeEnded) {
      // starting a new shape
      shapeEnded = false;
    }
    vertexIndex ++;
    vertexCounter ++;
    vertices.add(new PVector(mouseX, mouseY));
    if (debug)println("Point " + str(vertexIndex)+ " added.");
  } 
  else if (mouseButton == RIGHT) {
    if (vertexCounter>0) {
      vertices.remove(vertexIndex);
      if (debug)println("Point " + str(vertexIndex)+ " removed.");
      vertexIndex --;
      vertexCounter --;
    }
    else if (debug)println("Nothing left to remove in this shape!");
    /*
    // Trying to implement removing an arbitrary amount of
     // points here, including removing the shapes when it's 
     // points are missing. failed. fallback: beeing only able to
     // remove the points of the current shape.
     //
     if (vertexIndex > -1) {
     vertices.remove(vertexIndex);
     println("Point " + str(vertexIndex)+ " removed.");
     vertexIndex --;
     vertexCounter --;
     println("vertexCounter is now "+str(vertexCounter));
     if (vertexCounter < 1) {
     println("Trying to remove metaInformations "+str(metaIndex));
     metaInformations.remove(metaIndex);
     println("Shape " + str(metaIndex)+ " removed.");
     metaIndex --;
     if (metaIndex > -1) {
     vertexCounter = int(metaInformations.get(metaIndex).x)-1;
     }
     }
     }
     */
    //println("Point removed.");
  } 
  else { // This must be the MIDDLE mouse button
    shapeEnded = true;
    // create new shape information with current Group
    metaInformations.add(new PVector(vertexCounter, currentGroup, 0));
    if (debug)println("Shape "+ str(metaIndex)+" ended.");
    metaIndex ++;
    // start the next shape with vertex 0
    vertexCounter = 0;
  }
}

void keyPressed() {
  // toggle edit mode
  if (key == 'e') {
    if (editMode) {
      editMode = false;
      noCursor();
    }
    else editMode = true;
    cursor();
  }
  // apply group to shape, using the faders on GMF
  else if (key == 'a') {
    metaInformations.get(int(selectedShape)).set(metaInformations.get(int(selectedShape)).x, selectedGroup, 0.0);
  }
}


void oscEvent(OscMessage mess) {
  // clock signal received, reset cooldown.
  if (mess.checkAddrPattern("/gmf/clk")==true) {
    milliIncreaser = 80;
  }
  // collect GMF sliders (slider#, value)
  else if (mess.checkAddrPattern("/gmf/floats")==true) {
    if (mess.checkTypetag("if")) {
      int sliderNo = mess.get(0).intValue(); 
      float sliderValue = mess.get(1).floatValue();
      println(metaIndex);
      // first slider selects shape, second group
      if (sliderNo==0) selectedShape = floor(map(sliderValue, 0.0, 1.0, 0.0, float(metaIndex)-1));
      else if (sliderNo==1) selectedGroup = floor(map(sliderValue, 0.0, 1.0, 0.0, 20.0));
      println("You can assign shape "+str(selectedShape)+" to group "+str(selectedGroup));
    }
  }
}

