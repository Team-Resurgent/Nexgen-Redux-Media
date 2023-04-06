OrthoCameraNode@  orthoCamera = NodeManager::CreateOrthoCamera();
TextNode@ textFPS = NodeManager::CreateText();
TextNode@ textMem = NodeManager::CreateText();

SpriteNode@ PlayerImg = NodeManager::CreateSprite();
SpriteNode@ BulletImg = NodeManager::CreateSprite();
SpriteNode@ EnemyBulletImg = NodeManager::CreateSprite();
SpriteNode@ EnemyImg = NodeManager::CreateSprite();
SpriteNode@ BossImg = NodeManager::CreateSprite();



void OnWindowIconify(uint iconified)
{
    DebugPrint(LogLevelInfo, "OnWindowIconify iconified = " + iconified);
}

void OnWindowMaximize(uint maximized)
{
    DebugPrint(LogLevelInfo, "OnWindowMaximize maximized = " + maximized);
}

void OnWindowSize(uint width, uint height)
{
    DebugPrint(LogLevelInfo, "OnWindowSize width = " + width + ", height = " + height);
}

void OnWindowFocus(uint focused)
{
    DebugPrint(LogLevelInfo, "OnWindowFocus focused = " + focused);
}

void OnWindowKeyboardKey(uint key, uint scancode, uint action, uint modifier)
{
    DebugPrint(LogLevelInfo, "OnWindowKeyboardKey key = " + key + ", scancode = " + scancode + ", action = " + action + ", modifier = " + modifier);
}

void OnWindowKeyboardCharacter(uint codepoint)
{
    DebugPrint(LogLevelInfo, "OnWindowKeyboardCharacter codepoint = " + codepoint);
}

void OnWindowMouseCursorPosition(double xPos, double yPos)
{
    // commented out to reduce noisey logging
    //DebugPrint(LogLevelInfo, "OnWindowMouseCursorPosition xPos = " + xPos + ", yPos = " + yPos);
}

void OnWindowMouseCursorEnter(uint entered)
{
    //DebugPrint(LogLevelInfo, "OnWindowMouseCursorEnter entered = " + entered);
}

void OnWindowMouseButton(uint button, uint action, uint modifier)
{
    DebugPrint(LogLevelInfo, "OnWindowMouseButton button = " + button + ", action = " + action + ", modifier = " + modifier);
}

void OnWindowMouseScroll(double xOffset, double yOffset)
{
    DebugPrint(LogLevelInfo, "OnWindowMouseScroll xOffset = " + xOffset + ", yOffset = " + yOffset);
}

void OnWindowDrop(array<string> paths)
{
    for (uint i = 0; i < paths.length(); i++)
    {
        DebugPrint(LogLevelInfo, "OnWindowDrop paths" + i + " = " + paths[i]);
    }
}

void OnJoystickConnect(uint joystickID, uint connected)
{
    DebugPrint(LogLevelInfo, "OnJoystickConnect joystickID = " + joystickID + ", connected = " + connected);
}

uint64 currentTime;
uint64 previousTime;
uint frameCount;
float spriteRotate = 0;

//************************************************************************************************ 
// -- Image Width & Height
// --************************************************************************************************ 

int playerWidth = 110;
int playerHeight = 86;

int bossWidth = 94;
int bossHeight = 76;

int enemyWidth = 110;
int enemyHeight = 86;

int bulletWidth = 10;
int bulletHeight = 26;

// --------------------------------------------------------------------------------------------------

// Declare a global variable windowSize
SizeI windowSize;

// Define a function to initialize the windowSize variable
void InitWindowSize()
{
    // Call the GetWindowSize() function and assign the result to the windowSize variable
    windowSize = GetWindowSize();
}

dictionary Player;

void Init()
{

    

    FontManager::LoadFont("skin:assets\\fonts\\freesans.sfn");

    uint sceneID = SceneManager::CreateScene(true);
    SceneManager::SetCurrentScene(sceneID);

    orthoCamera.SetClearColor(Color4F(0, 0, 0, 1));
    orthoCamera.SetEye(Vec3F(0, 0, 50));
    orthoCamera.SetTarget(Vec3F(0, 0, 0));
    orthoCamera.SetUp(Vec3F(0, 1, 0));
    orthoCamera.SetLeft(0);
    orthoCamera.SetRight(640);
    orthoCamera.SetBottom(0);
    orthoCamera.SetTop(480);
    orthoCamera.SetZNear(-1024);
    orthoCamera.SetZFar(1024);

    SceneManager::AssignNode(orthoCamera, sceneID);

    FogNode@ fog = NodeManager::CreateFog();
    fog.SetFog(FogOperationDisabled);
    fog.SetFogColor(Color3F(0, 0.6, 0));
    fog.SetFogStart(-1024);
    fog.SetFogEnd(1024);
    fog.SetFogDensity(0.001);
    NodeManager::AssignNode(fog, orthoCamera.GetID());
    
    LightingNode@ lighting = NodeManager::CreateLighting();
    lighting.SetLights(LightsOperationDisabled);
    lighting.SetAmbientLight(Color3F(0, 0, 0));
    lighting.SetLight1(LightOperationDisabled);
    lighting.SetLight1Position(Vec3F(0, 0, 0));
    lighting.SetLight1Distance(0);
    lighting.SetLight1Diffuse(Color4F(0, 0, 0, 0));
    NodeManager::AssignNode(lighting, fog.GetID());

    SpriteNode@ sprite1 = NodeManager::CreateSprite();
    sprite1.SetTexturePath("skin:assets\\images\\backgrounds\\bg.png");
    sprite1.SetUV(RectF(0, 0, 1, 1));
    sprite1.SetSize(SizeF(640, 480));
    NodeManager::AssignNode(sprite1, lighting.GetID());
    
    PlayerImg.SetTexturePath("skin:\\assets\\images\\game\\plane.png");
    PlayerImg.SetUV(RectF(0, 0, 1, 1));
    PlayerImg.SetAnchor(Vec3F(64, 64, 0));
    PlayerImg.SetSize(SizeF(playerWidth, playerHeight));
	PlayerImg.SetDepth(DepthOperationDisabled);
	//PlayerImg.SetVisible(false);
    NodeManager::AssignNode(PlayerImg, lighting.GetID());
	
	BulletImg.SetTexturePath("skin:\\assets\\images\\game\\playerbullet.png");
    BulletImg.SetUV(RectF(0, 0, 1, 1));
    BulletImg.SetAnchor(Vec3F(0, 0, 0));
    BulletImg.SetPosition(Vec3F(74, 74, 0));
    BulletImg.SetSize(SizeF(bulletWidth, bulletHeight));
	BulletImg.SetDepth(DepthOperationDisabled);
		BulletImg.SetVisible(false);
    NodeManager::AssignNode(BulletImg, lighting.GetID());
	
	EnemyBulletImg.SetTexturePath("skin:\\assets\\images\\game\\enemybullet.png");
    EnemyBulletImg.SetUV(RectF(0, 0, 1, 1));
    EnemyBulletImg.SetAnchor(Vec3F(64, 64, 0));
    EnemyBulletImg.SetPosition(Vec3F(74, 96, 0));
    EnemyBulletImg.SetSize(SizeF(bulletWidth, bulletHeight));
	EnemyBulletImg.SetDepth(DepthOperationDisabled);
		EnemyBulletImg.SetVisible(false);
    NodeManager::AssignNode(EnemyBulletImg, lighting.GetID());
	
	EnemyImg.SetTexturePath("skin:\\assets\\images\\game\\enemy.png");
    EnemyImg.SetUV(RectF(0, 0, 1, 1));
    EnemyImg.SetAnchor(Vec3F(64, 64, 0));
    EnemyImg.SetPosition(Vec3F(200, 106, 0));
    EnemyImg.SetSize(SizeF(enemyWidth, enemyHeight));
	EnemyImg.SetDepth(DepthOperationDisabled);
		EnemyImg.SetVisible(false);
    NodeManager::AssignNode(EnemyImg, lighting.GetID());
	
	BossImg.SetTexturePath("skin:\\assets\\images\\game\\boss.png");
    BossImg.SetUV(RectF(0, 0, 1, 1));
    BossImg.SetAnchor(Vec3F(64, 64, 0));
    BossImg.SetSize(SizeF(bossWidth, bossWidth));
    BossImg.SetDepth(DepthOperationDisabled);
	BossImg.SetVisible(false);
    NodeManager::AssignNode(BossImg, lighting.GetID());
	


    textFPS.SetFontName("FreeSans");
    textFPS.SetFontStyle(0);
    textFPS.SetFontSize(60);
    //TODO: SetFontStyle(FontStyleBold | FontStyleItalic | FontStyleUnderline);
    textFPS.SetPosition(Vec3F(75, 360, 20));
    NodeManager::AssignNode(textFPS, lighting.GetID());
    
    textMem.SetFontName("FreeSans");
    textMem.SetFontStyle(0);
    textMem.SetFontSize(30);
    //TODO: SetFontStyle(FontStyleBold | FontStyleItalic | FontStyleUnderline);
    textMem.SetPosition(Vec3F(75, 300, 30));
    NodeManager::AssignNode(textMem, lighting.GetID());
    

    DebugPrint(LogLevelInfo, "Initializing...");

    // Create window example
    WindowCreateWithSize(640, 480, "Nexgen Redux Demo");


    SetWindowIconifyCallback(OnWindowIconify);
    SetWindowMaximizeCallback(OnWindowMaximize);
    SetWindowSizeCallback(OnWindowSize);
    SetWindowFocusCallback(OnWindowFocus);
    SetWindowKeyboardKeyCallback(OnWindowKeyboardKey);
    SetWindowKeyboardCharacterCallback(OnWindowKeyboardCharacter);
    SetWindowMouseCursorPositionCallback(OnWindowMouseCursorPosition);
    SetWindowMouseCursorEnterCallback(OnWindowMouseCursorEnter);
    SetWindowMouseButtonCallback(OnWindowMouseButton);
    SetWindowMouseScrollCallback(OnWindowMouseScroll);
    SetWindowDropCallback(OnWindowDrop);
	
	InitWindowSize();


//************************************************************************************************ 
// Table For Player
//***************************************************************************
    Player = {
        {"x", windowSize.width / 2},
        {"y", windowSize.height - playerHeight},
        {"speed", 400}
    };

//--------------------------------------------------------------------------------------------------		
	
    // initialize default for fps
    previousTime = GetMillisecondsNow();
	
        PlayerImg.SetPosition(Vec3F(float(Player["x"])-playerWidth/2, float(Player["y"]), 0));
		Player["x"] = (float(Player["x"])-playerWidth/2);

}

void Render(double dt)
{


//************************************************************************************************ 
// Fps & Mem
//************************************************************************************************ 
    currentTime = GetMillisecondsNow();
    double durationFPS = GetDurationSeconds(previousTime, currentTime);

    if (durationFPS > 2.0)
    {
        double fps = CalculateFramesPerSecond(frameCount, durationFPS);
        //textFPS.SetText("fps = " + fps);
        DebugPrint(LogLevelInfo, "fps = " + fps);
        frameCount = 0;
        previousTime = currentTime;
    }
    
    //textMem.SetText("free mem = " + (GetFreePhysicalMemory() / (1024 * 1024)) + "MB");

//-------------------------------------------------------------------------------------------------- 





//************************************************************************************************ 
// Controller Settings For Airplane Movement
//************************************************************************************************ 

    JoystickButtonStates joystickButtonStates = GetJoystickButtonStates(0);

if (joystickButtonStates.buttonDpadLeft == JoystickButtonStatePressed) {
    // Move left
    float xPosition = float(Player["x"]);
    if (xPosition > 0) {
        float newXPosition = float(xPosition - (float(Player["speed"]) * dt));
        Player["x"] = newXPosition;
        PlayerImg.SetPosition(Vec3F(newXPosition, float(Player["y"]), 0));
    }
    else {
        Player["x"] = 0;
    }
}
if (joystickButtonStates.buttonDpadRight == JoystickButtonStatePressed) {
    // Move right
    float xPosition = float(Player["x"]);
    if (xPosition < windowSize.width - bossWidth) {
        float newXPosition = float(xPosition + (float(Player["speed"]) * dt));
        Player["x"] = newXPosition;
        PlayerImg.SetPosition(Vec3F(newXPosition, float(Player["y"]), 0));
    }
    else {
        Player["x"] = windowSize.width - bossWidth;
    }
}
if (joystickButtonStates.buttonDpadUp == JoystickButtonStatePressed) {
    // Move up
    float yPosition = float(Player["y"]);
    if (yPosition < windowSize.height - bossHeight) {
        float newYPosition = float(yPosition + (float(Player["speed"]) * dt));
        Player["y"] = newYPosition;
        PlayerImg.SetPosition(Vec3F(float(Player["x"]), newYPosition, 0));
    }
    else {
        Player["y"] = windowSize.height - bossHeight;
    }
}
if (joystickButtonStates.buttonDpadDown == JoystickButtonStatePressed) {
    // Move down
    float yPosition = float(Player["y"]);
    if (yPosition > 0) {
        float newYPosition = float(yPosition - (float(Player["speed"]) * dt));
        Player["y"] = newYPosition;
        PlayerImg.SetPosition(Vec3F(float(Player["x"]), newYPosition, 0));
    }
    else {
        Player["y"] = 0;
    }
}

//-------------------------------------------------------------------------------------------------- 


    frameCount++;
}
