

void mouseWheel(MouseEvent event) {
  // Mouse wheel is used for group selection
  float e = event.getAmount();
  currentGroup += e;
  if (currentGroup<0) currentGroup = 0;
  if (currentGroup>maxGroups-1) currentGroup = 7;
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

