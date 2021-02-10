/**
 * Holds kinematic data for the character.
 */
Kinematic character;

/**
 * Holds kinematic data for the target.
 */
Kinematic target;

/**
 * Holds the radius and the forward offset of the 
 * wander circle
 */
float wanderOffset;
float wanderRadius;

/**
 * Holds the maximum rate at which the wander orientation 
 * can change.
 */
float wanderRate;

/**
 * Holds the current orientation of the wander target 
 */
float wanderOrientation;

/**
 * Holds the maximum acceleration of the character
 */
float maxAcceleration;

/**
 *  Max acceleration speed of the character.
 */
float maxSpeed;

/**
 * The distance between the character and the target.
 */
float distance;

/**
 * The size of the character that will be moving.
 */
float size;

 /**
  * Holds the radius for slowing down.
  */ 
float slowRadius;

/**
 * Holds the time in which to keep the target 
 * speed.
 */
float timeToTarget = 0.1;

/**
 * The number of times the character has 
 * turned in the same direcrion.
 */
float limit;

/**
 * Whether the last orientation change consisted
 * of a negative rotation or not.
 */
boolean neg;

/**
 * Limit must be equal count before the
 * character can switch rotation direction
 */
float count;

/**
 * The probability that the next orientation 
 * change should be zero.
 */
float zero;

/**
 * Funciton for setting up varaibles at the beganning of
 * the program.
 */
void setup() {
  
  // Initializing the size of the canvas. 
  size(800, 800);
  
  // Initializing character and target kinematics.
  character = new Kinematic();
  target = new Kinematic();
  
  // Initializing wanderOffset and wanderRadius
  wanderOffset = 0;
  wanderRadius = 200;
  
  // Initializes wanderRate and wanderOrientation
  wanderRate = 1;
  wanderOrientation = 0;
  
  // Initializes maxAcceleration & speed
  maxAcceleration = 0.5;
  maxSpeed = 3.5;
  
  // Initializing size of the character and its distance from the target.
  size = 30;
  distance = 0;
  
  // Initialize slow radius 
   slowRadius = 0;
  
  // Updating character starting position.
  character.position.x = size;
  character.position.y = size;
  
  // Intializing limit, neg, & count variables
  limit = 0;
  neg = false;
  count = 20;
  
  // Initializing zero probability variable
  zero = 0.5;
  
}  

/**
 * Responsible for graphics on the canvas.
 */
void draw() {
  
  // Establishing background color.
  background(25);
  
  // Displays character at the appropriate location and orientation.
  translate( character.position.x, character.position.y );
  rotate(character.orientation);  
  fill(180);
  noStroke();
  ellipse(0, 0, size, size);
  triangle( 0 + size/3.5, 0 + size/2.5, 0 + size/3.5, 0 - size/2.5, 0 + size, 0);
  
  update();
  
}  
  

/**
 * A steering update function responsible for updating 
 * variables, steering out & kinematics. 
 */
void update() {
  
  // Get Acceleration Requests
  SteeringOutput out = getSteeringWander();
  
  //character.velocity.add(out.linAccel);
  character.velocity.x += out.linAccel.x;
  character.velocity.y += out.linAccel.y;
  
  //// Clip to max velocity
  if ( character.velocity.mag() > maxSpeed ) {
     character.velocity.normalize();
     character.velocity.mult(maxAcceleration);
  }
    
  // Calculate new position.
  character.position.x += character.velocity.x;
  character.position.y += character.velocity.y; 
    
  // Calculate orientation.
  if ( character.velocity.x == 0 ) {
    character.orientation = 0;
  } else {  
   character.orientation = atan2( ( character.velocity.y), character.velocity.x);
  }  
      
}

/**
 * Returns a random floating point number in 
 * binomial fashion. 
 */
float randomBinomial() {
  
  float ret = random(0.5) - random(0.5);
    
  // Case 1: A negative number is requested
  if ( ret < 0 ) {
    
    // You are already negative
    if ( neg == true ) {
    
       // simply add to limit
       limit++;
     
    // You are positve and haven't hit limit requirement   
    } else if ( neg == false  && limit < count) {
      
      // Stay positive
      ret *= -1;
      limit++;
    
    // You are positve and have hit negative requirement   
    } else {
      
      // You are safe to change, reset limit.
      neg = true;
      limit = 0;
    } 
    
  // Case 2: A positive number is requested  
  } else {
    
    // You are already positive
    if ( neg == false ) {
    
       // simply add to limit
       limit++;
     
    // You are negative and haven't hit limit requirement   
    } else if ( neg == true  && limit < count) {
      
      // Stay negative
      ret *= -1;
      limit++;
    
    // You are negative and have hit limit requirement   
    } else {
      
      // You are safe to change, reset limit.
      neg = false;
      limit = 0;
    } 
    
  }  
  
  float rad = random(1.0);
  if ( rad < zero ) {
    ret = 0;
  }  
  return ret;
  
}  

/**
 * Accepts radians and produces the vector version of 
 * it.
 */
PVector asVector( float angle ) {
  PVector ret = new PVector( 0, 0 );
  ret.x = sin(angle);
  ret.y = cos(angle);
  return ret;
}   

/**
 * Implementation of Wander Algorithm from "Artificial Intellegence for Games" 2nd Ed. 
 * Ian Millington, John Funge - pg. 74
 */
SteeringOutput getSteeringWander() {
  
  //  ( 1 )  Calculate the target to delegate to face   //
  
  // A structure for holding our output.
  SteeringOutput steering = new SteeringOutput();
  
  // Update the wander orientation
  wanderOrientation += randomBinomial() * wanderRate;
  
  // Calculate the combined target orientation
  target.orientation = wanderOrientation + character.orientation;
  
  // Calculate the center of the wander circle 
  target.position.x = character.position.x + wanderOffset + asVector( character.orientation ).x;
  target.position.y = character.position.y + wanderOffset + asVector( character.orientation ).y;
  
  // Make sure wander circle is within bounds & clip if not
  if ( target.position.x < wanderRadius + size ) {
    target.position.x = wanderRadius;
  } 
  if ( target.position.x > 800 - wanderRadius - size) {
    target.position.x = 800 - wanderRadius - size;
  }  
  if ( target.position.y < wanderRadius + size ) {
    target.position.y = wanderRadius;
  } 
  if ( target.position.y > 800 - wanderRadius - size ) {
    target.position.y = 800 - wanderRadius - size;
  }  

  // Calculate the target location
  target.position.x += wanderRadius * asVector( target.orientation ).x;
  target.position.y += wanderRadius * asVector( target.orientation ).y;
  
  //  ( 2 )  Delegate to Seek   //
  
  // Get the direction of the target  
  PVector directionOfTarget = new PVector( 0, 0 );
  directionOfTarget.x += target.position.x;
  directionOfTarget.y += target.position.y; 
  directionOfTarget.x -= character.position.x;
  directionOfTarget.y -= character.position.y;
  
  distance = directionOfTarget.mag();
  
  // The speed one should use to approach the target.
  float targetSpeed;
  
  // If we are outside the slowRadius, then go to max speed.
  if ( distance > slowRadius ) {
    targetSpeed = maxSpeed;
    
  // Otherwise calculate a scaled speed. 
  } else {
    targetSpeed = maxSpeed * distance / slowRadius;
  }  
  
  // The target velocity combines speed and direction.
  target.velocity = directionOfTarget.normalize();
  target.velocity.mult(targetSpeed);
  
  // Acceleration tries to get to the target velocity.
  steering.linAccel.x = target.velocity.x;
  steering.linAccel.y = target.velocity.y;
  steering.linAccel.x -= character.velocity.x;
  steering.linAccel.y -= character.velocity.y;
  
  steering.linAccel.div( timeToTarget );
  
  // Check if acceleration is too fast.
  if ( steering.linAccel.mag() > maxAcceleration ) {
    steering.linAccel.normalize();
    steering.linAccel.mult(maxAcceleration);
  }  
  
  // Output the steering. 
  return steering;
}  
  
  
  
/**
 * A class that acts as a struct for holding 
 * kinematic variables. 
 */
class Kinematic {
  PVector velocity;
  PVector position;
  float orientation;
  float rotation; 
  
  public Kinematic() {
    velocity = new PVector(0, 0);
    position = new PVector(0, 0);
    orientation = 0;
    rotation = 0;
  }  
}

/**
 * A class that acts as a struct for holding
 * steering output.
 */
class SteeringOutput {
  PVector linAccel;
  float rotAccel;
  
  public SteeringOutput() {
    linAccel = new PVector(0, 0);
    rotAccel = 0;
  }  
}  
    
  
  
  
  
  
  
