using System;
using System.Collections;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Random = UnityEngine.Random;

[RequireComponent(typeof(Rigidbody))]
//CAMBIO PARA MVC
//No tomamos daño por observer, quito el IPlayerDamageObserver.
public class Player : MonoBehaviour, IInteractableItemObserver, IDoorGrayInteractObserver
{
    #region Events
    public delegate void OnNewRacketGrabbedDelegate();
    public event OnNewRacketGrabbedDelegate OnNewRacketGrabbed;
    public delegate void OnPlayerInteractDelegate(Transform player);
    public event OnPlayerInteractDelegate OnPlayerInteract;
    public delegate void OnPlayerNotificationObjectDelegate(Vector3 pos);
    public event OnPlayerNotificationObjectDelegate OnPlayerNotificationObject;
    #endregion

    #region Components
    private Rigidbody _rb;
    [SerializeField]
    private PlayerCamera _cam;
    public PlayerCamera Cam {
        get { return _cam; }
        set { _cam = value; }
    }
    public PostProcessVolume volume;
    public Vignette postProcessDamage;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    public ElectricWaveDamagePlayerPPSSettings postProcessElectricWaveDamagePlayer;
    public TankHitFistDamagePlayerPPSSettings postProcessTankHitFistDamagePlayer;
    public StunnedPlayerPPSSettings postProcessStunnedPlayer;
    private Coroutine TankHitFistDamagePlayerCoroutine;
    private Coroutine ElectricPlayerWaveDamageCoroutine;
    private Coroutine StunnedPlayerCoroutine;
    private Coroutine UnstunnedPlayerCoroutine;
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    [SerializeField] private Inventory _inventory;
    [SerializeField] private TrapHotBar _trapHotBar;
    public GameObject _weaponGORacket;
    public GameObject _weaponGOBaseballBat;
    public GameObject _weaponGORemoteControl;
    [SerializeField] private Melee _weapon;
    [SerializeField] private Remote _remoteControl;
    private GameObject _currentWeaponManager;
    private bool _weaponIsActive = false;
    private bool _hasMagicBoard = false;
    public string typeFloor { get; private set; }
    
    private AudioSource _audioSource;
    private GameObject _craftingScreen;
    private CraftingScreen _craftingScreenScript;
    [SerializeField] private GameObject _miniMapDisplay;
    private LevelManager _lm;
    public GameObject arrowUp, arrowDown, arrowLeft, arrowRight;
    #endregion

    #region Movement
    [SerializeField] private float speed = 5f;
    private float crouchSpeed = 2.5f;
    private float walkSpeed = 5f;
    private float sprintSpeed = 10f;
    private float maxVelocityChange = 20f;
    private float jumpForce = 7.5f;
    private bool jumpOnCooldown = false;
    private float jumpCooldown = 0.1f;

    public bool preventCheck = false;
    private float preventCheckTime = 0.1f;
    private Coroutine preventCheckCoroutine;
    [SerializeField]
    public bool isCrouchingSound = false;
    public bool isGrounded = true;
    [SerializeField]
    private bool isCrouching = false;
    [SerializeField]
    private bool isWalking = false;
    [SerializeField]
    private bool isRunning = false;
    [SerializeField]
    private bool isDamaged = false;
    [SerializeField]
    private bool isAttacking = false;
    private Vector3 _originalScale;
    private Vector3 _originalCamPos;
    #endregion

    #region Mouse
    // Mouse
    public bool canMoveCamera = true;
    public Image crosshair;
    public GameObject interactKey;
    public GameObject movingTrapButton;
    private Vector2 mouseSens = new Vector2(1f, 1f);
    private float yaw = 0f;
    private float pitch = 0f;
    private float lookAngle = 80f;
    #endregion

    #region Interactions

    [SerializeField] protected LayerMask obstacleMask;
    [SerializeField] public IInteractable lookingAt;
    public IMovable lookingIMovable;
    public InventoryItem lookingFor;
    public Vector3 lookingPlacement;
    public float timer = 0f;
    public bool isDead = false;
    [SerializeField] private bool _isAlive;
    public bool isAlive { get { return _isAlive; } }
    public int hp;
    public int maxHp = 3;
    public bool HasContextualMenu = false;
    public bool IsCrafting = false;
    #endregion

    //Gizmos
    public float gizmoScale = 1f;
    public LayerMask itemMask;
    private float _valueToChange;
    private bool _canStartNextWave;
    private bool _canMoveTraps;
    //SkillTree, deberia ver de mover esto a craftingrecipee, pero para llegar a este viernes sirve.
    private SkillTree _skillTree;
    private bool _canBuildMicrowaveTrap = false;
    private bool _canBuildSlowTrap = false;
    private bool _canBuildElectricTrap = false;
    private bool _canBuildPaintballMinigunTrap = false;
    private bool _canBuildTeslaCoilGenerator = false;
    public MicrowaveForceFieldGenerator microwaveFFG;
    public StationaryItem StationaryItem;
    //public ElectricTrap ElectricTrap;

    private void Awake()
    {
        _isAlive = true;
        Cursor.lockState = CursorLockMode.Locked;
        _rb = GetComponent<Rigidbody>();
        Cam = GameObject.Find("CamHolder").GetComponent<PlayerCamera>();
        volume = _cam.Camera.GetComponent<PostProcessVolume>();

        GameVars.Values.WaveManager.OnRoundEnd += CanStartNextWave;
        GameVars.Values.OnCapturedCatPosition += OnCapturedCatPosition;
        GameVars.Values.OnObjectNotificationPosition += OnObjectNotificationPosition;
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUnlocks;

        _craftingScreen = GameObject.Find("CraftingContainer");
        _craftingScreenScript = _craftingScreen.GetComponent<CraftingScreen>();
        _miniMapDisplay = GameObject.Find("MiniMapDisplay");
        _trapHotBar = FindObjectOfType<TrapHotBar>();
        _inventory = _craftingScreen.gameObject.GetComponentInChildren<Inventory>();
        //Cambia el GetChild a la raqueta nueva.
        _audioSource = GetComponent<AudioSource>();
        _originalScale = transform.localScale;
        _originalCamPos = _cam.transform.localPosition;
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        crosshair = GameObject.Find("Crosshair").GetComponent<Image>();

        hp = maxHp;
        GameVars.Values.ShowLivesRemaining(0,hp);
        ActiveFadeInEffect(1f);    
    }

   

    private void Start()
    {

    }

    private void Update()
    {
        if(_isAlive)
        {
            LookingAt();
            CheckGround();

            if (!GameVars.Values.crouchToggle)
            {
                if (Input.GetKey(GameVars.Values.crouchKey)) CrouchEnter();
                else CrouchExit();
            }
            else if (Input.GetKeyDown(GameVars.Values.crouchKey)) CrouchToggle();

            if (Input.GetKeyDown(GameVars.Values.sprintKey)) speed = sprintSpeed;
            if (Input.GetKeyUp(GameVars.Values.sprintKey)) speed = walkSpeed;

            if (Input.GetKeyDown(GameVars.Values.useKey))
            {
                if (lookingAt != null)
                {
                    Interact();
                    MovingObject(true);
                }
            }
            if (Input.GetKeyUp(GameVars.Values.useKey)) 
            {
                if (lookingAt != null)
                {
                    MovingObject(false);
                }
            }
            if (Input.GetKeyDown(GameVars.Values.hideShowMiniMapKey))
            {
                _miniMapDisplay.SetActive(!_miniMapDisplay.activeSelf);
            }

            //Cambiar la deteccion para no fijarte cada frame. Ver una mejor forma de detectar cuando tenemos un arma para no tener problema al agregar mas. Hacerlo cada vez que agarramos un item.

            if (Input.GetKeyDown(GameVars.Values.secondaryFire) && !IsCrafting)
            {
                if (lookingAt != null && lookingAt.gameObject.TryGetComponent<IMovable>(out IMovable aux) && _canMoveTraps)
                {
                    SwitchIsCrafting();
                    MoveTrap();
                }
            }
            if (Input.GetKeyDown(GameVars.Values.testOpenAllDoorsKey))
            {
                FindObjectsOfType<Door>().ToList().ForEach(x => { x.IsLocked = false; });
                FindObjectOfType<FootLocker>().IsBlocked = false;
            }
            if (Input.GetKeyDown(GameVars.Values.testRecieveWittsKey))
            {
                GameVars.Values.Inventory.ReceiveWitts(100);
            }
            if (Input.GetKeyDown(GameVars.Values.startWaveKey) && _canStartNextWave)
            {
                _canStartNextWave = false;
                _canMoveTraps = false;
                GameVars.Values.WaveManager.StartRound();
            }

            if(Input.GetKeyDown(GameVars.Values.inventoryKey) && _craftingScreen.activeInHierarchy)
            {
                Cursor.lockState = CursorLockMode.Locked;
                _craftingScreen.SetActive(false);
                _craftingScreenScript.IsWorkbenchScreenOpened = false;
                _miniMapDisplay.SetActive(true);
            }
            else if(Input.GetKeyDown(GameVars.Values.inventoryKey) && !_craftingScreen.activeInHierarchy)
            {
                //Cursor.lockState = CursorLockMode.Locked;
                if (_hasMagicBoard) 
                {
                    _craftingScreen.SetActive(true);
                    _craftingScreenScript.BTN_PageOne();
                    _miniMapDisplay.SetActive(false);
                }
            }

            if (!_craftingScreenScript.IsWorkbenchScreenOpened)
            {
                if (Input.GetKeyDown(GameVars.Values.primaryFire))
                {
                    if (_inventory.ContainsID(3, 1) || _inventory.ContainsID(11, 1) && !IsCrafting)
                    {
                        _weapon?.SetOwner(this);
                        _weapon?.MeleeAttack();
                    }

                    if (_inventory != null && (_inventory.ContainsID(14, 1)))
                    {
                        if (_weaponGORemoteControl.activeSelf)
                        {
                            _remoteControl?.SetOwner(this);
                            _remoteControl?.ActivatableAction();
                        }
                    }
                }

                if (Input.GetKeyDown(GameVars.Values.firstTrapHotKey) && !IsCrafting)
                {
                    _trapHotBar.PlayKeySlotHighlightAnim(1);
                    GameVars.Values.BaseballLauncher.Craft(_inventory);
                }

                if (Input.GetKeyDown(GameVars.Values.secondTrapHotKey) && !IsCrafting)
                {
                    if (_canBuildSlowTrap)
                    {
                        GameVars.Values.SlowTrap.Craft(_inventory);
                    }
                    else
                    {
                        if (GameVars.Values.HasSlowingTrapAppearedHotBar) 
                        {
                            _trapHotBar.PlayKeySlotHighlightAnim(2);
                            GameVars.Values.ShowNotification("You can't set Tar Slowing Trap until you have bought it in the Basement");
                        }
                           
                    }
                }

                if (Input.GetKeyDown(GameVars.Values.thirdTrapHotKey) && !IsCrafting)
                {
                    if (_canBuildMicrowaveTrap)
                    {
                        GameVars.Values.MicrowaveForceFieldGenerator.Craft(_inventory);
                    }
                    else
                    {
                        if (GameVars.Values.HasMicrowaveTrapAppearedHotBar) 
                        {
                            _trapHotBar.PlayKeySlotHighlightAnim(3);
                            GameVars.Values.ShowNotification("You can't set Microwave ForceField Machine until you have bought it in the Basement");
                        }
                    }
                }

                if (Input.GetKeyDown(GameVars.Values.fourthTrapHotKey) && !IsCrafting)
                {
                    if (_canBuildElectricTrap)
                    {
                        GameVars.Values.ElectricTrap.Craft(_inventory);
                    }
                    else
                    {
                        if (GameVars.Values.HasElectricTrapAppearedHotBar) 
                        {
                            _trapHotBar.PlayKeySlotHighlightAnim(4);
                            GameVars.Values.ShowNotification("You can't set the Electric Trap until you have bought it in the Basement");
                        }
                    }
                }

                if (Input.GetKeyDown(GameVars.Values.fifthTrapHotKey) && !IsCrafting)
                {
                    if (_canBuildPaintballMinigunTrap)
                    {
                        GameVars.Values.FERNPaintballMinigun.Craft(_inventory);
                    }
                    else
                    {
                        if (GameVars.Values.HasPaintballMinigunTrapAppearedHotBar) 
                        {
                            _trapHotBar.PlayKeySlotHighlightAnim(5);
                            GameVars.Values.ShowNotification("You can't set FERN Paintball Minigun until you have bought it in the Basement");
                        }
                    }
                }

                if (Input.GetKeyDown(GameVars.Values.sixthTrapHotKey) && !IsCrafting)
                {
                    if (_canBuildTeslaCoilGenerator)
                    {
                        GameVars.Values.TeslaCoilGenerator.Craft(_inventory);
                    }
                    else
                    {
                        if (GameVars.Values.HasTeslaCoilGeneratorAppearedHotBar) 
                        {
                            _trapHotBar.PlayKeySlotHighlightAnim(6);
                            GameVars.Values.ShowNotification("You can't set Tesla Coil Generator until you have bought it in the Basement");
                        }
                    }
                }

                if (Input.GetKeyDown(GameVars.Values.switchWeaponKey))
                {
                    SwitchWeapon();
                }
                if (isGrounded)
                {
                    if (Input.GetKeyDown(GameVars.Values.jumpKey) && !jumpOnCooldown) Jump();
                }
                else
                {
                    _rb.velocity -= new Vector3(0f, 9.8f * Time.deltaTime, 0f);
                }
            }

            if (Input.GetKeyDown(GameVars.Values.pauseKey))
            {
                var screenPause = Instantiate(Resources.Load<ScreenPause>("PauseCanvas"));
                ScreenManager.Instance.Push(screenPause);
                _rb.velocity = Vector3.zero;
                _rb.isKinematic = true;
            }

            /*if (Input.GetKeyDown(GameVars.Values.dropKey))
            {
                Damage(2, EnemyType.Tank);
                ActiveTankHitFistDamageEffect();
            }*/
        }
        
    }

    private void MovingObject(bool isMoving)
    {
        if(lookingAt == null) return;

        if (lookingAt.gameObject.TryGetComponent(out MovableObjects movableObject))
        {
            Debug.Log("Moviendo... ");
            movableObject.IsMoving = isMoving;
            movableObject.OwnerPlayer = this;
        }
    }

    private void FixedUpdate()
    {
        if (!_craftingScreenScript.IsWorkbenchScreenOpened && _isAlive)
        {
            if (canMoveCamera) Camera();
            LookingForPlacement();

            Walk();
        }
    }
    
    public void ActiveDamageEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessDamage))
        {
            StartCoroutine(LerpDamageEffect(0.6f,1f));
        }
    }

    public void SwitchKinematics()
    {
        if(_rb.isKinematic == false)
        {
            _rb.isKinematic = true;
        }
        else
        {
            _rb.isKinematic = false;
        }
    }

    IEnumerator LerpDamageEffect(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            postProcessDamage.intensity.value = _valueToChange;
            yield return null;
        }

        _valueToChange = endValue;
        StartCoroutine(LerpDamageEffect(0f,1f));
    }
    public void ActiveTankHitFistDamageEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessTankHitFistDamagePlayer))
        {
            if (TankHitFistDamagePlayerCoroutine != null) StopCoroutine(TankHitFistDamagePlayerCoroutine);
            TankHitFistDamagePlayerCoroutine = StartCoroutine(LerpTankHitFistDamageEffect(0.5f, 1f));
        }
    }
    IEnumerator LerpTankHitFistDamageEffect(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            postProcessTankHitFistDamagePlayer._Intensity.value = _valueToChange;
            yield return null;
        }

        _valueToChange = endValue;
        if (TankHitFistDamagePlayerCoroutine != null) StopCoroutine(TankHitFistDamagePlayerCoroutine);
        TankHitFistDamagePlayerCoroutine = StartCoroutine(LerpTankHitFistDamageEffect(0f, 1f));
    }

    public void ActiveFadeInEffect(float duration)
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeInSceneCoroutine != null) StopCoroutine(FadeInSceneCoroutine);
            FadeInSceneCoroutine = StartCoroutine(LerpFadeInEffect(duration));
        }
    }
    public void ActiveFadeOutEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(1f));
        }
    }
    public void ActiveFadeOutRestartEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutRestartEffect(1f));
        }
    }
    public void ActiveFadeOutYouWinEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutYouWinEffect(1f));
        }
    }
    public void ActiveFadeOutYouLoseEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutYouLoseEffect(1f));
        }
    }

    public void ActiveElectricWaveDamageEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessElectricWaveDamagePlayer))
        {
            if (StunnedPlayerCoroutine != null) StopCoroutine(StunnedPlayerCoroutine);
            StunnedPlayerCoroutine = StartCoroutine(LerpElectricWaveDamageEffect(1f));
        }
    }

    /*public void ActiveUnstunnedEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessElectricWaveDamagePlayer))
        {
            if (UnstunnedPlayerCoroutine != null) StopCoroutine(UnstunnedPlayerCoroutine);
            UnstunnedPlayerCoroutine = StartCoroutine(LerpUnstunnedEffect(1f));
        }
    }*/

    public void ActiveStunnedEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessStunnedPlayer))
        {
            if (StunnedPlayerCoroutine != null) StopCoroutine(StunnedPlayerCoroutine);
            StunnedPlayerCoroutine = StartCoroutine(LerpStunnedEffect(1f));
        }
    }

    public void ActiveUnstunnedEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessStunnedPlayer))
        {
            if (UnstunnedPlayerCoroutine != null) StopCoroutine(UnstunnedPlayerCoroutine);
            UnstunnedPlayerCoroutine = StartCoroutine(LerpUnstunnedEffect(1f));
        }
    }
    public void ActiveFadeOutEffect(string buttonEffect)
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(1f, buttonEffect));
        }
    }
    public void ActiveUIArrowFade(bool attacked, string arrowName) 
    {
        StartCoroutine(LerpArrowUIFade(1f, attacked, arrowName));
    }
    IEnumerator LerpArrowUIFade(float duration, bool attacked, string arrowName)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;
            if (arrowName.Equals("Up")) 
            {
                arrowDown.SetActive(false);
                arrowLeft.SetActive(false);
                arrowRight.SetActive(false);
                arrowUp.SetActive(true);
                arrowUp.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));
                
                if(attacked)
                    arrowUp.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            else if (arrowName.Equals("Down"))
            {
                arrowUp.SetActive(false);
                arrowLeft.SetActive(false);
                arrowRight.SetActive(false);
                arrowDown.SetActive(true);
                arrowDown.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));

                if (attacked)
                    arrowDown.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            else if (arrowName.Equals("Left"))
            {
                arrowDown.SetActive(false);
                arrowLeft.SetActive(false);
                arrowRight.SetActive(false);
                arrowLeft.SetActive(true);
                arrowLeft.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));

                if (attacked)
                    arrowLeft.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            else if (arrowName.Equals("Right"))
            {
                arrowDown.SetActive(false);
                arrowLeft.SetActive(false);
                arrowUp.SetActive(false);
                arrowRight.SetActive(true);
                arrowRight.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));

                if (attacked)
                    arrowRight.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            yield return null;
        }

        if (time <= 0f)
        {
            StartCoroutine(LerpArrowUIFadeOut(1f, attacked));
        }
    }
    IEnumerator LerpArrowUIFadeOut(float duration, bool attacked) 
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;

            if (arrowUp.activeSelf)
            {
                arrowUp.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));
                
                if(attacked)
                    arrowUp.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            else if (arrowDown.activeSelf)
            {
                arrowDown.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));

                if (attacked)
                    arrowDown.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            else if (arrowLeft.activeSelf)
            {
                arrowLeft.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));

                if (attacked)
                    arrowLeft.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            else if (arrowRight.activeSelf)
            {
                arrowRight.GetComponent<Image>().material.SetFloat("_AlphaTransitionVal", Mathf.Clamp01(time / duration));

                if (attacked)
                    arrowRight.GetComponent<Image>().material.SetFloat("_TransitionColorVal", Mathf.Clamp01(time / duration));
            }
            yield return null;
        }
    }
    IEnumerator LerpFadeOutEffect(float duration, string buttonEffect)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
        if (time < 0f)
        {
            if (buttonEffect.Equals("BackToMainMenu"))
            {
                Debug.Log("MAIN MENU");
                SceneManager.LoadScene(0);
            }
            else
            {
                Debug.Log("RESTART");
                SceneManager.LoadScene(1);
            }

        }
    }
    IEnumerator LerpElectricWaveDamageEffect(float duration)
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;

            postProcessElectricWaveDamagePlayer._ElectricDamageIntensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
        ElectricPlayerWaveDamageCoroutine = StartCoroutine(LerpElectricWaveDamageWearOffEffect(1f));
    }

    IEnumerator LerpElectricWaveDamageWearOffEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessElectricWaveDamagePlayer._ElectricDamageIntensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
    }
    IEnumerator LerpStunnedEffect(float duration)
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;

            postProcessStunnedPlayer._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
    }

    IEnumerator LerpUnstunnedEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessStunnedPlayer._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
    }

    IEnumerator LerpFadeInEffect(float duration)
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
    }
    IEnumerator LerpFadeOutEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }

        if (time < 0f)
        {
            Debug.Log("LLEGO AL FINAL??");
            SceneManager.LoadScene(0);
        }
    }
    IEnumerator LerpFadeOutYouLoseEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }

        if (time < 0f)
        {
            Debug.Log("LLEGO AL FINAL??");
            SceneManager.LoadScene(2);
        }
    }
    IEnumerator LerpFadeOutYouWinEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }

        if (time < 0f)
        {
            Debug.Log("LLEGO AL FINAL??");
            SceneManager.LoadScene(3);
        }
    }
    IEnumerator LerpFadeOutRestartEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }

        if (time < 0f)
        {
            Debug.Log("LLEGO AL FINAL??");
            SceneManager.LoadScene(1);
        }
    }
    public void Damage(int damageAmount, Enemy enemy)
    {
        _cam.CameraShakeDamage(1f, 0.8f);
        SelectDamagePostProcessEffectByType(enemy.enemyType);
        StartCoroutine(PlayDamageSound(3.4f));
        hp -= damageAmount;
        GameVars.Values.ShowLivesRemaining(damageAmount, hp, maxHp);
        if (hp <= 0) Die();
    }

    public void SelectDamagePostProcessEffectByType(EnemyType type)
    {
        if (type == EnemyType.Melee)
        {
            StartCoroutine(PlayDamageMeleeSound(1f));
            ActiveDamageEffect();
        }
        else if (type == EnemyType.Tank)
        {
            StartCoroutine(PlayDamageTankSound(1f));
            ActiveTankHitFistDamageEffect();
        }
        else
        {
            ActiveElectricWaveDamageEffect();
        }

    }

    public void Die()
    {
        //Ahora hacemos una animacion en la que se cae, se recupera y vuelve a tener la vida maxima.

        //_cam.DeactivateShake();

        //_audioSource.enabled = false;
        //_rb.isKinematic = true;
        _isAlive = false;
        canMoveCamera = false;
        _cam.SwitchStunnedState(true);
        StartCoroutine(PlayStunnedBirdsSound(_cam.StunDuration));
        ActiveStunnedEffect();
        //Invoke("Dead", 0.5f); //Esperabamos tres segundos antes.
    }

    public void Recover()
    {
        ActiveUnstunnedEffect();
        _isAlive = true;
        canMoveCamera = true;
        hp = maxHp;
        GameVars.Values.ShowLivesRemaining(0, hp);
    }

    public void SwitchIsCrafting()
    {
        if(IsCrafting)
        {
            IsCrafting = false;
        }
        else
        {
            IsCrafting = true;
        }

    }

    public void CheckForUnlocks()
    {
        if(_skillTree.isMicrowaveTrapUnlocked)
        {
            _canBuildMicrowaveTrap = true;
        }
        if(_skillTree.isSlowTrapUnlocked)
        {
            _canBuildSlowTrap = true;
        }
        if(_skillTree.isElectricTrapUnlocked)
        {
            _canBuildElectricTrap = true;
        }
        if(_skillTree.isPaintballMinigunTrapUnlocked)
        {
            _canBuildPaintballMinigunTrap = true;
        }
        if (_skillTree.isTeslaCoilGeneratorUnlocked)
        {
            _canBuildTeslaCoilGenerator = true;
        }
    }

    public void CanStartNextWave(int round)
    {
        _canStartNextWave = true;
        _canMoveTraps = true;
    }

    public void Dead()
    {
        isDead = true;
    }

    #region Movement

    private void Walk()
    {
        Vector3 input = new Vector3(Input.GetAxis("Horizontal"), 0f, Input.GetAxis("Vertical"));

        input = transform.TransformDirection(input) * speed;

        Vector3 velocity = _rb.velocity;
        Vector3 deltaVelocity = (input - velocity);
        deltaVelocity.x = Mathf.Clamp(deltaVelocity.x, -maxVelocityChange, maxVelocityChange);
        deltaVelocity.z = Mathf.Clamp(deltaVelocity.z, -maxVelocityChange, maxVelocityChange);
        deltaVelocity.y = 0f;

        Vector3 start = transform.position - new Vector3(0f, 0.9f, 0f);
        float maxDist = 0.35f;

        typeFloor = "";

        if (Physics.Raycast(start, -transform.up, out RaycastHit hit, maxDist))
        {
            if (hit.collider.gameObject.tag.Equals("GrassFloor"))
            {
                typeFloor = "Grass";
                //Debug.Log("TYPE FLOOR: " + typeFloor);
            }
            else
            {
                typeFloor = "Wood";
                //Debug.Log("TYPE FLOOR: " + typeFloor);
            }
        }

        _rb.AddForce(deltaVelocity, ForceMode.VelocityChange);

        if (_rb.velocity.magnitude > 1f && _rb.velocity.magnitude < 4f)
            if (!isCrouchingSound && isCrouching)
                StartCoroutine(PlayCrouchSound(0.8f));

        if (_rb.velocity.magnitude > 4f && _rb.velocity.magnitude <= 7.5f)
            if (!isWalking)
                StartCoroutine(PlayWalkSound(0.6f));

        if (_rb.velocity.magnitude > 7.5f && _rb.velocity.magnitude <= 15f)
            if (!isRunning)
                StartCoroutine(PlayRunSound(0.3f));

        //Debug.Log("VELOCITY: " + _rb.velocity.magnitude);
    }

    private void Jump()
    {
        isGrounded = false;
        _rb.velocity = new Vector3(_rb.velocity.x, 0f, _rb.velocity.z);
        _rb.AddForce(0f, jumpForce, 0f, ForceMode.Impulse);
    }

    public void SlowDown(float slowAmount)
    {
        speed -= slowAmount;
    } 

    IEnumerator PreventCheck()
    {
        preventCheck = true;
        yield return new WaitForSeconds(preventCheckTime);
        preventCheck = false;
    }

    #region Crouch

    private void CrouchEnter()
    {
        if (isCrouching) return;
        speed = crouchSpeed;
        transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y / 2, transform.localScale.z);
        transform.localPosition -= new Vector3(0f, 0.5f, 0f);
        _cam.SetInitPos(new Vector3(0f, -0.5f, 0f));
        isCrouching = true;
    }

    private void CrouchExit()
    {
        if (!isCrouching) return;
        speed = walkSpeed;
        transform.localScale = _originalScale;
        transform.localPosition += new Vector3(0f, 0.5f, 0f);
        _cam.SetInitPos(new Vector3(0f, 0f, 0f));
        isCrouching = false;
    }

    private void CrouchToggle()
    {
        if (isCrouching) CrouchExit();
        else CrouchEnter();
    }

    #endregion

    public Vector3 GetVelocity()
    {
        return _rb.velocity;
    }

    private void CheckGround()
    {
        LayerMask layermask = 1 << gameObject.layer;
        Vector3 start = transform.position - new Vector3(0f, 0.9f, 0f);
        float gizmoSin = 0.7f * gizmoScale;
        float maxDist = 0.35f;

        if (preventCheck) return;

        if (Physics.Raycast(start, -transform.up, maxDist, ~layermask))
        {
            isGrounded = true;
            return;
        }
        typeFloor = "";


        if (Physics.Raycast(start + new Vector3(gizmoScale, 0f, 0f), -transform.up, maxDist, ~layermask) ||
            Physics.Raycast(start + new Vector3(0f, 0f, gizmoScale), -transform.up, maxDist, ~layermask) ||
            Physics.Raycast(start + new Vector3(-gizmoScale, 0f, 0f), -transform.up, maxDist, ~layermask) ||
            Physics.Raycast(start + new Vector3(0f, 0f, -gizmoScale), -transform.up, maxDist, ~layermask))
        {
            isGrounded = true;
            return;
        }
        if (Physics.Raycast(start + new Vector3(gizmoSin, 0f, gizmoSin), -transform.up, maxDist, ~layermask) ||
            Physics.Raycast(start + new Vector3(-gizmoSin, 0f, gizmoSin), -transform.up, maxDist, ~layermask) ||
            Physics.Raycast(start + new Vector3(gizmoSin, 0f, -gizmoSin), -transform.up, maxDist, ~layermask) ||
            Physics.Raycast(start + new Vector3(-gizmoSin, 0f, -gizmoSin), -transform.up, maxDist, ~layermask))
        {
            isGrounded = true;
            return;
        }

        isGrounded = false;
    }

    #endregion

    #region Camera

    private void Camera()
    {
        yaw = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * mouseSens.x;
        pitch -= mouseSens.y * Input.GetAxis("Mouse Y");
        pitch = Mathf.Clamp(pitch, -lookAngle, lookAngle);

        transform.localEulerAngles = new Vector3(0f, yaw, 0f);
        _cam.ChangeAngles(new Vector3(pitch, yaw, 0f));
    }

    public Vector3 GetCameraPosition()
    {
        return _cam.transform.position;
    }

    public Vector3 GetCameraForward()
    {
        return _cam.transform.forward;
    }

    public float GetCameraRotation()
    {
        return _cam.transform.eulerAngles.y;
    }

    public Vector3 GetPrefabPlacement()
    {
        return lookingPlacement;
    }

    private void LookingAt()
    {
        RaycastHit hit;
        RaycastHit hitResult;
        RaycastHit wallHit;
        //if(!Physics.Raycast(_cam.transform.position, _cam.GetForward(), out wallHit, 5f, GameVars.Values.GetWallLayerMask()))
        //{

        if (Physics.Raycast(_cam.transform.position, _cam.GetForward(), out hit, 5f, GameVars.Values.GetItemLayerMask()))
        {
            Vector3 dir = hit.transform.position - _cam.transform.position;                             //Ahora usamos ObstacleMask;
            if(!Physics.Raycast(_cam.transform.position, _cam.GetForward(), out wallHit, dir.magnitude, obstacleMask))//GameVars.Values.GetWallLayerMask()))
            {
                if (Physics.Linecast(_cam.transform.position, hit.collider.gameObject.transform.position, out hitResult))
                {
                    if (hit.collider.name != hitResult.collider.name)
                    SetOffItem(lookingAt); 
                    //return;
                }

                if(hit.collider.gameObject.GetComponent<IInteractable>() != null)
                {
                    lookingAt = hit.collider.gameObject.GetComponent<IInteractable>();//.gameObject.GetComponent<Item>(); LookingAt ahora es un collider para incluir Item y Traps
                }
                
                SetOnItem(lookingAt);
                ChangeCrosshair();
            }
        }
        else
        {
            SetOffItem(lookingAt);
            lookingAt = null;
            ChangeCrosshair();
        }
    }

    private void ChangeCrosshair()
    {
        if (lookingAt == null)
        {
            interactKey.SetActive(false);
            movingTrapButton.SetActive(false);
            crosshair.sprite = GameVars.Values.crosshair;
            ChangeCrosshairSize(20f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<WorkBenchCraftingMenu>(out WorkBenchCraftingMenu wbCraftingMenu))
        {
            crosshair.sprite = GameVars.Values.crosshairWorkbenchCrafting;
            wbCraftingMenu.SetCraftingMenu(_craftingScreen.GetComponent<CraftingScreen>());
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<InventoryItem>(out InventoryItem aux))
        {
            crosshair.sprite = GameVars.Values.crosshairHandGrab;
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<StationaryItem>(out StationaryItem stationaryItem))
        {
            crosshair.sprite = GameVars.Values.crosshairAddOnBattery;
            StationaryItem = stationaryItem;
            OnPlayerInteract += stationaryItem.OnPlayerInteract;
            OnPlayerInteract(transform);
            stationaryItem.IndicatorLookAtPlayer();
            interactKey.SetActive(true);
            stationaryItem.ShowBlueprint();
            ChangeCrosshairSize(40f);
            return;
        }
        else 
        {
            if(StationaryItem != null)
                StationaryItem.IsLookedAt = false;
        }

        if (lookingAt.gameObject.TryGetComponent<TVTrap>(out TVTrap tvTrap))
        {
            if (!tvTrap.GetComponent<BoxCollider>().isTrigger) 
            {
                crosshair.sprite = GameVars.Values.crosshairAddOnBattery;
                interactKey.SetActive(true);
                ChangeCrosshairSize(40f);
            }
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<FootLocker>(out FootLocker fl))
        {
            crosshair.sprite = GameVars.Values.crosshairHandHold;
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<Letter>(out Letter letter))
        {
            crosshair.sprite = GameVars.Values.crosshairHandGrab;
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<Door>(out Door aux1))
        {
            crosshair.sprite = GameVars.Values.crosshairDoor;
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<PantryDoor>(out PantryDoor pantryDoor))
        {
            crosshair.sprite = GameVars.Values.crosshairDoor;
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<Drawer>(out Drawer drawer))
        {
            crosshair.sprite = GameVars.Values.crosshairHandHold;
            interactKey.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<BaseballLauncher>(out BaseballLauncher baseballLauncher))
        {
            baseballLauncher.HasTennisBallContainerSmall = _inventory.ContainsID(8, 1);
            baseballLauncher.HasTennisBallContainerLarge = _inventory.ContainsID(15, 1);
            if (baseballLauncher.IsEmpty)
            {
                crosshair.sprite = GameVars.Values.crosshairReloadTrap1;
            }
            else if (baseballLauncher.HasTennisBallContainerLarge) 
            {
                crosshair.sprite = GameVars.Values.switchTennisBallContainer;
                baseballLauncher.OnSwitchLargeContainer += OnSwitchLargeContainer;
            }
            else
            {
                crosshair.sprite = GameVars.Values.crosshairActivation;
                //interactKey.SetActive(true);
                movingTrapButton.SetActive(true);
                movingTrapButton.GetComponent<Image>().sprite = GameVars.Values.crosshairRightClickIcon;
                movingTrapButton.transform.GetChild(0).GetComponent<Image>().gameObject.SetActive(true);
            }

            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<TeslaCoilGenerator>(out TeslaCoilGenerator teslaCoilGenerator))
        {
            
            crosshair.sprite = GameVars.Values.crosshairActivation;
            movingTrapButton.SetActive(true);
            movingTrapButton.GetComponent<Image>().sprite = GameVars.Values.crosshairRightClickIcon;
            movingTrapButton.transform.GetChild(0).GetComponent<Image>().gameObject.SetActive(true);

            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<FERNPaintballMinigun>(out FERNPaintballMinigun FERNPaintballMinigun))
        {
            FERNPaintballMinigun.HasPaintballPelletMagazine = _inventory.ContainsID(7, 1);
            if (FERNPaintballMinigun.IsEmpty)
            {
                crosshair.sprite = GameVars.Values.reloadingMinigunIcon;
                FERNPaintballMinigun.OnReload += OnFERNPaintballMinigunReload;
            }
            else 
            {
                crosshair.sprite = GameVars.Values.crosshairActivation;
                FERNPaintballMinigun.SetInventory(_inventory);
                movingTrapButton.SetActive(true);
            }

            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<ElectricTrap>(out ElectricTrap ElectricTrap))
        {
            crosshair.sprite = GameVars.Values.crosshairActivation;
            //interactKey.SetActive(true);
            movingTrapButton.SetActive(true);
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent(out MovableObjects movableObjects))
        {
            crosshair.sprite = GameVars.Values.crosshairMovingObject;
            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<MicrowaveForceFieldGenerator>(out MicrowaveForceFieldGenerator microwaveFFG))
        {
            if (microwaveFFG.IsBatteryFried)
            {
                crosshair.sprite = GameVars.Values.crosshairAddOnBattery;
                movingTrapButton.SetActive(true);
                ChangeCrosshairSize(40f);
            }
            else
            {
                crosshair.sprite = GameVars.Values.crosshairActivation;
                movingTrapButton.SetActive(true);
                movingTrapButton.GetComponent<Image>().sprite = GameVars.Values.crosshairRightClickIcon;
                movingTrapButton.transform.GetChild(0).GetComponent<Image>().gameObject.SetActive(true);
                ChangeCrosshairSize(40f);
            }
            
            return;
        }

        crosshair.sprite = GameVars.Values.crosshair;
        ChangeCrosshairSize(20f);
    }

    

    private void ChangeCrosshairSize(float num)
    {
        crosshair.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, num);
        crosshair.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, num);
    }

    private void LookingForPlacement()
    {
        RaycastHit hit;
        //Crear variable distancia
        if (Physics.Raycast(_cam.transform.position, _cam.GetForward(), out hit, 10f, GameVars.Values.GetFloorLayerMask()))
        {
            lookingPlacement = hit.point;
        }
        else
        {
            lookingFor = null;
        }
    }

    #endregion

    public void Interact()
    {
        
        if (lookingAt.gameObject.TryGetComponent(out InventoryItem aux))
        {
            aux.AddObserver(this);
            
            InteractWithInventoryItem(aux);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent(out WorkBenchCraftingMenu wbCraftingMenu))
        {
            _craftingScreen.SetActive(true);
            wbCraftingMenu.OpenCraftingPurchaseMenu();
            _miniMapDisplay.SetActive(false);
            return;
        }
        lookingAt.Interact();
        if (lookingAt.gameObject.TryGetComponent(out BaseballLauncher auxBL))
        {
            if (auxBL.IsEmpty)
            {
                GameVars.Values.ShowNotification("You need a Tennis Ball Container to reload!");
                auxBL.OnReload += OnBaseballMachineReload;
            }
            if (_inventory.ContainsID(15, 1)) 
            {
                auxBL.SwitchLargeContainer();
            }

            if (auxBL._canActivate1aUpgrade && _inventory.ContainsID(2,1))
            {
                auxBL.Activate1aUpgrade();
            }
        }
        if (lookingAt.gameObject.TryGetComponent(out MicrowaveForceFieldGenerator microwaveFFG))
        {
            if (!_inventory.ContainsID(2, 1) && microwaveFFG.IsBatteryFried)
            {
                GameVars.Values.ShowNotification("You need a new Battery to replace it!");
                microwaveFFG.OnMicrowaveBatteryReplaced += OnMicrowaveReplaceBattery;
            }

            if(_inventory.ContainsID(2, 1))
            {
                microwaveFFG.BatteryReplaced();
            }
            
        }
        
        if (lookingAt.gameObject.TryGetComponent(out FERNPaintballMinigun FERNPaintballMinigun)) 
        {
            
            if (FERNPaintballMinigun.IsEmpty && !_inventory.ContainsID(7, 1))
            {
                GameVars.Values.ShowNotification("You need a Paintball Pellet Magazine to reload!");
            }

            if (_inventory.ContainsID(7,1)) 
            {
                _inventory.RemoveItemID(7,1);
            }
        }
        if (lookingAt.gameObject.TryGetComponent(out StationaryItem stationaryItem))
        {
            if (_inventory.ContainsID(2, 1))
            {
                _inventory.RemoveItemID(2, 1);
                stationaryItem.ActiveBatteryComponent();
                lookingAt = null;
                StationaryItem = null;
                return;
            }
            else
            {
                GameVars.Values.ShowNotificationDefinedTime("You need a Battery for this!", 2f, 
                    () => stationaryItem.HideBlueprint());
            }
        }

        if (lookingAt.gameObject.TryGetComponent(out TVTrap tvTrap))
        {
            if (!tvTrap.GetComponent<BoxCollider>().isTrigger)
            {
                if (_inventory.ContainsID(2, 1))
                {
                    _inventory.RemoveItemID(2, 1);
                    tvTrap.ActiveBatteryComponent();
                    lookingAt = null;
                    StationaryItem = null;
                    return;
                }
            }
            /*else
            {
                GameVars.Values.ShowNotificationDefinedTime("You need a Battery for this!", 2f,
                    () => stationaryItem.HideBlueprint());
            }*/
        }

        if (lookingAt.gameObject.TryGetComponent(out Door door))
        {
            if (door.IsLocked)
            {
                movingTrapButton.SetActive(true);
                movingTrapButton.GetComponent<Image>().sprite = GameVars.Values.crosshairLockDoor;
                movingTrapButton.transform.GetChild(0).GetComponent<Image>().gameObject.SetActive(false);
            }
            else
            {
                movingTrapButton.SetActive(false);
                movingTrapButton.GetComponent<Image>().sprite = GameVars.Values.crosshairRightClickIcon;
                movingTrapButton.transform.GetChild(0).GetComponent<Image>().gameObject.SetActive(true);
                _lm.ChangeDoorsStatus();
            }
        }
    }

    private void SwitchWeapon()
    {
        int weaponID = _inventory.GetNextWeapon();
        if(weaponID != 0)
        {

            Debug.Log("entro aca");
            if(weaponID == 11)
            {
                Debug.Log("entro a bat");
                _currentWeaponManager.SetActive(false);
                _currentWeaponManager = _weaponGOBaseballBat;
                _weapon = _weaponGOBaseballBat.GetComponent<BaseballBat>();
                _weaponGOBaseballBat.SetActive(true);
            }
            else if(weaponID == 3)
            {
                Debug.Log("entro a racket");
                _currentWeaponManager.SetActive(false);
                _currentWeaponManager = _weaponGORacket;
                _weapon = _weaponGORacket.GetComponent<Racket>();
                _weaponGORacket.SetActive(true);
            }
            else if(weaponID == 14)
            {
                Debug.Log("entro a remotecontrol");
                _currentWeaponManager.SetActive(false);
                _currentWeaponManager = _weaponGORemoteControl;
                _remoteControl = _weaponGORemoteControl.GetComponent<RemoteControl>();
                _weapon = null;
                _weaponGORemoteControl.SetActive(true);
            }
        }
    }
    private void OnSwitchLargeContainer()
    {
        if (_inventory.ContainsID(15, 1))
            _inventory.RemoveItemID(15, 1);
    }
    private void OnFERNPaintballMinigunReload()
    {
        if (_inventory.ContainsID(7, 1)) 
            _inventory.RemoveItemID(7, 1);
    }

    private void OnBaseballMachineReload()
    {
        if (_inventory.ContainsID(8, 1))
            _inventory.RemoveItemID(8, 1);
    }

    private void OnMicrowaveReplaceBattery()
    {
        if (_inventory.ContainsID(2, 1))
            _inventory.RemoveItemID(2, 1);
    }

    public void MoveTrap()
    {
        if (lookingAt.gameObject.TryGetComponent<IMovable>(out IMovable aux))
        {
            SetOffItem(lookingAt);
            lookingAt = null;
            aux.BecomeMovable();
            //ChangeCrosshair();

        }
        //lookingIMovable.BecomeMovable();
    }
    #region SFX Handle
    public IEnumerator PlayStunnedBirdsSound(float timer)
    {
        isAttacking = true;
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "StunnedBirds", 0.15f, false);
        yield return new WaitForSecondsRealtime(timer);
        isAttacking = false;
    }
    public IEnumerator PlayRacketSwingSound(float timer)
    {
        isAttacking = true;
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "RacketSwing", 0.06f, false);
        yield return new WaitForSecondsRealtime(timer);
        isAttacking = false;
    }

    public IEnumerator PlayDamageSound(float timer)
    {
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "KidDamage", 0.3f, false);
        isDamaged = true;

        yield return new WaitForSecondsRealtime(timer);
        isDamaged = false;
    }

    public IEnumerator PlayDamageMeleeSound(float timer)
    {
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "PunchHit_Melee", 0.3f, false);

        yield return new WaitForSecondsRealtime(timer);
    }

    public IEnumerator PlayDamageTankSound(float timer)
    {
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "PunchHit_Tank", 0.3f, false);

        yield return new WaitForSecondsRealtime(timer);
    }

    public IEnumerator PlayCrouchSound(float timer)
    {
        var clipName = "Footstep_" + typeFloor + "_0" + Random.Range(1, 3);
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, clipName, 0.15f, false);
        isCrouchingSound = true;

        yield return new WaitForSecondsRealtime(timer);
        isCrouchingSound = false;
    }

    public IEnumerator PlayWalkSound(float timer)
    {
        var clipName = "Footstep_" + typeFloor + "_0" + Random.Range(1, 3);
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, clipName, 0.2f, false);
        isWalking = true;

        yield return new WaitForSecondsRealtime(timer);

        isWalking = false;
    }

    public IEnumerator PlayRunSound(float timer)
    {
        var clipName = "Footstep_" + typeFloor + "_0" + Random.Range(1, 3);
        GameVars.Values.soundManager.PlaySoundOnce(_audioSource, clipName, 0.4f, false);
        isRunning = true;

        yield return new WaitForSecondsRealtime(timer);

        isRunning = false;
    }

    public void PlayPickUpSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("GrabSound", transform.position, 0.18f);
    }
    #endregion

    public void InteractWithInventoryItem(InventoryItem inventoryItem)
    {
        if (inventoryItem.myCraftingID == 0) 
        {
            GameVars.Values.HasMagicboard = _hasMagicBoard = true;
            GameVars.Values.PlayBackpackItemGrabbedAnim(inventoryItem.itemImage);
            inventoryItem.Interact();
            return;
        }

        if ((inventoryItem.myCraftingID == 3 || inventoryItem.myCraftingID == 11))
        {
            if (_inventory.ItemCountByID(inventoryItem.myCraftingID) < 1)
            {
                _inventory.AddItem(inventoryItem);
                GameVars.Values.PlayBackpackItemGrabbedAnim(inventoryItem.itemImage);
            }
        }
        else
        {
            if (inventoryItem.myCraftingID == 8)
            {
                GameVars.Values.HasSmallContainer = true;
            }
            else if (inventoryItem.myCraftingID == 15) 
            {
                GameVars.Values.HasLargeContainer = true;
            }
            GameVars.Values.PlayBackpackItemGrabbedAnim(inventoryItem.itemImage);
            _inventory.AddItem(inventoryItem);
        }
    }

    private void OnDrawGizmos()
    {
        Vector3 start = transform.position - new Vector3(0f, 0.5f, 0f);
        Vector3 down = new Vector3(0f, -1f, 0f);
        float gizmoScaleSin = 0.7f * gizmoScale;

        Gizmos.DrawLine(transform.position, transform.position - new Vector3(0f, 1f, 0f));

        Gizmos.DrawLine(start + new Vector3(gizmoScale, 0f, 0f), start + new Vector3(gizmoScale, 0f, 0f) + down);
        Gizmos.DrawLine(start + new Vector3(0f, 0f, gizmoScale), start + new Vector3(0f, 0f, gizmoScale) + down);
        Gizmos.DrawLine(start + new Vector3(-gizmoScale, 0f, 0f), start + new Vector3(-gizmoScale, 0f, 0f) + down);
        Gizmos.DrawLine(start + new Vector3(0f, 0f, -gizmoScale), start + new Vector3(0f, 0f, -gizmoScale) + down);

        Gizmos.DrawLine(start + new Vector3(gizmoScaleSin, 0f, gizmoScaleSin), start + new Vector3(gizmoScaleSin, 0f, gizmoScaleSin) + down);
        Gizmos.DrawLine(start + new Vector3(gizmoScaleSin, 0f, -gizmoScaleSin), start + new Vector3(gizmoScaleSin, 0f, -gizmoScaleSin) + down);
        Gizmos.DrawLine(start + new Vector3(-gizmoScaleSin, 0f, gizmoScaleSin), start + new Vector3(-gizmoScaleSin, 0f, gizmoScaleSin) + down);
        Gizmos.DrawLine(start + new Vector3(-gizmoScaleSin, 0f, -gizmoScaleSin), start + new Vector3(-gizmoScaleSin, 0f, -gizmoScaleSin) + down);
    }

    private void SetOnItem(IInteractable item)
    {
        if (item == null)
            return;

        var outLine = item.gameObject.GetComponent<Outline>();
        if (outLine == null)
            return;
        outLine.OutlineColor = Color.green;
        outLine.OutlineWidth = 6f;
    }

    private void SetOffItem(IInteractable item)
    {
        if (item == null)
            return;

        var outLine = item.gameObject.GetComponent<Outline>();
        if (outLine == null)
            return;

        outLine.OutlineWidth = 0f;

    }

    public void OnNotify(string message)
    {
        if (message.Equals("ItemGrabbed"))
        {
            if (_inventory.ContainsID(3, 1) && !_weaponIsActive)
            {
                _weaponIsActive = true;
                _currentWeaponManager = _weaponGORacket;
                _weaponGORacket.SetActive(true);
                _weapon = _weaponGORacket.GetComponent<Racket>();

                //_weaponGO.ActivateRacket();
                //_weaponGO.transform.GetComponentInChildren<Racket>().gameObject.layer = 0;
                //OnNewRacketGrabbed += _weaponGO.transform.GetComponentInChildren<Racket>().OnNewRacketGrabbed;
                //OnNewRacketGrabbed?.Invoke();
            }
            else if (_inventory.ContainsID(11, 1) && !_weaponIsActive)
            {
                _weaponIsActive = true;
                _currentWeaponManager = _weaponGOBaseballBat;
                _weaponGOBaseballBat.SetActive(true);
                _weapon = _weaponGOBaseballBat.GetComponent<BaseballBat>();
            }
            else if (_inventory.ContainsID(14, 1) && !_weaponIsActive)
            {
                _weaponIsActive = true;
                _currentWeaponManager = _weaponGORemoteControl;
                _weaponGORemoteControl.SetActive(true);
                _remoteControl = _weaponGORemoteControl.GetComponent<RemoteControl>();
            }
        }
    }

    //CAMBIO PARA MVC
    //No usamos observer para recibir daño, tomamos el daño directamente a traves de la funcion Damage().
    
    //public void OnNotifyPlayerDamage(string message)
    //{
        //if (message.Equals("DamagePlayer"))
        //{
            //Damage();
        //}
    //}

    public void OnNotifyDoorGrayInteract(string message)
    {
        if (message.Equals("GrayDoorInteract"))
        {
            GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "AlertNotificationDoorAccess", 0.18f, true);
        }
    }

    public void RacketInventoryRemoved()
    {
        _weaponIsActive = false;
        _inventory.RemoveItemByID(3);
        if(_inventory.ContainsID(11,1))
        {
            _weaponIsActive = true;
            _currentWeaponManager = _weaponGOBaseballBat;
            _weaponGORacket.SetActive(false);
            _weapon = _weaponGOBaseballBat.GetComponent<BaseballBat>();
            _weaponGOBaseballBat.SetActive(true);
        }
    }

    public void BaseballBatInventoryRemoved()
    {
        _weaponIsActive = false;
        _inventory.RemoveItemByID(11);
        if(_inventory.ContainsID(3,1))
        {
            _weaponIsActive = true;
            _currentWeaponManager = _weaponGORacket;
            _weaponGOBaseballBat.SetActive(false);
            _weapon = _weaponGORacket.GetComponent<Racket>();
            _weaponGORacket.SetActive(true);
        }
    }
    private void OnObjectNotificationPosition(Vector3 objectNotificationPos)
    {
        ActiveArrowUI(objectNotificationPos, false);
    }
    private void OnCapturedCatPosition(Vector3 catPos)
    {
        ActiveArrowUI(catPos,false);
    }
    internal void OnAttackPlayerPosition(Vector3 attackPos, bool attacked)
    {
        //Debug.Log("EL PLAYER ES ATACADO Y TE MUESTRO SU POSICION PAPU: " + attackPos);
        ActiveArrowUI(attackPos, attacked);
    }
    private void ActiveArrowUI(Vector3 pos, bool attacked) 
    {
        Vector3 screenPosition = Cam.gameObject.GetComponentInChildren<Camera>().WorldToScreenPoint(pos);

        Vector2 screenCenter = new Vector2(Screen.width / 2, Screen.height / 2);
        Vector2 direction = (screenPosition - (Vector3)screenCenter).normalized;
        //Debug.Log("Dirección: " + direction);
        if (Mathf.Abs(direction.x) > Mathf.Abs(direction.y))
        {
            if (direction.x > 0)
            {
                ActiveUIArrowFade(attacked, "Right");
            }
            else
            {
                ActiveUIArrowFade(attacked, "Left");
            }
        }
        else
        {
            if (direction.y > 0)
            {
                ActiveUIArrowFade(attacked, "Up");
            }
            else
            {
                ActiveUIArrowFade(attacked, "Down");
            }
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        var enemy = other.gameObject.GetComponent<Enemy>();
        if (enemy != null && _weapon != null)
        {
            enemy.TakeDamage(_weapon.damageAmount);
            _weapon.OnHitEffect();
        }
    }

    
}
