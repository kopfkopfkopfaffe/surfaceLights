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
