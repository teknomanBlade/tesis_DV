using System.Collections;
using System.Collections.Generic;
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
        ActiveBatteryComponent();
    }
    public void ActiveBatteryComponent()
    {
        if (!_isAddOnPlaced)
            gameObject.AddComponent<TVTrap>();

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
