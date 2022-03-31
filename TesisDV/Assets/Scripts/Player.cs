using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Player : MonoBehaviour
{
    // TEMP
    public TMP_Text lookingAtText;

    //---------
    private Rigidbody _rb;
    private Camera _cam;
    public ISWEP equippedWep;

    // Movement

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
    public Object lookingAt;

    private float strength = 5f;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        _cam = GameObject.Find("MainCamera").GetComponent<Camera>();

        originalScale = transform.localScale;
        originalCamPos = _cam.transform.localPosition;

        equippedWep = gameObject.AddComponent<SWEP_Hands>();
        equippedWep.OnEquip(this);
    }

    private void Update()
    {
        LookingAt();
        CheckGround();
        Camera();

        if (isGrounded)
        {
            if (Input.GetKeyDown(GameVars.Values.jumpKey)) Jump();

            if (!GameVars.Values.crouchToggle)
            {
                if (Input.GetKey(GameVars.Values.crouchKey)) CrouchEnter();
                else CrouchExit();
            } else if (Input.GetKeyDown(GameVars.Values.crouchKey)) CrouchToggle();
            
        }

        if (Input.GetKeyDown(GameVars.Values.sprintKey)) speed = sprintSpeed;
        if (Input.GetKeyUp(GameVars.Values.sprintKey)) speed = walkSpeed;

        if (Input.GetKeyDown(GameVars.Values.useKey)) equippedWep.Interaction();
        if (Input.GetKeyDown(GameVars.Values.primaryFire)) equippedWep.PrimaryFire();
        if (Input.GetKeyDown(GameVars.Values.secondaryFire)) equippedWep.SecondaryFire();

        //if (lookingAt != null) lookingAtText.text = lookingAt.name;
        //else lookingAtText.text = "null";
    }

    private void FixedUpdate()
    {
        Walk();
    }

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

    private void CheckGround()
    {
        isGrounded = Physics.CheckBox(transform.position - new Vector3(0f, 0.5f, 0f), new Vector3(0.51f, 0.51f, 0.51f), Quaternion.identity, GameVars.Values.GetFloorLayerMask());
    }

    private void Camera()
    {
        yaw = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * mouseSens.x;
        pitch -= mouseSens.y * Input.GetAxis("Mouse Y");
        pitch = Mathf.Clamp(pitch, -lookAngle, lookAngle);

        transform.localEulerAngles = new Vector3(0f, yaw, 0f);
        _cam.transform.localEulerAngles = new Vector3(pitch, 0f, 0f);
    }

    public Vector3 GetCameraPosition()
    {
        return _cam.transform.position;
    }

    public Vector3 GetCameraForward()
    {
        return _cam.transform.forward;
    }

    private void LookingAt()
    {
        RaycastHit hit;
        if (Physics.Raycast(_cam.transform.position, _cam.transform.forward, out hit, 10f, GameVars.Values.GetObjectLayerMask()))
        {
            lookingAt = hit.collider.gameObject.GetComponent<Object>();
        } else
        {
            lookingAt = null;
        }
    }

    public Vector3 GetVelocity()
    {
        return _rb.velocity;
    }
}
