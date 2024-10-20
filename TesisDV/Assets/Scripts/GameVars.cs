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
    public bool crouchToggle;

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
    public Sprite crosshairRightClickIcon;
    public Sprite imageBaseballTrap;
    public CraftingScreen craftingScreen;

    public Text notifications;
    public Image[] playerLives;

    public Animator playerLivesAnim { get; private set; }

    //public YouWinScreen youWinScreen;
    //public YouLoseScreen youLoseScreen;
    public List<AudioClip> audioClips;
    public GameObject backpack;
    public Image itemGrabbedImage;
    [Header("Crafting Recipes")]
    public CraftingRecipe BaseballLauncher;
    public CraftingRecipe MicrowaveForceFieldGenerator;
    public CraftingRecipe SlowTrap;
    public CraftingRecipe NailFiringMachine;
    public CraftingRecipe ElectricTrap;
    public bool HasBoughtMicrowaveTrap { get; set; }
    public bool HasBoughtSlowingTrap { get; set; }
    public bool HasBoughtDartsTrap { get; set; }
    public bool HasBoughtElectricTrap { get; set; }
    public bool HasElectricTrapAppearedHotBar { get; set; }
    public bool HasMicrowaveTrapAppearedHotBar { get; set; }
    public bool HasSlowingTrapAppearedHotBar { get; set; }
    public bool HasDartsTrapAppearedHotBar { get; set; }
    

    [Header("Game")]
    private float _fadeDelay = 1.1f;
    private bool _isFaded;
    public bool HasOpenedLetter { get; set; }
    public bool HasOpenedTrunk { get; set; }
    
    public float projectileLifeTime = 5f;
    public float itemPickUpLerpSpeed = 0.2f;
    public int currentShotsTrap1; //BaseballLauncher
    public int currentShotsTrap2; //NailFiringMachine
    public List<List<Node>> levelRoutes;
    public GameObject BasementDirectionMarkers;
    #region Events
    public delegate void OnCapturedCatChangeDelegate(bool isCaptured);
    public event OnCapturedCatChangeDelegate OnCapturedCatChange;
    #endregion

    private void Awake()
    {
        if (_gameVars == null) _gameVars = this;
        else Destroy(this);

        SetKeys();
        LoadResources();

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
        if (aux != null) player = aux.GetComponent<Player>();
        else player = null;
    }

    void FindCat(Scene scene, LoadSceneMode mode)
    {
        //var aux = GameObject.Find("cat");
        var aux = FindObjectOfType<Cat>();
        if (aux != null) cat = aux.GetComponent<Cat>();
        else cat = null;
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
        crosshairRightClickIcon = Resources.Load<Sprite>("RightClickMouseIcon");
        crosshairWorkbenchCrafting = Resources.Load<Sprite>("WorkbenchCraftIcon");
        craftingScreen = Resources.Load<CraftingScreen>("CraftingCanvas");
        audioClips = Resources.LoadAll<AudioClip>("Sounds").ToList();
        TrapHotBar = FindObjectOfType<TrapHotBar>();
        backpack = FindObjectsOfType<GameObject>().Where(x => x.name.Equals("Backpack")).First();
        itemGrabbedImage = FindObjectsOfType<Image>(true).Where(x => x.name.Equals("ItemGrabbed")).First();
        notifications = FindObjectsOfType<Text>().Where(x => x.gameObject.name.Equals("NotificationsText")).First();
        playerLives = FindObjectsOfType<Image>().Where(x => x.gameObject.name.Contains("Life")).OrderBy(x => x.name).ToArray();
        soundManager = FindObjectOfType<SoundManager>();
        craftingContainer = FindObjectOfType<CraftingScreen>();
        soundManager.SetAudioClips(audioClips);
        LevelManager = GetComponent<LevelManager>();
        WaveManager = GetComponent<WaveManager>();
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
    public void ShowNotification(string text)
    {
        notifications.text = text;
        StartCoroutine(ShowNotification());
    }

    public string ShowMessageNotificationByAction()
    {
        return HasOpenedLetter ? " First review the Footlocker at Kevin's Bed..." : " First review the letter in the Desk...";
    }

    public IEnumerator ShowNotification()
    {
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", true);
        yield return new WaitForSeconds(5f);
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", false);
    }

    public void ShowNotificationDefinedTime(string text, float time, Action action)
    {
        notifications.text = text;
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
        _isCatCaptured = false;
        CatDistanceBar.PlayFadeOut();
        OnCapturedCatChange(_isCatCaptured);
        cat.CatHasBeenReleased();
    }

    public float GetCatDistance()
    {
        return (cat != null) ? cat.GetDistance() : 0f;
    }

    public void TakeCat(Vector3 exitPos)
    {
        _isCatCaptured = true;
        CatDistanceBar.PlayFadeIn();
        OnCapturedCatChange(_isCatCaptured);
        cat.CatIsBeingTaken();
        cat.SetExitPos(exitPos);
    }
    #endregion
}
