using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class TVTrap : Item, IMovable
{
    private bool _canStun;
    private bool _activeOncePerRound;
    private float _timePassed;
    private float _recoveryTime = 8f;
    public GameObject batteryAddOn;
    public GameObject batteryBlueprint;
    public GameObject blueprintPrefab;
    [SerializeField]
    private LayerMask targetMask;
    
    void Start()
    {
        
    }
    private void Awake()
    {
        _canStun = true;
        _activeOncePerRound = false;
        _timePassed = _recoveryTime;
        _itemName = "StationaryTVTrap";
        itemType = ItemType.Weapon;
        targetMask = LayerMask.GetMask("Enemy");
        
    }
    // Update is called once per frame
    void Update()
    {
        if (GameVars.Values.WaveManager.InRound)
        {
            Invoke("HideBatteryAddOnForEnergyDepletion", 15f);
        }
        else
        {
            _activeOncePerRound = false;
        }
        

        if (!_canStun && _timePassed > 0)
        {
            _timePassed -= Time.deltaTime;
        }
        else
        {
            _canStun = true;
            _timePassed = _recoveryTime;
        }
    }
    public TVTrap SetAddOnGameObject(GameObject batteryAddOn)
    {
        this.batteryAddOn = batteryAddOn;
        return this;
    }
    public TVTrap SetBlueprint(GameObject batteryBlueprint)
    {
        this.batteryBlueprint = batteryBlueprint;
        return this;
    }
    public void HideBatteryAddOnForEnergyDepletion()
    {
        if (!_activeOncePerRound)
        {
            gameObject.AddComponent<StationaryItem>().SetAddOnGameObject(batteryAddOn).SetBlueprint(batteryBlueprint);
            gameObject.GetComponents<BoxCollider>().Where(x => x.isTrigger).FirstOrDefault().enabled = false;
            batteryAddOn.SetActive(false);
            Destroy(gameObject.GetComponent<TVTrap>());
        }
        _activeOncePerRound = true;
    }
    void OnTriggerEnter(Collider collision)
    {
        Debug.Log("1");
        if(_canStun)
        {
            Debug.Log("2");
            if (collision.gameObject.layer == LayerMask.NameToLayer("Enemy"))
            {
                Debug.Log("3");
                collision.gameObject.GetComponent<GrayModel>().Stun(3f);
                _canStun = false;
            }
        }
    }

    public void BecomeMovable()
    {
        Debug.Log("2");
        //GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        //Destroy(gameObject);
    }
}
