using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Rigidbody))]
public class Player : MonoBehaviour
{
    // TEMP
    public TMP_Text lookingAtText;

    //---------
    private Rigidbody _rb;
    
    private PlayerCamera _cam;
    [SerializeField]
    private Inventory _inventory;

    // Movement
    public CraftingRecipe craftingRecipe;
    private float speed = 5f;
    private float walkSpeed = 5f;
    private float sprintSpeed = 10f;
    private float maxVelocityChange = 20f;
    private float jumpForce = 5f;

    [SerializeField]
    private bool isGrounded = true;
    [SerializeField]
    private bool isCrouching = false;
    private Vector3 originalScale;
    private Vector3 originalCamPos;
    [SerializeField]
    private bool isSprinting = false;

    // Mouse

    private Vector2 mouseSens = new Vector2(1f, 1f);
    private float yaw = 0f;
    private float pitch = 0f;
    private float lookAngle = 80f;

    // Interactions

    [SerializeField]
    public Item lookingAt;
    public Switch activableLookingAt;
    public InventoryItem lookingFor;
    public Vector3 lookingPlacement;
    public GameObject[] invItem = new GameObject[3];
    public int currentInvSlot = 0;

    public float timer = 0f;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        _cam = GameObject.Find("MainCamera").GetComponent<PlayerCamera>();
        _inventory = GameObject.Find("InventoryBar").GetComponent<Inventory>();
        

        originalScale = transform.localScale;
        originalCamPos = _cam.transform.localPosition;
    }

    private void Start()
    {

    }

    private void Update()
    {
        LookingAt();
        CheckGround();
        Camera();
        LookingForPlacement();
        LookingFor();
        

        if (isGrounded)
        {
            if (Input.GetKeyDown(GameVars.Values.jumpKey)) Jump();

            if (!GameVars.Values.crouchToggle)
            {
                if (Input.GetKey(GameVars.Values.crouchKey)) CrouchEnter();
                else CrouchExit();
            }
            else if (Input.GetKeyDown(GameVars.Values.crouchKey)) CrouchToggle();

        }

        if (Input.GetKeyDown(GameVars.Values.sprintKey)) speed = sprintSpeed;
        if (Input.GetKeyUp(GameVars.Values.sprintKey)) speed = walkSpeed;

        if (Input.GetKeyUp(GameVars.Values.useKey))
        {
            if (activableLookingAt != null)
            {
                activableLookingAt.Interact();
            }
        }
        //if (invItem[currentInvSlot] != null)
        //{
        //    if (!InventoryFull() && Input.GetKeyUp(GameVars.Values.useKey)) Interact();
        //    if (Input.GetKey(GameVars.Values.useKey)) timer += Time.deltaTime;
        //    if (timer > 1f)
        //    {
        //        timer = 0;
        //        Replace();
        //    }
        //}
        //else if (Input.GetKeyDown(GameVars.Values.useKey) && !InventoryFull()) Interact();

        //if (Input.GetKeyDown(KeyCode.X)) Drop();
        //if (Input.GetKeyDown(GameVars.Values.secondaryFire)) equippedWep.SecondaryFire();

        if (Input.GetKeyDown(KeyCode.Alpha1)) currentInvSlot = 0;
        if (Input.GetKeyDown(KeyCode.Alpha2)) currentInvSlot = 1;
        if (Input.GetKeyDown(KeyCode.Alpha3)) currentInvSlot = 2;

        if (Input.GetKeyDown(GameVars.Values.grabKey))
        {
            InteractWithInventoryItem();
        }

        /* if(Input.GetKeyDown(KeyCode.Tab))
            {
                var screenCrafting = Instantiate(Resources.Load<CraftingScreen>("CraftingCanvas"));
                ScreenManager.Instance.Push(screenCrafting);
            } */
        
        if(Input.GetKeyDown(GameVars.Values.primaryFire))
        {
            if(craftingRecipe != null)
                craftingRecipe.Craft(_inventory);
        }

        UIText();
    }

    private void FixedUpdate()
    {
        Walk();
    }

    public void UIText()
    {
        if (lookingAtText == null)
            return;

        string temp = "";
        if (lookingAt != null) temp += "Looking At: " + lookingAt.name;
        else temp += "Looking At: null";

        temp += "\n";

        for (int i = 0; i < 3; i++)
        {
            if (invItem[i] != null) temp += $"\nInv[{i}]: " + invItem[i].name;
            else temp += $"\nInv[{i}]: null";
            if (currentInvSlot == i)
            {
                temp += " <--";
                if (invItem[currentInvSlot] != null) temp += " [Press X to drop]";
            }
        }


        lookingAtText.text = temp;
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
        _rb.AddForce(0f, jumpForce, 0f, ForceMode.Impulse);
        isGrounded = false;
    }

    #region Crouch

    private void CrouchEnter()
    {
        if (isCrouching) return;
        transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y / 2, transform.localScale.z);
        _cam.transform.localPosition = new Vector3(0f, _cam.transform.position.y / 2, 0f);
        isCrouching = true;
    }

    private void CrouchExit()
    {
        if (!isCrouching) return;
        transform.localScale = originalScale;
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
        isGrounded = Physics.CheckBox(transform.position - new Vector3(0f, 0.5f, 0f), new Vector3(0.51f, 0.51f, 0.51f), Quaternion.identity, GameVars.Values.GetFloorLayerMask());
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
        var crosshair = GameObject.Find("Crosshair").GetComponent<Image>();
        //Crear variable distancia
        if (Physics.Raycast(_cam.transform.position, _cam.transform.forward, out hit,  10f, GameVars.Values.GetActivableLayerMask()))
        {
            crosshair.sprite = Resources.Load<Sprite>("ButtonPress");
            crosshair.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, 40f);
            crosshair.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, 40f);
            activableLookingAt = hit.collider.gameObject.GetComponent<Switch>();
        }
        else
        {
            crosshair.sprite = Resources.Load<Sprite>("crosshair");
            crosshair.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, 20f);
            crosshair.rectTransform.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, 20f);
            activableLookingAt = null;
        }
    }


    private void LookingFor()
    {
        RaycastHit hit;
        //Crear variable distancia
        if (Physics.Raycast(_cam.transform.position, _cam.transform.forward, out hit,  10f, GameVars.Values.GetItemLayerMask()))
        {
            lookingFor = hit.collider.GetComponent<InventoryItem>();
        }
        else
        {
            lookingFor = null;
        }
    }

    private void LookingForPlacement()
    {
        RaycastHit hit;
        //Crear variable distancia
        if (Physics.Raycast(_cam.transform.position, _cam.transform.forward, out hit,  10f, GameVars.Values.GetFloorLayerMask()))
        {
            //Vector3 localHit = transform.InverseTransformPoint(hit.point);
            Debug.Log("Looking at floor!!!!");
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
        //lookingAt?.
    }

    public void InteractWithInventoryItem()
    {
        if(lookingFor != null)
        {
            _inventory.AddItem(lookingFor);
        }
        
    }
}
