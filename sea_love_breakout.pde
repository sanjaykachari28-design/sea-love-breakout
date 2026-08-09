// Sea Love Breakout - GAMEVOLTX UPDATED
// Responsive game + Score + Lives + Level + Play/Pause/Restart

float[] area = {25,25,724,530};
float paddleX, paddleW=128, paddleH=25, paddleY=500;
float bx,by,br=20,bvx,bvy,bspeed;
PImage bg,resources,paddle,ball,border,brickSheet;
ArrayList bricks;
int score=0,lives=3,level=1;
boolean playing=false,paused=false,gameOver=false;
int missTimer=0;

color[] cols={color(255,80,80),color(255,245,80),color(130,255,80),color(50,240,255),color(100,130,255)};

class Brick {
  float x,y,w=90,h=40; int hp=2;
  color c;
  Brick(float xx,float yy,color cc){x=xx;y=yy;c=cc;}
  void drawBrick(){
    if(hp<=0)return;
    noStroke(); fill(c); rect(x,y,w,h,4);
    fill(255,80); rect(x+2,y+2,w-4,h/2-2,3);
    stroke(0,80); noFill(); rect(x,y,w,h,4);
  }
}

void newLevel(){
  bricks=new ArrayList();
  for(int r=0;r<5;r++) for(int c=0;c<5;c++) bricks.add(new Brick(120+c*92,105+r*42,cols[r]));
  paddleX=(area[0]+area[2]-paddleW)/2;
  bx=375; by=330;
  bspeed=4.0+(level-1)*0.35;
  float a=radians(315); bvx=cos(a)*bspeed; bvy=-sin(a)*bspeed;
  missTimer=0;
}

void resetGame(){score=0;lives=3;level=1;playing=false;paused=false;gameOver=false;newLevel();}

void setup(){
  size(750,530); frameRate(40);
  bg=loadImage("background.jpg");
  resources=loadImage("resources.png");
  border=loadImage("border.png");
  paddle=createImage(128,25,ARGB); paddle.copy(resources,0,40,128,25,0,0,128,25);
  ball=createImage(43,43,ARGB); ball.copy(resources,0,65,43,43,0,0,43,43);
  resetGame();
}

void movePaddle(){
  if(mouseX>=0 && mouseX<=width){
    paddleX=mouseX-paddleW/2;
    paddleX=constrain(paddleX,area[0]+1,area[0]+area[2]-paddleW);
  }
}

void mouseMoved(){movePaddle();}
void mouseDragged(){movePaddle();}
void mousePressed(){
  if(!playing && !gameOver){playing=true;paused=false;}
  else if(gameOver){resetGame();playing=true;}
}

void keyPressed(){
  if(key=='p'||key=='P'||key==' '){if(playing&&!gameOver)paused=!paused;return;}
  if(key=='r'||key=='R'){resetGame();return;}
  if(key==CODED&&(keyCode==LEFT||keyCode==RIGHT)){
    paddleX+=(keyCode==LEFT?-14:14);
    paddleX=constrain(paddleX,area[0]+1,area[0]+area[2]-paddleW);
    if(!playing&&!gameOver)playing=true;
  }
}

boolean hitPaddle(){
  return bx+br>paddleX && bx-br<paddleX+paddleW && by+br>paddleY && by-br<paddleY+paddleH && bvy>0;
}

void updateGame(){
  if(!playing||paused||gameOver)return;
  movePaddle();

  if(missTimer>0){
    missTimer++;
    if(missTimer>45){
      lives--;
      if(lives<=0){gameOver=true;playing=false;return;}
      bx=375;by=330;float a=radians(315);bvx=cos(a)*bspeed;bvy=-sin(a)*bspeed;missTimer=0;
    }
    return;
  }

  bx+=bvx; by+=bvy;
  if(bx-br<=area[0]){bx=area[0]+br;bvx=abs(bvx);}
  if(bx+br>=area[0]+area[2]){bx=area[0]+area[2]-br;bvx=-abs(bvx);}
  if(by-br<=area[1]){by=area[1]+br;bvy=abs(bvy);}

  if(hitPaddle()){
    by=paddleY-br;
    float hit=(bx-(paddleX+paddleW/2))/(paddleW/2);
    bvx=hit*bspeed*1.15;
    float v=sqrt(max(1,bspeed*bspeed-bvx*bvx));
    bvy=-v;
  }

  for(int i=bricks.size()-1;i>=0;i--){
    Brick q=(Brick)bricks.get(i);
    if(q.hp<=0)continue;
    if(bx+br>q.x&&bx-br<q.x+q.w&&by+br>q.y&&by-br<q.y+q.h){
      q.hp--; score+=q.hp==0?100:50;
      float dx=min(abs(bx-q.x),abs(bx-(q.x+q.w)));
      float dy=min(abs(by-q.y),abs(by-(q.y+q.h)));
      if(dx<dy)bvx=-bvx; else bvy=-bvy;
      break;
    }
  }

  boolean clear=true; for(int i=0;i<bricks.size();i++) if(((Brick)bricks.get(i)).hp>0)clear=false;
  if(clear){level++;newLevel();}
  if(by-br>area[1]+area[3])missTimer=1;
}

void hud(){
  noStroke();fill(0,0,0,175);rect(30,8,690,42,10);
  fill(255);textAlign(LEFT,CENTER);textSize(16);text("SCORE  "+score,45,29);
  textAlign(CENTER,CENTER);text("LEVEL  "+level,375,29);
  textAlign(RIGHT,CENTER);text("LIVES  "+lives,705,29);
}

void overlay(String title,String line,String button){
  fill(0,0,0,185);rect(0,0,750,530);
  fill(255);textAlign(CENTER,CENTER);textSize(34);text(title,375,225);
  fill(220);textSize(16);text(line,375,268);
  fill(0,220,255);rect(285,315,180,50,12);
  fill(0);textSize(17);text(button,375,340);
}

void draw(){
  if(bg!=null)image(bg,0,0); else {background(10);}
  if(border!=null)image(border,0,0);

  for(int i=0;i<bricks.size();i++)((Brick)bricks.get(i)).drawBrick();
  if(paddle!=null)image(paddle,paddleX,paddleY); else {fill(230);rect(paddleX,paddleY,paddleW,paddleH);}
  if(ball!=null)image(ball,bx-br,by-br); else {fill(255);ellipse(bx,by,br*2,br*2);}

  updateGame(); hud();

  if(!playing&&!gameOver)overlay("SEA LOVE BREAKOUT","Break the blocks and collect points","▶  PLAY");
  if(paused&&!gameOver)overlay("PAUSED","Press P / SPACE or tap the game to continue","▶  PLAY");
  if(gameOver)overlay("GAME OVER","Final score: "+score,"↻  PLAY AGAIN");
}
