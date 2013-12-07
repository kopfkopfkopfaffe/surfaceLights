
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
  int mytempVertexCounter;
  float scaler = 500.0/screenSizeX;
  float averageX = 0.0;
  float averageY = 0.0;
  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    cp5.addSlider("abc").setRange(0, 255).setPosition(10, 10);
    cp5.addSlider("def").plugTo(parent, "def").setRange(0, 255).setPosition(10, 30);
    smooth();
    colorMode(HSB, 100);
  }

  public void draw() {
    background(0);
    mytempVertexCounter = 0;
    for (int shapes = 0; shapes < metaIndex; shapes++) {
      if (debug) println("Rendering shape "+str(shapes));
      averageX = 0.0;
      averageY = 0.0;
      //applyEffect(metaInformations.get(shapes).y);
      fill(100, 0, 50);
      noStroke();
      //strokeWeight(0);
      beginShape();
      for (int mypoints = 0;mypoints < metaInformations.get(shapes).x;mypoints ++) {
        vertex((vertices.get(mytempVertexCounter).x)*scaler, (vertices.get(mytempVertexCounter).y)*scaler);
        averageX += (vertices.get(mytempVertexCounter).x)*scaler;
        averageY += (vertices.get(mytempVertexCounter).y)*scaler;
        mytempVertexCounter ++;
      }
      endShape(CLOSE);
      fill (50,100,100);
      textSize(20);
      averageX = averageX/metaInformations.get(shapes).x;
      averageY = averageY/metaInformations.get(shapes).x;
      text(int(metaInformations.get(shapes).y), averageX, averageY);
    }
    // display fake mouse cursor in preview
    stroke(59, 100, 100);
    strokeWeight(2);
    line(globalmouseX*scaler,globalmouseY*scaler,globalmouseX*scaler-5,globalmouseY*scaler);
    line(globalmouseX*scaler,globalmouseY*scaler,globalmouseX*scaler+5,globalmouseY*scaler);
    line(globalmouseX*scaler,globalmouseY*scaler,globalmouseX*scaler,globalmouseY*scaler-5);
    line(globalmouseX*scaler,globalmouseY*scaler,globalmouseX*scaler,globalmouseY*scaler+5);
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

