using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class StationaryItem : Item
{
    public Transform Player;
    public bool IsLookedAt;
    public GameObject tvRotatePlane;
    public GameObject batteryBlueprint;
    public GameObject batteryAddOn;
    private bool _isAddOnPlaced;
    public float speed = 1.0f; // La velocidad de la rotación
    // Start is called before the first frame update
    void Start()
    {
        _isAddOnPlaced = false;
        IsLookedAt = false;
        if(tvRotatePlane != null)
            tvRotatePlane.SetActive(false);

    }

    // Update is called once per frame
    void Update()
    {
        if (!IsLookedAt) return;

        if (Input.GetAxis("Mouse ScrollWheel") > 0)
        {
            var lerpedVector = Vector3.Lerp(Vector3.forward, new Vector3(0f, 0f, Input.GetAxis("Mouse ScrollWheel") * 850f), Time.deltaTime * speed);
            transform.Rotate(lerpedVector, Space.Self);
        }

        if (Input.GetAxis("Mouse ScrollWheel") < 0)
        {
            var lerpedVector = Vector3.Lerp(Vector3.forward, new Vector3(0f, 0f, Input.GetAxis("Mouse ScrollWheel") * 850f), Time.deltaTime * speed);
            transform.Rotate(lerpedVector, Space.Self);
        }
    }

    public override void Interact()
    {
        //ActiveBatteryComponent();
    }
    public void OnPlayerInteract(Transform player) 
    {
        Player = player;
    }
    public void IndicatorLookAtPlayer() 
    {
        if (tvRotatePlane == null) return;

        tvRotatePlane.SetActive(true);
        tvRotatePlane.transform.LookAt(Player);
        Vector3 rotacionActual = tvRotatePlane.transform.localEulerAngles;
        IsLookedAt = true;
        // Aplicar clamp en el eje X
        rotacionActual.x = Mathf.Clamp(rotacionActual.x, -1f, 0f);
        rotacionActual.y = Mathf.Clamp(rotacionActual.y, 180f, 180f);

        // Asignar la rotación ajustada
        tvRotatePlane.transform.localEulerAngles = rotacionActual;
    }
    public StationaryItem SetAddOnGameObject(GameObject batteryAddOn)
    {
        this.batteryAddOn = batteryAddOn;
        return this;
    }
    public StationaryItem SetBlueprint(GameObject batteryBlueprint)
    {
        this.batteryBlueprint = batteryBlueprint;
        return this;
    }
    public void ActiveBatteryComponent()
    {
       
        if (!_isAddOnPlaced)
        {
            tvRotatePlane.SetActive(false);
            gameObject.AddComponent<TVTrap>().SetAddOnGameObject(batteryAddOn).SetBlueprint(batteryBlueprint);
            gameObject.GetComponents<BoxCollider>().Where(x => x.isTrigger).FirstOrDefault().enabled = true;
            Destroy(gameObject.GetComponent<StationaryItem>());
        }

        batteryAddOn.SetActive(true);
        batteryBlueprint.SetActive(false);
        _isAddOnPlaced = true;
        
    }
    public void ShowBlueprint()
    {
        if(!_isAddOnPlaced)
            batteryBlueprint.SetActive(true);

        //Invoke("HideBlueprint", 2f);
    }
    
    public void HideBlueprint()
    {
        if (tvRotatePlane == null) return;

        tvRotatePlane.SetActive(false);
        IsLookedAt = false;
        batteryBlueprint.SetActive(false);
    }
}
