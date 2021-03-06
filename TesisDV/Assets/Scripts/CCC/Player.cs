using System;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.UI;
using Random = UnityEngine.Random;

[RequireComponent(typeof(Rigidbody))]
public class Player : MonoBehaviour, IInteractableItemObserver, IPlayerDamageObserver, IDoorGrayInteractObserver
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
    public AttentionPlayerPPSSettings postProcessAttention;
    [SerializeField]
    private Inventory _inventory;
    public GameObject _weaponGO;
    [SerializeField]
    private Melee _weapon;
    public string typeFloor { get; private set; }
    
    private AudioSource _audioSource;
    private GameObject _craftingScreen;
    [SerializeField]
    private GameObject _miniMapDisplay;
    private LevelManager _lm;
    #endregion

    #region Movement
    private float speed = 5f;
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
    public Item lookingAt;
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

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        Cam = GameObject.Find("CamHolder").GetComponent<PlayerCamera>();
        volume = _cam.Camera.GetComponent<PostProcessVolume>();

        _craftingScreen = GameObject.Find("CraftingContainer");
        _miniMapDisplay = GameObject.Find("MiniMapDisplay");
        //_inventory = GameObject.Find("InventoryBar").GetComponent<Inventory>();
        _inventory = _craftingScreen.gameObject.GetComponentInChildren<Inventory>();
        _weapon = _weaponGO.transform.GetChild(0).GetComponent<Racket>();
        _audioSource = GetComponent<AudioSource>();
        _originalScale = transform.localScale;
        _originalCamPos = _cam.transform.localPosition;
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        crosshair = GameObject.Find("Crosshair").GetComponent<Image>();
        hp = maxHp;
        GameVars.Values.ShowLivesRemaining(hp, maxHp);
    }

    private void Start()
    {

    }

    private void Update()
    {
        
        LookingAt();
        CheckGround();
        if (GameVars.Values.IsCatCaptured)
        {
            ActiveAttentionEffect();
        }

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

        //Cambiar la deteccion para no fijarte cada frame. Ver una mejor forma de detectar cuando tenemos un arma para no tener problema al agregar mas. Hacerlo cada vez que agarramos un item.
        

        if (Input.GetKeyDown(GameVars.Values.primaryFire))
        {
            if (_inventory.ContainsID(3) && !IsCrafting) 
            {
                _weapon.SetOwner(this);
                _weapon.MeleeAttack();
            }
        }

        if (Input.GetKeyDown(GameVars.Values.secondaryFire))
        {
            if (lookingAt != null)
            {
                SwitchIsCrafting();
                MoveTrap();
            }
        }

        //if (Input.GetKeyDown(GameVars.Values.inventoryKey))  Dejo el c???digo del screenmanager para usarlo en las pantallas de win y loose, donde si queremos que el PJ no se pueda seguir controlando.
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
            _craftingScreen.SetActive(false);
            _miniMapDisplay.SetActive(true);
        }
        else if(Input.GetKeyDown(GameVars.Values.inventoryKey) && !_craftingScreen.activeInHierarchy)
        {
            _craftingScreen.SetActive(true);
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

        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            GameVars.Values.BaseballLauncher.Craft(_inventory);
        }

        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            GameVars.Values.TVTrap.Craft(_inventory);
            //GameVars.Values.TVTrapAgain.Craft(_inventory);
        }

        if(Input.GetKeyDown(KeyCode.Escape)) //|| Input.GetKeyDown(KeyCode.P))
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

        if (isGrounded)
        {
            if (Input.GetKeyDown(GameVars.Values.jumpKey) && !jumpOnCooldown) Jump();
        }
        else
        {
            _rb.velocity -= new Vector3(0f, 9.8f * Time.deltaTime, 0f);
        }
        
    }

    private void FixedUpdate()
    {  
        if (canMoveCamera) Camera();
        LookingForPlacement();

        Walk(); 
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

    public void ActiveAttentionEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessAttention))
        {
            StartCoroutine(LerpAttentionEffect(0.75f, 1f));
        }
    }

    IEnumerator LerpAttentionEffect(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            postProcessAttention._Interpolator.value = _valueToChange;
            yield return null;
        }

        _valueToChange = endValue;
        StartCoroutine(LerpAttentionEffect(0f, 1f));
    }

    public void Damage()
    {
        _cam.CameraShakeDamage(1f, 0.8f);
        ActiveDamageEffect();
        StartCoroutine(PlayDamageSound(3.4f));
        hp--;
        GameVars.Values.ShowLivesRemaining(hp, maxHp);
        if (hp <= 0) Die();
    }

    public void Die()
    {
        //_cam.DeactivateShake();
        _audioSource.enabled = false;
        _rb.isKinematic = true;
        canMoveCamera = false;
        Invoke("Dead", 3f);
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
        _rb.AddForce(0f, jumpForce, 0f, ForceMode.VelocityChange);
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
        //RaycastHit wallHit; No se usaba.
        RaycastHit hitResult;

        //if(!Physics.Raycast(_cam.transform.position, _cam.GetForward(), out wallHit, 5f, GameVars.Values.GetWallLayerMask()))
        //{
        if (Physics.Raycast(_cam.transform.position, _cam.GetForward(), out hit, 5f, GameVars.Values.GetItemLayerMask()))
        {
            if (Physics.Linecast(_cam.transform.position, hit.collider.gameObject.transform.position, out hitResult))
            {
                if (hit.collider.name != hitResult.collider.name)
                    return;
            }

            lookingAt = hit.collider.gameObject.GetComponent<Item>();
            SetOnItem(lookingAt);
            ChangeCrosshair();
        }
        else
        {
            SetOffItem(lookingAt);
            lookingAt = null;
            ChangeCrosshair();
        }
        //}
    }

    private void ChangeCrosshair()
    {
        if (lookingAt == null)
        {
            crosshair.sprite = GameVars.Values.crosshair;
            ChangeCrosshairSize(20f);
            return;
        }
        if (lookingAt.gameObject.TryGetComponent<InventoryItem>(out InventoryItem aux))
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
        if (lookingAt.gameObject.TryGetComponent<BaseballLauncher>(out BaseballLauncher baseballLauncher))
        {
            baseballLauncher.HasPlayerTennisBallBox = _inventory.ContainsID(8);
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
            InteractWithInventoryItem();
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
        }

        if (lookingAt.TryGetComponent<Door>(out Door door))
        {
            _lm.ChangeDoorsStatus();
        }
    }

    private void OnBaseballMachineReload()
    {
        if (_inventory.ContainsID(8))
            _inventory.RemoveItemByID(8);
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

    public void InteractWithInventoryItem()
    {
        _inventory.AddItem(lookingAt as InventoryItem);
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

    private void SetOnItem(Item item)
    {
        if (item == null)
            return;

        var outLine = item.gameObject.GetComponent<Outline>();
        if (outLine == null)
            return;
        outLine.OutlineColor = Color.green;
        outLine.OutlineWidth = 6f;
    }

    private void SetOffItem(Item item)
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
            if (_inventory.ContainsID(3))
            {
                _weaponGO.SetActive(true);
                _weaponGO.transform.GetComponentInChildren<Racket>().gameObject.layer = 0;
                OnNewRacketGrabbed += _weaponGO.transform.GetComponentInChildren<Racket>().OnNewRacketGrabbed;
                OnNewRacketGrabbed?.Invoke();
            }
        }
    }

    public void OnNotifyPlayerDamage(string message)
    {
        if (message.Equals("DamagePlayer"))
        {
            Damage();
        }
    }

    public void OnNotifyDoorGrayInteract(string message)
    {
        if (message.Equals("GrayDoorInteract"))
        {
            GameVars.Values.soundManager.PlaySoundOnce(_audioSource, "AlertNotificationDoorAccess", 0.18f, true);
            ActiveAttentionEffect();
        }
    }

    public void RacketInventoryRemoved()
    {
        _inventory.RemoveItemByID(3);
    }

}
