using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Rigidbody))]
public class Player : MonoBehaviour
{
    //---------
    private Rigidbody _rb;
    
    private PlayerCamera _cam;
    [SerializeField]
    private Inventory _inventory;

    // Movement
    //public CraftingRecipe craftingRecipe;
    private float speed = 5f;
    private float walkSpeed = 5f;
    private float sprintSpeed = 10f;
    private float maxVelocityChange = 20f;
    private float jumpForce = 7.5f;
    private bool jumpOnCooldown = false;
    private float jumpCooldown = 0.15f;

    public bool preventCheck = false;
    private float preventCheckTime = 0.25f;

    [SerializeField]
    private bool isGrounded = true;
    [SerializeField]
    private bool isCrouching = false;
    private Vector3 originalScale;
    private Vector3 originalCamPos;

    // Mouse

    public Image crosshair;
    private Vector2 mouseSens = new Vector2(1f, 1f);
    private float yaw = 0f;
    private float pitch = 0f;
    private float lookAngle = 80f;

    // Interactions

    [SerializeField]
    public Item lookingAt;
    public IMovable lookingIMovable;
    public InventoryItem lookingFor;
    public Vector3 lookingPlacement;
    public float timer = 0f;

    //Gizmos
    public float gizmoScale = 1f;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        _cam = GameObject.Find("MainCamera").GetComponent<PlayerCamera>();
        _inventory = GameObject.Find("InventoryBar").GetComponent<Inventory>();

        originalScale = transform.localScale;
        originalCamPos = _cam.transform.localPosition;

        crosshair = GameObject.Find("Crosshair").GetComponent<Image>();
    }

    private void Start()
    {

    }

    private void Update()
    {
        LookingAt();
        Camera();
        LookingForPlacement();
        

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

        if (Input.GetKeyDown(GameVars.Values.secondaryFire))
        {
            if (lookingAt != null)
            {
                MoveTrap();
            }
        }

        if (Input.GetKeyDown(GameVars.Values.inventoryKey))
        {
            var screenCrafting = Instantiate(GameVars.Values.craftingScreen);
            ScreenManager.Instance.Push(screenCrafting);
        }
        else if (Input.GetKeyUp(GameVars.Values.inventoryKey))
        {
            ScreenManager.Instance.Pop();
        }
        
        if(Input.GetKeyDown(KeyCode.Alpha1))
        {
            GameVars.Values.BaseballLauncher.Craft(_inventory);
        }
    }

    private void FixedUpdate()
    {
        Walk();
        CheckGround();

        if (isGrounded)
        {
            if (Input.GetKeyDown(GameVars.Values.jumpKey) && !jumpOnCooldown) Jump();
        } else
        {
            _rb.velocity -= new Vector3(0f, 9.8f * Time.deltaTime, 0f);
        }
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

        _rb.AddForce(deltaVelocity, ForceMode.VelocityChange);
    }

    private void Jump()
    {
        isGrounded = false;
        StartCoroutine("PreventCheck");
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
        transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y / 2, transform.localScale.z);
        transform.localPosition -= new Vector3(0f, 0.5f, 0f);
        _cam.transform.localPosition = new Vector3(0f, _cam.transform.position.y / 2, 0f);
        isCrouching = true;
    }

    private void CrouchExit()
    {
        if (!isCrouching) return;
        transform.localScale = originalScale;
        transform.localPosition += new Vector3(0f, 0.5f, 0f);
        _cam.transform.localPosition = new Vector3(0f, originalCamPos.y, 0f);
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
        float maxDist = 0.2f;

        if (preventCheck) return;

        if (Physics.Raycast(start, -transform.up, 0.25f, ~layermask))
        {
            isGrounded = true;
            return;
        }
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
        _cam.ChangePitch(new Vector3(pitch, 0f, 0f));
    }

    public Vector3 GetCameraPosition()
    {
        return _cam.transform.position;
    }

    public Vector3 GetCameraForward()
    {
        return _cam.transform.forward;
    }

    public Vector3 GetPrefabPlacement()
    {
        return lookingPlacement;
    }

    private void LookingAt()
    {
        RaycastHit hit;

        //Crear variable distancia
        if (Physics.Raycast(_cam.transform.position, _cam.transform.forward, out hit, 10f, GameVars.Values.GetItemLayerMask()))
        {
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
        if (Physics.Raycast(_cam.transform.position, _cam.transform.forward, out hit,  10f, GameVars.Values.GetFloorLayerMask()))
        {
            //Vector3 localHit = transform.InverseTransformPoint(hit.point);
            //Debug.Log("Looking at floor!!!!");
            //lookingPlacement = localHit;
            lookingPlacement = hit.point;
            //Debug.Log(lookingPlacement);
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
            InteractWithInventoryItem();
            return;
        }
        lookingAt.Interact();
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

    public void PlayPickUpSound()
    {
        GameVars.Values.soundManager.PlaySoundAtPoint("GrabSound", transform.position, 0.7f);
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
        if (item is null)
            return;

        var outLine = item.gameObject.GetComponent<OutLineItem>();
        if (outLine is null)
            return;
        outLine.SetMaterials();
        outLine.isFocus = true;
    }

    private void SetOffItem(Item item)
    {
        if (item is null)
            return;

        var outLine = item.gameObject.GetComponent<OutLineItem>();
        if (outLine is null)
            return;

        outLine.isFocus = false;
    }
}
