using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowTrap : MonoBehaviour
{
    [SerializeField] private float _slowAmount;
    [SerializeField] private float _slowAmountPlayer;
    //[SerializeField] private float _destroyTime;
    [SerializeField] private bool _doesDamage;
    #region Upgrades
    [Header("Upgrades")]
    [SerializeField] private GameObject _plus50SlowBlueprint;
    [SerializeField] private GameObject _plus50SlowUpgrade;
    [SerializeField] private GameObject _plus100SlowBlueprint;
    [SerializeField] private GameObject _plus100SlowUpgrade;
    [SerializeField] private GameObject _minus1HPPoisonDamageBlueprint;
    [SerializeField] private GameObject _minus1HPPoisonDamageUpgrade;
    [SerializeField] private GameObject _minus2HPPoisonDamageBlueprint;
    [SerializeField] private GameObject _minus2HPPoisonDamageUpgrade;
    public bool _canActivate1aUpgrade { get; private set; }
    public bool _canActivate2aUpgrade { get; private set; }
    public bool _canActivate1bUpgrade { get; private set; }
    public bool _canActivate2bUpgrade { get; private set; }
    private SkillTree _skillTree;

    #endregion
    Animator _animator;
    private AudioSource _as;

    void Start()
    {
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        _animator = GetComponent<Animator>();
        _as = GetComponent<AudioSource>();
        GameVars.Values.IsAllSlotsDisabled();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TarLiquidSFX", 0.15f, true);
    }

    void Update()
    {
        /*_destroyTime -= Time.deltaTime;

        if (_destroyTime <=0)
        {
            _animator.SetTrigger("IsDestroyed");
            GameVars.Values.soundManager.StopSound();
        }*/

        /* if (Input.GetKeyDown(KeyCode.G))
        {
            if (_doesDamage)
            {
                _doesDamage = false;
            }
            else
            {
                _doesDamage = true;
            }

        } */        
    }

    public void DestroyTrap()
    {
        Destroy(gameObject);
    }

    void OnTriggerEnter(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 
        //var player = other.GetComponent<Player>();

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(_slowAmount);
        }
        //else if (player && other.GetComponent<Player>())
        //{
            //other.GetComponent<Player>().SlowDown(_slowAmountPlayer);
        //}
    }

    void OnTriggerExit(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 
        //var player = other.GetComponent<Player>();

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(-_slowAmount);
        }
        //else if (player && other.GetComponent<Player>())
        //{
            //other.GetComponent<Player>().SlowDown(-_slowAmountPlayer);
        //}
    }

    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if (_skillTree.isMT1aActivated)
        {
            _plus50SlowBlueprint.SetActive(true);
            _canActivate1aUpgrade = true;
        }
        else if (_skillTree.isMT1bActivated)
        {
            _plus100SlowBlueprint.SetActive(true);
            _canActivate1bUpgrade = true;
        }
        else if (_skillTree.isMT2aActivated)
        {
            _minus1HPPoisonDamageBlueprint.SetActive(true);
            _canActivate2aUpgrade = true;
        }
        else if (_skillTree.isMT2bActivated)
        {
            _minus2HPPoisonDamageBlueprint.SetActive(true);
            _canActivate2bUpgrade = true;
        }
    }

    public void Activate1aUpgrade()
    {
        _plus50SlowBlueprint.SetActive(false);
        _plus50SlowUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }
    public void Activate1bUpgrade()
    {
        _plus100SlowBlueprint.SetActive(false);
        _plus100SlowUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }

    public void Activate2aUpgrade()
    {
        _minus1HPPoisonDamageBlueprint.SetActive(false);
        _minus1HPPoisonDamageUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }
    public void Activate2bUpgrade()
    {
        _minus2HPPoisonDamageBlueprint.SetActive(false);
        _minus2HPPoisonDamageUpgrade.SetActive(true);
        //Aplicar beneficio del Upgrade
    }

    #endregion
}
