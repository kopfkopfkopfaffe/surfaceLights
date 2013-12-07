

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
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;

ControlFrame cf;

OscP5 oscP5;
// set screen size manually
float screenSizeX = 1024.0+200;
float screenSizeY = 768.0;      
// contains ALL the vertices
ArrayList<PVector> vertices;
// contains informations of what to do with the vertices
ArrayList<PVector> metaInformations;
// mapping from group to effect, we have 8 groups
int maxGroups = 8;
int groupMap[]={0,1,2,3,12,5,6,7};
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
// global mouse coordinates
int globalmouseX = 0;
int globalmouseY = 0;
// font for group display
PFont font;
// obsolete variables
int col;
int counter;
float numberOfEffects;
boolean numberKeys[]={false,false,false,false,false,false,false,false,false};
void setup() {
  oscP5 = new OscP5(this, 5555);
  background(0);
  size(int(screenSizeX), int(screenSizeY), P2D);
  font = createFont("Georgia", 30);
  textSize(32);
  // pack all shaders in one arraylist
  shaders = new ArrayList();
  shaders.add(loadShader("monjori.glsl"));
  shaders.add(loadShader("myshader.glsl"));
  shaders.add(loadShader("caustics.glsl"));
  shaders.add(loadShader("boxWarp.glsl"));
  shaders.add(loadShader("crazyCarpet.glsl"));
  shaders.add(loadShader("futureTunnel.glsl"));
  shaders.add(loadShader("laserShow.glsl"));
  shaders.add(loadShader("nineties.glsl"));
  shaders.add(loadShader("persianRotor.glsl"));
  shaders.add(loadShader("psychoCircus.glsl"));
  shaders.add(loadShader("spaceHipster.glsl"));
  shaders.add(loadShader("stemCells.glsl"));
  shaders.add(loadShader("summerTime.glsl"));
  shaders.add(loadShader("waterColor.glsl"));
  shaders.add(loadShader("blackWhiteSwirl.glsl"));
  shaders.add(loadShader("blackWhiteNinetys.glsl"));
  numberOfEffects = shaders.size();
  // create control window
  cp5 = new ControlP5(this);
  //cp5.setMouseWheelRotation(1);
  cp5.setControlFont(font,20);
  
  cf = addControlFrame("LightController", 500,750);
  
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
  // adapt global mouse coordinates
  globalmouseX = mouseX;
  globalmouseY = mouseY;
  // increase timer for external clock timing
  milliIncreaser *= timeCoolDown;
  myMillis += milliIncreaser;
  // draw background
  background(0);
  // move all effects
  animateEffects();
  // show legend of all effects on the left
  int blockSize = int((screenSizeY/(shaders.size()-1))-5);
  for (int i = 0; i<shaders.size();i ++){
    applyEffect(i);
    rect(5,(i*blockSize+5),blockSize*2, blockSize);
    resetShader();
    fill(100,0,100);
    text(i,5,((i+1)*blockSize+5)-5);
  }
  
  // iterate over all shapes
  tempVertexCounter = 0;
  for (int shapes = 0; shapes < metaIndex; shapes++) {
    if (debug) println("Rendering shape "+str(shapes));
    applyEffect(groupMap[int(metaInformations.get(shapes).y)]);
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



