float g = .05;
PVector f;
Asteroid planet;
Asteroid[] planets = {};
int n_planets = 3;
PVector[] forces = {};
int max_hist = 400;
PVector centroid = new PVector(0, 0);
int max_hue = 255;
int hue_offset = 30;

int offset_hue(int hue) {
  return (hue + hue_offset) % max_hue;
}

PVector rotate(float theta, PVector v) {
  float new_x = v.x * cos(theta) - v.y * sin(theta);
  float new_y = v.x * sin(theta) + v.y * cos(theta);
  return new PVector(new_x, new_y);
}

PVector gravity(Asteroid a, Asteroid b) {
  PVector a_pos = a.p.copy();
  PVector b_pos = b.p.copy();

  float r = a_pos.dist(b_pos);
  
  if (r > 1) {
    PVector direction = b_pos.copy().sub(a_pos);
    PVector numerator = direction.copy().mult(g * a.m * b.m);
    float magnitude = direction.mag();
    float denom = pow(magnitude, 2);
    
    return numerator.div(denom);
  }
  else {
    return new PVector(0, 0);
  }

}

class Asteroid {
  float m;
  PVector p, v, a, t;
  PVector[] path = {};

  Asteroid (float mass, PVector pos, PVector vel, PVector acc) {
    m = mass;
    p = pos;
    v = vel;
    a = acc;
  }

  void update(PVector f) {
    path = (PVector[]) append(path, p.copy());
    a = f.div(m);
    v = v.add(a);
    p = p.add(v);
    if (path.length > max_hist) {
      path = (PVector[]) reverse(shorten(reverse(path)));
    }
  }

  void show(int h) {
    fill(h, max_hue, max_hue);
    circle(p.x, p.y, m);
    
    push();
    stroke(h, 255, 255);
    strokeWeight(2);
    beginShape(LINES);
    for (PVector z : path) {
      vertex(z.x, z.y);
    }
    endShape();
    pop();
  }
}

void setup() {
  size(1000, 1000);
  frameRate(100);
  colorMode(HSB);
  background(0);
  
  for (int i = 0; i < n_planets; i++) {
    planet = new Asteroid(
      20,
      new PVector(
        random(height / 4, 3 * height / 4),
        random(height / 4, 3 * height / 4)
      ),
      new PVector(0, 0),
      new PVector(0, 0)
    );
    
    planets = (Asteroid[]) append(planets, planet);
  }
}

void draw() {
  background(0);
  PVector[] forces = {};
  centroid = new PVector(0, 0);
  
  for (int i = 0; i < n_planets; i++) {
    f = new PVector(0, 0);
    for (int j = 0; j < n_planets; j++) {
      if (i != j) {
        PVector newforce = gravity(planets[i], planets[j]);
        f = f.add(newforce);
      }
    }
    forces = (PVector[]) append(forces, f);
  }
  
  for (int i = 0; i < n_planets; i++) {
    planets[i].update(forces[i]);
    planets[i].show(
      offset_hue((int) map(i, 0, n_planets, 0, max_hue))
    );
    centroid = centroid.add(planets[i].p);
  }
  centroid = centroid.div(n_planets);
  push();
  stroke(150);
  fill(150);
  circle(centroid.x, centroid.y, 10);

  stroke(150);
  for (int i = 0; i < n_planets; i++) {
    line(planets[i].p.x, planets[i].p.y, centroid.x, centroid.y);
  }
  pop();
}
