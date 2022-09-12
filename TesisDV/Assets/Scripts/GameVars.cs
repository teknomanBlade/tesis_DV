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
    public LevelManager LevelManager { get; set; }
    public WaveManager WaveManager { get; set; }
    
    [SerializeField]
    private Player player;
    public Player Player
    {
        get { return player; }
    }

    [SerializeField]
    private Cat cat;
    public Cat Cat
    {
        get { return cat; }
    }

    [SerializeField]
    private bool _isCatCaptured;
    public bool IsCatCaptured { get { return _isCatCaptured; } }

    [SerializeField]
    private string objectLayerName;
    [SerializeField]
    private string floorLayerName;
    [SerializeField]
    private string enemyLayerName;
    [SerializeField]
    private string wallLayerName;

    [Header("KeyBinds")]
    public KeyCode jumpKey;
    public KeyCode primaryFire;
    public KeyCode secondaryFire;
    public KeyCode useKey;
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
    public Sprite imageBaseballTrap;
    public CraftingScreen craftingScreen;
    public Text notifications;
    public Text playerLives;

    public Animator playerLivesAnim { get; private set; }

    //public YouWinScreen youWinScreen;
    //public YouLoseScreen youLoseScreen;
    public List<AudioClip> audioClips;

    [Header("Crafting Recipes")]
    public CraftingRecipe BaseballLauncher;
    public CraftingRecipe TVTrap;
    public CraftingRecipe SlowTrap;
    public TVCraftingRecipe TVTrapAgain;

    [Header("Game")]
    private float _fadeDelay = 1.1f;
    private bool _isFaded;
    public float projectileLifeTime = 5f;
    public float itemPickUpLerpSpeed = 0.2f;
    public int currentShotsTrap1;
    public List<List<Node>> levelRoutes;

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
        crosshairActivation = Resources.Load<Sprite>("ButtonPress");
        crosshairReloadTrap1 = Resources.Load<Sprite>("ReloadTrap1");
        imageBaseballTrap = Resources.Load<Sprite>("SpriteBaseballLauncher");
        craftingScreen = Resources.Load<CraftingScreen>("CraftingCanvas");
        audioClips = Resources.LoadAll<AudioClip>("Sounds").ToList();
        //youWinScreen = Resources.Load<YouWinScreen>("YouWin");
        //youLoseScreen = Resources.Load<YouLoseScreen>("YouLose");
        notifications = FindObjectsOfType<Text>().Where(x => x.gameObject.name.Equals("NotificationsText")).First();
        playerLives = FindObjectsOfType<Text>().Where(x => x.gameObject.name.Equals("HealthText")).First();
        playerLivesAnim = playerLives.gameObject.GetComponent<Animator>();
        playerLivesAnim.SetBool("IsDamaged", false);
        soundManager = FindObjectOfType<SoundManager>();
        soundManager.SetAudioClips(audioClips);
        LevelManager = GetComponent<LevelManager>();
        WaveManager = GetComponent<WaveManager>();
    }

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

    public void ShowLivesRemaining(int lives, int maxHP)
    {
        StartCoroutine(ShowAnimDamagedPlayer());
        playerLives.text = "X " + Mathf.Clamp(lives, 0, maxHP);
    }
    public IEnumerator ShowAnimDamagedPlayer()
    {
        playerLivesAnim.SetBool("IsDamaged", true);
        yield return new WaitForSeconds(1f);
        playerLivesAnim.SetBool("IsDamaged", false);
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

    public IEnumerator ShowNotification()
    {
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", true);
        yield return new WaitForSeconds(5f);
        notifications.gameObject.GetComponent<Animator>().SetBool("ShowNotification", false);
    }

    #endregion

    #region Cat
    public void SetCatFree()
    {
        _isCatCaptured = false;
        cat.CatHasBeenReleased();
    }

    public float GetCatDistance()
    {
        return (cat != null) ? cat.GetDistance() : 0f;
    }

    public void TakeCat(Vector3 exitPos)
    {
        _isCatCaptured = true;
        cat.CatIsBeingTaken();
        cat.SetExitPos(exitPos);
    }
    #endregion
}
