use context starter2024
import reactors as R
import image as I


data PlatformLevel: 
  | top
  | middle
  | bottom
end

data GameStatus:
  | ongoing
  | transitioning
  | game-over
end

type Platform = {
  x :: Number,
  y :: Number,
  dx :: Number,
}

type Egg = {
  x :: Number,
  y :: Number,
  dx :: Number,
  dy :: Number,
  ay :: Number,
  is-airborne :: Boolean,
}


type State = {
  game-status :: GameStatus,
  egg :: Egg,
  top-platform :: Platform,
  middle-platform :: Platform,
  bottom-platform :: Platform,
  current-platform :: PlatformLevel,
  other-platforms :: List<Platform>,
  score :: Number,
  lives :: Number,
}

### CONSTANTS ###
FPS = 60

SCREEN-WIDTH = 300
SCREEN-HEIGHT = 500
SCREEN-TRANSITION-SPEED = 3

PLATFORM-WIDTH = 70
PLATFORM-HEIGHT = 13
PLATFORM-COLOR = 'brown'
PLATFORM-VELOCITY-LIMIT = 9
PLATFORM-DISTANCE = 150
TOP-PLATFORM-Y = SCREEN-HEIGHT / 4 # 125
MID-PLATFORM-Y = TOP-PLATFORM-Y + PLATFORM-DISTANCE # 275
BOT-PLATFORM-Y = MID-PLATFORM-Y + PLATFORM-DISTANCE # 425

SCREEN-WIDTH-PLATFORM-LIMIT = SCREEN-WIDTH - PLATFORM-WIDTH 

EGG-RADIUS = 20
EGG-COLOR = 'blanched-almond'
EGG-JUMP-HEIGHT = -20
EGG-AY = 0.9
EGG-INITIAL-X = 100


INITIAL-STATE = {
  game-status: ongoing, 
  egg: {
      x: EGG-INITIAL-X, 
      y: (TOP-PLATFORM-Y + 300) - EGG-RADIUS,  
      dx: 0, 
      dy: 0,
      ay: 0, 
      is-airborne: false,
      color: EGG-COLOR}, 

  top-platform:    {
      x: num-random(SCREEN-WIDTH-PLATFORM-LIMIT), 
      y: TOP-PLATFORM-Y, 
      dx: 
        block: #block set to exclude zero velocity blocks
          VELOCITY-RANDOMIZER = num-random(PLATFORM-VELOCITY-LIMIT)
          if VELOCITY-RANDOMIZER == 0:
            1
          else:
            VELOCITY-RANDOMIZER
          end
        end
    }, 

  middle-platform: {
      x: num-random(SCREEN-WIDTH-PLATFORM-LIMIT), 
      y: MID-PLATFORM-Y, 
      dx:   
        block:
          VELOCITY-RANDOMIZER = num-random(PLATFORM-VELOCITY-LIMIT)
          if VELOCITY-RANDOMIZER == 0:
            1
          else:
            VELOCITY-RANDOMIZER
          end
        end
    },

  bottom-platform: {
      x: EGG-INITIAL-X - (PLATFORM-WIDTH / 2), #same with egg starting x position
      y: BOT-PLATFORM-Y, 
      dx: 
        block:
          VELOCITY-RANDOMIZER = num-random(PLATFORM-VELOCITY-LIMIT)
          if VELOCITY-RANDOMIZER == 0:
            1
          else:
            VELOCITY-RANDOMIZER
          end
        end
    },

  current-platform: bottom,  #egg start at bottom platform
  other-platforms: [list: ],
  score: 0, 
  lives: 12,
}



### DRAWING ###
fun draw-egg(state :: State, img :: Image) -> Image:
  doc:```Draws egg on screen```
  eggimg = circle(EGG-RADIUS, "solid", state.egg.color)
  I.place-image(eggimg, state.egg.x, state.egg.y, img)
end

fun draw-platform(platform :: Platform, img :: Image) -> Image:
  doc:```Draws platform on screen```

  platform-img = rectangle(PLATFORM-WIDTH, PLATFORM-HEIGHT, 'solid', PLATFORM-COLOR ) 
  place-image-align(platform-img, platform.x, platform.y, 'left', 'top', img)
end

fun draw-platforms(state :: State, img :: Image) -> Image:
  doc:```Compiles all platforms in state to place on canvas```

  cases (GameStatus) state.game-status:
    | ongoing => #Draws platforms on initial state movement enabled
      [list: 
        state.top-platform, 
        state.middle-platform, 
        state.bottom-platform].foldr(draw-platform(_, _), img)

    | transitioning => #Draws platforms including generated other platforms
      [list:  
        state.top-platform, 
        state.middle-platform, 
        state.bottom-platform,
        state.other-platforms.get(0), 
        state.other-platforms.get(1)].foldr(draw-platform(_, _), img)

    | game-over => #Draws platforms but movement is disabled
      [list: 
        state.top-platform, 
        state.middle-platform, 
        state.bottom-platform].foldr(draw-platform(_, _), img)

  end
end


fun draw-score(state :: State, img :: Image) -> Image:
  doc:```Draws current score from state.score```
  text-img = text-font(num-to-string(state.score), 19, "black", "Arial", "decorative", "normal", "normal", false)

  I.place-image(text-img, SCREEN-WIDTH / 1.05, SCREEN-HEIGHT / 24, img)
end

fun draw-lives(state :: State, img :: Image) -> Image:
  doc:```Draws current lives from state.lives```
  text-img = text-font(num-to-string(state.lives), 19, "black", "Arial", "decorative", "normal", "normal", false)

  I.place-image(text-img, SCREEN-WIDTH / 4.25, SCREEN-HEIGHT / 24, img)
end


fun draw-game-over(state :: State, img :: Image) -> Image:
  doc:```Displays game over if case of GameStatus is game-over```
  cases (GameStatus) state.game-status:
    | ongoing => img
    | transitioning => img
    | game-over  =>  
      text-img = text-font('GAME OVER', 45, "red", "Arial",
        "decorative", "normal", "bold", false)
      I.place-image(text-img, SCREEN-WIDTH / 2, SCREEN-HEIGHT / 2, img)
  end
end

fun draw-handler(state :: State) -> Image:
  doc:```Draws the image on the screen```
  canvas = empty-color-scene(SCREEN-WIDTH, SCREEN-HEIGHT, "light-blue")

  ###Static Images###
  lives-text = text-font('Lives:', 19, "black", "Arial",
    "decorative", "normal", "normal", false)

  place-lives = I.place-image(lives-text, SCREEN-WIDTH / 9, SCREEN-HEIGHT / 24, _)

  score-text = text-font('Score:', 19, "black", "Arial",
    "decorative", "normal", "normal", false)
  place-score = I.place-image(score-text, SCREEN-WIDTH / 1.215, SCREEN-HEIGHT / 24, _)

  canvas 
    ^ draw-platforms(state, _)
    ^ draw-egg(state, _)
    ^ place-score
    ^ draw-score(state, _)
    ^ place-lives
    ^ draw-lives(state, _)
    ^ draw-game-over(state, _)
end

### KEYBOARD ###

fun key-handler(state :: State, key :: String) -> State:
  doc:```Draw state reacts ifdikey is pressed```

  #If spacebar was pressed, set according to game status
  if key == " ":
    cases (GameStatus) state.game-status:
      | ongoing => 

        #Disable jumping if airborne, allow if not airborne
        if state.egg.is-airborne:
          state
        else:
          #|Egg jumps with set jump height - dy, 
          enable gravity by setting acceleration - ay|#
          state.{ egg: state.egg.{ dy: EGG-JUMP-HEIGHT, ay: EGG-AY}}
        end

      | transitioning =>  
        state

      | game-over  =>  
        INITIAL-STATE #If space key pressed back to initial state
    end

  else:
    state 
  end


end


### TICKS ###
fun update-y-velocity(state :: State) -> State:
  doc:```dy: velocity increases as acceleration adds up```
  state.{ egg: state.egg.{dy: state.egg.dy + state.egg.ay }}
end

fun update-y-coordinate(state :: State) -> State:
  doc:```y: position of the egg changes, drops faster as velocity increases```
  state.{ egg: state.egg.{y: state.egg.y + state.egg.dy}} 
end


fun update-x-velocity(state :: State) -> State:
  doc:```updates velocity(dx) of egg to match velocity of current platform```

  current-plat = 
    if state.current-platform == bottom:
      state.bottom-platform
    else if state.current-platform == middle:
      state.middle-platform
    else:
      state.top-platform
    end

  #Implementation egg stops moving when it hits edge of screen

  #If egg hits left edge screen, no moving; 
  #  if platform reaches left edge screen allow moving
  if (state.egg.x - EGG-RADIUS) <= 0:
    if current-plat.x <= 0:
      state.{ egg: state.egg.{dx: current-plat.dx}} 
    else:
      state.{ egg: state.egg.{dx: 0}} 
    end

    #If egg hits right edge screen, no moving; 
    #  if platform reaches right edge screen allow moving
  else if (state.egg.x + EGG-RADIUS) >= SCREEN-WIDTH:
    if (current-plat.x + PLATFORM-WIDTH) >= SCREEN-WIDTH:
      state.{ egg: state.egg.{dx: current-plat.dx}} 
    else:
      state.{ egg: state.egg.{dx: 0}} 
    end

    #Conditionals to match velocity when egg lands  
  else if state.current-platform == bottom:
    state.{ egg: state.egg.{dx: state.bottom-platform.dx}} 

  else if state.current-platform == middle:
    state.{ egg: state.egg.{dx: state.middle-platform.dx}} 


  else if state.current-platform == top:
    state.{ egg: state.egg.{dx: state.top-platform.dx}} 


  else:
    state
  end


end

fun update-x-coordinate(state :: State) -> State:
  doc:```with current same velocity platform of the egg,
       update x coordinate of egg according to velocity of current platform```
  #detects egg when out of screen horizontally
  
  #If egg is not airborne/ jumping, move with current landed platform
  if not(state.egg.is-airborne):
    state.{ egg: state.egg.{x: state.egg.x + state.egg.dx}} 
  else:
    state
  end

end

fun update-airborne(state :: State) -> State:
  doc:```Updates state of egg is-airborne to true when egg is airborne```
  #If velocity is present, set egg state airborne to true
  if not(state.egg.dy == 0):
    state.{ egg: state.egg.{is-airborne: true}}
  else:
    state
  end
end

fun update-platform-dx(state :: State) -> State:
  doc:```Moves platforms with current velocities(dx)```
  state.{
    top-platform: state.top-platform.{x: state.top-platform.x + state.top-platform.dx},
    middle-platform: state.middle-platform.{x: state.middle-platform.x + state.middle-platform.dx},
    bottom-platform: state.bottom-platform.{x: state.bottom-platform.x + state.bottom-platform.dx}
  }
end

fun update-bottom-platform-bounds(state :: State) -> State:
  doc:```Reverses velocity to move platforms left and right on screen bounds```
  if (state.bottom-platform.x <= 0) or (state.bottom-platform.x >= SCREEN-WIDTH-PLATFORM-LIMIT):
    state.{bottom-platform: state.bottom-platform.{dx: state.bottom-platform.dx * -1}}
  else:
    state
  end
end 

fun update-middle-platform-bounds(state :: State) -> State:
  doc:```Reverses velocity to move platforms left and right on screen bounds```
  if (state.middle-platform.x <= 0) or (state.middle-platform.x >= SCREEN-WIDTH-PLATFORM-LIMIT):
    state.{middle-platform: state.middle-platform.{dx: state.middle-platform.dx * -1}}
  else:
    state
  end
end 

fun update-top-platform-bounds(state :: State) -> State:
  doc:```Reverses velocity to move platforms left and right on screen bounds```
  if (state.top-platform.x <= 0) or (state.top-platform.x >= SCREEN-WIDTH-PLATFORM-LIMIT):
    state.{top-platform: state.top-platform.{dx: state.top-platform.dx * -1}}
  else:
    state
  end
end 


fun update-collision-gamestatus-currentplatform-and-lives(state :: State) -> State:
  doc:```
      Collision:
      -Detects collision of egg and platform for landing

      Game Status:
      -Sets to game over if egg runs out of lives
      -Sets gamestatus to transitioning when egg reaches top platform
      
      Current Platform:
      -Updates current landed platform
      
      Lives:
      -Subtracts a life when egg goes out of canvas and place back at current platform```

  fun is-hitting-plat(platform :: Platform) -> Boolean:
    doc:```Collision detection for platform(rectangle) and egg```

    half-plat-width = PLATFORM-WIDTH / 2
    half-plat-height = PLATFORM-HEIGHT / 2

    circ-dist-y = num-abs(state.egg.y - (platform.y + half-plat-height))

    #|Modified collision to collide the center bottom point 
       of the egg to the width of the platform|#
    if (state.egg.x < platform.x) or (state.egg.x > (platform.x + PLATFORM-WIDTH)):
      false
    else if circ-dist-y > (half-plat-height + EGG-RADIUS):
      false
    else if (state.egg.x >= platform.x) and (state.egg.x <= (platform.x + PLATFORM-WIDTH)):
      true
    else if circ-dist-y <= half-plat-height:
      true
    else:
      false
    end

  end

  egg-top = state.egg.y - EGG-RADIUS

  is-egg-out-of-canvas = egg-top >= SCREEN-HEIGHT

  current-plat = 
    if state.current-platform == bottom:
      state.bottom-platform
    else if state.current-platform == middle:
      state.middle-platform
    else:
      state.top-platform
    end

  if is-egg-out-of-canvas: 

    if state.lives == 1: 
      #Set to game over if egg out of canvas a last life left
      state.{
        egg: state.egg.{
            x: current-plat.x + (PLATFORM-WIDTH / 2),
            y: current-plat.y - EGG-RADIUS, 
            dy: 0, ay: 0, is-airborne: false}, 
        lives: state.lives - 1,
        game-status: game-over}

    else:
      #|If egg went out of canvas:
         -place back at center platform
         -subtract one life
      |#
      cases (PlatformLevel) state.current-platform:
        | bottom => 
          state.{
            egg: state.egg.{
                x: state.bottom-platform.x + (PLATFORM-WIDTH / 2),
                y: state.bottom-platform.y - EGG-RADIUS, 
                dy: 0, ay: 0, is-airborne: false}, 
            lives: state.lives - 1}
        | middle => 
          state.{
            egg: state.egg.{
                x: state.middle-platform.x + (PLATFORM-WIDTH / 2),
                y: state.middle-platform.y - EGG-RADIUS, 
                dy: 0, ay: 0, is-airborne: false}, 
            lives: state.lives - 1}
        | top =>
          state #no state update since transitioning phase is set, jumping disallowed
      end
    end


  else: #Detect collision if egg is not out of canvas
    is-hitting-middle-plat  = is-hitting-plat(state.middle-platform)  
    is-hitting-top-plat  =  is-hitting-plat(state.top-platform)

    current-egg-velocity = state.egg.dy

    is-falling = current-egg-velocity >= 0

    #|For each current platform the egg is, 
     it will detect only the next platform to hit.
    For the egg to land on the platform:
       -the egg must be falling (velocity is zero/negative)
       -must detect if it hits the current platform|#

    #|If egg landed on platform:
    - egg.state.y set to current y of platform on bottom egg radius
    - egg won't have gravity, airborne status false
    - current platform will update
    - +1 score will be added|#

    cases (PlatformLevel) state.current-platform:
      | bottom => 
        if is-falling and is-hitting-middle-plat:
          state.{ egg: 
              state.egg.{ 
                y: state.middle-platform.y - EGG-RADIUS, 
                dy: 0, ay: 0, is-airborne: false},
            current-platform: middle, 
            score: state.score + 1}
        else:
          state
        end
      | middle => 
        if is-hitting-top-plat and is-falling:
          state.{ 
            game-status: transitioning,
            egg: 
              state.egg.{
                y: state.top-platform.y - EGG-RADIUS, 
                dy: 0, ay: 0, is-airborne: false}, 
            current-platform: top,  
            score: state.score + 1}
        else:
          state
        end
      | top =>
        state.{game-status: transitioning}
    end
  end
end

fun update-edge-egg(state :: State) -> State:
  
  if (state.egg.x + EGG-RADIUS) <= 0:
    state.{ egg: state.egg.{x: 0}} 

  else if (state.egg.x + EGG-RADIUS) >= SCREEN-WIDTH:
    state.{ egg: state.egg.{dx: 0}} 
  else:
    state
  end
end

fun add-new-platforms(state :: State) -> State:
  doc:```Adds new platforms if transition starts```

  fun generate-middle-and-top-plat() -> List<Platform>:
    doc:```Generates new top and middle platforms```

    middle-platform = {
      x: num-random(SCREEN-WIDTH-PLATFORM-LIMIT), 
      y: TOP-PLATFORM-Y - 150, 
      dx:
        block:
          VELOCITY-RANDOMIZER = num-random(PLATFORM-VELOCITY-LIMIT)
          if VELOCITY-RANDOMIZER == 0:
            1
          else:
            VELOCITY-RANDOMIZER
          end
        end
    }

    top-platform = {
      x: num-random(SCREEN-WIDTH-PLATFORM-LIMIT), 
      y: (TOP-PLATFORM-Y - 150) - 150, 
      dx:
        block:
          VELOCITY-RANDOMIZER = num-random(PLATFORM-VELOCITY-LIMIT)
          if VELOCITY-RANDOMIZER == 0:
            1
          else:
            VELOCITY-RANDOMIZER
          end
        end
    }

    [list: middle-platform, top-platform]
  end

  cases (GameStatus) state.game-status:
    | ongoing => 

      #|To fulfill peformance requirement:
      ensures off-screen platforms does not exist|#
      state.{other-platforms: [list: ]}

    | transitioning => 

      #Platforms are added at 'other-platforms' when transition starts
      new-platforms = generate-middle-and-top-plat()  
      state.{other-platforms: new-platforms}

    | game-over =>
      state
  end
end

fun scroll-down(state :: State) -> State:
  doc:```-Scrolls down to new level if GameStatus is transitioning
         -Assigns new platforms from other platform when transitioning ends```

  #All platforms starts scrolling down according to the set transition speed

  if state.top-platform.y >= BOT-PLATFORM-Y:
    #|Scrolling down will stop if current top platform 
       matches y coordinate of initial botom platform|#
    #Sets back game status to ongoing and assignes current platform to bottom 
    #Reassigns new platforms of middle and top from 'other-platforms'
    state.{
      game-status: ongoing,
      top-platform: state.other-platforms.get(1),
      middle-platform: state.other-platforms.get(0),
      bottom-platform: state.top-platform,
      current-platform: bottom}

  else:

    #Egg, top, mid, and bot platforms pans down by adding y coordinate states
    state.{
      egg: state.egg.{y: state.egg.y + SCREEN-TRANSITION-SPEED},

      top-platform: 
        state.top-platform.{y: state.top-platform.y + SCREEN-TRANSITION-SPEED},

      middle-platform: 
        state.middle-platform.{y: state.middle-platform.y + SCREEN-TRANSITION-SPEED},

      bottom-platform: 
        state.bottom-platform.{y: state.bottom-platform.y + SCREEN-TRANSITION-SPEED},

      #Other platforms are drawn, maps y coordinates each platforms in list to go down too
      other-platforms: state.other-platforms.map(lam(plat): plat.{y: plat.y + SCREEN-TRANSITION-SPEED} end)}
  end


end


fun tick-handler(state :: State) -> State:
  doc:```State changes according to seconds-per-tick```

  cases (GameStatus) state.game-status:
    | ongoing  =>
      state
        ^ update-y-velocity(_)   #state.egg.dy changes
        ^ update-y-coordinate(_) #state.egg.y changes
        ^ update-x-velocity(_)   #state.egg.dx changes
        ^ update-x-coordinate(_) #state.egg.x changes
        ^ update-airborne(_)     #detects if egg is airborne
        ^ update-platform-dx(_)            #move platform
        ^ update-bottom-platform-bounds(_) #move opposite direction platform
        ^ update-middle-platform-bounds(_) #move opposite direction platform
        ^ update-top-platform-bounds(_)    #move opposite direction platform
        ^ update-collision-gamestatus-currentplatform-and-lives(_)  
        ^ update-edge-egg(_)
        ^ add-new-platforms(_)             #adds new platforms

    | transitioning =>
      state
        ^ scroll-down(_) #screen pans upward

    | game-over =>
      state
  end
end




### MAIN ###

world = reactor:
  title:'Egg Toss',
  init: INITIAL-STATE,
  to-draw: draw-handler,
  seconds-per-tick: 1 / FPS, 
  on-tick: tick-handler,
  on-key: key-handler,  
end

R.interact(world)