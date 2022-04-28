using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameVars : MonoBehaviour
{
    private static GameVars _gameVars;
    public static GameVars Values { get { return _gameVars; } }

    public SoundManager soundManager { get; private set; }

    [SerializeField]
    private Player player;

    [SerializeField]
    private string objectLayerName;
    [SerializeField]
    private string floorLayerName;
    [SerializeField]
    private string enemyLayerName;

    // KeyBinds
    public KeyCode jumpKey;
    public KeyCode primaryFire;
    public KeyCode secondaryFire;
    public KeyCode useKey;
    public KeyCode inventoryKey;
    public KeyCode inventoryItem1Key;
    public KeyCode sprintKey;
    public KeyCode crouchKey;
    public bool crouchToggle;

    //Resources
    public Sprite crosshair;
    public Sprite crosshairDoor;
    public Sprite crosshairHandGrab;
    public Sprite crosshairActivation;
    public CraftingScreen craftingScreen;
    public List<AudioClip> audioClips;

    // Game
    public float projectileLifeTime = 5f;
    public float itemPickUpLerpSpeed = 0.2f;

    public List<List<Node>> levelRoutes;

    private void Awake()
    {
        if (_gameVars == null) _gameVars = this;
        else Destroy(this);

        SetKeys();
        LoadResources();

        SceneManager.sceneLoaded += FindPlayer;
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

    private void LoadResources()
    {
        crosshair = Resources.Load<Sprite>("crosshair");
        crosshairDoor = Resources.Load<Sprite>("OpenDoor");
        crosshairHandGrab = Resources.Load<Sprite>("HandGrab");
        crosshairActivation = Resources.Load<Sprite>("ButtonPress");
        craftingScreen = Resources.Load<CraftingScreen>("CraftingCanvas");
        audioClips = Resources.LoadAll<AudioClip>("Sounds").ToList();
        soundManager = FindObjectOfType<SoundManager>();
        soundManager.SetAudioClips(audioClips);
    }

    #region Player

    public Vector3 GetPlayerPos()
    {
        if (player != null) return player.transform.position;
        return default(Vector3);
    }

    public void PlayPickUpSound()
    {
        player.PlayPickUpSound();
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
}
