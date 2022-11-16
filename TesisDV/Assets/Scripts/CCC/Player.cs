using System;
using System.Collections;
using TMPro;
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
    #endregion

    #region Components
    private Rigidbody _rb;
    private PlayerCamera _cam;
    public PlayerCamera Cam {
        get { return _cam; }
        set { _cam = value; }
    }
    public PostProcessVolume volume;
    public Vignette postProcessDamage;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    [SerializeField] private Inventory _inventory;
    public GameObject _weaponGORacket;
    public GameObject _weaponGOBaseballBat;
    public GameObject _weaponGORemoteControl;
    [SerializeField] private Melee _weapon;
    [SerializeField] private Remote _remoteControl;
    private GameObject _currentWeaponManager;
    private bool _weaponIsActive = false;
    public string typeFloor { get; private set; }
    
    private AudioSource _audioSource;
    private GameObject _craftingScreen;
    private CraftingScreen _craftingScreenScript;
    [SerializeField] private GameObject _miniMapDisplay;
    private LevelManager _lm;
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
    private Vector2 mouseSens = new Vector2(1f, 1f);
    private float yaw = 0f;
    private float pitch = 0f;
    private float lookAngle = 80f;
    #endregion

    #region Interactions

    [SerializeField]
    public IInteractable lookingAt;
    public IMovable lookingIMovable;
    public InventoryItem lookingFor;
    public Vector3 lookingPlacement;
    public float timer = 0f;
    public bool isDead = false;
    public int hp;
    public int maxHp = 4;
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
    private bool _canBuildDartsTrap = false;
    private void Awake()
    {
        Cursor.lockState = CursorLockMode.Locked;
        _rb = GetComponent<Rigidbody>();
        Cam = GameObject.Find("CamHolder").GetComponent<PlayerCamera>();
        volume = _cam.Camera.GetComponent<PostProcessVolume>();

        GameVars.Values.WaveManager.OnRoundEnd += CanStartNextWave;

        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUnlocks;

        _craftingScreen = GameObject.Find("CraftingContainer");
        _craftingScreenScript = _craftingScreen.GetComponent<CraftingScreen>();
        _miniMapDisplay = GameObject.Find("MiniMapDisplay");
        //_inventory = GameObject.Find("InventoryBar").GetComponent<Inventory>();
        _inventory = _craftingScreen.gameObject.GetComponentInChildren<Inventory>();
        //Cambia el GetChild a la raqueta nueva.
        _audioSource = GetComponent<AudioSource>();
        _originalScale = transform.localScale;
        _originalCamPos = _cam.transform.localPosition;
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        crosshair = GameObject.Find("Crosshair").GetComponent<Image>();
        hp = maxHp;
        GameVars.Values.ShowLivesRemaining(hp, maxHp);
        ActiveFadeInEffect(1f);    
    }

    private void Start()
    {

    }

    private void Update()
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

        if (Input.GetKeyDown(KeyCode.Return) && _canStartNextWave)
        {
            _canStartNextWave = false;
            _canMoveTraps = false;
            GameVars.Values.WaveManager.StartRound();
        }


        //if (Input.GetKeyDown(GameVars.Values.inventoryKey))  Dejo el c�digo del screenmanager para usarlo en las pantallas de win y loose, donde si queremos que el PJ no se pueda seguir controlando.
        //{
            //var screencrafting = instantiate(gamevars.values.craftingscreen);
            //screenmanager.instance.push(screencrafting);
            
        //}
        //else if (Input.GetKeyUp(GameVars.Values.inventoryKey))
        //{
            //screenmanager.instance.pop();
            
        //}

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
            _craftingScreen.SetActive(true);
            _craftingScreenScript.BTN_PageOne();
            _miniMapDisplay.SetActive(false);
        }

        //if (!IsCrafting) //Va al TrapHotBar.
        //{

        //    contextualMenuAnim.SetBool("HasTraps", GameVars.Values.BaseballLauncher.CanCraft(_inventory));
        //    if (GameVars.Values.BaseballLauncher.HasBaseballTrapItems(_inventory))
        //    {
        //        contextualMenuScript.ActivatePanelTrap1();
        //    }

        //    if (GameVars.Values.BaseballLauncher.HasTVTrapItems(_inventory))
        //    {
        //        contextualMenuScript.ActivatePanelTrap2();
        //    }
        //}
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
                    _remoteControl?.SetOwner(this);
                    _remoteControl?.ActivatableAction();
                }
            }

            if (Input.GetKeyDown(KeyCode.Alpha1) && !IsCrafting)
            {
                GameVars.Values.BaseballLauncher.Craft(_inventory);
            }

            if (Input.GetKeyDown(KeyCode.Alpha2) && !IsCrafting && _canBuildMicrowaveTrap)
            {
                GameVars.Values.MicrowaveForceFieldGenerator.Craft(_inventory);
            }

            if (Input.GetKeyDown(KeyCode.Alpha3) && !IsCrafting && _canBuildSlowTrap)
            {
                GameVars.Values.SlowTrap.Craft(_inventory);
            }

            if (Input.GetKeyDown(KeyCode.Alpha4) && !IsCrafting && _canBuildDartsTrap)
            {
                GameVars.Values.NailFiringMachine.Craft(_inventory);
            }

            if (Input.GetKeyDown(KeyCode.Alpha5) && !IsCrafting && _canBuildElectricTrap)
            {
                GameVars.Values.ElectricTrap.Craft(_inventory);
            }
            if (Input.GetKeyDown(KeyCode.H))
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

        if (Input.GetKeyDown(KeyCode.Escape)) //|| Input.GetKeyDown(KeyCode.P))
        {
            var screenPause = Instantiate(Resources.Load<ScreenPause>("PauseCanvas"));
            ScreenManager.Instance.Push(screenPause);
            _rb.velocity = Vector3.zero;
            _rb.isKinematic = true;
        }

        

        //if (Input.GetKeyDown(GameVars.Values.dropKey))
        //{
        //    _inventory.DropItem();
        //}

        
        
    }

    private void FixedUpdate()
    {
        if (!_craftingScreenScript.IsWorkbenchScreenOpened)
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
    public void Damage(int damageAmount)
    {
        _cam.CameraShakeDamage(1f, 0.8f);
        ActiveDamageEffect();
        StartCoroutine(PlayDamageSound(3.4f));
        hp -= damageAmount;
        GameVars.Values.ShowLivesRemaining(hp, maxHp);
        if (hp <= 0) Die();
    }

    public void Die()
    {
        //_cam.DeactivateShake();
        _audioSource.enabled = false;
        _rb.isKinematic = true;
        canMoveCamera = false;
        Invoke("Dead", 0.5f); //Esperabamos tres segundos antes.
        
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
        if(_skillTree.isDartsTrapUnlocked)
        {
            _canBuildDartsTrap = true;
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
            Vector3 dir = hit.transform.position - _cam.transform.position;
            if(!Physics.Raycast(_cam.transform.position, _cam.GetForward(), out wallHit, dir.magnitude, GameVars.Values.GetWallLayerMask()))
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
            crosshair.sprite = GameVars.Values.crosshair;
            ChangeCrosshairSize(20f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<WorkBenchCraftingMenu>(out WorkBenchCraftingMenu wbCraftingMenu))
        {
            crosshair.sprite = GameVars.Values.crosshairWorkbenchCrafting;
            wbCraftingMenu.SetCraftingMenu(_craftingScreen.GetComponent<CraftingScreen>());
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<InventoryItem>(out InventoryItem aux))
        {
            crosshair.sprite = GameVars.Values.crosshairHandGrab;
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<StationaryItem>(out StationaryItem stationaryItem))
        {
            crosshair.sprite = GameVars.Values.crosshairAddOnBattery;
            stationaryItem.ShowBlueprint();
            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<FootLocker>(out FootLocker fl))
        {
            crosshair.sprite = GameVars.Values.crosshairHandHold;
            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<Letter>(out Letter letter))
        {
            crosshair.sprite = GameVars.Values.crosshairHandGrab;
            ChangeCrosshairSize(40f);
            return;
        }

        if (lookingAt.gameObject.TryGetComponent<Door>(out Door aux1))
        {
            crosshair.sprite = GameVars.Values.crosshairDoor;
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<PantryDoor>(out PantryDoor pantryDoor))
        {
            crosshair.sprite = GameVars.Values.crosshairDoor;
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<Drawer>(out Drawer drawer))
        {
            crosshair.sprite = GameVars.Values.crosshairHandHold;
            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<BaseballLauncher>(out BaseballLauncher baseballLauncher))
        {
            baseballLauncher.HasPlayerTennisBallBox = _inventory.ContainsID(8, 1);
            if (baseballLauncher.IsEmpty)
            {
                crosshair.sprite = GameVars.Values.crosshairReloadTrap1;
            }
            else
            {
                crosshair.sprite = GameVars.Values.crosshairActivation;
            }

            ChangeCrosshairSize(40f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<NailFiringMachine>(out NailFiringMachine nailFiringMachine))
        {
            crosshair.sprite = GameVars.Values.crosshairActivation;
            ChangeCrosshairSize(40f);
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
        if (lookingAt.gameObject.TryGetComponent<InventoryItem>(out InventoryItem aux))
        {
            aux.AddObserver(this);
            InteractWithInventoryItem(aux);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<WorkBenchCraftingMenu>(out WorkBenchCraftingMenu wbCraftingMenu))
        {
            _craftingScreen.SetActive(true);
            wbCraftingMenu.OpenCraftingPurchaseMenu();
            _miniMapDisplay.SetActive(false);
            return;
        }
        lookingAt.Interact();
        if (lookingAt.gameObject.TryGetComponent<BaseballLauncher>(out BaseballLauncher auxBL))
        {
            if (auxBL.IsEmpty)
            {
                GameVars.Values.ShowNotification("You need a Tennis Ball Box to reload!");
                auxBL.OnReload += OnBaseballMachineReload;
            }
            if (auxBL._canActivate1Upgrade && _inventory.ContainsID(2,1))
            {
                auxBL.ActivateFirstUpgrade();
            }
        }
        if (lookingAt.gameObject.TryGetComponent<StationaryItem>(out StationaryItem stationaryItem))
        {
            if (_inventory.ContainsID(2, 1))
            {
                _inventory.RemoveItemID(2, 1);
                stationaryItem.ActiveBatteryComponent();
            }
            else
            {
                GameVars.Values.ShowNotificationDefinedTime("You need a Battery for this!", 2f, 
                    () => stationaryItem.HideBlueprint());
            }
        }

        if (lookingAt.gameObject.TryGetComponent<Door>(out Door door))
        {
            _lm.ChangeDoorsStatus();
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
        
        /* if(_inventory.IsThereAnotherWeapon())
        {
            if(_inventory.ContainsID(11, 1) && _currentWeaponManager == _weaponGORacket)
            {
                _currentWeaponManager = _weaponGOBaseballBat;
                _weaponGORacket.SetActive(false);
                _weapon = _weaponGOBaseballBat.GetComponent<BaseballBat>();
                _weaponGOBaseballBat.SetActive(true);
            }
            else if(_inventory.ContainsID(3, 1) && _currentWeaponManager == _weaponGOBaseballBat)
            {
                _currentWeaponManager = _weaponGORacket;
                _weaponGOBaseballBat.SetActive(false);
                _weapon = _weaponGORacket.GetComponent<Racket>();
                _weaponGORacket.SetActive(true);
            }
            else if (_inventory.ContainsID(14, 1) && _currentWeaponManager == _weaponGORacket)
            {
                _currentWeaponManager = _weaponGORemoteControl;
                _weaponGORacket.SetActive(false);
                _remoteControl = _weaponGORemoteControl.GetComponent<RemoteControl>();
                _weapon = null;
                _weaponGORemoteControl.SetActive(true);
            }
            else if (_inventory.ContainsID(14, 1) && _currentWeaponManager == _weaponGOBaseballBat)
            {
                _currentWeaponManager = _weaponGORemoteControl;
                _weaponGOBaseballBat.SetActive(false);
                _remoteControl = _weaponGORemoteControl.GetComponent<RemoteControl>();
                _weapon = null;
                _weaponGORemoteControl.SetActive(true);
            }
            else if (_inventory.ContainsID(3, 1) && _currentWeaponManager == _weaponGORemoteControl)
            {
                _currentWeaponManager = _weaponGORacket;
                _weaponGORemoteControl.SetActive(false);
                _weapon = _weaponGORacket.GetComponent<Racket>();
                _remoteControl = null;
                _weaponGORacket.SetActive(true);
            }
        } */
    }

    private void OnBaseballMachineReload()
    {
        if (_inventory.ContainsID(8, 1))
            _inventory.RemoveItemID(8, 1);
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

    public void InteractWithInventoryItem(InventoryItem inventoryItem)
    {
        if ((inventoryItem.myCraftingID == 3 || inventoryItem.myCraftingID == 11))
        {
            if (_inventory.ItemCountByID(inventoryItem.myCraftingID) < 1)
            {
                _inventory.AddItem(inventoryItem);
            }
        }
        else
        {
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
