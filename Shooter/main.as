OrthoCameraNode@  orthoCamera = NodeManager::CreateOrthoCamera();
FogNode@ fog = NodeManager::CreateFog();
LightingNode@ lighting = NodeManager::CreateLighting();

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

//************************************************************************************************ 
// Table For Player
//************************************************************************************************

Vec2F PlayerPos = Vec2F();
float PlayerSpeed = 400;
uint64 PlayerLastBulletFiredTime = 0;

//************************************************************************************************ 
// Table For Boss
//************************************************************************************************

Vec2F BossEnemyPos = Vec2F();
float BossEnemySpeed = 200;
uint64 BossEnemyLastBulletFiredTime = 0;


//************************************************************************************************ 
// Main Function: Initialise all main assets
//************************************************************************************************
void Init()
{
    FontManager::LoadFont("skin:asset\\fonts\\freesans.sfn");

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

    fog.SetFog(FogOperationDisabled);
    fog.SetFogColor(Color3F(0, 0.6, 0));
    fog.SetFogStart(-1024);
    fog.SetFogEnd(1024);
    fog.SetFogDensity(0.001);
    NodeManager::AssignNode(fog, orthoCamera.GetID());
    
    lighting.SetLights(LightsOperationDisabled);
    lighting.SetAmbientLight(Color3F(0, 0, 0));
    lighting.SetLight1(LightOperationDisabled);
    lighting.SetLight1Position(Vec3F(0, 0, 0));
    lighting.SetLight1Distance(0);
    lighting.SetLight1Diffuse(Color4F(0, 0, 0, 0));
    NodeManager::AssignNode(lighting, fog.GetID());

    SpriteNode@ sprite1 = NodeManager::CreateSprite();
    sprite1.SetTexturePath("asset:images\\backgrounds\\bg.png");
    sprite1.SetUV(RectF(0, 0, 1, 1));
    sprite1.SetSize(SizeF(640, 480));
    NodeManager::AssignNode(sprite1, lighting.GetID());
    
    PlayerImg.SetTexturePath("asset:images\\game\\plane.png");
    PlayerImg.SetUV(RectF(0, 0, 1, 1));
    PlayerImg.SetAnchor(Vec3F(64, 64, 0));
    PlayerImg.SetSize(SizeF(playerWidth, playerHeight));
	PlayerImg.SetDepth(DepthOperationDisabled);
	//PlayerImg.SetVisible(false);
    NodeManager::AssignNode(PlayerImg, lighting.GetID());
	
	BulletImg.SetTexturePath("asset:images\\game\\playerbullet.png");
    BulletImg.SetUV(RectF(0, 0, 1, 1));
    BulletImg.SetAnchor(Vec3F(0, 0, 0));
    BulletImg.SetPosition(Vec3F(74, 74, 0));
    BulletImg.SetSize(SizeF(bulletWidth, bulletHeight));
	BulletImg.SetDepth(DepthOperationDisabled);
	BulletImg.SetVisible(false);
    NodeManager::AssignNode(BulletImg, lighting.GetID());
	
	EnemyBulletImg.SetTexturePath("asset:images\\game\\enemybullet.png");
    EnemyBulletImg.SetUV(RectF(0, 0, 1, 1));
    EnemyBulletImg.SetAnchor(Vec3F(64, 64, 0));
    EnemyBulletImg.SetPosition(Vec3F(74, 96, 0));
    EnemyBulletImg.SetSize(SizeF(bulletWidth, bulletHeight));
	EnemyBulletImg.SetDepth(DepthOperationDisabled);
	EnemyBulletImg.SetVisible(false);
    NodeManager::AssignNode(EnemyBulletImg, lighting.GetID());
	
	EnemyImg.SetTexturePath("asset:images\\game\\enemy.png");
    EnemyImg.SetUV(RectF(0, 0, 1, 1));
    EnemyImg.SetAnchor(Vec3F(64, 64, 0));
    EnemyImg.SetPosition(Vec3F(200, 106, 0));
    EnemyImg.SetSize(SizeF(enemyWidth, enemyHeight));
	EnemyImg.SetDepth(DepthOperationDisabled);
	EnemyImg.SetVisible(false);
    NodeManager::AssignNode(EnemyImg, lighting.GetID());
	
	BossImg.SetTexturePath("asset:images\\game\\boss.png");
    BossImg.SetUV(RectF(0, 0, 1, 1));
    BossImg.SetAnchor(Vec3F(64, 64, 0));
    BossImg.SetSize(SizeF(bossWidth, bossWidth));
    BossImg.SetDepth(DepthOperationDisabled);
	BossImg.SetVisible(false);
    NodeManager::AssignNode(BossImg, lighting.GetID());
	


    textFPS.SetFontName("FreeSans");
    textFPS.SetFontStyle(0);
    textFPS.SetFontSize(20);
    //TODO: SetFontStyle(FontStyleBold | FontStyleItalic | FontStyleUnderline);
    textFPS.SetPosition(Vec3F(5, 455, 20));
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

//--------------------------------------------------------------------------------------------------		
	
    // initialize default for fps
    previousTime = GetMillisecondsNow();
	
	PlayerPos.x = windowSize.width / 2 - playerWidth /2;
	PlayerPos.y = windowSize.height - playerHeight;
    PlayerImg.SetPosition(Vec3F(PlayerPos.x, PlayerPos.y, 0));
}

void Render(double dt)
{

//************************************************************************************************ 
// Fps & Mem
//************************************************************************************************ 
    currentTime = GetMillisecondsNow();
    double durationFPS = GetDurationSeconds(previousTime, currentTime);

    if (durationFPS > 0.1)
    {
        double fps = CalculateFramesPerSecond(frameCount, durationFPS);
        textFPS.SetText("fps = " + fps);
        //DebugPrint(LogLevelInfo, "fps = " + fps);
        frameCount = 0;
        previousTime = currentTime;
    }
    
    //textMem.SetText("free mem = " + (GetFreePhysicalMemory() / (1024 * 1024)) + "MB");

//-------------------------------------------------------------------------------------------------- 





//************************************************************************************************ 
// Controller Settings For Airplane Movement + Firing Bullets
//************************************************************************************************ 

JoystickAxisStates joystickAxisStates = GetJoystickAxisStates(0);
JoystickButtonStates joystickButtonStates = GetJoystickButtonStates(0);

if (joystickButtonStates.buttonDpadLeft == JoystickButtonStatePressed || joystickAxisStates.axisLeftX < -0.2) {
    // Move left
    if (PlayerPos.x > 0) {
        PlayerPos.x = float(PlayerPos.x - (PlayerSpeed * dt));
        PlayerImg.SetPosition(Vec3F(PlayerPos.x, PlayerPos.y, 0));
    }
    else {
        PlayerPos.x = 0;
    }
}
if (joystickButtonStates.buttonDpadRight == JoystickButtonStatePressed || joystickAxisStates.axisLeftX > 0.2) {
    // Move right
    if (PlayerPos.x < windowSize.width - bossWidth) {
        PlayerPos.x = float(PlayerPos.x + (PlayerSpeed * dt));
        PlayerImg.SetPosition(Vec3F(PlayerPos.x, PlayerPos.y, 0));
    }
    else {
        PlayerPos.x = windowSize.width - bossWidth;
    }
}
if (joystickButtonStates.buttonDpadUp == JoystickButtonStatePressed || joystickAxisStates.axisLeftY < -0.2) {
    // Move up
    if ( PlayerPos.y < windowSize.height - bossHeight) {
        PlayerPos.y = float(PlayerPos.y + (PlayerSpeed * dt));
        PlayerImg.SetPosition(Vec3F(PlayerPos.x, PlayerPos.y, 0));
    }
    else {
        PlayerPos.y = windowSize.height - bossHeight;
    }
}
if (joystickButtonStates.buttonDpadDown == JoystickButtonStatePressed || joystickAxisStates.axisLeftY > 0.2) {
    // Move down
    if (PlayerPos.y > 0) {
        PlayerPos.y = float(PlayerPos.y - (PlayerSpeed * dt));
        PlayerImg.SetPosition(Vec3F(PlayerPos.x, PlayerPos.y, 0));
    }
    else {
        PlayerPos.y = 0;
    }
}
if (joystickButtonStates.buttonA == JoystickButtonStatePressed || joystickAxisStates.axisRightTrigger > 0.1)
{
	currentTime = GetMillisecondsNow();
    double durationPlayerBulletLastFiredToNow = GetDurationSeconds(PlayerLastBulletFiredTime, currentTime);
	if (durationPlayerBulletLastFiredToNow > 0.5)
	{	
		FirePlayerBullet();
		PlayerLastBulletFiredTime = currentTime;
	}
	
}

//-------------------------------------------------------------------------------------------------- 


    frameCount++;
}

//************************************************************************************************ 
// Define Bullet Lists
//************************************************************************************************ 



//************************************************************************************************ 
// Create a Bullet for Player and Play Sound
//************************************************************************************************ 
void FirePlayerBullet()
{	
	SpriteNode@ BulletImg2 = NodeManager::CreateSprite();
	
	BulletImg2.SetTexturePath("asset:images\\game\\playerbullet.png");
	BulletImg2.SetUV(RectF(0, 0, 1, 1));
	BulletImg2.SetAnchor(Vec3F(0, 0, 0));
	BulletImg2.SetPosition(Vec3F(PlayerPos.x + 50, PlayerPos.y - 20, 0));
	BulletImg2.SetSize(SizeF(bulletWidth, bulletHeight));
	BulletImg2.SetDepth(DepthOperationDisabled);
	//BulletImg2.SetVisible(true);
	
	NodeManager::AssignNode(BulletImg2, lighting.GetID());
	
	//Vec3F bulletPosition = BulletImg2.GetPosition();
	//currentTime = GetMillisecondsNow();
	//uint64 LastUpdatedBulletTime = 0;
    //double SecondsSinceBulletUpdated = GetDurationSeconds(LastUpdatedBulletTime, currentTime);
	if (SecondsSinceBulletUpdated > 1)
	{
		//if(BulletImg2.GetPosition().y > 2)
		{
			//BulletImg2.SetPosition(Vec3F(bulletPosition.x, bulletPosition.y - 2, 0));
		}
		//else
		{
			//NodeManager::DeleteNode(nodeID);
		}
	}

}

