
ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}


// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {
  int w, h;
  int selectedGroup = -1; 
  int mytempVertexCounter;
  float scaler = 500.0/screenSizeX;
  float averageX = 0.0;
  float averageY = 0.0;
  Knob [] groupKnobsLeft = new Knob[maxGroups];
  Knob [] groupKnobsRight = new Knob[maxGroups];

  public void setup() {
    // set up gui
    size(w, h);
    cp5 = new ControlP5(this);
    cp5.setControlFont(font, 18);
    for (int i = 0; i<maxGroups;i++) {
      groupKnobsLeft[i]=cp5.addKnob("left_"+str(i));
      groupKnobsLeft[i].setRange(0.0, numberOfEffects);
      groupKnobsLeft[i].setValue(0);
      groupKnobsLeft[i].setNumberOfTickMarks(int(numberOfEffects)); 
      groupKnobsLeft[i].setResolution(numberOfEffects);
      groupKnobsLeft[i].setPosition(10, (screenSizeY*scaler)+10+i*45);
      groupKnobsLeft[i].setRadius(20);
      groupKnobsLeft[i].setScrollSensitivity(1);
      groupKnobsLeft[i].snapToTickMarks(true);  
      groupKnobsLeft[i].setColorCaptionLabel(0);
      groupKnobsLeft[i].setDecimalPrecision(0);
      groupKnobsLeft[i].scrolled(3);
      groupKnobsLeft[i].setScrollSensitivity(.5);
    }

    for (int i = 0; i<maxGroups;i++) {
      groupKnobsRight[i]=cp5.addKnob(str(i));
      groupKnobsRight[i].setRange(0.0, numberOfEffects);
      groupKnobsRight[i].setValue(0);
      groupKnobsRight[i].setNumberOfTickMarks(int(numberOfEffects)); 
      groupKnobsRight[i].setResolution(numberOfEffects);
      groupKnobsRight[i].setPosition(70, (screenSizeY*scaler)+10+i*45);
      groupKnobsRight[i].setRadius(20);
      groupKnobsRight[i].setScrollSensitivity(1);
      groupKnobsRight[i].snapToTickMarks(true);  
      groupKnobsRight[i].setColorCaptionLabel(0);
      groupKnobsRight[i].setDecimalPrecision(0);
      groupKnobsRight[i].scrolled(3);
      groupKnobsRight[i].setScrollSensitivity(.5);
    }

    //smooth();
    colorMode(HSB, 100);
  }

  public void draw() {
    // highlight groups by mouse hover
    if (mouseX > 1 && mouseX < 150) {
      selectedGroup = int(floor((mouseY-screenSizeY*scaler)-10)/45.0);
      println(selectedGroup);
    }
    else {
      selectedGroup = -1;
    }
    // apply knob settings to groups
    for (int i = 0; i<maxGroups;i++) {
      groupMap[i]=int(groupKnobsLeft[i].getValue());
    }
    background(0);
    // render little shape preview
    mytempVertexCounter = 0;
    for (int shapes = 0; shapes < metaIndex; shapes++) {
      averageX = 0.0;
      averageY = 0.0;
      fill(100, 0, 50);
      strokeWeight(1);
      if (int(metaInformations.get(shapes).y)==selectedGroup) {
        stroke(90, 100, 100);
      }
      else {
        stroke(50, 100, 100);
      }
      beginShape();
      for (int mypoints = 0;mypoints < metaInformations.get(shapes).x;mypoints ++) {
        vertex((vertices.get(mytempVertexCounter).x)*scaler, (vertices.get(mytempVertexCounter).y)*scaler);
        averageX += (vertices.get(mytempVertexCounter).x)*scaler;
        averageY += (vertices.get(mytempVertexCounter).y)*scaler;
        mytempVertexCounter ++;
      }
      endShape(CLOSE);
      // put group number in 'center' of shape
      if (int(metaInformations.get(shapes).y)==selectedGroup) {
        stroke(90, 100, 100);
        fill(90, 100, 100);
      }
      else {
        stroke(50, 100, 100);
        fill(50, 100, 100);
      }
      textSize(20);
      averageX = averageX/metaInformations.get(shapes).x;
      averageY = averageY/metaInformations.get(shapes).x;
      text(int(metaInformations.get(shapes).y), averageX, averageY);
    }
    // display fake mouse cursor in preview
    stroke(55, 100, 100);
    strokeWeight(1);
    line(globalmouseX*scaler-2, globalmouseY*scaler, globalmouseX*scaler-10, globalmouseY*scaler);
    line(globalmouseX*scaler+2, globalmouseY*scaler, globalmouseX*scaler+10, globalmouseY*scaler);
    line(globalmouseX*scaler, globalmouseY*scaler-2, globalmouseX*scaler, globalmouseY*scaler-10);
    line(globalmouseX*scaler, globalmouseY*scaler+2, globalmouseX*scaler, globalmouseY*scaler+10);
    stroke(100, 0, 100);
    line(0, screenSizeY*scaler, 500, screenSizeY*scaler);
  }

  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return cp5;
  }


  ControlP5 cp5;

  Object parent;
}

