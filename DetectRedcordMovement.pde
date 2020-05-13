
import processing.video.*;

Movie mov;

//to scale up screen size
final float scaleVal = 2.65;
int movWidth = 640;
int movHeight = 360;

int numPixels;
int[] previousFrame;  //to store the previously captured frame

int[] redDotArr;  //to detect motion with less outlier
int redDotSize = 5;

int[] movementSumArr; // to see how long motion lasts
int movementSumArrSize = 50;
int movementThreshold = 600000; 

int frameIdx = 0;
 
PFont f;
PImage p;

void setup() {
  //font
  f = createFont("SourceCodePro-Regular.ttf", 24);
 
  //set video attr
  
  size(1920, 1080);
  background(0);
  frameRate(10);
  numPixels = movWidth*movHeight;
  
  //initialize Arr
  previousFrame = new int[numPixels];
  redDotArr = new int[redDotSize];
  movementSumArr = new int[movementSumArrSize]; 
  
  // load video
  mov = new Movie(this, "attackUp.mp4"); 
  mov.play();
 
 //full screen
  p = createImage(640, 360, RGB);
  loadPixels();
}

void draw() {
  scale(scaleVal);
  mov.read(); // Read the new frame from the camera
  mov.loadPixels(); // Make its pixels[] array available
    
    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = mov.pixels[i];
      color prevColor = previousFrame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
     
      int threshold = 90;
      //If a pixel diff is over threshold, make it red
      if (diffR + diffG + diffB > threshold) {
         p.pixels[i] = color(255, 0, 0);
      } else {
        p.pixels[i]=mov.pixels[i];
      }
      previousFrame[i] = currColor;
    } //for
  
    frameIdx++;
    movementSum -= 640886;
    
    //Calculate average of red dot size(movementSum) for last 5(redDotSize) frames.
    //It will be used to smoothing movementvalue
    redDotArr[frameIdx % redDotSize] = movementSum;
    int redDotAvg = 0;
    for(int i = 0; i < redDotSize ; i++) {
      redDotAvg += redDotArr[i];
    }
    redDotAvg /= redDotSize;
    
    //Danger Situation Detection
    movementSumArr[frameIdx % movementSumArrSize] = movementSum;
    //Count how many frames have exceeded the threshold for last 50(movementSumArrSize) frames
    int movementCnt = 0;
    for(int i = 0; i < movementSumArrSize ; i++) {
      if(movementThreshold < movementSumArr[i]) {
        movementCnt++;
      }
    }
   
    p.updatePixels();
    int offset = 46;
    image(p,offset,0);
 
    //If more than 45 of the 50 frames have exceeded the threshold, 
    //the action is determined to have lasted for a period of time or longer.
    if (movementCnt > 45) {
      fill(0);
      noStroke();
      rectMode(CENTER);
      rect(movWidth/2+offset,movHeight/2-15,200,50);
      fill(255,0,0);
      textSize(40);
      textAlign(CENTER);
      text("WARNING",movWidth/2+offset, movHeight/2); 
    }
    
    //draw movementValue
    fill(0,255,0);
    textAlign(LEFT);
    textSize(24);
    text("Movement Value : "+redDotAvg, 10+offset, 30); 
    
    //graph
    stroke(255,255,0);
    strokeWeight(3);
    
    //window size 640, 360
    //graph range x: 10 - 330
    //graph range y: 310 - 630

    int graphWidth = 160;
    int graphHeight = 160;
    int graphPosX = 10+offset;
    int graphPosY = movHeight - graphHeight - 40;
    line(graphPosX, graphPosY, graphPosX, graphPosY + graphHeight); //vertical line (length : 320)
    line(graphPosX, graphPosY + graphHeight, graphPosX + graphWidth, graphPosY + graphHeight); //horizontal line (length : 320)
    
    //redDotArr
    //redDotSize
    //frameIdx
    
    for(int i = 1; i<redDotSize; i++)
    {
      int fromIndex = (frameIdx + i) % redDotSize;
      int toIndex = (frameIdx + i+1) % redDotSize;
      int fromHeight = (int)((double)redDotArr[fromIndex]/25000000*graphHeight);
      fromHeight = Math.max(fromHeight,0);
      fromHeight = Math.min(fromHeight, graphHeight);
      int toHeight = (int)((double)redDotArr[toIndex]/25000000*graphHeight);
      toHeight = Math.max(toHeight,0);
      toHeight = Math.min(toHeight, graphHeight);
      line(graphPosX + (i-1)*graphWidth/redDotSize, graphPosY + graphHeight - fromHeight,
        graphPosX + i*graphWidth/redDotSize, graphPosY + graphHeight - toHeight);
    }
}
