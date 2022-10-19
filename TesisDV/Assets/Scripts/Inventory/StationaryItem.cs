using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class StationaryItem : Item
{
    public GameObject batteryBlueprint;
    public GameObject batteryAddOn;
    private bool _isAddOnPlaced;
    // Start is called before the first frame update
    void Start()
    {
        _isAddOnPlaced = false;
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void Interact()
    {
        //ActiveBatteryComponent();
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

        Invoke("HideBlueprint", 2f);
    }
    
    public void HideBlueprint()
    {
        batteryBlueprint.SetActive(false);
    }
}
