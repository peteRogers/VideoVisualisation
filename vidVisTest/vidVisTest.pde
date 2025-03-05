import processing.pdf.*;

String[][] csvData;
ArrayList<float[]> frames = new ArrayList<>();
int currentFrame = 0;
PImage img;

void setup() {
  img = loadImage("screenGrab.png");
  size(1280, 720, PDF, "filename.pdf");
  // background(255);
  tint(10, 10,10);
 // image(img, 0, 0, width, height);
  colorMode(HSB, 1000);
  frameRate(240);
  
  // Load CSV file
  String csvPath = "human_pose_tracking.csv"; // Ensure this file is in the data folder
  String[] lines = loadStrings(csvPath);
  
  if (lines != null && lines.length > 1) {
    for (int i = 1; i < lines.length; i++) { // Skip header
      String[] values = split(lines[i], ",");
      if (values.length >= 12) {
        float[] keypoints = new float[12];
        for (int j = 1; j < 13; j++) { // Skip frame number column
          keypoints[j - 1] = float(values[j]); 
        }
        frames.add(keypoints);
      }
    }
  } else {
    println("❌ CSV file not found or empty.");
  }
}



void draw() {
 // background(255);
  
  if (frames.size() > 0) {
    float[] keypoints = frames.get(currentFrame);
    
    for (int i = 0; i < keypoints.length; i += 2) {
      float x = keypoints[i] * width;  // Scale X to fit 600x600
      float y = (1 - keypoints[i + 1]) * height; // Flip Y-axis and scale
      
     // fill(0+i*10, 1000, 1000);
      noStroke();
      drawGradientCircle(x, y, 5, color(0+i*5, 1000, 1000)); // Red glow effect
      //ellipse(x, y, 5, 5);
    }

    currentFrame = (currentFrame + 1);
    
  }
  if(currentFrame == frames.size()){
    exit();
  }
  
 // delay(50); // Adjust speed for smoother animation
}

void drawGradientCircle(float x, float y, float radius, color centerColor) {
  for (float r = radius; r > 0; r -= 1) {
    float alpha = map(r, 0, radius, 100, 0); // More transparency as radius increases
    fill(centerColor, alpha);
    noStroke();
    ellipse(x, y, r * 2, r * 2);
  }
}
