/********************************************************
 * XCOM: Enemy Unknown - Rapid Fire Calculator           *
 * Calculates when it is better to use a normal shot or  *
 * the Rapid Fire ability, which makes 2 shots at a -15% *
 * penalty to hit.                                       *
 ********************************************************/
int damagePerShot = 5;
int simulationsToRun = 1000;

int simulationsRun = 0;
int totalSumOfPercentages = 0;

boolean debug = false;

void setup() {
  size(1000, 600);
  noStroke();

  RunSimulation();
}

void draw() {
  //This needs to exist for change to be possible
}

void mousePressed() {
  RunSimulation();
}

void RunSimulation() {
  //Reset the image
  simulationsRun++;
  background(255);
  //Useful constants
  int barHeight = height / 200;
  int maxBarWidth = 2 * damagePerShot;
  //Arrays to hold the calculated values for post analysis
  float[] oneShots = new float[100];
  float[] twoShots = new float[100];
  //run the odds for each percentage
  for (int i = 0; i < 100; i++) {
    float one = CalcAverageDamage_OneShot(i + 1);
    float two = CalcAverageDamage_TwoShot(GetTwoShotPercentage(i + 1));
    oneShots[i] = one;
    twoShots[i] = two;
    fill(255, 0, 0);
    float percentOfTotal = one / maxBarWidth;
    rect(0, i * barHeight * 2, percentOfTotal * width, barHeight);
    fill(0);
    percentOfTotal = two / maxBarWidth;
    rect(0, i * barHeight * 2 + barHeight, percentOfTotal * width, barHeight);
  }
  //Update the HUD
  CalcGuaranteeLine(oneShots, twoShots, barHeight);
  DrawHelpText();
}

//Adjust the percent to hit for the two shot penalty
int GetTwoShotPercentage(int oneShot) {
  return max(oneShot - 15, 1);
}

//Run the average
float CalcAverageDamage_OneShot(float percentToHit) {
  float hits = 0;
  for (int i = 0; i < simulationsToRun; i++) {
    float rolledValue = random(0, 100);
    if (rolledValue < percentToHit) {
      hits++;
    }
  }
  return damagePerShot * (hits / simulationsToRun);
}

//Run the average, shooting twice since they can hit twice
float CalcAverageDamage_TwoShot(int percentToHit) {
  float hits = 0;
  for (int i = 0; i < simulationsToRun; i++) {
    for (int j = 0; j < 2; j++) {
      float rolledValue = random(1, 100);
      if (rolledValue < percentToHit) {
        hits++;
      }
    }
  }
  return damagePerShot * (hits / simulationsToRun);
}

//Draw the line above which all two shots are better than their matching one shot
void CalcGuaranteeLine(float[] one, float[] two, int barHeight) {
  int oneBetterThanTwo = 0;
  for (int i = one.length - 1; i >= 0; i--) {
    if (two[i] < one[i]) {
      oneBetterThanTwo = i;
      break;
    }
  }
  //update the global counter
  totalSumOfPercentages += oneBetterThanTwo;
  //calculate the y position on the screen
  int y = barHeight * oneBetterThanTwo * 2;
  //draw and print info
  stroke(0, 255, 0);
  strokeWeight(2);
  line(0, y, width, y);
  noStroke();
  String textToDraw = String.format("%2d%%", oneBetterThanTwo);
  fill(0);
  textSize(12);
  text(textToDraw, width - 30, y);
  if (debug) {
    String textToPrint = String.format("Two shots deal more damage on average above %2d%%%n", oneBetterThanTwo);
    print(textToPrint);
  }
}

void DrawHelpText() {
  fill(0);
  textSize(15);
  //Text that always appears
  text("Red bars are average damage from one shot", width - 323, 15);
  text("Black bars are average damage from two shots", width - 344, 35);
  text("Order going down is the original percent to hit with a single shot", width - 474, 55);
  float percentSoFar = (float)totalSumOfPercentages / (float)simulationsRun;
  String t = String.format("Average so far: %2.2f%%", percentSoFar);
  text(t, width - 170, 75);
  text("Click to run again", width - 130, 95);
}

