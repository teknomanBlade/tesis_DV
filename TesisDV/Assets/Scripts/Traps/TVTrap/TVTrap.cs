using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class TVTrap : Item
{
    public Coroutine CoroutineBatteryDepletion;
    public Animator anim;
    public bool IsTurnOn;
    private bool _canStun;
    private bool _activeOncePerRound;
    private float _timePassed;
    private float _recoveryTime = 8f;
    public GameObject batteryAddOn;
    public GameObject batteryBlueprint;
    public GameObject blueprintPrefab;
    public GameObject TVLight;
    [SerializeField]
    private LayerMask targetMask;
    private AudioSource _as;

    void Start()
    {
        
    }
    private void Awake()
    {
        _as = GetComponent<AudioSource>();
        anim = GetComponent<Animator>();
        _canStun = true;
        _activeOncePerRound = false;
        _timePassed = _recoveryTime;
        _itemName = "StationaryTVTrap";
        itemType = ItemType.Weapon;
        targetMask = LayerMask.GetMask("Enemy");
        TVLight = transform.GetChild(2).gameObject;
    }
    // Update is called once per frame
    void Update()
    {
        /*if (!GameVars.Values.WaveManager.InRound)
        {
            _activeOncePerRound = false;
        }*/

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
    IEnumerator BatteryDepletion() 
    {
        Debug.Log("START BATTERY DEPLETION...");
        yield return new WaitForSeconds(12f);
        HideBatteryAddOnForEnergyDepletion();
        Debug.Log("END BATTERY DEPLETION...");
    }
    public void HideBatteryAddOnForEnergyDepletion()
    {
        TurnOff();
        Debug.Log("TV TURNED OFF...");
        gameObject.GetComponents<BoxCollider>().Where(x => x.isTrigger).FirstOrDefault().enabled = false;
        batteryAddOn.SetActive(false);
        GameVars.Values.soundManager.StopSound(_as);
    }

    public void TurnOff()
    {
        if (CoroutineBatteryDepletion == null) return;
        GameVars.Values.soundManager.StopSound(_as);
        IsTurnOn = false;
        TVLight.SetActive(false);
        anim.SetBool("IsTurnedOn", false);
        StopCoroutine(CoroutineBatteryDepletion);
        gameObject.GetComponents<BoxCollider>().Where(x => x.isTrigger).FirstOrDefault().enabled = false;
    }

    public void TurnOn()
    { 
        IsTurnOn = true;
        TVLight.SetActive(true);
        anim.SetBool("IsTurnedOn", true);
        GameVars.Values.soundManager.PlaySound(_as, "TvStaticSFX", 0.1f, true, 1f);
        CoroutineBatteryDepletion = StartCoroutine(BatteryDepletion());
        gameObject.GetComponents<BoxCollider>().Where(x => x.isTrigger).FirstOrDefault().enabled = true;
    }

    void OnTriggerEnter(Collider collision)
    {
        if(_canStun)
        {
            var enemy = collision.gameObject.GetComponent<Enemy>();
            if (enemy)
            {
                Debug.Log("STUNEO AL GRIS? - CHECK ONTRIGGERENTER?");
                enemy.Stun(4f, _canStun);
                _canStun = false;
            } 
        }
    }

    internal void ActiveBatteryComponent()
    {
        batteryAddOn.SetActive(true);
        batteryBlueprint.SetActive(false);
    }
}
