// Sea love breakout
// Coder: Hryhir Teteria (e-mail:lyrurustetrix@airmail.cc, git repo: https://github.com/LyrurusTetrix/)
// Artist: Anhelina Suschevska (e-mail: gelofdesign@gmail.com, portfolio: https://www.behance.net/gelof)
// Code and graphical resource licensed under Public Domain

/* @pjs preload="background.jpg,resources.png,border.png"; crisp="false"; globalKeyEvents="true"; */

float[] active_region = {25, 25, 724, 530};
float platform_width, platform_height, platform_x, platform_baseline, platform_velocity;
float ball_speed_x, ball_speed_y, ball_speed, ball_angle, ball_radius, ball_x, ball_y;
int ms;
boolean loading;
PImage bgImg, ballImg, platformImg, borderImg, bricksImg;
ArrayList<Brick> bricks;
color colors[] = {color(255, 0, 0), color(255, 255, 0), color(128, 255, 0), color(0, 255, 255), color(0, 0, 255), color(128, 0, 128)};

void reload() {
  platform_width = platformImg.width;
  platform_height = platformImg.height;
  platform_x = (active_region[0]+active_region[2]-platform_width)/2;
  platform_baseline = 500;
  platform_velocity = 8.0;
  ball_speed = 4.0;
  ball_angle = 315.0;
  ball_x = 30;
  ball_y = 280;
  change_ball_angle();
  bricks = new ArrayList<Brick>();
  for(int y = 0; y < 5; y++) {
    float transp = 0.1;
    for(int x = 0; x < 5; x++) {
      bricks.add(new Brick(120+x*92, 120 + y*42, colors[y], transp));
      transp+=0.1;
    }
  }
  ms = 0;
}

PImage mixwithcolor(PImage img, color c, float t) {
  PImage result;
  result = createImage(img.width, img.height, ARGB);
  img.loadPixels();
  result.loadPixels();
  for(int i = 0; i < img.width*img.height; i++) {
    result.pixels[i] = color(ceil(t*red(c)+(1.0-t)*(red(img.pixels[i]))), 
    ceil(t*green(c)+(1.0-t)*(green(img.pixels[i]))), 
    ceil(t*blue(c)+(1.0-t)*(blue(img.pixels[i]))));
  }
  result.updatePixels();
  return(result);
}

float[] check_collision_ball_rectangle(float[] rect, float[] circle) {
  float[] result = new float[4];
  result[0] = 0;
  if ((rect.length != 4) || (circle.length != 3)) 
    return(result);
  float rx0 = rect[0], ry0 = rect[1], rx1 = rect[0]+rect[2]-1, ry1 = rect[1]+rect[3]-1, 
    cx = circle[0], cy = circle[1], cr = circle[2];
  float x = (cx < rx0)?rx0:((cx>rx1)?rx1:cx), y = (cy < ry0)?ry0:((cy>ry1)?ry1:cy);
  float dX = cx-x;
  float dY = cy-y;
  float dist = sqrt((dX*dX)+(dY*dY));
  result[1] = x;
  result[2] = y;
  result[3] = dist;
  if (dist <= cr) {
    result[0] = 1.0;
  } 
  return(result);
}

float[] resolve_collision_ball_rectangle(float[] rect, float[] ball) {
  float dir_x = 0, dir_y = 0;
  float distance = ball[2]+1;
  float result[] = new float[4];
  result[0] = 0;
  float[] collision = check_collision_ball_rectangle(rect, ball);
  if (collision[0] > 0.0) {
    result[0] = 1;
    dir_x = (ball[0] < rect[0])?-1.0:((ball[0] > rect[0] + rect[2])?1.0:0.0);
    dir_y = ((ball[1] < rect[1])?-1.0:((ball[1] >= rect[1] + rect[3])?1.0:0.0));
    result[1] = (dir_y+1)*3+dir_x+1;
    if ((dir_x == 0) && (dir_y == 0)) {
      result[2] = collision[1]; 
      result[3] = collision[2];
    } if (dir_x == 0) {
      result[2] = collision[1]; 
      result[3] = collision[2]+distance * dir_y; 
    } else if (dir_y == 0) {
      result[2] = collision[1]+distance * dir_x; 
      result[3] = collision[2]; 
    } else {
      result[2] = collision[1] + dir_x*(abs(collision[1]-ball[0])*distance/collision[3]);
      result[3] = collision[2] + dir_y*(abs(collision[2]-ball[1])*distance/collision[3]);
    }
  }
  return(result);
}

void collision_reflection(float[] collision) {
  float angles[] = {315.0,270.0,225.0,0.0,0.0,180.0,45.0,90.0,135.0};
  if (collision[0] > 0) {
    ball_x = collision[2];
    ball_y = collision[3];
    ball_angle = reflect_angle(angles[ceil(collision[1])], ball_angle);
    change_ball_angle();
  }
}

class Brick {
  float x, y, width, height;
  int state;
  PImage brick, brokenbrick;
  
  Brick (float x0, float y0, color c, float transp) {
    x = x0; y = y0; width = bricksImg.width/2; height = bricksImg.height; state = 2;
    PImage bricks;
    bricks = mixwithcolor(bricksImg, c, transp);
    brick = createImage(90,40,ARGB);
    brokenbrick = createImage(90,40,ARGB);
    brick.copy(bricks, 0, 0, 90, 40, 0, 0, 90, 40);
    brokenbrick.copy(bricks, 90, 0, 90, 40, 0, 0, 90, 40);
  }
  
  void next_tick() {
    float[] rect = {x, y, width, height};
    float[] circle = {ball_x, ball_y, ball_radius};
    float[] collision = resolve_collision_ball_rectangle(rect, circle);
    if (collision[0]>0) {
      collision_reflection(collision);
      state--;
    }
  }
  
  void draw() {
    if (state > 0) image((state == 1)?brokenbrick:brick, x, y);
  }
}

float angle360(float alpha) {
  alpha %= 360.0;
  return((alpha<0.0)?(360.0+alpha):alpha);
}

float reflect_angle(float nrm, float angle_ball) {
  return(angle360(180.0-angle_ball+nrm*2.0));
}

void change_ball_angle() {
  ball_speed_x = cos(radians(ball_angle))*ball_speed;
  ball_speed_y = -sin(radians(ball_angle))*ball_speed;
}

void setup() {
  frameRate(40);
  size(750, 530);
  bgImg = loadImage("background.jpg");
  PImage resourcesImg = loadImage("resources.png");
  platformImg = createImage(128, 25, ARGB);
  platformImg.copy(resourcesImg, 0, 40, 128, 25, 0, 0, 128, 25);
  ballImg = createImage(43, 43, ARGB);
  ballImg.copy(resourcesImg, 0, 65, 43, 43, 0, 0, 43, 43);
  borderImg = loadImage("border.png");
  bricksImg = createImage(180, 40, ARGB);
  bricksImg.copy(resourcesImg, 0, 0, 180, 40, 0, 0, 180,40);
  ball_radius = 20;
  reload();
}

void draw() {
  float ball_left_point = ball_x-ball_radius+1, ball_right_point = ball_x+ball_radius-1, ball_up_point = ball_y-ball_radius+1, ball_down_point = ball_y+ball_radius-1;
  image(bgImg, 0.0, 0.0);
  if (bricks.size()==0) {
    return;
  }
  image(borderImg, 0, 0);
  for(int i=0; i<bricks.size(); i++) {
    Brick brick = bricks.get(i);
    brick.draw();
    brick.next_tick();
    if (brick.state == 0) {
      bricks.remove(i);
    }
  }
  image(platformImg, platform_x, platform_baseline);
  image(ballImg, ball_x-ball_radius, ball_y-ball_radius);
  if (ms > 0) {
    if(millis()-ms >= 3000) {
      reload();    
    }
    return;
  }
  if (ball_up_point >= active_region[3]) {
    ms = millis();
    return;
  }
  if ((key == CODED) && (keyPressed == true) && ((keyCode == LEFT)||(keyCode == RIGHT))) {
    platform_x = (keyCode == LEFT)?(platform_x - platform_velocity):(platform_x + platform_velocity);
    platform_x = constrain(platform_x, active_region[0]+1, active_region[2]-platform_width);
  }
  float[] rect = {platform_x, platform_baseline, platform_width, platform_height};
  float[] circle = {ball_x, ball_y, ball_radius};
  float[] collision = resolve_collision_ball_rectangle(rect, circle);
  if (collision[0] > 0) {
    collision_reflection(collision);
    return;
  }  
  if ((ball_left_point <= active_region[0]) || (ball_right_point >= active_region[2]) || (ball_up_point <= active_region[1])) {
    if (ball_up_point <= active_region[1]) {
      ball_angle = reflect_angle(270.0, ball_angle);
      ball_y = active_region[1]+ball_radius+1;
    } else {
      ball_angle = reflect_angle((ball_left_point <= active_region[0])?180:0, ball_angle);
      ball_x = (ball_left_point <= active_region[0])?active_region[0]+ball_radius:active_region[2]-ball_radius;
    }
    change_ball_angle();
    return;
  }
  ball_x += ball_speed_x;
  ball_y += ball_speed_y;
}
