//introduce variables and objects
PImage mapImage;
Table locationTable; //this is using the Table object
Table amountsTable; //this is using the Table object
int rowCount;
float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;

color c= color(35,35,125);

//global variables assigned values in drawData()
float closestDist;
String closestText;
float closestTextX;
float closestTextY;

float minusrad;
float moreopa;

//The Temperature read by the Arduino serial
float tempy = 0;

//Serial, the program will only work if the Arduino component is plugged in
import processing.serial.*;
Serial thisPort;

void setup() {
  size(1200, 800);
  mapImage = loadImage("emotiongraphdotless.png");
  
//  String Tempport = Serial.list()[0];
//  thisPort = new Serial(this, Tempport, 9600);

  //assign tables to object
  locationTable = new Table("locations.tsv");  
  amountsTable = new Table("amounts.tsv");

  // get number of rows and store in a variable called rowCount
  rowCount = locationTable.getRowCount();
  //count through rows to find max and min values in random.tsv and store values in variables
  for (int row = 1; row< rowCount; row++) {
    //get the value of the second field in each row (1)
    float value = amountsTable.getFloat(row, 0);
    //if the highest # in the table is higher than what is stored in the 
    //dataMax variable, set value = dataMax
    if (value>dataMax) {
      dataMax = value;
    }
    //same for dataMin
    if (value<dataMin) {
      dataMin = value;
    }
  }
  //Serial, will only work if the Arduino component is plugged in, otherwise comment out.
  thisPort = new Serial(this, Serial.list()[0], 9600);
  thisPort.bufferUntil('\n');
}

void draw() {
  background(255);
  image(mapImage, 0, 0);
  
  textSize(24);
  fill(0,0,0);
  text("Temperature", 475, 30);
  //Serial, will only work if the Arduino component is plugged in, otherwise comment out.
  textSize(30);
  fill(0,0,0);
  text(tempy, 625, 30);
  
  textSize(30);
  fill(0,0,0);
  text("F", 750, 30);

  closestDist = MAX_FLOAT;

//count through rows of location table, 
  for (int row = 0; row<rowCount; row++) {
    //assign id values to variable called id
    String id = amountsTable.getRowName(row);
    //get the 2nd and 3rd fields and assign them to
    float x = locationTable.getFloat(id, 1);
    float y = locationTable.getFloat(id, 2);
    
    int inc = row+1;
    
    if(inc>rowCount-1){
      inc = 0;
    }
    
    float x2 = locationTable.getFloat(inc, 1);
    float y2 = locationTable.getFloat(inc, 2);
    
    //use the drawData function (written below) to position and visualize
    drawData(x, y, x2, y2, id);
  }

//if the closestDist variable does not equal the maximum float variable....
  if (closestDist != MAX_FLOAT) {
    fill(0);
    textAlign(CENTER);
    text(closestText, closestTextX, closestTextY);
  }
}

//we write this function to visualize our data 
// it takes 3 arguments: x, y and id
void drawData(float x, float y, float x2, float y2, String id) {
//value variable equals second field in row
  float value = amountsTable.getFloat(id, 1);
  float radius = 0;
  
//if the value variable holds a float greater than or equal to 0
  if (value>=15) {
    //remap the value to a range between 1.5 and 15
    radius = map(value, 21, dataMax/3, 20, 50); 
    //and make it this color
    
    strokeWeight(0);
  } else {
    //otherwise, if the number is negative, make it this color.
    radius = map(value, 12, dataMax/3, 20, 50);   
    strokeWeight(0);
  }
  //make a circle at the x and y locations using the radius values assigned above
  noStroke();
  fill(50*(tempy/6), 50, 100/(tempy/15));
  ellipseMode(RADIUS);
  ellipse(x, y/(tempy/15), radius, radius);
  stroke(50*(tempy/6), 50, 100/(tempy/15));
  strokeWeight(3);
  line(x,y/(tempy/15),x2,y2/(tempy/15));
  float d = dist(x, y/(tempy/15), mouseX, mouseY);

// println(d);

//if the mouse is hovering over circle, show information as text
  if ((d<radius+2) && (d<closestDist)) {
   // closestDist = d;
   // String name = amountsTable.getString(id, 1);
   // closestText = tempy*y/10+"";
   // closestTextX = x;
   // closestTextY = y-radius-4;
    
    //minusrad = -20;
    //moreopa = 250;
    fill(100*(tempy/6),100,150/(tempy/15));
    ellipseMode(RADIUS);
    ellipse(x, y/(tempy/15), radius+20, radius+20);
  }
    else {
      minusrad = 0;
      moreopa = 0;
  }
}
//Serial, will only work if the Arduino component is plugged in, otherwise comment out.
void serialEvent(Serial thisPort) {
  String inString = thisPort.readStringUntil('\n');
  
  if (inString != null) {
    inString = trim(inString);
    tempy = float(inString);
    println(tempy);
  }
}

void writeText(String textToWrite){
  fill(0);
  text(textToWrite, 525, 30);
}