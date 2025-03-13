import processing.pdf.*;
import java.io.File;

ArrayList<float[]> frames = new ArrayList<>();
ArrayList<Integer> frameColors = new ArrayList<>(); // Stores color for each frame
int currentFrame = 0;
PImage img;
String[] csvFiles;
HashMap<String, Integer> csvColors = new HashMap<>(); // Map CSV file paths to colors

void setup() {
  size(1280, 720);

  img = loadImage("screenGrab.png");
  String timestamp = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" +
                     nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  beginRecord(PDF, "output_" + timestamp + ".pdf");

  colorMode(HSB, 1000);
  frameRate(240);
  
  // ✅ Find all CSV files in the "data" folder and its subfolders
  csvFiles = getAllCSVFiles("data");
  
  if (csvFiles.length == 0) {
    println("❌ No CSV files found.");
    exit();
  }

  // ✅ Load all detected CSV files and assign each one a unique color
  for (int i = 0; i < csvFiles.length; i++) {
    String csvFile = csvFiles[i];
    
    // Generate a unique color for each CSV file
    int csvColor = color((i * 200) % 1000, 800, 1000); 
    csvColors.put(csvFile, csvColor);

    println("📂 Loading CSV: " + csvFile + " | Assigned Color: " + csvColor);
    loadCSV(csvFile, csvColor);
  }
}

void draw() {
  if (frames.size() > 0) {
    float[] keypoints = frames.get(currentFrame);
    int frameColor = frameColors.get(currentFrame); // ✅ Get the color assigned to this frame
    
    for (int i = 0; i < keypoints.length; i += 2) {
      float x = keypoints[i] * width;  
      float y = (1 - keypoints[i + 1]) * height; 

      noStroke();
      drawGradientCircle(x, y, 5, frameColor);
    }

    currentFrame++;
  }

  if (currentFrame >= frames.size()) {
    println("✅ Finished processing all frames.");
    endRecord();
    exit();
  }
}

// ✅ Scans the "data" folder and returns all CSV file paths
String[] getAllCSVFiles(String directory) {
  File folder = new File(sketchPath(directory));
  ArrayList<String> csvList = new ArrayList<>();

  scanForCSV(folder, csvList);
  
  return csvList.toArray(new String[0]);
}

// ✅ Recursively scans for CSV files
void scanForCSV(File folder, ArrayList<String> csvList) {
  if (folder.isDirectory()) {
    File[] files = folder.listFiles();
    if (files != null) {
      for (File file : files) {
        if (file.isDirectory()) {
          scanForCSV(file, csvList); // Recursively check subfolders
        } else if (file.getName().toLowerCase().endsWith(".csv")) {
          csvList.add(file.getAbsolutePath());
        }
      }
    }
  }
}

// ✅ Loads a single CSV file and assigns colors
void loadCSV(String csvPath, int assignedColor) {
  String[] lines = loadStrings(csvPath);

  if (lines != null && lines.length > 1) {
    for (int i = 0; i < lines.length; i++) { 
      String[] values = split(lines[i], ",");
      if (values.length >= 12) {
        float[] keypoints = new float[12];
        for (int j = 0; j < 12; j++) { 
          keypoints[j] = float(values[j]); 
        }
        frames.add(keypoints);
        frameColors.add(assignedColor); // ✅ Store corresponding color for each frame
      }
    }
  } else {
    println("❌ Skipping empty or missing CSV: " + csvPath);
  }
}

// ✅ Draws a gradient "glow" effect at a given point
void drawGradientCircle(float x, float y, float radius, color centerColor) {
  for (float r = radius; r > 0; r -= 1) {
    float alpha = map(r, 0, radius, 100, 0);
    fill(centerColor, alpha);
    noStroke();
    ellipse(x, y, r * 2, r * 2);
  }
}
