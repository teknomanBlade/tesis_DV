using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class GameVars : MonoBehaviour
{
    private static GameVars _gameVars;
    public static GameVars Values { get { return _gameVars; } }

    public bool HasSmallContainer;
    public bool HasLargeContainer;
    public int enemyCount = 0;
    
    public SoundManager soundManager { get; private set; }
    public CraftingScreen craftingContainer { get; private set; }
    public LevelManager LevelManager { get; set; }
    public WaveManager WaveManager { get; set; }
    public CatDistanceBar CatDistanceBar;
    [SerializeField] private Player player;
    public Player Player 
    {
        get { return player; }
    }

    [SerializeField] private Cat cat;
    public Cat Cat
    {
        get { return cat; }
    }

    [SerializeField] private Inventory inventory;
    public Inventory Inventory
    {
        get { return inventory; }
    }
    [SerializeField] private TrapHotBar TrapHotBar;
    [SerializeField] private bool _isCatCaptured;
    public bool IsCatCaptured { get { return _isCatCaptured; } }

    [SerializeField] private string objectLayerName;
    [SerializeField] private string floorLayerName;
    [SerializeField] private string enemyLayerName;
    [SerializeField] private string wallLayerName;

    [Header("KeyBinds")]
    public KeyCode jumpKey;
    public KeyCode primaryFire;
    public KeyCode secondaryFire;
    public KeyCode useKey;
    public KeyCode hideShowMiniMapKey;
    public KeyCode dropKey;
    public KeyCode inventoryKey;
    public KeyCode inventoryItem1Key;
    public KeyCode sprintKey;
    public KeyCode crouchKey;
    public KeyCode startWaveKey;
    public KeyCode firstTrapHotKey;
    public KeyCode secondTrapHotKey;
    public KeyCode thirdTrapHotKey;
    public KeyCode fourthTrapHotKey;
    public KeyCode fifthTrapHotKey;
    public KeyCode sixthTrapHotKey;
    public KeyCode pauseKey;
    public KeyCode switchWeaponKey;
    public bool crouchToggle;

    [Header("KeyDebugBinds")]
    public KeyCode testRecieveWittsKey;
    public KeyCode testOpenAllDoorsKey;
    public KeyCode testKillingEnemiesKey;
    public KeyCode testBuySixthTrap;
    public KeyCode testBuyFifthTrap;
    public KeyCode testBuyFourthTrap;
    public KeyCode testBuyThirdTrap;

    [Header("Resources")]
    public Sprite crosshair;
    public Sprite crosshairDoor;
    public Sprite crosshairActivation;
    public Sprite crosshairReloadTrap1;
    public Sprite crosshairHandGrab;
    public Sprite crosshairHandHold;
    public Sprite crosshairAddOnBattery;
    public Sprite crosshairWorkbenchCrafting;
    public Sprite crosshairLockDoor;
    public Sprite crosshairMovingTrap;
    public Sprite crosshairMovingObject;
    public Sprite crosshairRightClickIcon;
    public Sprite imageBaseballTrap;
    public Sprite switchTennisBallContainer;
    public Sprite reloadingMinigunIcon;
    public CraftingScreen craftingScreen;

    public RectTransform notifications;
    public Image[] playerLives;

    public Animator playerLivesAnim { get; private set; }

    public List<AudioClip> audioClips;
    public GameObject backpack;
    public Image itemGrabbedImage;
    [Header("Crafting Recipes")]
    public CraftingRecipe BaseballLauncher;
    public CraftingRecipe MicrowaveForceFieldGenerator;
    public CraftingRecipe SlowTrap;
    public CraftingRecipe FERNPaintballMinigun;
    public CraftingRecipe ElectricTrap;
    public CraftingRecipe TeslaCoilGenerator;
    public bool HasBoughtMicrowaveTrap { get; set; }
    public bool HasBoughtSlowingTrap { get; set; }
    public bool HasBoughtPaintballMinigunTrap { get; set; }
    public bool HasBoughtTeslaCoilGenerator { get; set; }
    public bool HasBoughtElectricTrap { get; set; }
    public bool HasElectricTrapAppearedHotBar { get; set; }
    public bool HasMicrowaveTrapAppearedHotBar { get; set; }
    public bool HasSlowingTrapAppearedHotBar { get; set; }
    public bool HasPaintballMinigunTrapAppearedHotBar { get; set; }
    public bool HasTeslaCoilGeneratorAppearedHotBar { get; set; }


    [Header("Game")]
    private float _fadeDelay = 1.1f;
    private bool _isFaded;
    public bool IsUFOExitPlanetAnimFinished;
    public bool IsCatBasementStateFinished;
    public bool HasMagicboard { get; set; }
    public bool HasOpenedLetter { get; set; }
    public bool HasOpenedTrunk { get; set; }
    
    public float projectileLifeTime = 5f;
    public float itemPickUpLerpSpeed = 0.2f;
    public List<List<Node>> levelRoutes;
    public int BaseballLauncherCount = 0;
    public int FERNPaintballMinigunCount = 0;
    public int TeslaCoilGeneratorCount = 0;
    public int TeslaElectricTrapCount = 0;
    public int MicrowaveForceFieldGeneratorCount = 0;
    [Header("Pool Operations")]
    public ParticleSystem SmokePrefab;
    public BaseballLauncher BaseballLauncherPrefab;
    public FERNPaintballMinigun FERNPaintballMinigunPrefab;
    public TeslaCoilGenerator TeslaCoilGeneratorPrefab;
    public ElectricTrap TeslaElectricTrapPrefab;
    public MicrowaveForceFieldGenerator MicrowaveForceFieldGeneratorPrefab;
    public int InitialStock { get; private set; }
    public PoolObjectStack<BaseballLauncher> BaseballLauncherPool { get; set; }
    public PoolObjectStack<FERNPaintballMinigun> FERNPaintballMinigunPool { get; set; }
    public PoolObjectStack<TeslaCoilGenerator> TeslaCoilGeneratorPool { get; set; }
    public PoolObjectStack<ElectricTrap> TeslaElectricTrapPool { get; set; }
    public PoolObjectStack<MicrowaveForceFieldGenerator> MicrowaveForceFieldGeneratorPool { get; set; }
    public PoolObjectStack<ParticleSystem> SmokeParticlesPool { get; set; }
    [Header("Tutorial Operations")]
    public bool PassedTutorial;
    public bool IsTutorial;
    [Header("ArrowUI Operations")]
    public Vector3 positionObjectNotification;
    public Vector3 smokeParticlesPos;
    #region Events
    public delegate void OnCapturedCatChangeDelegate(bool isCaptured);
    public event OnCapturedCatChangeDelegate OnCapturedCatChange;
    public delegate void OnCapturedCatPositionDelegate(Vector3 catPos);
    public event OnCapturedCatPositionDelegate OnCapturedCatPosition;
    public delegate void OnObjectNotificationPositionDelegate(Vector3 objectNotificationPos);
    public event OnObjectNotificationPositionDelegate OnObjectNotificationPosition;
    #endregion

    private void Awake()
    {
        if (_gameVars == null) _gameVars = this;
        else Destroy(this);
        
        SetKeys();
        LoadResources();
        PassedTutorial = false;
        IsTutorial = false;
        IsUFOExitPlanetAnimFinished = false;
        SceneManager.sceneLoaded += FindPlayer;
        SceneManager.sceneLoaded += FindCat;
    }
    
    private void SetKeys()
    {
        jumpKey = KeyCode.Space;
        primaryFire = KeyCode.Mouse0;
        secondaryFire = KeyCode.Mouse1;
        inventoryKey = KeyCode.Tab;
        useKey = KeyCode.E;
        sprintKey = KeyCode.LeftShift;
        crouchKey = KeyCode.LeftControl;
        crouchToggle = false;
    }

    void FindPlayer(Scene scene, LoadSceneMode mode)
    {
        var aux = GameObject.Find("Player");
        if (aux == null) return;
        player = aux.GetComponent<Player>();

    }

    void FindCat(Scene scene, LoadSceneMode mode)
    {
        //var aux = GameObject.Find("cat");
        var aux = FindObjectOfType<Cat>();
        if (aux != null) cat = aux.GetComponent<Cat>();
        else cat = null;
        /*if (scene.buildIndex == 1) 
        {
            OnCatReleased += cat.CatHasBeenReleased;
            OnCatTaken += cat.CatIsBeingTaken;
        }*/
    }

    private void LoadResources()
    {
        crosshair = Resources.Load<Sprite>("crosshair");
        crosshairDoor = Resources.Load<Sprite>("OpenDoor");
        crosshairHandGrab = Resources.Load<Sprite>("HandGrab");
        crosshairHandHold = Resources.Load<Sprite>("HandHold");
        crosshairAddOnBattery = Resources.Load<Sprite>("BatteryAddOnTVIcon");
        crosshairActivation = Resources.Load<Sprite>("ButtonPress");
        crosshairReloadTrap1 = Resources.Load<Sprite>("ReloadTrap1");
        imageBaseballTrap = Resources.Load<Sprite>("SpriteBaseballLauncher");
        crosshairLockDoor = Resources.Load<Sprite>("LockDoorIcon");
        crosshairMovingTrap = Resources.Load<Sprite>("MovingTrapIcon");
        crosshairMovingObject = Resources.Load<Sprite>("MoveObject");
        crosshairRightClickIcon = Resources.Load<Sprite>("RightClickMouseIcon");
        crosshairWorkbenchCrafting = Resources.Load<Sprite>("WorkbenchCraftIcon");
        switchTennisBallContainer = Resources.Load<Sprite>("SwitchTennisBallsContainer");
        reloadingMinigunIcon = Resources.Load<Sprite>("ReloadingMinigunIcon");
        craftingScreen = Resources.Load<CraftingScreen>("CraftingCanvas");
        audioClips = Resources.LoadAll<AudioClip>("Sounds").ToList();
        TrapHotBar = FindObjectOfType<TrapHotBar>();
        backpack = FindObjectsOfType<GameObject>().Where(x => x.name.Equals("Backpack")).First();
        itemGrabbedImage = FindObjectsOfType<Image>(true).Where(x => x.name.Equals("ItemGrabbed")).First();
        notifications = FindObjectsOfType<RectTransform>(true).Where(x => x.gameObject.name.Equals("NotificationsBkg")).First();
        playerLives = FindObjectsOfType<Image>().Where(x => x.gameObject.name.Contains("Life")).OrderBy(x => x.name).ToArray();
        soundManager = FindObjectOfType<SoundManager>();
        craftingContainer = FindObjectOfType<CraftingScreen>();
        soundManager.SetAudioClips(audioClips);
        LevelManager = GetComponent<LevelManager>();
        WaveManager = GetComponent<WaveManager>();
        InitialStock = 5;
        BaseballLauncherPool = new PoolObjectStack<BaseballLauncher>(BaseballLauncherFactory, ActivateBaseballLauncher, DeactivateBaseballLauncher, InitialStock, true);
        FERNPaintballMinigunPool = new PoolObjectStack<FERNPaintballMinigun>(FERNPaintballMinigunFactory, ActivateFERNPaintballMinigun, DeactivateFERNPaintballMinigun, InitialStock, true);
        TeslaCoilGeneratorPool = new PoolObjectStack<TeslaCoilGenerator>(TeslaCoilGeneratorFactory, ActivateTeslaCoilGenerator, DeactivateTeslaCoilGenerator, InitialStock, true);
        TeslaElectricTrapPool = new PoolObjectStack<ElectricTrap>(TeslaElectricTrapFactory, ActivateTeslaElectricTrap, DeactivateTeslaElectricTrap, InitialStock, true);
        MicrowaveForceFieldGeneratorPool = new PoolObjectStack<MicrowaveForceFieldGenerator>(MicrowaveForceFieldGeneratorFactory, ActivateMicrowaveForceFieldGenerator, DeactivateMicrowaveForceFieldGenerator, InitialStock, true);
        SmokeParticlesPool = new PoolObjectStack<ParticleSystem>(SmokeParticlesFactory, ActivateSmokeParticles, DeactivateSmokeParticles, InitialStock, true);
    }

    private void DeactivateMicrowaveForceFieldGenerator(MicrowaveForceFieldGenerator o)
    {
        o.gameObject.transform.parent = WaveManager.MainGameParent.transform;
        o.gameObject.SetActive(false);
        if (!o.gameObject.name.Contains("_"))
        {
            MicrowaveForceFieldGeneratorCount++;
            o.gameObject.name = o.gameObject.name.Replace("(Clone)", "");
            o.gameObject.name += "_" + MicrowaveForceFieldGeneratorCount;
        }
        o.transform.position = Vector3.zero;
        o.transform.localPosition = Vector3.zero;
    }

    private void ActivateMicrowaveForceFieldGenerator(MicrowaveForceFieldGenerator o)
    {
        o.gameObject.SetActive(true);
    }

    private MicrowaveForceFieldGenerator MicrowaveForceFieldGeneratorFactory()
    {
        return Instantiate(MicrowaveForceFieldGeneratorPrefab);
    }

    private void DeactivateTeslaElectricTrap(ElectricTrap o)
    {
        o.gameObject.transform.parent = WaveManager.MainGameParent.transform;
        o.gameObject.SetActive(false);
        if (!o.gameObject.name.Contains("_"))
        {
            TeslaElectricTrapCount++;
            o.gameObject.name = o.gameObject.name.Replace("(Clone)", "");
            o.gameObject.name += "_" + TeslaElectricTrapCount;
        }
        o.transform.position = Vector3.zero;
        o.transform.localPosition = Vector3.zero;
    }

    private void ActivateTeslaElectricTrap(ElectricTrap o)
    {
        o.gameObject.SetActive(true);
    }

    private ElectricTrap TeslaElectricTrapFactory()
    {
        return Instantiate(TeslaElectricTrapPrefab);
    }

    private void DeactivateSmokeParticles(ParticleSystem o)
    {
        o.gameObject.transform.parent = null;
        o.gameObject.SetActive(false);
    }

    private void ActivateSmokeParticles(ParticleSystem o)
    {
        o.gameObject.SetActive(true);
        o.gameObject.transform.parent = WaveManager.MainGameParent.transform;
        o.transform.position = smokeParticlesPos;
    }

    private ParticleSystem SmokeParticlesFactory()
    {
        return Instantiate(SmokePrefab);
    }

    private void DeactivateTeslaCoilGenerator(TeslaCoilGenerator o)
    {
        o.gameObject.transform.parent = WaveManager.MainGameParent.transform;
        o.gameObject.SetActive(false);
        if (!o.gameObject.name.Contains("_"))
        {
            TeslaCoilGeneratorCount++;
            o.gameObject.name = o.gameObject.name.Replace("(Clone)", "");
            o.gameObject.name += "_" + TeslaCoilGeneratorCount;
        }
        o.transform.position = Vector3.zero;
        o.transform.localPosition = Vector3.zero;
    }

    private void ActivateTeslaCoilGenerator(TeslaCoilGenerator o)
    {
        o.gameObject.SetActive(true);
    }

    private TeslaCoilGenerator TeslaCoilGeneratorFactory()
    {
        return Instantiate(TeslaCoilGeneratorPrefab);
    } 

    private void DeactivateFERNPaintballMinigun(FERNPaintballMinigun o)
    {
        o.gameObject.transform.parent = WaveManager.MainGameParent.transform;
        o.gameObject.SetActive(false);
        if (!o.gameObject.name.Contains("_"))
        {
            FERNPaintballMinigunCount++;
            o.gameObject.name = o.gameObject.name.Replace("(Clone)", "");
            o.gameObject.name += "_" + FERNPaintballMinigunCount;
        }
        o.transform.position = Vector3.zero;
        o.transform.localPosition = Vector3.zero;
    }

    private void ActivateFERNPaintballMinigun(FERNPaintballMinigun o)
    {
        o.gameObject.SetActive(true);
        o.InitializeTrap();
    }

    private FERNPaintballMinigun FERNPaintballMinigunFactory()
    {
        return Instantiate(FERNPaintballMinigunPrefab);
    }

    private void DeactivateBaseballLauncher(BaseballLauncher o)
    {
        o.gameObject.transform.parent = WaveManager.MainGameParent.transform;
        o.gameObject.SetActive(false);
        if (!o.gameObject.name.Contains("_")) 
        { 
            BaseballLauncherCount++;
            o.gameObject.name = o.gameObject.name.Replace("(Clone)", "");
            o.gameObject.name += "_" + BaseballLauncherCount;
        }
        o.transform.position = Vector3.zero;
        o.transform.localPosition = Vector3.zero;
    }

    private void ActivateBaseballLauncher(BaseballLauncher o)
    {
        o.gameObject.SetActive(true);
        o.InitializeTrap();
    }

    private BaseballLauncher BaseballLauncherFactory()
    {
        return Instantiate(BaseballLauncherPrefab);
    }
    #region TrapHotBar

    public bool IsAllSlotsDisabled()
    {
        return TrapHotBar.IsAllSlotsDisabled();
    }

    #endregion

    #region Player

    public Player GetPlayer()
    {
        return player;
    }

    public Vector3 GetPlayerPos()
    {
        if (player != null) return player.transform.position;
        return default(Vector3);
    }

    public void PlayPickUpSound()
    {
        player.PlayPickUpSound();
    }

    public void PlayBackpackItemGrabbedAnim(Sprite itemImage)
    {
        itemGrabbedImage.sprite = itemImage;
        StartCoroutine(ShowAnimationBackpack());
    }
    public IEnumerator ShowAnimationBackpack()
    {
        backpack.GetComponent<Animator>().SetBool("IsItemGrabbed", true);
        yield return new WaitForSeconds(1.2f);
        backpack.GetComponent<Animator>().SetBool("IsItemGrabbed", false);
    }
    public void ShowLivesRemaining(int damageAmount, int hp, int maxHP = 0)
    {
        if (hp == 3)
        {
            playerLives.ToList().ForEach(x => x.GetComponent<Animator>().SetBool("IsDamaged", false));
            return;
        }
        //WIP Multiple Lives
        if (damageAmount == 2)
        {
            var lives = playerLives.OrderByDescending(x => x.name).Skip(1);
            lives.ToList().ForEach(x => x.GetComponent<Animator>().SetBool("IsDamaged", true));
            Debug.Log("VIDAS: " + lives.Count());
        }
        else
        {
            if (hp == 2)
            {
                playerLives[maxHP - maxHP].GetComponent<Animator>().SetBool("IsDamaged", true);
            }
            else if (hp == 1)
            {
                playerLives[maxHP - 2].GetComponent<Animator>().SetBool("IsDamaged", true);
            }
            else if (hp == 0)
            {
                playerLives[maxHP - 1].GetComponent<Animator>().SetBool("IsDamaged", true);
            }
        }
    }
    public Vector3 GetPlayerPrefabPlacement()
    {
        return player.GetPrefabPlacement();
    }

    public Vector3 GetPlayerCameraPosition()
    {
        return player.GetCameraPosition();
    }

    public Vector3 GetPlayerCameraForward()
    {
        return player.GetCameraForward();
    }

    public float GetPlayerCameraRotation()
    {
        return player.GetCameraRotation();
    }   

    #endregion

    #region LayerManagement

    public int GetItemLayer()
    {
        return LayerMask.NameToLayer(objectLayerName);
    }

    public LayerMask GetItemLayerMask()
    {
        LayerMask lm = 1 << GetItemLayer();
        return lm;
    }

    public int GetFloorLayer()
    {
        return LayerMask.NameToLayer(floorLayerName);
    }

    public LayerMask GetFloorLayerMask()
    {
        LayerMask lm = 1 << GetFloorLayer();
        return lm;
    }

    public int GetWallLayer()
    {
        return LayerMask.NameToLayer(wallLayerName);
    }

    public LayerMask GetWallLayerMask()
    {
        LayerMask lm = 1 << GetWallLayer();
        return lm;
    }

    public int GetEnemyLayer()
    {
        return LayerMask.NameToLayer(enemyLayerName);
    }

    public LayerMask GetEnemyLayerMask()
    {
        LayerMask lm = 1 << GetEnemyLayer();
        return lm;
    }

    #endregion

    #region Notifications
    public void ShowNotification(string text, Vector3 pos = new Vector3())
    {
        if (pos != Vector3.zero) 
        {
            positionObjectNotification = pos;
            OnObjectNotificationPosition(positionObjectNotification);
        }

        notifications.GetComponentInChildren<Text>().text = text;
        StartCoroutine(ShowNotification());
    }
    public string ShowMessageTutorialReminder() 
    {
        return PassedTutorial ? " First review the Footlocker at Kevin's Bed..." : "You have to press 'Enter' to conclude Tutorial before starting the waves. ";
    }
    public string ShowMessageNotificationByAction()
    {
        return HasOpenedLetter ? ShowMessageMagicboard() : " First review the letter in the Desk...";
    }

    public string ShowMessageMagicboard() 
    {
        return HasMagicboard ? ShowMessageTutorialReminder() : " Grab the Magicboard to keep a record of new experiments.";
    }

    public IEnumerator ShowNotification()
    {
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", true);
        yield return new WaitForSeconds(5f);
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", false);
    }

    public void ShowNotificationDefinedTime(string text, float time, Action action)
    {
        notifications.GetComponentInChildren<Text>().text = text;
        StartCoroutine(ShowNotificationDefinedTime(time, action));
    }

    public IEnumerator ShowNotificationDefinedTime(float time, Action action)
    {
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", true);
        yield return new WaitForSeconds(time);
        action.Invoke();
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", false);
    }

    #endregion

    #region Cat
    public void SetCatFree()
    {
        //_isCatCaptured = false;
        CatDistanceBar.PlayFadeOut();
        //OnCapturedCatChange(_isCatCaptured);
        //OnCatReleased();
    }

    public float GetCatDistance()
    {
        return (cat != null) ? cat.GetDistance() : 0f;
    }
    public void TakeCat()
    {
        if (cat == null) return;

        //_isCatCaptured = true;
        CatDistanceBar.PlayFadeIn();
        //OnCapturedCatChange(_isCatCaptured);
        //OnCatTaken();
        //cat.SetExitPos(exitPos);
        //cat.SetOwner(owner);
        OnCapturedCatPosition(cat.transform.localPosition);
    }

    internal void OnSmokeParticlesPosition(Vector3 smokeParticlePos)
    {
        smokeParticlesPos = smokeParticlePos;
    }
    #endregion
}
